---
name: weekly
description: "Week-to-date summary — email volume, open threads, meetings, key decisions, and patterns. Use for Monday planning or Friday wrap-up."
argument-hint: "[this-week|last-week]"
---

# /weekly — Week-to-Date Summary

Arguments: $ARGUMENTS

## Overview

High-level summary of the week's communications. Designed for Monday morning planning ("what am I walking into?") or Friday wrap-up ("what do I need to tie up?").

---

## Step 0: Determine Date Range

- Default (no argument or `this-week`): Monday of current week → now
- `last-week`: Previous Monday → previous Friday
- If today is Monday, default shows last week + today's new items

Read `~/.claude/triage-config.md` for timezone and preferences.

---

## Step 1: Gather Data

### Email Volume & Threads

Search for all emails in the date range:

```
outlook_email_search:
  query: "*"
  afterDateTime: "{week_start}"
  beforeDateTime: "{week_end}"
  limit: 50
```

For emails that appear to need follow-up or are from VIP senders, read full content:

```
read_resource:
  uri: "mail:///messages/{messageId}"
```

### Calendar

```
outlook_calendar_search:
  query: "*"
  afterDateTime: "{week_start}"
  beforeDateTime: "{week_end}"
  limit: 50
```

### Slack Highlights

```
slack_search_public:
  query: "to:me after:{week_start_date}"
  sort: "timestamp"
  limit: 30
```

### Teams Highlights

```
chat_message_search:
  query: "*"
  afterDateTime: "{week_start_iso}"
  limit: 30
```

---

## Step 2: Analyse

### Email Analysis
- **Total volume**: count of emails received
- **By category**: how many would classify as skip / info_only / action_required
- **Open threads**: emails that appear unanswered (user was in To:, no reply from user found in thread)
- **Top senders**: who emailed the user most this week
- **VIP emails**: all emails from VIP senders with status (replied / pending)

### Meeting Analysis
- **Total meetings**: count
- **Hours in meetings**: total time
- **Back-to-back days**: days where meetings were stacked

### Communication Patterns
- **Busiest day**: which day had the most incoming messages
- **Response gaps**: threads where someone is waiting for the user's reply
- **Cross-platform threads**: same topic appearing in email + Slack/Teams

---

## Step 3: Present Summary

```
# Weekly Summary — {week_start_date} to {today_date}

## At a Glance

| Metric | Count |
|--------|-------|
| Emails received | {total} |
| Action required | {action_count} |
| Replied to | {replied_count} |
| Still pending | {pending_count} |
| Meetings | {meeting_count} ({hours}h total) |
| Slack mentions | {slack_count} |
| Teams messages | {teams_count} |

## Open Threads ({count})

These emails appear to need your response:

1. **Sender** — Subject — received {date} — {days} days waiting
2. **Sender** — Subject — received {date} — {days} days waiting
3. ...

## VIP Email Status

| Sender | Subject | Status | Date |
|--------|---------|--------|------|
| CEO | Q3 Planning | Replied | Mon |
| Board | Audit report | **Pending** | Wed |
| Client | Contract renewal | Replied | Tue |

## This Week's Meetings

| Day | Meetings | Hours | Notable |
|-----|----------|-------|---------|
| Mon | 4 | 3.5h | Board meeting, 1:1 with CEO |
| Tue | 3 | 2.0h | Client call |
| Wed | 5 | 4.5h | Back-to-back afternoon |
| Thu | 2 | 1.5h | — |
| Fri | 1 | 0.5h | Team standup |

## Patterns & Insights

- **Top email senders:** Person1 ({N} emails), Person2 ({N}), Person3 ({N})
- **Busiest day:** {day} with {N} incoming messages
- **Meeting load:** {hours}h in meetings this week ({percentage}% of work hours)
- {Any notable patterns: e.g., "Finance team sent 15 emails — might be worth a sync instead"}

## Loose Ends

Items to tie up before the weekend (or start of next week):

1. Reply to Sender — Subject ({days} days pending)
2. Reply to Sender — Subject ({days} days pending)
3. Follow up on: topic (sent {date}, no response yet)

---

{pending_count} items still need your attention.
```

---

## Step 4: Offer Follow-Up

> "Want me to help with any of the loose ends? I can draft replies for the pending items."

If yes, process each pending item using the same draft flow as `/triage`.

---

## Notes

- The weekly summary is read-only — it never sends, moves, or archives anything
- Email counts may be approximate if there are more than 50 emails in the period (pagination limits)
- If the week is particularly heavy (>100 emails), focus the summary on action_required and VIP items rather than trying to categorise everything
- Cross-reference open threads against calendar — if there's a meeting scheduled with the same person, note "meeting scheduled {date}" next to the open thread
