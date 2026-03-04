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

If not found, tell the user to run `/true setup` first.

---

## Step 1: Fetch Emails

Detect which email connector is available and fetch accordingly.

**If Microsoft 365 (Outlook) is available:**

```
outlook_email_search:
  query: "*"
  folderName: "Inbox"
  afterDateTime: "{today_midnight_iso}"
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
_{count} items — see inbox hygiene below_

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
- Attempt to move emails to their target folders
- Create folders that don't exist yet
- If it succeeds → "Moved {N} emails to {X} folders."
- If permission error → degrade gracefully:

  > "I'd move these {N} emails for you, but `Mail.ReadWrite` (Outlook) / `gmail.modify` (Gmail) isn't enabled.
  > Here's the breakdown so you can sort them manually:
  >
  > **Notifications** (9): GitHub ×6, Asana ×3
  > **Marketing** (3): Newsletter A, Vendor B, Promo C
  >
  > Enable `{permission}` to unlock automatic inbox sorting."

**If "Show details":**
- List every skipped email with its target folder
- Then re-offer [Move all] [Leave in inbox]

**Folder mapping** comes from the user's config (`Skip Folders` section). See [classification.md](../triage/classification.md) for defaults.

If argument is `check`, stop here (classify + inbox hygiene only — no drafting).

---

## Step 4: Draft Replies

Ask: "Want me to draft replies for the {N} action-required emails?"

For each action_required email:

1. Read the full thread if not already loaded
2. Check for scheduling keywords → if found, check calendar
3. Draft a reply following [tone-guide.md](../triage/tone-guide.md)
4. Present draft to user with [Approve] [Edit] [Skip] options
5. **On Approve** — attempt the best available action, degrade if permissions are missing:

   **Gmail:**
   - Try `gmail_create_draft` → if success: "Draft saved to Gmail."
   - If permission error: *"Here's your draft. I'd save this to your Gmail Drafts, but `gmail.compose` isn't enabled."*
   - If draft saved, offer to send → try send, degrade if `gmail.send` missing: *"Draft saved. I'd send it directly, but `gmail.send` isn't enabled. Open Drafts and hit send."*

   **Outlook:**
   - Present draft text for the user to copy
   - Note: *"With `Mail.Send`, I could send this directly. With `Mail.ReadWrite`, I could save it to your Drafts."*

6. Wait for user decision before proceeding to next

**No signature** — your mail client appends it automatically.

---

## Step 5: Summary

```
Inbox triage complete.
- Drafted: {N}
- Saved to Drafts: {N}
- Sent: {N}
- Pending (copy to mail client): {N}
- Moved to folders: {N} skipped items
```

If any actions were blocked by missing permissions, add:

```
Some actions were limited by missing permissions:
- {action}: needs `{permission}`
```
