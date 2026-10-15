# KaamSetu — Demo Guide (for judges)

## Run the app
```bash
cd rozgari
flutter pub get
flutter run          # any device; web verified via `flutter build web`
flutter test         # 8/8 green incl. end-to-end flow test
```
No login, no backend, no API keys. First launch opens **Language Selection** (Hindi default).

## Demo Mode (no login needed)
- Tap the **flask icon** (top-right) or open the **drawer** → switch roles instantly:
  - **Worker: Ramesh Patil — Electrician** (`w01`)
  - **Employer: Meera Shah** (`e01`)
- **Reset demo data** restores 15 workers • 5 employers • 28 jobs.
- Amber **Demo Mode** banner + drawer note always disclose simulation. One shared state:
  actions as one role are visible as the other; everything survives restart (SharedPreferences).

## 24-step judge walkthrough (≈6 min)
1. Open KaamSetu → pick **हिंदी** → Continue.
2. Landing → **काम ढूँढें / Find Work**.
3. Role → **I Want Work** → Continue → profile form (prefilled for Ramesh) → **Preview & Save Passport** → lands on worker Home.
4. Home: note name/trade/availability, live counts, recommended jobs.
5. Open **Skill Passport** (drawer) — trade, skills, experience, expected pay.
6. Toggle **Availability** off/on — note discoverability message; existing jobs untouched.
7. **Jobs tab** → filter Trade=Electrician, City=Pune → open **“House wiring repair — 2BHK”** (Meera's `j01`).
8. Job detail: wage hero, logistics grid, Work Promise preview, safety section → **Apply & Lock Job**.
9. Confirm snackbar “Application saved — employer notified”; check **My Jobs → Applications**.
10. Flask icon → **Switch to Employer: Meera Shah** (role flips to Employer tabs).
11. Employer Home → tap **“House wiring repair — 2BHK”** → applicants list → find **Ramesh Patil**.
12. **Shortlist** → status chip changes; worker gets notified (check after switching back).
13. **Send offer** → Work Promise v1 created.
14. Flask icon → **Switch to Worker: Ramesh**.
15. **My Jobs → Offers** → open **Work Promise**.
16. Review wage/hours/location/terms → **Accept & Confirm terms**.
17. Slip now shows **CONFIRMED by both sides** (dual-confirm rule enforced).
18. Back in My Jobs → **Start work** → **Mark complete (simulated)** → payment row appears (Pending).
19. Employer side → **Work tab → Update payment → Paid (simulated)**.
20. **Restart the app** (stop + `flutter run`) → log back in as either role → statuses intact.
21. Drawer → **Reset demo data** → `j01` application gone, 28 jobs restored.
22. Bonus: **Chowk tab** (pause availability → employer Chowk hides Ramesh) • **Kaam Bolo** (paste Hindi query → chips → results) • **Safety** (open “Easy high-pay data task” → flags + report) • **Welfare Hub** search.

## Limitations (frontend-only, stated in-app)
Local data only (no cross-device sync) • simulated payments/notifications/calls • honest mic fallback •
no real job editing (close + repost) • no guided tour • partial full-text translation.
