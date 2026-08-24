(function () {
    'use strict';

    var POLL_MS = 8000;
    var $grid = $('#cardGrid');
    var $empty = $('#emptyState');
    var $errorBanner = $('#errorBanner');
    var template = document.getElementById('cardTemplate').innerHTML;
    var pollTimer = null;
    var busyIds = {};

    function buildCard(v) {
        var $card = $($.parseHTML(template.trim()));
        $card.attr('data-id', v.id);
        $card.toggleClass('is-inside', v.isInside);

        $card.find('.v-card__plate').text(v.vehicleNo);

        var $badge = $card.find('.badge');
        if (v.isInside) {
            $badge.addClass('badge-inside').text('Inside');
        } else {
            $badge.addClass('badge-pending').text('Pending');
        }

        $card.find('[data-f="transporter"]').text(v.transporter);
        $card.find('[data-f="withoutPCS"]').text(v.withoutPCS ? 'Yes' : 'No');
        $card.find('[data-f="manualPCS"]').text(v.withoutPCS ? 'N/A' : (v.manualPCS ? 'Yes' : 'No'));
        $card.find('[data-f="material"]').text(v.material);

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
        $grid.empty();
        if (!vehicles.length) {
            $empty.show();
            return;
        }
        $empty.hide();
        vehicles.forEach(function (v) {
            $grid.append(buildCard(v));
        });
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

    $('#refreshBtn').on('click', function () { refresh(true); });

    refresh(true);
    pollTimer = setInterval(function () { refresh(false); }, POLL_MS);

    $(window).on('beforeunload', function () {
        if (pollTimer) clearInterval(pollTimer);
    });
})();
