-- GreenChannelVehicles MySQL schema
-- Run in MySQL 8.x: mysql -u root -p < schema.sql

CREATE DATABASE IF NOT EXISTS gcv_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE gcv_db;

CREATE TABLE IF NOT EXISTS vehicle_entries (
  id            INT           NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vehicle_no    VARCHAR(15)   NOT NULL,
  transporter   VARCHAR(60)   NOT NULL,
  buyer_name    VARCHAR(60)   NOT NULL,
  token         VARCHAR(20)   NOT NULL,
  without_pcs   TINYINT(1)    NULL,
  manual_pcs    TINYINT(1)    NULL,
  material      VARCHAR(50)   NULL,
  pg_id         INT           NOT NULL,   -- FK to plant_master.tbl_PG.PG_ID (Plant_ID = 4)
  submitted_at  DATETIME      NOT NULL,
  is_inside     TINYINT(1)    NOT NULL DEFAULT 0,
  inside_at     DATETIME      NULL,

  INDEX idx_vehicle_no (vehicle_no),
  INDEX idx_token (token),
  INDEX idx_is_inside_submitted (is_inside, submitted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- plant_master.tbl_PG (PG_ID, PG_Name, Plant_ID, ...) is assumed to already
-- exist as a separate pre-existing database on the same server; nothing here
-- creates or modifies it.

-- Dedicated least-privilege app user (change the password before running)
CREATE USER IF NOT EXISTS 'gcv_app'@'localhost' IDENTIFIED BY 'CHANGE_ME_STRONG_PASSWORD';
GRANT SELECT, INSERT, UPDATE ON gcv_db.vehicle_entries TO 'gcv_app'@'localhost';
FLUSH PRIVILEGES;
