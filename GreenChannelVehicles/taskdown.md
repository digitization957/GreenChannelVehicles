# Taskdown

- Added Buyer.aspx (gate entry form: vehicle no, transporter, Without PCS / Manual PCS toggle logic, 50-char material field, submit confirmation modal, success receipt) with Buyer.aspx.cs WebMethod `SubmitVehicle`.
- Added Security.aspx (live card dashboard, auto-refresh polling, "Vehicle is inside gate" action) with Security.aspx.cs WebMethods `GetVehicles` / `MarkVehicleInside`.
- Added VehicleGateStore.cs: thread-safe in-memory store with server-side validation (regex on vehicle no/transporter, 50-char + unsafe-char check on material). No DB used yet — data resets on app pool recycle.
- Added Content/gcv.css: Hallmark-styled shared token system (Mahindra red accent, OKLCH tokens, 4pt spacing, full interactive states) used by both pages.
- Added Scripts/buyer.js and Scripts/security.js: client validation, AJAX calls to WebMethods, safe DOM rendering (`.text()`, no `innerHTML` of user data) to avoid stored XSS.
- Security hardening: added CSP-adjacent headers (X-Content-Type-Options, X-Frame-Options, Referrer-Policy, X-XSS-Protection) and disabled ASP.NET version header in Web.config; server-side regex validation blocks HTML/script injection in free-text fields.
- Wired Buyer.aspx / Security.aspx into GreenChannelVehicles.csproj and linked from Default.aspx home page.
