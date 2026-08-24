using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;

namespace GreenChannelVehicles
{
    public partial class Security : Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod(EnableSession = false)]
        public static object GetVehicles()
        {
            var list = VehicleGateStore.GetAll().Select(e => new
            {
                id = e.Id,
                vehicleNo = e.VehicleNo,
                transporter = e.Transporter,
                buyerName = e.BuyerName,
                token = e.Token,
                withoutPCS = e.WithoutPCS,
                manualPCS = e.ManualPCS,
                material = e.Material,
                submittedAt = e.SubmittedAt.ToString("dd MMM, hh:mm tt"),
                isInside = e.IsInside,
                insideAt = e.InsideAt.HasValue ? e.InsideAt.Value.ToString("dd MMM, hh:mm tt") : null
            }).ToList();

            return new
            {
                success = true,
                vehicles = list,
                pending = list.Count(v => !v.isInside),
                inside = list.Count(v => v.isInside)
            };
        }

        [WebMethod(EnableSession = false)]
        public static object MarkVehicleInside(string id)
        {
            try
            {
                var entry = VehicleGateStore.MarkInside(id);
                return new
                {
                    success = true,
                    id = entry.Id,
                    insideAt = entry.InsideAt.Value.ToString("dd MMM, hh:mm tt")
                };
            }
            catch (ArgumentException ex)
            {
                return new { success = false, message = ex.Message };
            }
        }
    }
}
