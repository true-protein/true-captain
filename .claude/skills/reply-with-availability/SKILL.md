---
name: reply-with-availability
description: "Draft a scheduling reply with available time slots from your calendar. Checks mutual availability when other attendees are mentioned."
argument-hint: "<sender or subject to search for>"
---

# /reply-with-availability — Calendar-Aware Scheduling Reply

Arguments: $ARGUMENTS

## Overview

Find an email about scheduling, check calendar availability, and draft a reply proposing times that work. If other attendees are mentioned, check their availability too.

---

## Step 0: Load User Configuration

Read `~/.claude/triage-config.md` for:
- Work hours, preferred meeting start time
- Number of time slots to offer
- Weekdays-only preference
- Meeting buffer preference
- Timezone

---

## Step 1: Find the Email

Search for the email using the argument. Detect which email connector is available.

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

If multiple matches, present a list and ask the user to pick.

---

## Step 2: Read Full Thread

Read the full email to understand:
- What kind of meeting is being proposed
- Suggested duration (default to 60 min if not specified)
- Other attendees mentioned
- Any constraints ("before end of month", "mornings only", etc.)

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

---

## Step 3: Check Availability

### If only the user's calendar matters:

Search the next 14 days for free slots. Detect which calendar connector is available.

**If Microsoft 365 (Outlook Calendar):**

```
outlook_calendar_search:
  query: "*"
  afterDateTime: "{today}"
  beforeDateTime: "{today + 14 days}"
  limit: 50
```

**If Google Workspace (Google Calendar):**

```
gcal_find_my_free_time:
  calendarIds: ["primary"]
  timeMin: "{today_start_iso}"
  timeMax: "{today_plus_14_days_iso}"
  timeZone: "{user_timezone}"
```

Identify gaps that match the user's work hours and preferences.

### If other attendees are mentioned:

Use mutual availability check.

**If Microsoft 365:**

```
find_meeting_availability:
  participants: ["{attendee1_email}", "{attendee2_email}"]
  duration: {duration_minutes}
  afterDateTime: "{today_start_utc}"
  beforeDateTime: "{today_plus_14_days_utc}"
  timeZone: "{user_timezone}"
```

**If Google Workspace:**

```
gcal_find_meeting_times:
  attendees: ["{attendee1_email}", "{attendee2_email}"]
  duration: {duration_minutes}
  timeMin: "{today_start_iso}"
  timeMax: "{today_plus_14_days_iso}"
  timeZone: "{user_timezone}"
```

### Apply user preferences:
- Filter to work hours from config
- Respect preferred meeting start time
- Ensure meeting buffer between slots
- Weekdays only if configured
- Select top N slots (from config, default 3)

---

## Step 4: Draft Reply

Draft a reply that includes the available time slots:

Follow the scheduling reply format from [tone-guide.md](../triage/tone-guide.md):

```
Hi {name},

{Brief acknowledgement of what the meeting is about — one line}

Here are some times that work{" for all of us" if multi-attendee}:

- {Day} {Date}, {Time range} {Timezone}
- {Day} {Date}, {Time range} {Timezone}
- {Day} {Date}, {Time range} {Timezone}

Let me know what suits{" and I'll send through a calendar invite" if user is organising}.
```

**Present to user:**

```
#### Reply to: Sender — Subject

**Available slots found:**
1. Day Date, Time — Time (free)
2. Day Date, Time — Time (free)
3. Day Date, Time — Time (free)

{If multi-attendee: "Checked availability for: Person1, Person2, You"}

**Draft:**

{draft reply text}

→ [Approve] [Edit] [More slots] [Different week]
```

- **More slots**: Find additional time slots
- **Different week**: Search a different date range

---

## Step 5: Post-Approval

When user approves:

1. Remind user to paste the reply into Outlook and send
2. If calendar write permissions are available:
   - Offer to create tentative calendar events for all proposed slots
   - When a date is confirmed later, clean up the unused tentative events

---

## Notes

- Times are always shown in the user's configured timezone with the timezone label
- If the other person is in a different timezone, note both timezones in the reply
- Never commit to times on the user's behalf — always draft for review
- If no slots are available in the next 14 days, say so and ask if the user wants to search further out
