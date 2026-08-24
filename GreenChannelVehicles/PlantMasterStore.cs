using System.Collections.Generic;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace GreenChannelVehicles
{
    public class PgOption
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public static class PlantMasterStore
    {
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["PlantMasterDb"].ConnectionString;

        private const int PlantId = 4;

        public static List<PgOption> GetPGList()
        {
            var list = new List<PgOption>();

            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT PG_ID, PG_Name FROM tbl_PG WHERE Plant_ID = @plantId ORDER BY PG_Name", conn))
                {
                    cmd.Parameters.AddWithValue("@plantId", PlantId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            list.Add(new PgOption
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("PG_ID")),
                                Name = reader["PG_Name"].ToString()
                            });
                        }
                    }
                }
            }

            return list;
        }
    }
}
