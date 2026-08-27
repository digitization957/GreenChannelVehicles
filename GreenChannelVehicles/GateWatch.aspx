<%@ Page Title="Gate Watch -Green Channel" Language="C#" AutoEventWireup="true" CodeBehind="GateWatch.aspx.cs" Inherits="GreenChannelVehicles.GateWatch" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Gate Watch</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@500;600&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; }
  html, body {
    margin: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    user-select: none;
    -webkit-user-select: none;
  }

  /* ---------- board tokens (same design as kiosk) ---------- */
  body {
    --p: oklch(98% 0.004 85);
    --p2: oklch(100% 0 0);
    --p3: oklch(95.5% 0.006 85);
    --ink: oklch(20% 0.012 260);
    --ink-dim: oklch(46% 0.012 260);
    --red: oklch(52% 0.19 27);
    --plate-yellow: oklch(84% 0.16 92);
    --plate-border: oklch(16% 0 0);
    --plate-blue: oklch(38% 0.13 260);

    background: var(--p);
    color: var(--ink);
    font-family: 'Inter', sans-serif;
  }

  .board { display: flex; flex-direction: column; height: 100vh; width: 100vw; }

  .bd-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1.04% 2.2%;
    border-bottom: 2px solid var(--red);
    flex-shrink: 0;
  }
  img.bd-logo { height: clamp(16px, 2.6vw, 30px); width: auto; display: block; flex-shrink: 0; }

  .bd-cols {
    display: grid;
    grid-template-columns: 34% 26% 24% 16%;
    background: var(--red);
    padding: 0.7% 2.2%;
    font-size: clamp(0.75rem, 1.5vw, 1.05rem);
    font-weight: 700;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: white;
    flex-shrink: 0;
  }
  .bd-rows { flex: 1; overflow: hidden; display: flex; flex-direction: column; padding-top: 0.6%; }
  .bd-row {
    display: grid;
    grid-template-columns: 34% 26% 24% 16%;
    align-items: center;
    padding: 1.4% 2.2%;
    font-size: clamp(0.6rem, 1.25vw, 0.92rem);
  }
  .bd-row:nth-child(odd) { background: var(--p2); }
  .bd-row:nth-child(even) { background: var(--p3); }
  .bd-row .c { padding-right: 0.6em; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

  .bd-plate {
    display: inline-flex;
    align-items: stretch;
    background: var(--plate-yellow);
    border: 2px solid var(--plate-border);
    border-radius: 5px;
    overflow: hidden;
    box-shadow: 0 1px 0 oklch(100% 0 0 / 0.5) inset, 0 2px 4px oklch(20% 0 0 / 0.18);
  }
  .bd-plate .ind {
    background: var(--plate-blue);
    color: white;
    font-family: 'Inter', sans-serif;
    font-weight: 700;
    font-size: clamp(0.4rem, 0.85vw, 0.6rem);
    letter-spacing: 0.02em;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 0.5em;
    border-right: 1px solid var(--plate-border);
  }
  .bd-plate .num {
    font-family: 'Space Grotesk', sans-serif;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    font-size: clamp(1rem, 2.6vw, 1.9rem);
    letter-spacing: 0.03em;
    color: var(--plate-border);
    padding: 0.12em 0.5em 0.12em 0.4em;
  }

  .bd-transporter {
    font-family: 'Space Grotesk', sans-serif;
    font-weight: 600;
    font-size: clamp(1.1rem, 2.3vw, 1.7rem);
    letter-spacing: 0.005em;
  }
  .bd-pg {
    font-family: 'Space Grotesk', sans-serif;
    font-weight: 500;
    font-size: clamp(0.95rem, 2vw, 1.45rem);
  }
  .bd-pcs {
    font-family: 'Space Grotesk', sans-serif;
    font-weight: 600;
    font-size: clamp(0.95rem, 2vw, 1.45rem);
    text-align: center;
  }
  .bd-cols > div:nth-child(4) { text-align: center; }

  .bd-foot {
    flex-shrink: 0;
    background: var(--red);
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.35% 2.2%;
  }
  .bd-foot-count {
    font-family: 'Inter', sans-serif;
    font-weight: 600;
    font-size: clamp(0.55rem, 1vw, 0.78rem);
    letter-spacing: 0.02em;
  }
  .bd-foot-count strong { font-family: 'JetBrains Mono', monospace; font-variant-numeric: tabular-nums; }
  .bd-foot-time { display: flex; align-items: baseline; gap: 0.6em; }
  .bd-foot-clock { font-family: 'JetBrains Mono', monospace; font-weight: 700; font-size: clamp(0.6rem, 1.25vw, 0.9rem); font-variant-numeric: tabular-nums; }
  .bd-foot-date { font-size: clamp(0.5rem, 0.9vw, 0.68rem); opacity: 0.85; }

  .bd-empty {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--ink-dim);
    font-family: 'Space Grotesk', sans-serif;
    font-size: clamp(1rem, 2.4vw, 1.7rem);
    text-align: center;
  }

  .bd-error {
    position: fixed;
    left: 2.2%;
    bottom: calc(2.2% + 3em);
    background: var(--plate-border);
    color: white;
    font-family: 'JetBrains Mono', monospace;
    font-size: clamp(0.5rem, 1vw, 0.7rem);
    padding: 0.5em 0.9em;
    border-radius: 5px;
    opacity: 0.85;
    display: none;
  }
  .bd-error.is-visible { display: block; }

  .bd-fs-hint {
    position: fixed;
    right: 2.2%;
    bottom: calc(2.2% + 3em);
    background: var(--ink);
    color: white;
    font-family: 'JetBrains Mono', monospace;
    font-size: clamp(0.5rem, 1vw, 0.7rem);
    padding: 0.5em 0.9em;
    border-radius: 5px;
    opacity: 0.85;
    cursor: pointer;
    display: none;
  }
  .bd-fs-hint.is-visible { display: block; }
