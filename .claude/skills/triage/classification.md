# Classification Rules

Classify each item into one of four categories. Apply top-to-bottom — first match wins.

## 1. skip (noise — moved to folders for inbox hygiene)

Each skipped email is routed to a target folder based on its type. The folder mapping comes from the user's config (`Skip Folders` section) with these defaults:

| Pattern | Folder | Examples |
|---------|--------|----------|
| `@github.com`, `@atlassian.com`, `@jira`, `@asana.com`, `@notion.so`, `@slack.com`, `@linear.app` | **Notifications** | GitHub, Jira, Confluence, Asana, Slack email alerts |
| `noreply`, `no-reply`, `notification`, `alert`, `mailer-daemon` | **Notifications** | Generic automated senders |
| Subject contains `[GitHub]`, `[Jira]`, `[Confluence]`, `[Asana]`, `[Slack]` | **Notifications** | Bracketed app notifications |
| Newsletter, promotional, marketing, `unsubscribe` in body/headers | **Marketing** | Newsletters, vendor promos |
| Subject starts with `Accepted:`, `Declined:`, `Tentative:`, `Invitation:`, `Canceled:` | **Calendar** | Meeting responses and invites |
| Automated reports, build alerts, scheduled summaries | **Reports** | Looker, CI/CD, backup reports |
| Automated invoice/receipt from `noreply` or known billing systems | **Payments** | Transactional receipts from billing systems |
| All other skip matches | **Notifications** | Default folder for unmatched skip items |

After classification, skipped emails are grouped by target folder and presented in Step 3.5 for the user to confirm before moving.

**Missing folders:** The MS365 and Gmail MCP connectors cannot create mail folders. If a target folder doesn't exist, fall back to **Archive** (which always exists). Before moving, check available folders with `list-mail-folders` (M365) or `gmail_list_labels` (Gmail). Note any missing folders in the hygiene summary so the user knows to create them manually if they want finer sorting in future runs.

Recommended folders (created via `/true setup` or manually in the mail client):
- **Notifications** — GitHub, Jira, Asana, Slack, automated alerts
- **Marketing** — newsletters, promos, vendor emails
- **Calendar** — meeting responses, invites
- **Reports** — automated reports, build alerts
- **Payments** — invoices, receipts from billing systems

## 2. info_only (show summary, no reply needed)

- User is in CC (not direct recipient in To:)
- Internal FYI emails, shared documents, announcements
- Receipts or invoices from real people (not automated noreply senders)
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
