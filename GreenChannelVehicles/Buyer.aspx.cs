using System;
using System.Web.Services;
using System.Web.UI;

namespace GreenChannelVehicles
{
    public partial class Buyer : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod(EnableSession = false)]
        public static object SubmitVehicle(string vehicleNo, string transporter, string buyerName, string token, bool? withoutPCS, bool? manualPCS, string material)
        {
            try
            {
                var entry = VehicleGateStore.Add(vehicleNo, transporter, buyerName, token, withoutPCS, manualPCS, material);
                return new
                {
                    success = true,
                    id = entry.Id,
                    vehicleNo = entry.VehicleNo,
                    transporter = entry.Transporter,
                    buyerName = entry.BuyerName,
                    token = entry.Token,
                    withoutPCS = entry.WithoutPCS,
                    manualPCS = entry.ManualPCS,
                    material = entry.Material,
                    submittedAt = entry.SubmittedAt.ToString("dd MMM yyyy, hh:mm tt")
                };
            }
            catch (ArgumentException ex)
            {
                return new { success = false, message = ex.Message };
            }
            catch
            {
                return new { success = false, message = "Could not submit entry. Please try again." };
            }
        }
    }
}
