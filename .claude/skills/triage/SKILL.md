---
name: triage
description: "Morning briefing — classify and prioritise Outlook email, Slack, Teams, and Asana. Surfaces what needs attention, drafts replies for action-required items."
argument-hint: "[check|draft|all|2h|4h|1d|yesterday|since monday]"
---

# /triage — Morning Briefing & Email Triage

Arguments: $ARGUMENTS

## Overview

Fetch email, Slack, Teams, Asana, and calendar data. Classify all messages and tasks, surface what needs attention, and draft replies for action-required items.

**Goal:** Zero undecided items — every message gets a classification and every action-required item gets a draft reply before the briefing ends.

---

## Step 0: Load User Configuration

Read the user's personal triage config:

```
~/.claude/triage-config.md
```

If the file doesn't exist, tell the user to copy the template from `config/triage-config.example.md` and customise it. Do not proceed without configuration.

Extract:
- User's name, role, email, timezone
- VIP senders list
- Skip patterns
- Which channels to include (email, Slack, Teams, Asana)
- Skip handling preferences
- Communication tone preferences

---

## Step 0.5: Parse Time Range

Parse `$ARGUMENTS` for a time range. Time range arguments can be combined with mode arguments (e.g. `/triage check 2h`).

| Argument | Time range |
|----------|-----------|
| _(no time arg)_ | Since midnight today in user's timezone |
| `2h`, `4h`, etc. | Last N hours |
| `1d` | Last 24 hours |
| `yesterday` | Since yesterday 00:00 in user's timezone |
| `since monday`, `this-week` | Since Monday 00:00 in user's timezone |

Convert the resolved start time to ISO datetime using the user's timezone from config.

If the time range is large (>24h), focus the summary on **action_required** and **VIP** items rather than trying to categorise everything. Note the time range in the briefing header.

---

## Step 1: Parallel Data Fetch

**Launch all applicable fetches simultaneously using Task agents. Use the resolved time range from Step 0.5 as `afterDateTime` for all searches.**

### 1a: Outlook Email

Search for emails within the time range:

```
outlook_email_search:
  query: "*"
  folderName: "Inbox"
  afterDateTime: "{resolved_start_time}"
  limit: 50
```

For emails that need more context (multi-message threads, action_required candidates), read the full message:

```
read_resource:
  uri: "mail:///messages/{messageId}"
```

### 1b: Slack

Search for mentions and DMs within the time range:

```
slack_search_public:
  query: "to:me after:{resolved_start_date}"
  sort: "timestamp"
```

Also check recent DMs:

```
slack_search_public:
  query: "in:@{user_slack_id} after:{resolved_start_date}"
```

### 1c: Teams

Search for Teams messages within the time range:

```
chat_message_search:
  query: "*"
  afterDateTime: "{resolved_start_time_iso}"
  limit: 50
```

### 1d: Calendar

Fetch today's schedule for cross-referencing:

```
outlook_calendar_search:
  query: "*"
  afterDateTime: "today"
  beforeDateTime: "tomorrow"
  limit: 30
```

### 1e: Asana

Search for incomplete tasks assigned to the user:

```
search_tasks_preview:
  assignee_any: "me"
  completed: false
```

Also check for tasks where user is a follower (mentioned/collaborating):

```
search_tasks_preview:
  followers_any: "me"
  completed: false
```

For action_required candidates, read the full task for context:

```
get_task:
  task_id: "{task_gid}"
  opt_fields: "name,notes,assignee,due_on,completed,projects,custom_fields,followers,modified_at"
```

---

## Step 2: Classify

Apply the classification rules from [classification.md](classification.md) to every message.

For each email, classify as: **skip**, **info_only**, **meeting_info**, or **action_required**.

**Important rules:**
- VIP senders from user config → always **action_required**, always high priority
- Skip patterns from user config → always **skip**
- If user is in CC (not To:) → **info_only** unless from VIP
- Multi-message threads: read the full thread before classifying. If user already replied and no new question → **info_only** or **skip**

For Slack, Teams, and Asana, apply the same classification framework from [classification.md](classification.md).

### Cross-platform deduplication

Before presenting results, check for the same topic across platforms:
- Same person + similar keywords across email and Slack/Teams → merge into one item
- Pick the primary platform (where the main conversation lives)
- Use the highest classification tier across platforms

---

## Step 3: Present Briefing

Format output as:

