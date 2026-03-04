---
name: mail
description: "Email-only triage — classify and prioritise your inbox (Outlook or Gmail), draft replies for action-required emails. Use when you just want to clear your inbox without the full briefing."
argument-hint: "[check|draft]"
---

# /mail — Email Triage

Arguments: $ARGUMENTS

## Overview

Email-only version of `/triage`. Classify inbox, prioritise what needs attention, draft replies. No Slack or Teams — just email.

---

## Step 0: Load User Configuration

Read `~/.claude/triage-config.md` for VIP senders, skip patterns, tone preferences, and timezone.

If not found, tell the user to copy from `config/triage-config.example.md`.

---

## Step 1: Fetch Emails

Detect which email connector is available and fetch accordingly.

**If Microsoft 365 (Outlook) is available:**

```
outlook_email_search:
  query: "*"
  folderName: "Inbox"
  limit: 50
```

Read full messages:

```
read_resource:
  uri: "mail:///messages/{messageId}"
```

**If Google Workspace (Gmail) is available:**

```
gmail_search_messages:
  q: "in:inbox is:unread"
  maxResults: 50
```

Read full messages:

```
gmail_read_message:
  messageId: "{messageId}"
```

---

## Step 2: Classify

Apply classification rules from the triage skill's [classification.md](../triage/classification.md).

Classify each email as: **skip**, **info_only**, **meeting_info**, or **action_required**.

**Thread context check:** For multi-message threads, always read the full thread before classifying. If user already replied and no new question was asked → **info_only** or **skip**.

---

## Step 3: Present Results

```
# Inbox Triage — {date}

### Skipped ({count})
- sender — subject

### Info Only ({count})
- sender — subject — one-line summary

### Meeting Info ({count})
- sender — subject — calendar status

### Action Required ({count})

#### 1. [HIGH] Sender Name <email>
**Subject:** ...
**Summary:** what they need from you

#### 2. [MEDIUM] ...

---

{action_count} emails need your response. {skip_count} skipped, {info_count} FYI.
```

---

## Step 3.5: Skipped Items — Batch Action

If skip_count > 0, present the skipped items grouped by sender and ask:

> "{skip_count} emails were skipped (notifications, newsletters, automated alerts).
> Want me to summarise them for bulk cleanup?"
>
> → [Show summary for manual archive] [Leave as-is]

If "Show summary":
- Group by sender/type (e.g. "12× GitHub, 5× Asana, 3× newsletters")
- List senders with counts so user can bulk-select in their mail client
- Note: "Auto-archive will be available once Mail.ReadWrite (Outlook) or Gmail.Modify (Google) permissions are granted. For now, you can select these in your mail client and archive/delete in bulk."

If argument is `check`, stop here (after skip summary).

---

## Step 4: Draft Replies

Ask: "Want me to draft replies for the {N} action-required emails?"

For each action_required email:

1. Read the full thread if not already loaded
2. Check for scheduling keywords → if found, check calendar
3. Draft a reply following [tone-guide.md](../triage/tone-guide.md)
4. Present draft to user with [Approve] [Edit] [Skip] options
5. Wait for user decision before proceeding to next

**No signature** — your mail client appends it automatically. For Gmail, approved drafts can be created directly via `gmail_create_draft`.

---

## Step 5: Summary

```
Inbox triage complete. Drafted {N}, approved {N}, skipped {N}.
Pending: {list any skipped items for later}
```
