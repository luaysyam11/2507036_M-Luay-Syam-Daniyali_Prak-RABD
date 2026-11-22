-- =====================================================================
-- TUGAS 3: PENGELOLAAN TRANSAKSI (PERTEMUAN 3)
-- =====================================================================

-- SKENARIO A: Transaksi Penjualan Berhasil
-- Pelanggan membeli 1 unit Laptop (PRD001) dan 2 unit Mouse (PRD002).
-- Sistem mencatat header penjualan, detail penjualan, dan memperbarui stok dalam satu transaksi.

START TRANSACTION;

-- 1. Catat ke tabel penjualan
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX005', NOW(), 'PLG001', 'PGW002', 15000000.00, 1500000.00, 13500000.00);

-- 2. Catat ke tabel detail_penjualan
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX005', 'PRD001', 1, 14500000.00, 14500000.00),
       ('TRX005', 'PRD002', 2, 250000.00, 500000.00);

-- 3. Perbarui (kurangi) stok produk secara otomatis
UPDATE produk SET stok = stok - 1 WHERE id_produk = 'PRD001';
UPDATE produk SET stok = stok - 2 WHERE id_produk = 'PRD002';

-- Simpan perubahan secara permanen ke database
COMMIT;


-- =====================================================================
-- SKENARIO B: Transaksi Gagal (Pembelian Melebihi Stok Tersedia)
-- Pelanggan mencoba membeli produk dengan jumlah yang melebihi stok yang ada di database.
-- Karena gagal, seluruh perubahan dibatalkan menggunakan ROLLBACK[span_2](start_span)[span_2](end_span).
-- =====================================================================

START TRANSACTION;

-- Misal pelanggan memesan 5 unit Smart TV Sony (PRD006), padahal stok saat ini hanya tersisa 2 unit.
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX006', NOW(), 'PLG002', 'PGW002', 42500000.00, 4250000.00, 38250000.00);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD006', 5, 8500000.00, 42500000.00);

-- Simulasi pengecekan logika aplikasi: Stok tidak mencukupi, batalkan transaksi!
ROLLBACK;


-- =====================================================================
-- SKENARIO C: Pembatalan Sebagian Transaksi Menggunakan SAVEPOINT
-- Dalam satu transaksi besar, terdapat beberapa item. Kita buat SAVEPOINT 
-- agar jika item tertentu batal, kita bisa rollback sebagian tanpa membatalkan seluruh transaksi[span_3](start_span)[span_3](end_span).
-- =====================================================================

START TRANSACTION;

-- Transaksi awal
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX007', NOW(), 'PLG003', 'PGW002', 1200000.00, 0.00, 1200000.00);

-- Masukkan item pertama (Keyboard K2 - 1 unit) -> Berhasil/Valid
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD003', 1, 1200000.00, 1200000.00);

-- Buat Savepoint setelah item pertama aman
SAVEPOINT sp_setelah_keyboard;

-- Masukkan item kedua (Misal Smart TV Sony 5 unit) yang ternyata keliru/ingin dibatalkan
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD006', 5, 8500000.00, 42500000.00);

-- Batalkan perubahan HANYA pada penambahan item kedua saja menggunakan savepoint
ROLLBACK TO SAVEPOINT sp_setelah_keyboard;

-- Hapus savepoint yang sudah tidak dipakai
RELEASE SAVEPOINT sp_setelah_keyboard;

-- Commit transaksi final (hanya mencatat item pertama yang valid)
COMMIT;

-- Melihat daftar transaksi yang berhasil masuk
SELECT * FROM penjualan;

-- Melihat rincian produk, jumlah, dan subtotal per transaksi
SELECT * FROM detail_penjualan;

-- Bandingkan stok produk sesudah transaksi (misal PRD001 dan PRD002)
SELECT id_produk, nama_produk, stok FROM produk;

-- Melihat riwayat keluar-masuk barang di gudang[cite: 9]
SELECT * FROM log_stok;