---
name: triage
description: "Morning briefing — classify and prioritise email (Outlook or Gmail), Slack, Teams, and Asana. Surfaces what needs attention, drafts replies for action-required items."
argument-hint: "[check|draft|all|2h|4h|1d|yesterday|since monday]"
---

# /triage — Morning Briefing & Email Triage

Arguments: $ARGUMENTS

## Overview

Fetch email, Slack, Teams, Asana, and calendar data. Classify all messages and tasks, surface what needs attention, and draft replies for action-required items.

**Goal:** Zero undecided items — every message gets a classification and every action-required item gets a draft reply before the briefing ends.

### Tool Detection & Graceful Degradation

Before fetching, detect which MCP connectors are available. The skill supports both Microsoft 365 and Google Workspace:

| Function | Microsoft 365 | Google Workspace |
|----------|--------------|-----------------|
| Email search | `outlook_email_search` | `gmail_search_messages` |
| Read email | `read_resource` (uri: `mail:///messages/{id}`) | `gmail_read_message` |
| Read thread | `read_resource` (uri: `mail:///messages/{id}`) | `gmail_read_thread` |
| Calendar events | `outlook_calendar_search` | `gcal_list_events` |
| Free/busy | `find_meeting_availability` | `gcal_find_meeting_times` |
| Draft reply | Copy to mail client | `gmail_create_draft` |

Use whichever tools are available. If both are present:
- If user's config says `microsoft365` or `google` → use that one
- If config says `auto` → prefer **Microsoft 365** for work email (Outlook is typically the work account) and note which platform was used in the briefing header
- If neither email tool is available, skip the email steps and note it in the briefing

### Permission-Gated Actions

Some actions require elevated permissions that may not be granted. **Always attempt the action first.** If it fails with a permission/auth error, degrade gracefully by explaining what would have happened:

| Action | M365 Permission | Google Scope | Fallback when missing |
|--------|----------------|-------------|----------------------|
| Save draft | `Mail.ReadWrite` | `gmail.compose` | Show draft text: *"Here's your draft. I'd save this to your Drafts folder, but `{permission}` isn't enabled."* |
| Send email | `Mail.Send` | `gmail.send` | After approval: *"Draft ready to send. With `{permission}`, I'd send this directly. For now, copy it to your mail client."* |
| Move to folders | `Mail.ReadWrite` | `gmail.modify` | Show list: *"With `{permission}`, I'd move these {N} items to folders. Here's the breakdown for manual cleanup."* |
| Create calendar event | `Calendars.ReadWrite` | `calendar.events` | *"With `{permission}`, I'd create a tentative event for {time}. Add it manually or ask your admin to enable this."* |

**Key principle:** Never silently skip a feature. Always show the user what *would* happen and which permission is needed to unlock it. This way users know what they're missing and can ask their admin for the right permissions.

---

## Step 0: Load User Configuration

Read the user's personal triage config:

```
~/.claude/triage-config.md
```

If the file doesn't exist, tell the user to run `/true setup` first. Do not proceed without configuration.

Extract:
- User's name, role, email, timezone
- VIP senders list
- Skip patterns
- Which channels to include (email, Slack, Teams, Asana)
- Skip folder preferences
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

### 1a: Email (Outlook or Gmail)

**If Microsoft 365 (Outlook) is available:**

```
outlook_email_search:
  query: "*"
  folderName: "Inbox"
  afterDateTime: "{resolved_start_time}"
  limit: 50
```

For emails that need more context, read the full message:

```
read_resource:
  uri: "mail:///messages/{messageId}"
```

**If Google Workspace (Gmail) is available:**

```
gmail_search_messages:
  q: "in:inbox after:{resolved_start_date_yyyy/mm/dd}"
  maxResults: 50
```

For emails that need more context, read the full message:

```
gmail_read_message:
  messageId: "{messageId}"
```

### 1b: Slack

Search for mentions and DMs within the time range. Use `slack_search_public_and_private` if the user has consented, otherwise fall back to `slack_search_public` (public channels only):

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

**Note:** `slack_search_public` only covers public channels. Private channels and group DMs require `slack_search_public_and_private` which needs user consent.

### 1c: Teams

Search for Teams messages within the time range:

```
chat_message_search:
  query: "*"
  afterDateTime: "{resolved_start_time_iso}"
  limit: 50
```

### 1d: Calendar (Outlook or Google)

**If Microsoft 365 (Outlook Calendar) is available:**

```
outlook_calendar_search:
  query: "*"
  afterDateTime: "today"
  beforeDateTime: "tomorrow"
  limit: 30
```

**If Google Workspace (Google Calendar) is available:**

```
gcal_list_events:
  timeMin: "{today_start_iso}"
  timeMax: "{today_end_iso}"
  maxResults: 30
```

### 1e: Asana

Fetch incomplete tasks assigned to the user:

```
get_tasks:
  assignee: "me"
  opt_fields: "name,due_on,completed,modified_at,assignee.name,projects.name,notes"
  limit: 20
```

**Note:** `search_tasks_preview` returns a rendered UI preview that can't be processed — always use `get_tasks` for data.

