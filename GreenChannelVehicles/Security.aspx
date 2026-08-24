<%@ Page Title="Security -Green Channel" Language="C#" AutoEventWireup="true" CodeBehind="Security.aspx.cs" Inherits="GreenChannelVehicles.Security" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Security -Green Channel Vehicles</title>
    <link href="Content/gcv.css" rel="stylesheet" />
</head>
<body>
    <header class="topbar">
        <div class="topbar__identity">
            <div class="topbar__mark" aria-hidden="true">GC</div>
            <div class="topbar__text">
                <div class="topbar__title">Green Channel Vehicles</div>
                <div class="topbar__subtitle">Security -Gate Watch</div>
            </div>
        </div>
        <img class="topbar__logo" src="mahindra-rise.png" alt="Mahindra Rise" />
    </header>

    <main class="shell">
        <div class="dash-toolbar">
            <div class="page-head" style="margin-bottom:0;">
                <h1>Incoming critical vehicles</h1>
                <p>Vehicles flagged by buyers for priority gate entry appear here in real time.</p>
            </div>
            <div class="stat-row">
                <div class="stat-chip"><span class="live-dot" aria-hidden="true"></span>&nbsp;<span>Live</span></div>
                <div class="stat-chip"><strong id="pendingCount">0</strong><span>Pending</span></div>
                <div class="stat-chip"><strong id="insideCount">0</strong><span>Inside</span></div>
                <div class="search-box" id="searchBox">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" id="searchInput" placeholder="Search vehicle, transporter, material" aria-label="Search vehicles" autocomplete="off" />
                    <button type="button" class="clear-btn" id="clearSearch" aria-label="Clear search">&times;</button>
                </div>
            </div>
        </div>

        <div id="errorBanner" class="banner banner-error" style="display:none;" role="alert"></div>

        <div id="cardGrid" class="card-grid" aria-live="polite"></div>

        <div id="emptyState" class="empty-state" style="display:none;">
            <div class="display" id="emptyTitle">No vehicles yet</div>
            <p id="emptyBody">Entries submitted by buyers will show up here automatically.</p>
        </div>
    </main>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>

    <script id="cardTemplate" type="text/x-template">
        <article class="v-card" data-id="">
            <div class="v-card__head">
                <div class="v-card__plate"></div>
                <span class="v-card__status"></span>
            </div>
            <div class="v-card__rows">
                <div class="v-card__row"><span class="k">Transporter</span><span class="v" data-f="transporter"></span></div>
                <div class="v-card__row"><span class="k">Without PCS</span><span class="v" data-f="withoutPCS"></span></div>
                <div class="v-card__row"><span class="k">Manual PCS</span><span class="v" data-f="manualPCS"></span></div>
            </div>
            <div class="v-card__material" data-f="material"></div>
            <div class="v-card__meta" data-f="meta"></div>
            <button type="button" class="btn btn-primary btn-block" data-action="inside">Mark inside gate</button>
        </article>
    </script>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script src="Scripts/security.js"></script>
</body>
</html>
