<%@ Page Title="Buyer -Green Channel" Language="C#" AutoEventWireup="true" CodeBehind="Buyer.aspx.cs" Inherits="GreenChannelVehicles.Buyer" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Buyer -Green Channel Vehicles</title>
    <link href="Content/gcv.css" rel="stylesheet" />
</head>
<body>
    <header class="topbar">
        <div class="topbar__identity">
            <div class="topbar__mark" aria-hidden="true">GC</div>
            <div class="topbar__text">
                <div class="topbar__title">Green Channel Vehicles</div>
                <div class="topbar__subtitle">Buyer -Gate Entry Request</div>
            </div>
        </div>
        <img class="topbar__logo" src="mahindra-rise.png" alt="Mahindra Rise" />
    </header>

    <main class="shell" style="max-width: 640px;">
        <div class="page-head">
            <h1>Raise a critical vehicle entry</h1>
            <p>Submit vehicle details for a critical-material vehicle. Security at the gate is notified immediately once you submit.</p>
        </div>

        <div id="formPanel" class="surface form-card">
            <div id="errorBanner" class="banner banner-error" style="display:none;" role="alert"></div>

            <form id="vehicleForm" novalidate>
                <div class="field" id="fieldVehicleNo">
                    <label for="vehicleNo">Vehicle number</label>
                    <input type="text" id="vehicleNo" maxlength="15" autocomplete="off" placeholder="e.g. MH12AB1234" />
                    <p class="error-msg">Enter a valid vehicle number (4-15 letters/digits).</p>
                </div>

                <div class="field" id="fieldTransporter">
                    <label for="transporter">Transporter</label>
                    <input type="text" id="transporter" maxlength="60" autocomplete="off" placeholder="Transporter name" />
                    <p class="error-msg">Enter the transporter name.</p>
                </div>

                <div class="field" id="fieldWithoutPCS">
                    <fieldset>
                        <legend>Without PCS</legend>
                        <div class="toggle-group" id="withoutPCSGroup">
                            <div class="toggle-option">
                                <input type="radio" name="withoutPCS" id="withoutPCSYes" value="yes" />
                                <label for="withoutPCSYes">Yes</label>
                            </div>
                            <div class="toggle-option">
                                <input type="radio" name="withoutPCS" id="withoutPCSNo" value="no" />
                                <label for="withoutPCSNo">No</label>
                            </div>
                        </div>
                    </fieldset>
                    <p class="hint">Selecting "Yes" disables Manual PCS below.</p>
                </div>

                <div class="field" id="fieldManualPCS">
                    <fieldset>
                        <legend>Manual PCS</legend>
                        <div class="toggle-group" id="manualPCSGroup">
                            <div class="toggle-option">
                                <input type="radio" name="manualPCS" id="manualPCSYes" value="yes" />
                                <label for="manualPCSYes">Yes</label>
                            </div>
                            <div class="toggle-option">
                                <input type="radio" name="manualPCS" id="manualPCSNo" value="no" />
                                <label for="manualPCSNo">No</label>
                            </div>
                        </div>
                    </fieldset>
                    <p class="error-msg">Select Manual PCS status.</p>
                </div>

                <div class="field" id="fieldMaterial">
                    <label for="material">Material details</label>
                    <input type="text" id="material" maxlength="50" autocomplete="off" placeholder="What is the vehicle carrying?" />
                    <div class="char-count"><span id="materialCount">0</span>/50</div>
                    <p class="error-msg">Enter material details (up to 50 characters).</p>
                </div>

                <div style="display:flex; gap: var(--space-sm); margin-top: var(--space-xl);">
                    <button type="submit" class="btn btn-primary btn-block" id="submitBtn">Submit to gate</button>
                    <button type="button" class="btn btn-secondary" id="resetBtn">Reset</button>
                </div>
            </form>
        </div>

        <div id="successPanel" class="surface success-panel" style="display:none;">
            <div class="success-panel__icon">&#10003;</div>
            <h2>Sent to security gate</h2>
            <p>This entry is on its way to the gate and cannot be edited or reversed.</p>
            <dl class="receipt" id="receipt"></dl>
            <button type="button" class="btn btn-primary" id="newEntryBtn">Raise another entry</button>
        </div>
    </main>

    <div class="modal-scrim" id="confirmScrim">
        <div class="modal" role="dialog" aria-modal="true" aria-labelledby="confirmTitle">
            <h2 id="confirmTitle">Send to security gate?</h2>
            <p>Security will be alerted immediately for this vehicle. Once sent, this entry cannot be edited or reversed.</p>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" id="confirmCancel">Cancel</button>
                <button type="button" class="btn btn-primary" id="confirmOk">Yes, send it</button>
            </div>
        </div>
    </div>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script src="Scripts/buyer.js"></script>
</body>
</html>
