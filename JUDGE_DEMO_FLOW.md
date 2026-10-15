# JUDGE_DEMO_FLOW.md — Rozgari hackathon demo script

App: Rozgari — Beyond the Waiting Line. 100% frontend, no backend.
All data lives on-device (SharedPreferences). EN/HI switcher in the top bar.

## Starting state

Fresh install (or drawer → Reset demo data). Seeds: 15 workers, 5 employers,
28 jobs. Language defaults to Hindi; switch to English anytime via the
translate icon — the whole app re-renders, nothing is lost.

## Demo identities (pre-seeded)

- Worker: **Ramesh Patil** — Electrician, Pune, 7 yrs (drawer → Demo controls →
  Switch to Worker).
- Employer: **Meera Shah** — Homeowner, Pune (Demo controls → Switch to Employer).

## The 22-step journey (matches spec §22)

1. Open app as **Employer Meera** (Demo controls → Switch to Employer).
2. DASHBOARD → **Post Job • 1-min form**. Fill: title `Electrical Repair
   Assistance`, category Electrician, description (min 20 chars), locality
   `Kothrud, Pune`, start Tomorrow, `9am – 5pm`, 1 day, ₹800, Daily cash,
   1 worker. Review → **Publish job**.
   Expected: `Job published ✓`; appears in worker Find Work + My listings.
3. Switch to **Worker Ramesh** (Demo controls).
4. Chowk tab → **Go Available** (+ Today). Expected: `CHOWK LIVE`.
5. Jobs tab → search `Electrical` → open Meera's job.
6. **Apply & Lock Job** → confirmation dialog → View My Jobs.
   Expected: application in Applied; employer notified.
7. Switch to **Employer Meera**. Open the job → Applicants.
8. Applicant row shows `Ramesh Patil • Electrician • 7 yrs…`.
9. **Shortlist** → worker sees Shortlisted + notification.
10. **Send offer** → Work Promise Card v1 created; worker notified.
11. Switch to **Worker Ramesh** → My Jobs → Offers → **Review offer**.
12. Review terms (wage ₹800, timing, location, payment).
13. **Accept & Confirm terms** → `CONFIRMED by both sides`.
14. Open **Work Promise** → slip shows job/worker/employer/wage/date/timing.
15. Switch to **Employer Meera** → Work tab → agreement CONFIRMED.
16. Confirmed worker visible with Start work.
17. **Start work** → In Progress.
18. **Mark complete (simulated)** → Completed + payment row created.
19. **Update payment** → Paid (simulated).
20. Switch to **Ramesh** → My Jobs → Completed shows the job + Paid.
21. Kill + restart app → everything persists (role, language, records).
22. Drawer → **Reset demo data** → original 28 jobs / clean pipeline restored.

Extra to show off: role-guard (a worker deep-link to `/post` offers one-tap
switch), job edit (Applicants screen → Edit), close-listing cascade, invitation
accept → auto-application, Hindi↔English instant switch, report/safety flags,
voice search with honest mic fallback.

## Simulated (never real)

Calls, mic recording, photo upload, payments, enforcement on reports, GPS
(distances are Haversine from fixed locality coordinates).

## Known limitations

- Offer accept/decline is one-tap demo UX; no negotiation threads.
- Posted content (job text, names, welfare articles) stays in its written
  language; only UI chrome translates.
- One device = one shared dataset; no multi-device sync.