```
# Triage Briefing — {date} ({day_of_week}) — {time_range_label}

## Today's Schedule ({count})

| Time | Event | Location/Link | Notes |
|------|-------|---------------|-------|
| 09:00–10:00 | Team standup | Teams: {link} | — |
| 14:00–15:00 | Client meeting | Board room | Prep needed |

## Email

### Skipped ({count})
- sender — subject (one line each)

### Info Only ({count})
- sender — subject — one-line summary

### Meeting Info ({count})
- sender — subject — calendar status (linked / missing link / no event found)

### Action Required ({count})

#### 1. [HIGH] Sender Name <email>
**Subject:** ...
**Received:** date time
**Summary:** one-line summary of what they need from you
**Context:** relationship context if available from previous interactions

#### 2. [MEDIUM] Sender Name <email>
...

## Slack ({action_count} action required, {info_count} info)

### Action Required
- #channel @person: summary of what they need
- DM @person: summary

### Info Only
- #channel: topic summary

## Teams ({action_count} action required, {info_count} info)

### Action Required
- Chat with Person: summary

### Info Only
- Channel: topic summary

## Asana ({action_count} action required, {info_count} info)

### Action Required
- [{project}] {task name} — due {date} — {summary of what's needed}

### Info Only
- [{project}] {task name} — updated by {person} — {summary}

---

Summary: {total} items processed. {action_count} need your response.
{skip_count} skipped, {info_count} FYI, {meeting_count} meeting-related.
```

---

## Step 3.5: Skipped Items — Batch Action

If skip_count > 0, present the skipped items grouped by source and ask:

> "{skip_count} items were skipped (notifications, newsletters, automated alerts).
> Want me to summarise them for bulk cleanup?"
>
> → [Show summary for manual archive] [Leave as-is]

If "Show summary":
- Group by sender/type (e.g. "12× GitHub, 5× Asana, 3× newsletters")
- List senders with counts so user can bulk-select in Outlook
- Note: "Auto-archive will be available once Mail.ReadWrite permissions are granted. For now, you can select these in Outlook and archive/delete in bulk."

If Mail.ReadWrite permissions become available (future):
- Offer [Archive all] [Move to folder] [Leave as-is]
- Require explicit confirmation before moving/archiving

---

## Step 4: Draft Replies

After presenting the briefing, ask:

> "Want me to draft replies for the {N} action-required items?"

If user agrees (or if argument was `draft` or `all`), process each action-required item:

### For each action_required email:

1. **Read the full thread** if not already loaded

2. **Check for scheduling keywords** — if detected, check calendar availability:
   ```
   find_meeting_availability or outlook_calendar_search
   ```

3. **Draft a reply** following the tone guide in [tone-guide.md](tone-guide.md):
   - Match the thread's tone
   - Be concise and direct
   - No signature (Outlook appends it)
   - Australian English

4. **Present to user:**
   ```
   #### Reply to: Sender — Subject

   > Original: one-line summary of what they asked

   **Draft:**

   {draft reply text}

   → [Approve] [Edit] [Skip]
   ```

5. Wait for user decision before moving to next item.

### For Slack action_required:

Draft a reply matching Slack's casual tone. Present the same way.

If user approves a Slack reply AND has given permission, send via:
```
slack_send_message:
  channel_id: {channel}
  message: {reply}
  thread_ts: {thread_ts}  # if replying in thread
```

### For Teams action_required:

Draft a reply. Present for review. (Sending requires admin approval for Graph API.)

### For Asana action_required:

Draft a comment on the task. Present for review. If user approves, post via Asana MCP tools.

---

## Step 5: Post-Triage Summary

After all items are processed:

```
# Triage Complete

- Drafted: {N} replies
- Approved: {N}
- Skipped: {N}
- Sent (Slack): {N}
- Pending send (email/Teams — copy to Outlook): {N}

{List any pending items the user chose to skip for later}
```

---

## Notes

- **Never send emails** without explicit user approval. All email replies are drafts for the user to send from Outlook.
- **Slack messages** can be sent directly if the user approves, as the Slack MCP tools support sending.
- **Teams messages** are draft-only until Graph API permissions are granted.
- If the user runs `/triage check` — only do Steps 0–3.5 (classify, present, and skip summary — no drafting).
- If the user runs `/triage draft` — do Steps 0–4 (classify + draft).
- If the user runs `/triage all` — do Steps 0–5 (full flow).
