---
name: true
description: "True Captain — list commands (/true) or run interactive setup (/true setup)."
argument-hint: "[setup [section]]"
---

# /true — True Captain

Arguments: $ARGUMENTS

---

## Route by Argument

- If `$ARGUMENTS` is empty or blank → go to **Show Commands**
- If `$ARGUMENTS` is exactly `setup` → go to **Setup Flow**
- If `$ARGUMENTS` starts with `setup ` followed by a section name → go to **Setup Section** with that section

---

## Show Commands

Read the version from `~/.claude/skills/.true-utils-version`. If the file doesn't exist, show "unknown".

Print the following and **stop**:

```
True Captain v{version}

Commands:
  /triage              Full briefing: email + Slack + Teams + Asana + calendar
  /triage check        Classify only, no drafting
  /triage draft        Classify + draft replies (no prompt)
  /triage 2h           Last 2 hours (back from a meeting)
  /triage 4h           Last 4 hours
  /triage 1d           Last 24 hours
  /triage yesterday    Since yesterday morning
  /mail                Email-only triage
  /mail check          Email classify only
  /reply <search>      Draft reply to a specific email
  /reply-with-availability <search>   Scheduling reply with calendar slots
  /weekly              Week-to-date summary
  /weekly last-week    Previous week summary
  /true setup          Configure preferences (or reconfigure)
  /true setup <section>  Jump to a specific section

Setup sections: identity, vip, skip, schedule, tone, channels, platform

Config: ~/.claude/triage-config.md

Made with ❤️ by TrueTech
```

---

## Setup Flow

Interactive onboarding for True Captain. Creates `~/.claude/triage-config.md` which all triage skills use.

### Step 1: Check for Existing Config

Check if `~/.claude/triage-config.md` already exists.

- If it **does not exist** → run the **Full Wizard** (all sections in order)
- If it **exists** and `$ARGUMENTS` is exactly `setup` → go to **Setup Menu**
- If it **exists** and `$ARGUMENTS` is `setup all` → run the **Full Wizard** from scratch
- If it **exists** and `$ARGUMENTS` is `setup {section}` → go to **Setup Section**

---

### Setup Menu

Read the existing config and show a summary of what's configured, then ask which section to update:

```
Current config:
  Identity:      {name} ({role}) — {email}
  VIP senders:   {count} configured
  Skip patterns: {count} patterns
  Skip folders:  Notifications, Marketing, Calendar, Reports, Payments
  Schedule:      {start}–{end} AEST
  Tone:          External: {ext} / Internal: {int}
  Channels:      {list of enabled channels}
  Platform:      {platform}

What would you like to update?
```

Use AskUserQuestion with options:
- **Identity** — name, role, email
- **VIP senders** — high priority contacts
- **Skip patterns** — auto-skip noise
- **Schedule** — work hours, meeting buffer
- **Tone** — external/internal communication style
- **Channels** — which tools to include in /triage
- **Platform** — email platform (auto/M365/Google)
- **All settings** — full wizard from scratch

The user can also say things like "add Sarah to VIP", "change tone to formal", etc. Handle natural language updates directly without going through the menu.

When the user picks a section, go to **Setup Section** for that section.

---

### Setup Section

Run **only** the selected section's questions (below), then merge the result into the existing config file (preserving all other sections unchanged).

After updating, show a confirmation of just what changed:

```
Updated {section}:
  {summary of changes}

Config saved to ~/.claude/triage-config.md
```

---

### Full Wizard

Run all sections in order. Ask the user the following questions using AskUserQuestion. Group related questions together to keep it quick.

---

#### Section: identity

Ask in one go:
- **What's your name?** (for draft replies)
- **What's your role?** (e.g. CFO, Head of Engineering, Marketing Manager — helps prioritise emails)
- **What's your email address?** (e.g. name@company.com)

---

#### Section: vip

Ask: **Whose emails should never be missed? List the email addresses of people whose messages are always high priority.**

Suggest common examples:
- CEO, board members, direct manager
- Key clients or external partners
- Regulators or auditors

