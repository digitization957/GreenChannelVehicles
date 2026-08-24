(function () {
    'use strict';

    var VEHICLE_RE = /^[A-Za-z0-9\- ]{4,15}$/;
    var TRANSPORTER_RE = /^[A-Za-z0-9&.,\- ]{2,60}$/;
    var UNSAFE_RE = /[<>"']/;

    var $form = $('#vehicleForm');
    var $manualGroup = $('#manualPCSGroup');
    var $manualField = $('#fieldManualPCS');
    var $material = $('#material');
    var $submitBtn = $('#submitBtn');
    var $errorBanner = $('#errorBanner');

    function updateManualPCSState() {
        var withoutVal = $('input[name="withoutPCS"]:checked').val();
        var disabled = withoutVal === 'yes';
        $manualGroup.find('input').prop('disabled', disabled);
        $manualGroup.toggleClass('is-disabled', disabled);
        if (disabled) {
            $('input[name="manualPCS"]').prop('checked', false);
            $manualField.removeClass('has-error');
        }
    }

    $('input[name="withoutPCS"]').on('change', updateManualPCSState);
    updateManualPCSState();

    $material.on('input', function () {
        $('#materialCount').text($material.val().length);
    });

    function clearErrors() {
        $('.field').removeClass('has-error');
        $errorBanner.hide().text('');
    }

    function validate() {
        clearErrors();
        var ok = true;

        var vehicleNo = $('#vehicleNo').val().trim();
        if (!VEHICLE_RE.test(vehicleNo)) {
            $('#fieldVehicleNo').addClass('has-error');
            ok = false;
        }

        var transporter = $('#transporter').val().trim();
        if (!TRANSPORTER_RE.test(transporter)) {
            $('#fieldTransporter').addClass('has-error');
            ok = false;
        }

        var material = $material.val().trim();
        if (material.length < 1 || material.length > 50 || UNSAFE_RE.test(material)) {
            $('#fieldMaterial').addClass('has-error');
            ok = false;
        }

        return ok;
    }

    function collectPayload() {
        var withoutValRaw = $('input[name="withoutPCS"]:checked').val();
        var withoutVal = withoutValRaw ? withoutValRaw === 'yes' : null;
        var manualValRaw = $('input[name="manualPCS"]:checked').val();
        var manualVal = withoutVal === true ? null : (manualValRaw ? manualValRaw === 'yes' : null);
        return {
            vehicleNo: $('#vehicleNo').val().trim(),
            transporter: $('#transporter').val().trim(),
            withoutPCS: withoutVal,
            manualPCS: manualVal,
            material: $material.val().trim()
        };
    }

    $form.on('submit', function (e) {
        e.preventDefault();
        if (!validate()) return;
        $('#confirmScrim').addClass('is-open');
    });

    $('#confirmCancel').on('click', function () {
        $('#confirmScrim').removeClass('is-open');
    });

    $('#confirmScrim').on('click', function (e) {
        if (e.target === this) $(this).removeClass('is-open');
    });

    $('#confirmOk').on('click', function () {
        $('#confirmScrim').removeClass('is-open');
        submitEntry();
    });

    function submitEntry() {
        var payload = collectPayload();
        $submitBtn.addClass('is-loading').prop('disabled', true);

        $.ajax({
            url: 'Buyer.aspx/SubmitVehicle',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify(payload)
        }).done(function (res) {
            var data = res.d;
            if (data && data.success) {
                showSuccess(data);
            } else {
                showError((data && data.message) || 'Could not submit entry.');
            }
        }).fail(function () {
            showError('Network error. Please check connection and try again.');
        }).always(function () {
            $submitBtn.removeClass('is-loading').prop('disabled', false);
        });
    }

    function showError(msg) {
        $errorBanner.text(msg).show();
        $errorBanner[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    function pcsLabel(v) {
        return v === true ? 'Yes' : v === false ? 'No' : 'Not specified';
    }

    function showSuccess(data) {
        var $receipt = $('#receipt');
        $receipt.empty();
        var rows = [
            ['Vehicle number', data.vehicleNo],
            ['Transporter', data.transporter],
            ['Without PCS', pcsLabel(data.withoutPCS)],
            ['Manual PCS', data.withoutPCS === true ? 'N/A' : pcsLabel(data.manualPCS)],
            ['Material', data.material],
            ['Submitted', data.submittedAt]
        ];
        rows.forEach(function (r) {
            $receipt.append($('<dt>').text(r[0]));
            $receipt.append($('<dd>').text(r[1]));
        });

        $('#formPanel').hide();
        $('#successPanel').show();
        $('#successPanel')[0].scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    $('#resetBtn').on('click', function () {
        $form[0].reset();
        $('#materialCount').text('0');
        clearErrors();
        updateManualPCSState();
    });

    $('#newEntryBtn').on('click', function () {
        $form[0].reset();
        $('#materialCount').text('0');
        clearErrors();
        updateManualPCSState();
        $('#successPanel').hide();
        $('#formPanel').show();
    });
})();
