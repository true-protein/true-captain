# Triage Configuration
#
# Copy this file to ~/.claude/triage-config.md and customise for your role.
#
# Claude reads this at the start of every /triage, /mail, /reply,
# /reply-with-availability, and /weekly command.

## Identity

- **Name:** Your Name
- **Role:** Your role (e.g., CFO, Head of Engineering, Marketing Manager)
- **Email:** your.email@company.com
- **Timezone:** Australia/Sydney

## VIP Senders (always action_required, always high priority)

<!-- Add email addresses or domains of people whose emails should never be missed -->

- ceo@company.com
- board@company.com

## Skip Patterns (auto-skip, don't even show in triage)

<!-- Add sender patterns or subject keywords to always skip -->

<!-- Common patterns are already built into the classification rules.
     Add any extra patterns specific to your inbox here. -->

- notifications@github.com
- Subject contains: automated report

## Scheduling Preferences

- **Work hours:** 9:00–17:00 AEST
- **Preferred meeting start:** 10:00 (avoid early mornings)
- **Meeting buffer:** 15 min between meetings
- **Time slots to offer:** 3
- **Weekdays only:** yes

## Communication Tone

- **External:** Professional, warm, concise
- **Internal:** Direct, casual

## Email Platform

<!-- Which email/calendar platform to use. The skills auto-detect, but you can force one. -->

- **Platform:** auto (auto | microsoft365 | google)

## Channels to Include in /triage

<!-- Which communication channels to scan during full triage -->

- Email: yes
- Slack: yes
- Teams: yes
- Asana: yes

## Skip Folders

<!-- Skipped emails are moved to these folders for inbox hygiene.
     The classification rules auto-detect which folder each email belongs in.
     Customise the folder names below, or add/remove categories.

     IMPORTANT: /triage can't create folders — the MCP connectors don't support it.
     Create these folders manually in Outlook or Gmail. If a folder doesn't exist,
     /triage moves those emails to Archive instead (still clears your inbox).
     Run /true setup to check which folders exist in your mailbox.

     Common aliases are also accepted:
     - Marketing → Newsletters, Promos
     - Payments → Orders, Invoices, Billing
     - Reports → Analytics, Dashboards
     - Calendar → Meeting Responses
     - Notifications → Alerts -->

- **Notifications:** GitHub, Jira, Confluence, Asana, Slack, Linear
- **Marketing:** newsletters, promos, vendor marketing
- **Calendar:** meeting responses (accepted, declined, tentative)
- **Reports:** automated reports, CI/CD, backups
- **Payments:** invoices, receipts, billing

<!-- Set to "no" to skip the folder-move step and just list skipped items -->
- **Move skipped emails to folders:** yes

## Weekly Summary Preferences

- **Include:** email volume stats, open threads, meetings attended, key decisions
- **Exclude:** skip-category emails from stats
