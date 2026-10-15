# Rozgari — Project Overview
> **Beyond the Waiting Line — Connecting Hawkers to Better Employment Opportunities**

## What it is
Rozgari is a hyperlocal, accessible employment platform connecting informal workers
(electricians, plumbers, carpenters, painters, masons, helpers, …) with nearby employers
in Pune & Mumbai. This repo is a **frontend-only interactive prototype** (no backend):
all data lives on-device in a single shared Riverpod state persisted with SharedPreferences.

## Target users
- **Workers** with limited digital literacy: no résumé, bilingual UI (Hindi default, Marathi, English),
  voice-assisted search, large touch targets, audio cues, Skill Passport instead of CV.
- **Employers**: households, contractors, societies — post jobs in ~1 minute, discover available
  workers in Digital Labour Chowk, shortlist → offer → Work Promise Card → completion & simulated payment.
- **Assisted users** via Sahayak helpline entry points and audio-mode patterns from the HTML design.

## Problems solved (from the brief)
1. Daily work uncertainty → availability toggle + live matching + invitations.
2. No access to nearby opportunities → distance-aware search/filter/sort, Labour Chowk.
3. No résumé → Skill Passport (trade, skills, experience, area, expected pay, completed jobs).
4. Can't showcase skills → passport + completed-job counts derived from real records.
5. Unclear pay/conditions → Work Promise Card both sides must confirm; payments labelled simulated.
6. Welfare/safety awareness → Kaam Suraksha (rule-based flags + reporting) + Welfare Hub directory.
7. Language/digital-literacy barriers → trilingual strings, voice parse with editable chips, honest mic fallback.
8. Employer discovery pain → deterministic Chowk matching (skill + availability + area), no fake AI scores.

## Key features (all wired to one state)
Onboarding (language → landing → role → profile) • Worker dashboard • Job discovery •
Kaam Bolo voice • Apply lifecycle (10 statuses, guarded) • Digital Labour Chowk (both sides) •
Employer post/edit/close • Shortlist/offer • Work Promise Card (dual-confirm, versions) •
My Jobs tabs • Simulated payments • Notifications with deep-links • Safety + Welfare •
Demo Mode (Ramesh ↔ Meera switch, reset) • Restart persistence.

## Design source
Visual language converted from `Frontend/code.html` (11 HTML screens): deep forest green
`#00231A` + amber `#825500/#FDB64C`, warm canvas `#F7F3EA`, rounded-xl cards, stadium CTAs,
bilingual editorial headings, trust banners, Material Symbols icons.