Filter results to recent activity:
- Keep tasks with `modified_at` within the time range, OR
- Keep tasks with `due_on` within the next 48 hours

For tasks that need more context (recent comments, mentions), read the full task:

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
_{count} items — see inbox hygiene below_

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

## Step 3.5: Inbox Hygiene — Move Skipped Emails to Folders

If skip_count > 0, present skipped emails grouped by target folder:

> "{skip_count} emails can be sorted out of your inbox:"
>
> | Folder | Count | Top senders |
> |--------|-------|-------------|
> | Notifications | 9 | GitHub (6), Asana (3) |
> | Marketing | 3 | Newsletter A, Vendor B |
> | Calendar | 2 | Meeting responses |
>
> → [Move all] [Show details] [Leave in inbox]

**If "Move all":**
- Attempt to move emails to their target folders using available tools
- Create folders that don't exist yet
- If it succeeds → report: "Moved {N} emails to {X} folders."
- If permission error → degrade gracefully:

  > "I'd move these {N} emails for you, but `Mail.ReadWrite` (Outlook) / `gmail.modify` (Gmail) isn't enabled.
  > Here's the breakdown so you can sort them manually:
  >
  > **Notifications** (9): GitHub ×6, Asana ×3
  > **Marketing** (3): Newsletter A, Vendor B, Promo C
  > **Calendar** (2): meeting responses
  >
  > Enable `{permission}` to unlock automatic inbox sorting."

**If "Show details":**
- List every skipped email with its target folder
- Then re-offer [Move all] [Leave in inbox]

**Folder mapping** comes from the user's config (`Skip Folders` section). See [classification.md](classification.md) for defaults.

If argument is `check`, stop here (classify + inbox hygiene only — no drafting).

---

## Step 4: Draft Replies

After presenting the briefing, ask:

> "Want me to draft replies for the {N} action-required items?"

If user agrees (or if argument was `draft` or `all`), process each action-required item:

### For each action_required email:

1. **Read the full thread** if not already loaded

2. **Check for scheduling keywords** — if detected, check the user's calendar for conflicts using `outlook_calendar_search` (M365) or `gcal_list_events` (Google). For full scheduling replies with availability slots, suggest the user runs `/reply-with-availability` instead.

3. **Draft a reply** following the tone guide in [tone-guide.md](tone-guide.md):
   - Match the thread's tone
   - Be concise and direct
   - No signature (mail client appends it)
   - Australian English

4. **Present to user:**
   ```
   #### Reply to: Sender — Subject

   > Original: one-line summary of what they asked

   **Draft:**

   {draft reply text}

   → [Approve] [Edit] [Skip]
   ```

5. **On Approve** — attempt the best available action, degrade if permissions are missing:

   **Gmail:**
   - Try `gmail_create_draft` to save the draft directly to Gmail Drafts
   - If permission error: *"Here's your draft. I'd save this to your Gmail Drafts, but `gmail.compose` isn't enabled. Copy it into a new email, or ask your admin to enable `gmail.compose`."*
   - If draft saved successfully, ask: "Draft saved. Want me to send it?" → try send, degrade if `gmail.send` is missing: *"Draft saved to Gmail. I'd send it directly, but `gmail.send` isn't enabled. Open your Drafts and hit send, or ask your admin to enable `gmail.send`."*

   **Outlook:**
   - Present draft text for the user to copy into Outlook
   - Note: *"With `Mail.Send` enabled, I could send this directly. With `Mail.ReadWrite`, I could save it to your Outlook Drafts."*

6. Wait for user decision before moving to next item.

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

Draft a reply. Present for review. On approve, attempt to send. If permission error: *"I'd send this in Teams, but `Chat.ReadWrite` isn't enabled. Copy and paste it into your Teams chat."*

### For Asana action_required:

Draft a comment on the task. Present for review. If user approves, post via Asana MCP tools. (Asana MCP typically supports writing — if it fails, show the comment text for manual posting.)

---

## Step 5: Post-Triage Summary

After all items are processed:

```
# Triage Complete

- Drafted: {N} replies
- Saved to Drafts: {N} (Gmail)
- Sent: {N} (Slack)
- Pending (copy to mail client): {N}
- Moved to folders: {N} skipped emails
- Left in inbox: {N}

{List any pending items the user chose to skip for later}
```

If any actions were blocked by missing permissions, add a footer:

```
## Permissions Note

Some actions were limited by missing permissions:
- {action}: needs `{permission}` — ask your admin to enable it
```

---

## Notes

- **Never send emails** without explicit user approval. Always draft first, then ask.
- **Graceful degradation**: Always attempt the best action. If a permission error occurs, explain what would have happened and which permission is needed. Never silently skip features.
- **Slack messages** can be sent directly if the user approves, as the Slack MCP tools support sending.
- **Teams messages**: attempt to send on approve; degrade with permission note if blocked.
- If the user runs `/triage check` — only do Steps 0–3.5 (classify, present, and skip summary — no drafting).
- If the user runs `/triage draft` — do Steps 0–4 (classify + draft).
- If the user runs `/triage all` — do Steps 0–5 (full flow).
