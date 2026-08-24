# Taskdown

- Added Buyer.aspx (gate entry form: vehicle no, transporter, Without PCS / Manual PCS toggle logic, 50-char material field, submit confirmation modal, success receipt) with Buyer.aspx.cs WebMethod `SubmitVehicle`.
- Added Security.aspx (live card dashboard, auto-refresh polling, "Vehicle is inside gate" action) with Security.aspx.cs WebMethods `GetVehicles` / `MarkVehicleInside`.
- Added VehicleGateStore.cs: thread-safe in-memory store with server-side validation (regex on vehicle no/transporter, 50-char + unsafe-char check on material). No DB used yet — data resets on app pool recycle.
- Added Content/gcv.css: Hallmark-styled shared token system (Mahindra red accent, OKLCH tokens, 4pt spacing, full interactive states) used by both pages.
- Added Scripts/buyer.js and Scripts/security.js: client validation, AJAX calls to WebMethods, safe DOM rendering (`.text()`, no `innerHTML` of user data) to avoid stored XSS.
- Security hardening: added CSP-adjacent headers (X-Content-Type-Options, X-Frame-Options, Referrer-Policy, X-XSS-Protection) and disabled ASP.NET version header in Web.config; server-side regex validation blocks HTML/script injection in free-text fields.
- Wired Buyer.aspx / Security.aspx into GreenChannelVehicles.csproj and linked from Default.aspx home page.
- Redesigned Security cards: removed the colored left accent border (AI-slop pattern), replaced badges with a quieter status-tag (pulsing dot for Pending, checkmark for Inside, muted card background once inside).
- Security dashboard is now live: polling dropped to 3s, newly-arrived vehicles get a highlight glow + toast ("New vehicle · <plate>") instead of silently appearing.
- Added a search box (top-right of Security toolbar) filtering by vehicle no / transporter / material, with match highlighting and a dedicated "no matches" empty state.
- Buyer form: Vehicle no / Transporter / Material are the only mandatory fields (marked with *); Without PCS / Manual PCS are now optional and shown side by side in a two-column row.
- Backend (VehicleGateStore, Buyer.aspx.cs) updated: WithoutPCS is now nullable and no longer enforced server-side, matching the relaxed validation.
- Added App_Data/schema.sql: MySQL schema (gcv_db.vehicle_entries table matching VehicleEntry fields) + least-privilege app user. Not wired into the app yet — DB access wasn't available in this environment, app still runs on the in-memory VehicleGateStore.
- Built the app (no Visual Studio/MSBuild web targets installed) and ran it via IIS Express on http://localhost:8080 — Default/Buyer/Security all return 200.
- Fixed Security dashboard toolbar: stat chips (Live/Pending/Inside) + search bar now stay right-aligned instead of drifting to center when wrapping on mid-width screens.