The user can provide email addresses or just names/roles and you'll format them.

If updating (not fresh setup), show the current VIP list first and ask what to add/remove/replace.

---

#### Section: skip

Ask: **Are there any automated emails or notifications you want to always skip?**

Suggest common patterns:
- GitHub notifications (notifications@github.com)
- Jira/Confluence alerts
- Automated reports
- Marketing newsletters

If updating, show the current skip list first and ask what to add/remove/replace.

---

#### Section: schedule

Ask using AskUserQuestion with options:
- **Work hours:** Default 9:00–17:00 AEST
- **Preferred meeting start:** Default 10:00 (avoid early mornings)
- **Time slots to offer in scheduling replies:** Default 3

---

#### Section: tone

Ask using AskUserQuestion with options:
- **External tone:** Professional and warm (default) / Formal / Casual
- **Internal tone:** Direct and casual (default) / Professional

---

#### Section: channels

Ask using AskUserQuestion with multiSelect:
- **Which channels do you want included in /triage?**
  - Email (default: yes)
  - Slack (default: yes)
  - Teams (default: yes)
  - Asana (default: yes)

---

#### Section: platform

Ask using AskUserQuestion with options:
- **Which email platform do you use?**
  - Auto-detect (Recommended) — uses whichever connector is available
  - Microsoft 365 (Outlook)
  - Google Workspace (Gmail)

---

### Generate Config

Write the config file to `~/.claude/triage-config.md` using the gathered information.

For **section updates**, read the existing file, update only the relevant section, and write it back. Preserve all other sections and comments.

For **full wizard**, write the complete file:

```markdown
# Triage Configuration
#
# Generated by /true setup on {date}
# Edit this file anytime, or run /true setup again to reconfigure.
# Jump to a section: /true setup vip, /true setup tone, etc.

## Identity

- **Name:** {name}
- **Role:** {role}
- **Email:** {email}
- **Timezone:** Australia/Sydney

## VIP Senders (always action_required, always high priority)

{list of VIP email addresses, one per line with - prefix}

## Skip Patterns (auto-skip, don't even show in triage)

{list of skip patterns, one per line with - prefix}

## Scheduling Preferences

- **Work hours:** {start}–{end} AEST
- **Preferred meeting start:** {time}
- **Meeting buffer:** 15 min between meetings
- **Time slots to offer:** {count}
- **Weekdays only:** yes

## Communication Tone

- **External:** {external_tone}
- **Internal:** {internal_tone}

## Email Platform

- **Platform:** {platform}

## Channels to Include in /triage

- Email: {yes/no}
- Slack: {yes/no}
- Teams: {yes/no}
- Asana: {yes/no}

## Skip Folders

- **Notifications:** GitHub, Jira, Confluence, Asana, Slack, Linear
- **Marketing:** newsletters, promos, vendor marketing
- **Calendar:** meeting responses (accepted, declined, tentative)
- **Reports:** automated reports, CI/CD, backups
- **Payments:** invoices, receipts, billing
- **Move skipped emails to folders:** yes
```

---

### Confirm

Show the user a summary of what was configured:

```
Setup complete! Here's your config:

- Name: {name} ({role})
- Email: {email}
- Platform: {platform}
- VIP senders: {count} configured
- Skip patterns: {count} configured
- Skip folders: Notifications, Marketing, Calendar, Reports, Payments
- Work hours: {hours}
- Channels: {list}

Config saved to ~/.claude/triage-config.md

Skip folders are pre-configured with sensible defaults. Customise them
anytime in ~/.claude/triage-config.md under "Skip Folders".

You're ready to go! Try /triage to start.
```

---

## Notes

- Always use Australia/Sydney as the default timezone (True Protein is Australian)
- If the user gives partial info, use sensible defaults and tell them what was defaulted
- The config file includes comments explaining each section so users can edit it later
- If the user runs /true setup again, preserve their existing config unless they explicitly want to change sections
- Section updates should be surgical — only modify the targeted section, leave everything else untouched
- Handle natural language shortcuts: "add john@example.com to VIP" should work without going through the menu