</style>
</head>
<body>
  <div class="board">
    <div class="bd-head">
      <img class="bd-logo" src="gclogo.webp" alt="Green Channel" />
      <img class="bd-logo" src="mahindra-rise.png" alt="Mahindra Rise" />
    </div>

    <div class="bd-cols">
      <div>Vehicle No</div><div>Transporter</div><div>Receiving PG</div><div>Without PCS</div>
    </div>

    <div class="bd-rows" id="rows"></div>
    <div class="bd-empty" id="emptyState" style="display:none;">No vehicles pending</div>

    <div class="bd-foot">
      <div class="bd-foot-count"><strong id="pendingCount">0</strong> pending</div>
      <div class="bd-foot-time">
        <div class="bd-foot-clock" data-clock>00:00:00</div>
        <div class="bd-foot-date" data-date></div>
      </div>
    </div>
  </div>

  <div class="bd-error" id="errorBanner"></div>
  <div class="bd-fs-hint" id="fsHint">Click anywhere for full screen</div>

  <script id="rowTemplate" type="text/x-template">
    <div class="bd-row">
      <div class="c"><span class="bd-plate"><span class="ind">IND</span><span class="num" data-f="plate"></span></span></div>
      <div class="c bd-transporter" data-f="transporter"></div>
      <div class="c bd-pg" data-f="pgName"></div>
      <div class="c bd-pcs" data-f="withoutPcs"></div>
    </div>
  </script>

  <script src="Scripts/jquery-3.7.0.min.js"></script>
  <script>
    (function () {
      var $rows = document.getElementById('rows');
      var $empty = document.getElementById('emptyState');
      var $error = document.getElementById('errorBanner');
      var $pendingCount = document.getElementById('pendingCount');
      var $fsHint = document.getElementById('fsHint');
      var template = document.getElementById('rowTemplate').innerHTML;

      var POLL_MS = 3000;

      function formatPlate(raw) {
        var s = String(raw || '').replace(/\s+/g, '').toUpperCase();
        if (s.length <= 2) return s;
        if (s.length <= 4) return s.slice(0, 2) + ' ' + s.slice(2);
        return s.slice(0, 2) + ' ' + s.slice(2, 4) + ' ' + s.slice(4);
      }

      function pcsLabel(v) {
        return v === true || v === 1 ? 'Yes' : v === false || v === 0 ? 'No' : '—';
      }

      // ---- Auto-scroll: slow continuous top-to-bottom loop, only while rows overflow ----
      var SCROLL_SPEED_PX_PER_SEC = 28;
      var SCROLL_PAUSE_MS = 1400;
      var scrollLoopActive = false;
      var scrollLoopToken = 0;

      function maxScrollTop() {
        return Math.max(0, $rows.scrollHeight - $rows.clientHeight);
      }

      function animateScrollTop(toTop, duration, token, onDone) {
        var fromTop = $rows.scrollTop;
        var startTime = null;
        function step(ts) {
          if (token !== scrollLoopToken) return;
          if (startTime === null) startTime = ts;
          var t = duration <= 0 ? 1 : Math.min(1, (ts - startTime) / duration);
          var cappedTarget = Math.min(toTop, maxScrollTop());
          $rows.scrollTop = fromTop + (cappedTarget - fromTop) * t;
          if (t < 1) {
            requestAnimationFrame(step);
          } else if (onDone) {
            onDone();
          }
        }
        requestAnimationFrame(step);
      }

      function runScrollLoop(token) {
        if (token !== scrollLoopToken) return;
        var distance = maxScrollTop();
        if (distance <= 0) {
          scrollLoopActive = false;
          return;
        }
        var duration = (distance / SCROLL_SPEED_PX_PER_SEC) * 1000;
        animateScrollTop(distance, duration, token, function () {
          if (token !== scrollLoopToken) return;
          setTimeout(function () {
            if (token !== scrollLoopToken) return;
            $rows.scrollTop = 0;
            setTimeout(function () { runScrollLoop(token); }, SCROLL_PAUSE_MS);
          }, SCROLL_PAUSE_MS);
        });
      }

      function syncAutoScroll() {
        var overflowing = maxScrollTop() > 0;
        if (overflowing && !scrollLoopActive) {
          scrollLoopActive = true;
          scrollLoopToken += 1;
          $rows.scrollTop = 0;
          runScrollLoop(scrollLoopToken);
        } else if (!overflowing && scrollLoopActive) {
          scrollLoopActive = false;
          scrollLoopToken += 1;
          $rows.scrollTop = 0;
        }
      }

      function render(vehicles) {
        $rows.innerHTML = '';
        $pendingCount.textContent = vehicles.length;
        if (!vehicles.length) {
          $empty.style.display = '';
          scrollLoopActive = false;
          scrollLoopToken += 1;
          $rows.scrollTop = 0;
          return;
        }
        $empty.style.display = 'none';
        vehicles.forEach(function (v) {
          var $row = document.createElement('div');
          $row.innerHTML = template.trim();
          var $node = $row.firstElementChild;
          $node.querySelector('[data-f="plate"]').textContent = formatPlate(v.vehicleNo);
          $node.querySelector('[data-f="transporter"]').textContent = v.transporter;
          $node.querySelector('[data-f="pgName"]').textContent = v.pgName || '—';
          $node.querySelector('[data-f="withoutPcs"]').textContent = pcsLabel(v.withoutPcs);
          $rows.appendChild($node);
        });
        requestAnimationFrame(syncAutoScroll);
      }

      function showError(msg) {
        $error.textContent = msg;
        $error.classList.add('is-visible');
      }
      function clearError() {
        $error.classList.remove('is-visible');
      }

      var pollTimer = null;
      function poll() {
        $.ajax({
          url: 'GateWatch.aspx/GetPendingVehicles',
          type: 'POST',
          contentType: 'application/json; charset=utf-8',
          dataType: 'json',
          data: '{}'
        }).done(function (res) {
          var data = res && res.d ? res.d : res;
          if (data && data.success) {
            clearError();
            render(data.vehicles || []);
          } else {
            showError('Data feed error: ' + (data && data.message ? data.message : 'unknown'));
          }
        }).fail(function () {
          showError('Reconnecting to gate feed...');
        }).always(function () {
          pollTimer = setTimeout(poll, POLL_MS);
        });
      }
      poll();

      function tick() {
        var now = new Date();
        var time = [now.getHours(), now.getMinutes(), now.getSeconds()]
          .map(function (n) { return String(n).padStart(2, '0'); })
          .join(':');
        var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var date = now.getDate() + ' ' + months[now.getMonth()] + ' ' + now.getFullYear();
        document.querySelectorAll('[data-clock]').forEach(function (el) { el.textContent = time; });
        document.querySelectorAll('[data-date]').forEach(function (el) { el.textContent = date; });
      }
      tick();
      setInterval(tick, 1000);

      document.addEventListener('contextmenu', function (e) { e.preventDefault(); });

      // ---- Auto full screen (browsers require a user gesture; try immediately, then arm a click/key fallback) ----
      function isFullscreen() {
        return !!(document.fullscreenElement || document.webkitFullscreenElement || document.msFullscreenElement);
      }
      function requestFs() {
        var el = document.documentElement;
        var req = el.requestFullscreen || el.webkitRequestFullscreen || el.msRequestFullscreen;
        if (req) {
          try { req.call(el).catch(function () {}); } catch (e) {}
        }
      }
      function armFallback() {
        if (isFullscreen()) { $fsHint.classList.remove('is-visible'); return; }
        $fsHint.classList.add('is-visible');
        function onGesture() {
          requestFs();
        }
        document.addEventListener('click', onGesture, { once: true });
        document.addEventListener('keydown', onGesture, { once: true });
      }
      document.addEventListener('fullscreenchange', function () {
        if (isFullscreen()) $fsHint.classList.remove('is-visible');
        else armFallback();
      });
      requestFs();
      setTimeout(armFallback, 300);
    })();
  </script>
</body>
</html>
