# True Captain

Claude Code skills for communication triage across email, Slack, Teams, and Asana.

## Skills

This repo provides email and communication triage skills that work with **Microsoft 365** (Outlook, Teams) or **Google Workspace** (Gmail, Google Calendar), plus Slack and Asana via MCP connectors.

### Available Commands

- `/true` — List all commands and current version
- `/true setup` — Interactive onboarding and configuration
- `/triage` — Full briefing: email + Slack + Teams + Asana + calendar. Supports time ranges (e.g. `/triage 2h`, `/triage yesterday`)
- `/mail` — Email-only inbox triage
- `/reply <search>` — Draft a reply to a specific email
- `/reply-with-availability <search>` — Draft a scheduling reply with calendar availability
- `/weekly` — Week-to-date summary and loose ends

### Prerequisites

Users must have at least one email connector, plus any optional channels:
- **Microsoft 365** (Outlook email, calendar, Teams) **or** **Gmail** (Gmail, Google Calendar)
- **Slack** (channel search, DMs, mentions) — optional
- **Asana** (task search, assignments, mentions) — optional

### User Configuration

Each user must create `~/.claude/triage-config.md` via `/true setup` or from the template in `config/triage-config.example.md`. This file configures VIP senders, skip patterns, work hours, and tone preferences.

## Code Conventions

- Australian English spelling: `organise`, `colour`, `recognise`
- All email replies are drafts — never send automatically
- Slack messages may be sent with explicit user approval
- Skills auto-detect available MCP connectors (M365 vs Google)
