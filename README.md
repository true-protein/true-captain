# True Captain

A set of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills that triage your inbox, Slack, Asana, and Teams — classifying messages, surfacing what needs attention, and drafting replies so you can stay on top of communications without context-switching all day.

Works with **Microsoft 365** (Outlook, Teams) and **Google Workspace** (Gmail, Google Calendar).

Built by the team at [True Protein](https://www.trueprotein.com.au).

## What It Does

Run `/triage` in Claude Code and get a prioritised briefing across all your channels:

```
/triage
```

```
# Morning Briefing — 4 Mar 2026

## Skipped (14)
- GitHub notifications (9), Asana status updates (3), newsletters (2)

## Info Only (6)
- Sarah Chen — Q3 budget approved — no action needed
- Dev team — deploy completed — FYI
  ...

## Action Required (3)

### 1. [HIGH] Martin Curtis <martin@example.com>
Subject: Board deck — need your section by EOD
Summary: Needs your engineering update slide for tomorrow's board meeting.

### 2. [MEDIUM] Client Services <client@example.com>
Subject: Integration timeline query
Summary: Asking for estimated delivery date on API integration.
  ...

3 emails need your response. 14 skipped, 6 FYI.
Want me to draft replies for the 3 action-required emails?
```

Every message is classified as **skip** (noise), **info_only** (FYI), **meeting_info** (calendar), or **action_required** (needs your reply). VIP senders are always high priority. Skipped items are grouped for bulk cleanup.

## Quick Start

### 1. Install

**Option A: One-liner**

```bash
bash <(curl -s https://raw.githubusercontent.com/true-protein/true-captain/main/install-remote.sh)
```

**Option B: Clone and install**

```bash
git clone https://github.com/true-protein/true-captain.git
cd true-captain
./install.sh        # Mac/Linux
# or double-click install.bat on Windows
```

Both options copy the skills to `~/.claude/skills/` so they work from any directory in Claude Code.

### 2. Connect your tools

You need at least one email connector, plus any optional channels:

| Connector | Platform | Used for |
|-----------|----------|----------|
| **Microsoft 365** | Microsoft | Outlook email, calendar, Teams |
| **Gmail** | Google | Gmail, Google Calendar |
| **Slack** | — | Channels, DMs, mentions |
| **Asana** | — | Task assignments, mentions, project updates |

Set these up via the Claude Code MCP connector marketplace. You don't need both Microsoft 365 and Gmail — pick whichever your organisation uses.

### 3. Run the setup

```
/true setup
```

Interactive onboarding — configures your name, role, VIP senders, skip patterns, and tone preferences. Takes about 2 minutes.

### 4. Start triaging

```
/triage              # Full morning briefing
/triage 2h           # Back from a meeting — what did I miss?
/mail                # Just email, skip Slack/Teams
/reply Sarah         # Draft a reply to Sarah's email
/weekly              # Week-to-date summary
```

## Commands

| Command | What it does |
|---------|-------------|
| `/true` | List all commands and current version |
| `/true setup` | Interactive setup (menu if already configured) |
| `/true setup vip` | Jump to VIP senders config |
| `/true setup <section>` | Jump to a section: `identity`, `vip`, `skip`, `schedule`, `tone`, `channels`, `platform` |
| `/triage` | Full briefing: email + Slack + Teams + Asana + calendar |
| `/triage check` | Classify only, no drafting |
| `/triage draft` | Classify + draft replies (skip the "want me to draft?" prompt) |
| `/triage 2h` | Last 2 hours (also `4h`, `1d`, `yesterday`) |
| `/mail` | Email-only triage |
| `/reply <search>` | Draft a reply to a specific email |
| `/reply-with-availability <search>` | Scheduling reply with calendar availability |
| `/weekly` | Week-to-date summary |
| `/weekly last-week` | Previous week summary |

## How It Works

### Classification

Every message is sorted into one of four buckets:

| Category | Examples | Action |
|----------|----------|--------|
| **skip** | GitHub notifications, newsletters, automated alerts | Moved to folders (Notifications, Marketing, etc.) |
| **info_only** | CC'd emails, FYI, receipts | One-line summary |
| **meeting_info** | Calendar invites, meeting links | Cross-referenced with calendar |
| **action_required** | Direct questions, requests, VIP emails | Prioritised, draft reply offered |

VIP senders (from your config) are always **action_required** and high priority.

### Platform auto-detection

The skills auto-detect which MCP connectors are available and use the right tools:

| Function | Microsoft 365 | Google Workspace |
|----------|--------------|-----------------|
| Search email | `outlook_email_search` | `gmail_search_messages` |
| Read email | `read_resource` | `gmail_read_message` |
| Create draft | `create-draft-email` (Softeria MCP) | `gmail_create_draft` |
| Move email | `move-mail-message` (Softeria MCP) | Gmail labels |
| Calendar events | `outlook_calendar_search` | `gcal_list_events` |
| Find availability | `find_meeting_availability` | `gcal_find_meeting_times` |

### Draft-only safety

All email replies are **drafts only** — Claude never sends on your behalf without explicit approval. For Outlook, drafts are created directly in your Drafts folder via the Softeria MCP server. For Gmail, drafts are created via `gmail_create_draft`. Either way, you review and send from your mail client.

Slack messages can be sent directly with your explicit approval.

### Inbox hygiene

Skipped emails are automatically sorted into folders to keep your inbox clean:

```
14 emails can be sorted out of your inbox:

  Notifications (9): GitHub ×6, Asana ×3
  Marketing (3): Newsletter A, Vendor B, Promo C
  Calendar (2): meeting responses

→ [Move all] [Show details] [Leave in inbox]
```

Default folders: **Notifications**, **Marketing**, **Calendar**, **Reports**, **Payments**. Customise in your config. Requires `Mail.ReadWrite` (Outlook) or `gmail.modify` (Gmail) — without these, you get a grouped list for manual cleanup.

### Asana integration

`/triage` checks for Asana tasks assigned to you or where you're mentioned. Tasks due within 48 hours or with new comments directed at you are flagged as action-required.

## Configuration

Your personal config lives at `~/.claude/triage-config.md`. Run `/true setup` to generate it interactively, or edit it directly.

The config controls:
- **VIP senders** — always high priority
- **Skip patterns** — auto-skip noise (GitHub, Jira, newsletters)
- **Skip folders** — where to move skipped emails (Notifications, Marketing, Calendar, Reports, Payments)
- **Scheduling preferences** — work hours, meeting buffer, slots to offer
- **Communication tone** — external (professional/warm) vs internal (direct/casual)
- **Channels** — which tools to include in `/triage`
- **Email platform** — auto-detect, or force Microsoft 365 / Google

See [`config/triage-config.example.md`](config/triage-config.example.md) for the full template.

## Permissions

The skills work in **read-only mode** out of the box. For full functionality, additional permissions can be granted by your admin.

### Microsoft 365 (Entra ID delegated permissions)

| Permission | Required | Enables |
|------------|----------|---------|
| `Mail.Read` | Yes | Read inbox |
| `Mail.ReadWrite` | Optional | Move skipped emails to folders |
| `Mail.Send` | Optional | Send replies directly from Claude |
| `Calendars.Read` | Yes | Read calendar |
| `Calendars.ReadWrite` | Optional | Create calendar events for proposed meeting times |
| `Chat.Read` | Optional | Read Teams chat messages |
| `Chat.ReadWrite` | Optional | Send replies in Teams chats |

These are **delegated** permissions — Claude can only access what the signed-in user can access. An Entra ID admin grants these via **Identity > Applications > Enterprise applications > [app] > Permissions > Grant admin consent**.

### Google Workspace (OAuth scopes)

| Scope | Required | Enables |
|-------|----------|---------|
| `gmail.readonly` | Yes | Read inbox |
| `gmail.modify` | Optional | Move skipped emails to labels/folders |
| `gmail.compose` | Optional | Create draft replies |
| `gmail.send` | Optional | Send replies directly from Claude |
| `calendar.readonly` | Yes | Read calendar |
| `calendar.events` | Optional | Create calendar events for proposed meeting times |

Google scopes are granted per-user during OAuth consent. A Workspace admin can pre-approve scopes via **Admin Console > Security > API controls > App access control**.

## Project Structure

```
install.sh                        # Installer (Mac/Linux)
install.bat                       # Installer (Windows)
install-remote.sh                 # One-liner remote installer
VERSION                           # Current version
.claude/
  skills/
    true/
      SKILL.md                    # /true — commands, version, setup
    triage/
      SKILL.md                    # /triage command
      classification.md           # Classification rules
      tone-guide.md               # Reply tone and style guide
    mail/
      SKILL.md                    # /mail command
    reply/
      SKILL.md                    # /reply command
    reply-with-availability/
      SKILL.md                    # /reply-with-availability command
    weekly/
      SKILL.md                    # /weekly command
config/
  triage-config.example.md        # Config template
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with MCP connector support
- **One of:** Microsoft 365 account (Outlook/Teams) **or** Google Workspace account (Gmail/Calendar)
- Slack workspace (optional)
- Asana workspace (optional)

## License

MIT

---

Made with ❤️ by TrueTech
