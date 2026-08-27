using System;
using System.Linq;
using System.Web.Services;
using System.Web.UI;

namespace GreenChannelVehicles
{
    public partial class GateWatch : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod(EnableSession = false)]
        public static object GetPendingVehicles()
        {
            try
            {
                var pgNames = PlantMasterStore.GetPGList().ToDictionary(p => p.Id, p => p.Name);

                var vehicles = VehicleGateStore.GetAll()
                    .Where(v => !v.IsInside)
                    .Select(v => new
                    {
                        vehicleNo = v.VehicleNo,
                        transporter = v.Transporter,
                        pgName = pgNames.ContainsKey(v.PgId) ? pgNames[v.PgId] : null,
                        withoutPcs = v.WithoutPCS
                    })
                    .ToList();

                return new { success = true, vehicles };
            }
            catch
            {
                return new { success = false, message = "Could not load gate feed.", vehicles = new object[0] };
            }
        }
    }
}
