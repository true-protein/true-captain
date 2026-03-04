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

- notifications@github.com
- noreply@slack.com
- Subject contains: [Jira], [GitHub], automated report, unsubscribe

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

## Skip Handling

<!-- What to do with skipped items (notifications, newsletters, automated alerts) -->

- **Show skip summary after briefing:** yes
- **Auto-archive when available:** no

## Weekly Summary Preferences

- **Include:** email volume stats, open threads, meetings attended, key decisions
- **Exclude:** skip-category emails from stats
