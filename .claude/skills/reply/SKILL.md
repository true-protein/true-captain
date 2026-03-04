---
name: reply
description: "Draft a reply to a specific email. Pass the sender name, subject, or search term as an argument."
argument-hint: "<sender or subject to search for>"
---

# /reply — Quick Reply to One Email

Arguments: $ARGUMENTS

## Overview

Find a specific email and draft a reply. For when you know exactly which email you want to respond to.

---

## Step 0: Load User Configuration

Read `~/.claude/triage-config.md` for tone preferences and timezone.

---

## Step 1: Find the Email

Use the argument to search for the email. Detect which email connector is available.

**If Microsoft 365 (Outlook) is available:**

```
outlook_email_search:
  query: "$ARGUMENTS"
  limit: 10
```

**If Google Workspace (Gmail) is available:**

```
gmail_search_messages:
  q: "$ARGUMENTS"
  maxResults: 10
```

If multiple results match, present a numbered list and ask the user to pick:

```
Found {N} matching emails:

1. Sender — Subject — Date
2. Sender — Subject — Date
3. ...

Which one?
```

---

## Step 2: Read Full Thread

Once the email is identified, read the full message.

**If Microsoft 365:**

```
read_resource:
  uri: "mail:///messages/{messageId}"
```

**If Gmail:**

```
gmail_read_thread:
  threadId: "{threadId}"
```

Note the thread context so the reply is informed.

---

## Step 3: Draft Reply

1. **Check for scheduling keywords** — if the email is about scheduling, suggest using `/reply-with-availability` instead, or offer to check calendar automatically

2. **Draft the reply** following the tone guide in [tone-guide.md](../triage/tone-guide.md):
   - Match the thread's formality level
   - Be concise
   - No signature
   - Australian English

3. **Present to user:**

   ```
   #### Reply to: Sender — Subject

   > They asked: one-line summary

   **Draft:**

   {draft reply text}

   → [Approve] [Edit] [Redo]
   ```

4. If user says **Edit**, ask what to change, redraft.
5. If user says **Redo**, generate a fresh alternative.
6. If user says **Approve**, confirm the draft is ready. Remind them to paste it into Outlook and send.

---

## Notes

- Email replies are always drafts. Never attempt to send without explicit approval.
- For Gmail, approved drafts can be created directly via `gmail_create_draft`.
- For Outlook, drafts are presented for the user to copy into Outlook.
- If the user provides no argument, ask: "Which email do you want to reply to? Give me a sender name, subject, or keyword."
