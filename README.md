# True Utilities

A set of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skills that triage your inbox, Slack, Asana, and Teams — classifying messages, surfacing what needs attention, and drafting replies so you can stay on top of communications without spending hours in Outlook.

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

### 1. Clone and install

```bash
git clone https://github.com/trueprotein/true-utils.git
cd true-utils
./install.sh        # Mac/Linux
# or double-click install.bat on Windows
```

This copies the skills to `~/.claude/skills/` so they work from any directory.

### 2. Connect your tools

You need the following MCP connectors enabled in Claude Code:

| Connector | Used for |
|-----------|----------|
| **Microsoft 365** | Outlook email, calendar, Teams |
| **Slack** | Channels, DMs, mentions |
| **Asana** | Task assignments, mentions, project updates |

Set these up via the Claude Code MCP connector marketplace.

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
| `/true setup` | Interactive setup and configuration |
| `/triage` | Full briefing: email + Slack + Teams + Asana + calendar |
| `/triage check` | Classify only, no drafting |
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
| **skip** | GitHub notifications, newsletters, automated alerts | Grouped for bulk cleanup |
| **info_only** | CC'd emails, FYI, receipts | One-line summary |
| **meeting_info** | Calendar invites, meeting links | Cross-referenced with calendar |
| **action_required** | Direct questions, requests, VIP emails | Prioritised, draft reply offered |

VIP senders (from your config) are always **action_required** and high priority.

### Draft-only safety

All email and Teams replies are **drafts only** — Claude never sends on your behalf. You review the draft and send it yourself.

Slack messages can be sent directly with your explicit approval.

### Skip handling

Skipped items (notifications, newsletters, automated alerts) are grouped by source after the briefing:

```
14 emails were skipped:
  9x GitHub, 3x Asana, 2x newsletters

Want me to summarise them for bulk cleanup?
```

When `Mail.ReadWrite` permissions are available, auto-archive is supported.

### Asana integration

`/triage` checks for Asana tasks assigned to you or where you're mentioned. Tasks due within 48 hours or with new comments directed at you are flagged as action-required.

## Configuration

Your personal config lives at `~/.claude/triage-config.md`. Run `/true setup` to generate it interactively, or edit it directly.

The config controls:
- **VIP senders** — always high priority
- **Skip patterns** — auto-skip noise (GitHub, Jira, newsletters)
- **Scheduling preferences** — work hours, meeting buffer, slots to offer
- **Communication tone** — external (professional/warm) vs internal (direct/casual)
- **Channels** — which tools to include in `/triage`

See [`config/triage-config.example.md`](config/triage-config.example.md) for the full template.

## Microsoft 365 Permissions

The skills work in **read-only mode** out of the box. For full functionality, an Entra ID admin can grant these delegated permissions:

| Permission | Enables |
|------------|---------|
| `Mail.Read` | Read inbox (likely already granted) |
| `Mail.ReadWrite` | Auto-archive skipped emails, move to folders |
| `Mail.Send` | Send replies directly from Claude |
| `Calendars.Read` | Read calendar (likely already granted) |
| `Calendars.ReadWrite` | Create calendar events for proposed meeting times |
| `Chat.Read` | Read Teams chat messages |

These are **delegated** permissions — Claude can only access what the signed-in user can access.

## Project Structure

```
install.sh                        # Installer (Mac/Linux)
install.bat                       # Installer (Windows)
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
- Microsoft 365 account (for Outlook/Teams)
- Slack workspace (optional)
- Asana workspace (optional)

## License

MIT

---

Made with :heart: by TrueTech
