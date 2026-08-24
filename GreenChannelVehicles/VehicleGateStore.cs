using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;

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
        public int PgId { get; set; }
        public DateTime SubmittedAt { get; set; }
        public bool IsInside { get; set; }
        public DateTime? InsideAt { get; set; }
    }

    public static class VehicleGateStore
    {
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["GcvDb"].ConnectionString;

        private static readonly Regex VehicleNoPattern = new Regex(@"^[A-Za-z0-9\- ]{4,15}$");
        private static readonly Regex TransporterPattern = new Regex(@"^[A-Za-z0-9&.\-, ]{2,60}$");
        private static readonly Regex BuyerNamePattern = new Regex(@"^[A-Za-z .,'\-]{2,60}$");
        private static readonly Regex TokenPattern = new Regex(@"^[A-Za-z0-9\-]{3,20}$");
        private static readonly Regex UnsafeCharsPattern = new Regex(@"[<>""']");

        private static MySqlConnection OpenConnection()
        {
            var conn = new MySqlConnection(ConnectionString);
            conn.Open();
            return conn;
        }

        public static VehicleEntry Add(string vehicleNo, string transporter, string buyerName, string token, bool? withoutPCS, bool? manualPCS, string material, int pgId)
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

            if (material.Length > 50 || UnsafeCharsPattern.IsMatch(material))
                throw new ArgumentException("Material details must be up to 50 characters with no special symbols.");

            if (pgId <= 0)
                throw new ArgumentException("Select a PG.");

            var entry = new VehicleEntry
            {
                VehicleNo = vehicleNo,
                Transporter = transporter,
                BuyerName = buyerName,
                Token = token,
                WithoutPCS = withoutPCS,
                ManualPCS = withoutPCS == true ? (bool?)null : manualPCS,
                Material = material,
                PgId = pgId,
                SubmittedAt = DateTime.Now,
                IsInside = false,
                InsideAt = null
            };

            using (var conn = OpenConnection())
            using (var cmd = new MySqlCommand(
                @"INSERT INTO vehicle_entries
                    (vehicle_no, transporter, buyer_name, token, without_pcs, manual_pcs, material, pg_id, submitted_at, is_inside, inside_at)
                  VALUES
                    (@vehicleNo, @transporter, @buyerName, @token, @withoutPCS, @manualPCS, @material, @pgId, @submittedAt, 0, NULL)", conn))
            {
                cmd.Parameters.AddWithValue("@vehicleNo", entry.VehicleNo);
                cmd.Parameters.AddWithValue("@transporter", entry.Transporter);
                cmd.Parameters.AddWithValue("@buyerName", entry.BuyerName);
                cmd.Parameters.AddWithValue("@token", entry.Token);
                cmd.Parameters.AddWithValue("@withoutPCS", (object)entry.WithoutPCS ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@manualPCS", (object)entry.ManualPCS ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@material", entry.Material);
                cmd.Parameters.AddWithValue("@pgId", entry.PgId);
                cmd.Parameters.AddWithValue("@submittedAt", entry.SubmittedAt);
                cmd.ExecuteNonQuery();
                entry.Id = cmd.LastInsertedId.ToString();
            }

            return entry;
        }

        public static VehicleEntry MarkInside(string id)
        {
            int entryId;
            if (!int.TryParse(id, out entryId))
                throw new ArgumentException("Vehicle entry not found.");

            var insideAt = DateTime.Now;

            using (var conn = OpenConnection())
            {
                using (var cmd = new MySqlCommand(
                    "UPDATE vehicle_entries SET is_inside = 1, inside_at = @insideAt WHERE id = @id AND is_inside = 0", conn))
                {
                    cmd.Parameters.AddWithValue("@insideAt", insideAt);
                    cmd.Parameters.AddWithValue("@id", entryId);
                    cmd.ExecuteNonQuery();
                }

                using (var cmd = new MySqlCommand("SELECT * FROM vehicle_entries WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", entryId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                            throw new ArgumentException("Vehicle entry not found.");
                        return ReadEntry(reader);
                    }
                }
            }
        }

        public static List<VehicleEntry> GetAll()
        {
            var list = new List<VehicleEntry>();

            using (var conn = OpenConnection())
            using (var cmd = new MySqlCommand(
                "SELECT * FROM vehicle_entries WHERE DATE(submitted_at) = CURDATE() ORDER BY is_inside ASC, submitted_at DESC", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                    list.Add(ReadEntry(reader));
            }

            return list;
        }

        private static VehicleEntry ReadEntry(MySqlDataReader reader)
        {
            return new VehicleEntry
            {
                Id = reader["id"].ToString(),
                VehicleNo = reader["vehicle_no"].ToString(),
                Transporter = reader["transporter"].ToString(),
                BuyerName = reader["buyer_name"].ToString(),
                Token = reader["token"].ToString(),
                WithoutPCS = reader["without_pcs"] == DBNull.Value ? (bool?)null : Convert.ToBoolean(reader["without_pcs"]),
                ManualPCS = reader["manual_pcs"] == DBNull.Value ? (bool?)null : Convert.ToBoolean(reader["manual_pcs"]),
                Material = reader["material"].ToString(),
                PgId = Convert.ToInt32(reader["pg_id"]),
                SubmittedAt = Convert.ToDateTime(reader["submitted_at"]),
                IsInside = Convert.ToBoolean(reader["is_inside"]),
                InsideAt = reader["inside_at"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["inside_at"])
            };
        }
    }
}
