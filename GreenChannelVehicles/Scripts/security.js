(function () {
    'use strict';

    var POLL_MS = 3000;
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
    var seenIds = {};
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
            v.material.toLowerCase().indexOf(term) !== -1;
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

    function buildCard(v, term, isNew) {
        var $card = $($.parseHTML(template.trim()));
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
        $card.find('[data-f="withoutPCS"]').text(pcsLabel(v.withoutPCS));
        $card.find('[data-f="manualPCS"]').text(v.withoutPCS === true ? 'N/A' : pcsLabel(v.manualPCS));
        $card.find('[data-f="material"]').empty().append(highlightText(v.material, term));

        var meta = 'Submitted ' + v.submittedAt;
        if (v.isInside && v.insideAt) meta += ' - Inside at ' + v.insideAt;
        $card.find('[data-f="meta"]').text(meta);

        var $btn = $card.find('[data-action="inside"]');
        if (v.isInside) {
            $btn.remove();
        } else {
            $btn.on('click', function () { markInside(v.id, $card); });
            if (busyIds[v.id]) $btn.addClass('is-loading').prop('disabled', true);
        }

        return $card;
    }

    function render(vehicles) {
        var visible = vehicles.filter(function (v) { return matchesSearch(v, searchTerm); });
        $grid.empty();

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
            visible.forEach(function (v) {
                var isNew = !firstLoad && !seenIds[v.id];
                $grid.append(buildCard(v, searchTerm, isNew));
                if (isNew) showToast(v);
            });
        }

        vehicles.forEach(function (v) { seenIds[v.id] = true; });
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

    function markInside(id, $card) {
        busyIds[id] = true;
        var $btn = $card.find('[data-action="inside"]');
        $btn.addClass('is-loading').prop('disabled', true);

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
        });
    }

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
    pollTimer = setInterval(function () { refresh(false); }, POLL_MS);

    $(window).on('beforeunload', function () {
        if (pollTimer) clearInterval(pollTimer);
    });
})();
