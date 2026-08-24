(function () {
    'use strict';

    var POLL_MS = 10000;
    var $grid = $('#cardGrid');
    var $empty = $('#emptyState');
    var $emptyTitle = $('#emptyTitle');
    var $emptyBody = $('#emptyBody');
    var $errorBanner = $('#errorBanner');
    var $searchBox = $('#searchBox');
    var $searchInput = $('#searchInput');
    var $toastStack = $('#toastStack');
    var template = document.getElementById('cardTemplate').innerHTML;
    var pollTimer = null;
    var busyIds = {};
    var cardsById = {};
    var firstLoad = true;
    var searchTerm = '';

    var CHECK_ICON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>';

    function pcsLabel(v) {
        return v === true ? 'Yes' : v === false ? 'No' : 'Not specified';
    }

    function highlightText(text, term) {
        text = text == null ? '' : String(text);
        if (!term) return document.createTextNode(text);
        var idx = text.toLowerCase().indexOf(term.toLowerCase());
        if (idx === -1) return document.createTextNode(text);
        var frag = document.createDocumentFragment();
        frag.appendChild(document.createTextNode(text.slice(0, idx)));
        var mark = document.createElement('mark');
        mark.textContent = text.slice(idx, idx + term.length);
        frag.appendChild(mark);
        frag.appendChild(document.createTextNode(text.slice(idx + term.length)));
        return frag;
    }

    function matchesSearch(v, term) {
        if (!term) return true;
        term = term.toLowerCase();
        return v.vehicleNo.toLowerCase().indexOf(term) !== -1 ||
            v.transporter.toLowerCase().indexOf(term) !== -1 ||
            v.material.toLowerCase().indexOf(term) !== -1 ||
            (v.buyerName || '').toLowerCase().indexOf(term) !== -1 ||
            (v.token || '').toLowerCase().indexOf(term) !== -1;
    }

    function showToast(v) {
        var $toast = $('<div class="toast"></div>');
        $toast.append(document.createTextNode('New vehicle · '));
        $toast.append($('<strong>').text(v.vehicleNo));
        $toastStack.append($toast);
        setTimeout(function () {
            $toast.addClass('is-leaving');
            setTimeout(function () { $toast.remove(); }, 250);
        }, 3200);
    }

    // Fills (or refreshes) a card's content in place. Never recreates the DOM
    // node, so an already-rendered card just patches text on each poll instead
    // of flickering / losing hover-focus-scroll state.
    function fillCard($card, v, term, isNew) {
        $card.attr('data-id', v.id);
        $card.toggleClass('is-inside', v.isInside);
        if (isNew) $card.addClass('is-new');

        $card.find('.v-card__plate').empty().append(highlightText(v.vehicleNo, term));

        var $status = $card.find('.v-card__status');
        if (v.isInside) {
            $status.attr('class', 'v-card__status status-tag is-inside').html(CHECK_ICON + ' Inside');
        } else {
            $status.attr('class', 'v-card__status status-tag is-pending').html('<span class="dot"></span> Pending');
        }

        $card.find('[data-f="transporter"]').empty().append(highlightText(v.transporter, term));
        $card.find('[data-f="buyerName"]').empty().append(highlightText(v.buyerName, term));
        $card.find('[data-f="token"]').empty().append(highlightText(v.token, term));
        $card.find('[data-f="withoutPCS"]').text(pcsLabel(v.withoutPCS));
        $card.find('[data-f="manualPCS"]').text(v.withoutPCS === true ? 'N/A' : pcsLabel(v.manualPCS));
        $card.find('[data-f="material"]').empty().append(highlightText(v.material, term));

        var meta = 'Submitted ' + v.submittedAt;
        if (v.isInside && v.insideAt) meta += ' - Inside at ' + v.insideAt;
        $card.find('[data-f="meta"]').text(meta);

        var $btn = $card.find('[data-action="inside"]');
        if (v.isInside) {
            $btn.remove();
        } else if ($btn.length) {
            $btn.toggleClass('is-loading', !!busyIds[v.id]).prop('disabled', !!busyIds[v.id]);
        }

        return $card;
    }

    function createCard(v, term, isNew) {
        var $card = $($.parseHTML(template.trim()));
        return fillCard($card, v, term, isNew);
    }

    // Reconciles the DOM against the latest vehicle list: updates cards that
    // are still present in place, inserts genuinely new ones, removes ones
    // that dropped out (e.g. filtered by search), and only moves a card's
    // position when the server order actually changed.
    function render(vehicles) {
        var visible = vehicles.filter(function (v) { return matchesSearch(v, searchTerm); });
        var visibleIds = {};
        visible.forEach(function (v) { visibleIds[v.id] = true; });

        Object.keys(cardsById).forEach(function (id) {
            if (!visibleIds[id]) {
                cardsById[id].remove();
                delete cardsById[id];
            }
        });

        if (!vehicles.length) {
            $empty.show();
            $emptyTitle.text('No vehicles yet');
            $emptyBody.text('Entries submitted by buyers will show up here automatically.');
        } else if (!visible.length) {
            $empty.show();
            $emptyTitle.text('No matches');
            $emptyBody.text('No vehicle, transporter or material matches "' + searchTerm + '".');
        } else {
            $empty.hide();
        }

        var $prev = null;
        visible.forEach(function (v) {
            var isNew = !cardsById[v.id];
            var $card;
            if (isNew) {
                $card = createCard(v, searchTerm, !firstLoad);
                cardsById[v.id] = $card;
                if (!firstLoad) showToast(v);
            } else {
                $card = fillCard(cardsById[v.id], v, searchTerm, false);
            }

            if ($prev === null) {
                if (!$grid.children().first().is($card)) $grid.prepend($card);
            } else if (!$prev.next().is($card)) {
                $prev.after($card);
            }
            $prev = $card;
        });

        firstLoad = false;
    }

    function refresh(showSpinnerError) {
        $.ajax({
            url: 'Security.aspx/GetVehicles',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: '{}'
        }).done(function (res) {
            var data = res.d;
            if (!data || !data.success) return;
            $errorBanner.hide();
            $('#pendingCount').text(data.pending);
            $('#insideCount').text(data.inside);
            render(data.vehicles);
        }).fail(function () {
            if (showSpinnerError) {
                $errorBanner.text('Could not refresh vehicle list. Retrying automatically.').show();
            }
        });
    }

    function startPolling() {
        if (pollTimer) return;
        pollTimer = setInterval(function () { refresh(false); }, POLL_MS);
    }

    function stopPolling() {
        if (!pollTimer) return;
        clearInterval(pollTimer);
        pollTimer = null;
    }

    // While a "mark inside" call is in flight, polling is paused so no stale
    // list can overwrite the optimistic loading state; it resumes (with an
    // immediate resync) the moment the server confirms the write.
    function markInside(id, $card) {
        busyIds[id] = true;
        var $btn = $card.find('[data-action="inside"]');
        $btn.addClass('is-loading').prop('disabled', true);
        stopPolling();

        $.ajax({
            url: 'Security.aspx/MarkVehicleInside',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({ id: id })
        }).done(function (res) {
            var data = res.d;
            delete busyIds[id];
            if (data && data.success) {
                refresh(false);
            } else {
                $btn.removeClass('is-loading').prop('disabled', false);
                $errorBanner.text((data && data.message) || 'Could not update vehicle.').show();
            }
        }).fail(function () {
            delete busyIds[id];
            $btn.removeClass('is-loading').prop('disabled', false);
            $errorBanner.text('Network error while updating vehicle.').show();
        }).always(function () {
            startPolling();
        });
    }

    $grid.on('click', '[data-action="inside"]', function () {
        var $card = $(this).closest('.v-card');
        markInside($card.attr('data-id'), $card);
    });

    $searchInput.on('input', function () {
        searchTerm = $searchInput.val().trim();
        $searchBox.toggleClass('has-value', searchTerm.length > 0);
        refresh(false);
    });

    $('#clearSearch').on('click', function () {
        $searchInput.val('');
        searchTerm = '';
        $searchBox.removeClass('has-value');
        refresh(false);
        $searchInput.trigger('focus');
    });

    refresh(true);
    startPolling();

    $(window).on('beforeunload', stopPolling);
})();
