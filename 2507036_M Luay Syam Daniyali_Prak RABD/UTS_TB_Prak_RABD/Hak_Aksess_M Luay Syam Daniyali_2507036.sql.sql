-- =====================================================================
-- 1. PEMBUATAN ROLE (CREATE ROLE)
-- =====================================================================
CREATE ROLE IF NOT EXISTS role_admin;
CREATE ROLE IF NOT EXISTS role_penjualan;
CREATE ROLE IF NOT EXISTS role_gudang;
CREATE ROLE IF NOT EXISTS role_manajer;


-- =====================================================================
-- 2. PEMBERIAN HAK AKSES (GRANT) SESUAI TUGAS & TANGGUNG JAWAB
-- =====================================================================

-- Role Admin: Mengelola seluruh objek dan data basis data[span_2](start_span)[span_2](end_span)
GRANT ALL PRIVILEGES ON electromart_db.* TO role_admin;

-- Role Penjualan: Melihat produk & pelanggan, serta menginput transaksi[span_3](start_span)[span_3](end_span)
GRANT SELECT ON electromart_db.produk TO role_penjualan;
GRANT SELECT ON electromart_db.pelanggan TO role_penjualan;
GRANT INSERT, SELECT ON electromart_db.penjualan TO role_penjualan;
GRANT INSERT, SELECT ON electromart_db.detail_penjualan TO role_penjualan;

-- Role Gudang: Melihat produk dan memperbarui stok[span_4](start_span)[span_4](end_span)
GRANT SELECT, UPDATE (stok) ON electromart_db.produk TO role_gudang;
GRANT SELECT, INSERT ON electromart_db.log_stok TO role_gudang;

-- Role Manajer: Melihat informasi produk dan laporan penjualan[span_5](start_span)[span_5](end_span)
GRANT SELECT ON electromart_db.produk TO role_manajer;
GRANT SELECT ON electromart_db.pelanggan TO role_manajer;
GRANT SELECT ON electromart_db.penjualan TO role_manajer;
GRANT SELECT ON electromart_db.detail_penjualan TO role_manajer;
GRANT SELECT ON electromart_db.log_stok TO role_manajer;


-- =====================================================================
-- 3. PENCABUTAN HAK AKSES (REVOKE) 
-- =====================================================================
-- Contoh penerapan perintah REVOKE sesuai instruksi kerja modul:
-- Misal jika sebelumnya role_gudang tidak sengaja diberi hak INSERT ke tabel penjualan, cabut kembali:
REVOKE INSERT ON electromart_db.penjualan FROM role_gudang;


-- =====================================================================
-- 4. PEMBUATAN AKUN PENGGUNA (CREATE USER) & PENGHUBUNGAN DENGAN ROLE
-- =====================================================================

-- Membuat user untuk masing-masing role[span_6](start_span)[span_6](end_span)
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin123!';
CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'Sales123!';
CREATE USER 'warehouse_user'@'localhost' IDENTIFIED BY 'Gudang123!';
CREATE USER 'manager_user'@'localhost' IDENTIFIED BY 'Manager123!';

-- Menghubungkan pengguna dengan role yang sesuai[span_7](start_span)[span_7](end_span)
GRANT role_admin TO 'admin_user'@'localhost';
GRANT role_penjualan TO 'sales_user'@'localhost';
GRANT role_gudang TO 'warehouse_user'@'localhost';
GRANT role_manajer TO 'manager_user'@'localhost';

-- Mengaktifkan default role untuk masing-masing user saat login
SET DEFAULT ROLE ALL TO 'admin_user'@'localhost', 
                        'sales_user'@'localhost', 
                        'warehouse_user'@'localhost', 
                        'manager_user'@'localhost';


-- Login sebagai warehouse_user
UPDATE produk SET stok = 20 WHERE id_produk = 'PRD001';
-- (Hasil: BERHASIL karena role_gudang memiliki hak akses UPDATE pada kolom stok produk)

-- Login sebagai sales_user
ALTER TABLE produk ADD COLUMN garansi VARCHAR(50);
-- (Hasil: ERROR / DITOLAK, karena sales_user tidak memiliki hak ALTER/ADMIN pada tabel produk)

-- Login sebagai sales_user
SELECT * FROM log_stok;
-- (Hasil: ERROR / DITOLAK, karena hak akses log_stok hanya diberikan untuk role_gudang dan role_manajer)[span_8](start_span)[span_8](end_span)