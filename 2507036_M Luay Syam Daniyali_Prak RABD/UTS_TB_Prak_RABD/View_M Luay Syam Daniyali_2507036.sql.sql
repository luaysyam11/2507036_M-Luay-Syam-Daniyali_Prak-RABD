-- =====================================================================
-- TUGAS 6: IMPLEMENTASI SQL VIEW (PERTEMUAN 6)
-- =====================================================================

-- 1. View_Produk: Informasi produk (mengambil dari 1 tabel)
CREATE OR REPLACE VIEW View_Produk AS
SELECT id_produk, nama_produk, kategori, harga, stok
FROM produk;

-- 2. View_Transaksi: Informasi transaksi beserta nama pelanggan (menggunakan JOIN antartabel)[cite: 4, 5]
CREATE OR REPLACE VIEW View_Transaksi AS
SELECT 
    t.id_penjualan,
    t.tanggal,
    p.id_pelanggan,
    p.nama_pelanggan,
    t.total_harga,
    t.diskon,
    t.total_bayar
FROM penjualan t
JOIN pelanggan p ON t.id_pelanggan = p.id_pelanggan;

-- 3. View_Laporan_Penjualan: Menggunakan fungsi agregasi (COUNT, SUM) dan GROUP BY berdasarkan kategori produk[cite: 4, 5]
CREATE OR REPLACE VIEW View_Laporan_Penjualan AS
SELECT 
    pr.kategori,
    COUNT(DISTINCT t.id_penjualan) AS jumlah_transaksi,
    SUM(dp.jumlah) AS total_unit_terjual,
    SUM(dp.subtotal) AS total_pendapatan
FROM penjualan t
JOIN detail_penjualan dp ON t.id_penjualan = dp.id_penjualan
JOIN produk pr ON dp.id_produk = pr.id_produk
GROUP BY pr.kategori;

-- 4. View_Stok_Rendah: Menampilkan produk dengan jumlah stok di bawah batas tertentu (stok < 5)[cite: 4]
CREATE OR REPLACE VIEW View_Stok_Rendah AS
SELECT id_produk, nama_produk, kategori, stok
FROM produk
WHERE stok < 5;


-- =====================================================================
-- PENGUJIAN VIEW & WITH CHECK OPTION (INSTRUKSI KERJA 41-47)
-- =====================================================================

-- A. Uji Coba SELECT terhadap seluruh View
SELECT * FROM View_Produk;
SELECT * FROM View_Transaksi;
SELECT * FROM View_Laporan_Penjualan;
SELECT * FROM View_Stok_Rendah;

-- B. Pembuatan View dengan WITH CHECK OPTION (Pembatasan updatable data berdasarkan kondisi view)[cite: 5]
CREATE OR REPLACE VIEW View_Aksesoris AS
SELECT id_produk, nama_produk, kategori, harga, stok
FROM produk
WHERE kategori = 'Aksesoris'
WITH CHECK OPTION;

-- C. Uji Coba SELECT View Aksesoris[cite: 5]
SELECT * FROM View_Aksesoris;

-- D. Bukti Penghapusan View (DROP VIEW) sesuai instruksi kerja[cite: 5]
DROP VIEW IF EXISTS View_Stok_Rendah;