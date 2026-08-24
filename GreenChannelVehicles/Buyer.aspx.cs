using System;
using System.Linq;
using System.Web.Services;
using System.Web.UI;

namespace GreenChannelVehicles
{
    public partial class Buyer : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod(EnableSession = false)]
        public static object SubmitVehicle(string vehicleNo, string transporter, string buyerName, string token, bool? withoutPCS, bool? manualPCS, string material, int pgId)
        {
            try
            {
                var entry = VehicleGateStore.Add(vehicleNo, transporter, buyerName, token, withoutPCS, manualPCS, material, pgId);
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

        [WebMethod(EnableSession = false)]
        public static object GetPGList()
        {
            try
            {
                var list = PlantMasterStore.GetPGList()
                    .Select(p => new { id = p.Id, name = p.Name })
                    .ToList();
                return new { success = true, items = list };
            }
            catch
            {
                return new { success = false, message = "Could not load PG list.", items = new object[0] };
            }
        }
    }
}
