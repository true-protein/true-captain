# Classification Rules

Classify each item into one of four categories. Apply top-to-bottom — first match wins.

## 1. skip (flagged for batch cleanup)

- From contains `noreply`, `no-reply`, `notification`, `alert`, `mailer-daemon`
- From contains `@github.com`, `@slack.com`, `@jira`, `@notion.so`, `@atlassian.com`, `@asana.com`
- Subject contains `[GitHub]`, `[Slack]`, `[Jira]`, `[Confluence]`, `[Asana]`
- Automated reports, system notifications, build alerts
- Marketing newsletters, promotional content
- Service receipts where no action is needed

**Note:** Skipped items are grouped by source and presented for optional bulk cleanup (see Step 3.5 in triage flow). Auto-archive will be available once Mail.ReadWrite permissions are granted.

## 2. info_only (show summary, no reply needed)

- User is in CC (not direct recipient in To:)
- Internal FYI emails, shared documents, announcements
- Receipts, invoices (informational)
- Auto-replies to user's own inquiries
- Thread where user already replied and no new question was asked

## 3. meeting_info (calendar cross-reference)

- Contains meeting link (Teams, Zoom, Google Meet, WebEx URL)
- Contains calendar invite or .ics attachment
- Contains date/time + meeting context
- Location or room share
- Meeting reschedule or cancellation notices

### meeting_info processing:
1. Extract: date/time, meeting link, location, title, attendees
2. Cross-reference with calendar via `outlook_calendar_search` (M365) or `gcal_list_events` (Google)
3. Report gaps: missing link, missing location, no matching calendar event
4. If event exists with all info → mark as resolved

## 4. action_required (needs a reply)

- User is a direct recipient (in To:) AND email contains a question or request
- Question markers: `?`, `please confirm`, `let me know`, `can you`, `could you`, `your thoughts`, `approval needed`, `action required`, `RSVP`, `by EOD`, `by end of`
- From a VIP sender (defined in user's triage-config.md)
- Thread where someone asked user a direct question after user's last reply
- Escalations or items marked urgent/high priority

## Priority signals within action_required

Rank action_required emails by urgency:

| Signal | Priority |
|--------|----------|
| From VIP sender (board, CEO, direct reports, key clients) | High |
| Contains deadline language (by EOD, by Friday, urgent) | High |
| External sender (client, partner, regulator) | High |
| User is sole recipient (not group email) | Medium |
| Contains question but no deadline | Medium |
| Reply to existing thread | Low |
| Group email where user is one of many in To: | Low |

## Slack Classification Rules

### skip
- Bot/app posts
- User's own posts
- Join/leave/topic change notifications
- Automated workflow messages

### info_only
- Channel posts without @mention of user
- @channel/@here announcements
- File shares without direct question

### action_required
- Direct @mention of user with a question/request
- DM where other party sent last message
- Thread user participated in with unanswered follow-up

## Teams Classification Rules

### skip
- Bot messages, automated notifications
- User's own messages

### info_only
- Channel posts without @mention
- General announcements

### action_required
- Direct @mention with question/request
- 1:1 chat where other party sent last message
- Urgent/important flagged messages

## Asana Classification Rules

### action_required
- Task assigned to user with due date within 48 hours
- Task assigned to user marked high priority
- Task where someone left a comment/mention directed at user (after user's last activity on the task)
- Task assigned to user with no due date but recently created (last 7 days)

### info_only
- User is a follower (not assignee) and task was updated
- Task assigned to user with due date > 48 hours away and no new comments
- Completed task where user is a follower (status update)

### skip
- User is a follower on a task with no activity in the time range
- Automated status changes with no human comment
