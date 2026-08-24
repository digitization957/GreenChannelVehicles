using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace GreenChannelVehicles
{
    public class VehicleEntry
    {
        public string Id { get; set; }
        public string VehicleNo { get; set; }
        public string Transporter { get; set; }
        public string BuyerName { get; set; }
        public string Token { get; set; }
        public bool? WithoutPCS { get; set; }
        public bool? ManualPCS { get; set; }
        public string Material { get; set; }
        public DateTime SubmittedAt { get; set; }
        public bool IsInside { get; set; }
        public DateTime? InsideAt { get; set; }
    }

    public static class VehicleGateStore
    {
        private static readonly ConcurrentDictionary<string, VehicleEntry> Entries =
            new ConcurrentDictionary<string, VehicleEntry>();

        private static readonly Regex VehicleNoPattern = new Regex(@"^[A-Za-z0-9\- ]{4,15}$");
        private static readonly Regex TransporterPattern = new Regex(@"^[A-Za-z0-9&.\-, ]{2,60}$");
        private static readonly Regex BuyerNamePattern = new Regex(@"^[A-Za-z .,'\-]{2,60}$");
        private static readonly Regex TokenPattern = new Regex(@"^[A-Za-z0-9\-]{3,20}$");
        private static readonly Regex UnsafeCharsPattern = new Regex(@"[<>""']");

        public static VehicleEntry Add(string vehicleNo, string transporter, string buyerName, string token, bool? withoutPCS, bool? manualPCS, string material)
        {
            vehicleNo = (vehicleNo ?? string.Empty).Trim().ToUpperInvariant();
            transporter = (transporter ?? string.Empty).Trim();
            buyerName = (buyerName ?? string.Empty).Trim();
            token = (token ?? string.Empty).Trim().ToUpperInvariant();
            material = (material ?? string.Empty).Trim();

            if (!VehicleNoPattern.IsMatch(vehicleNo))
                throw new ArgumentException("Enter a valid vehicle number (4-15 letters/digits).");

            if (!TransporterPattern.IsMatch(transporter))
                throw new ArgumentException("Enter a valid transporter name.");

            if (!BuyerNamePattern.IsMatch(buyerName))
                throw new ArgumentException("Enter a valid buyer name (2-60 letters).");

            if (!TokenPattern.IsMatch(token))
                throw new ArgumentException("Enter a valid token (3-20 letters/digits).");

            if (material.Length < 1 || material.Length > 50 || UnsafeCharsPattern.IsMatch(material))
                throw new ArgumentException("Material details must be 1-50 characters with no special symbols.");

            var entry = new VehicleEntry
            {
                Id = Guid.NewGuid().ToString("N"),
                VehicleNo = vehicleNo,
                Transporter = transporter,
                BuyerName = buyerName,
                Token = token,
                WithoutPCS = withoutPCS,
                ManualPCS = withoutPCS == true ? (bool?)null : manualPCS,
                Material = material,
                SubmittedAt = DateTime.Now,
                IsInside = false,
                InsideAt = null
            };

            Entries[entry.Id] = entry;
            return entry;
        }

        public static VehicleEntry MarkInside(string id)
        {
            VehicleEntry entry;
            if (string.IsNullOrEmpty(id) || !Entries.TryGetValue(id, out entry))
                throw new ArgumentException("Vehicle entry not found.");

            if (!entry.IsInside)
            {
                entry.IsInside = true;
                entry.InsideAt = DateTime.Now;
            }

            return entry;
        }

        public static List<VehicleEntry> GetAll()
        {
            return Entries.Values
                .OrderBy(e => e.IsInside)
                .ThenByDescending(e => e.SubmittedAt)
                .ToList();
        }
    }
}
