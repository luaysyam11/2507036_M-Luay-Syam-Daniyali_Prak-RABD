-- =====================================================================
-- TUGAS 5: IMPLEMENTASI FUNCTION DAN TRIGGER (PERTEMUAN 5)
-- =====================================================================

DELIMITER //

-- =====================================================================
-- A. MEMBUAT STORED FUNCTION
-- =====================================================================

-- 1. hitung_total(): Menghitung harga satuan dikalikan jumlah pembelian
DELIMITER //

DROP FUNCTION IF EXISTS hitung_total //
CREATE FUNCTION hitung_total(p_harga DECIMAL(12,2), p_jumlah INT) 
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN p_harga * p_jumlah;
END //

DELIMITER ;

-- 2. hitung_diskon(): Menghitung diskon 10% apabila total transaksi minimal Rp1.000.000[cite: 4]
DELIMITER //

DROP FUNCTION IF EXISTS hitung_diskon //
CREATE FUNCTION hitung_diskon(p_total DECIMAL(12,2)) 
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_diskon DECIMAL(12,2);
    IF p_total >= 1000000.00 THEN
        SET v_diskon = p_total * 0.10;
    ELSE
        SET v_diskon = 0.00;
    END IF;
    RETURN v_diskon;
END //

DELIMITER ;


-- =====================================================================
-- B. MEMBUAT TRIGGER
-- =====================================================================

DELIMITER //

-- 1. Trigger validasi_penjualan (BEFORE INSERT pada detail_penjualan)
-- Memvalidasi produk, jumlah pembelian, dan ketersediaan stok sebelum transaksi disimpan[cite: 4].
DROP TRIGGER IF EXISTS validasi_penjualan //
CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT;
    DECLARE v_cek_produk INT;
    
    -- Cek apakah produk terdaftar dan ambil stoknya
    SELECT COUNT(*), stok INTO v_cek_produk, v_stok 
    FROM produk 
    WHERE id_produk = NEW.id_produk;
    
    -- Pengujian 38: Produk tidak terdaftar[cite: 4]
    IF v_cek_produk = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Gagal: Produk tidak terdaftar dalam sistem!';
    
    -- Pengujian 37: Jumlah nol atau negatif[cite: 4]
    ELSEIF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Gagal: Jumlah pembelian harus lebih dari nol (positif)!';
    
    -- Pengujian 36: Pembelian dengan jumlah melebihi stok[cite: 4]
    ELSEIF v_stok < NEW.jumlah THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Gagal: Stok produk tidak mencukupi untuk transaksi ini!';
    END IF;
END //

-- 2. Trigger update_stok_penjualan (AFTER INSERT pada detail_penjualan)
-- Mengurangi stok dan mencatat perubahan persediaan ke tabel log_stok setelah transaksi berhasil[cite: 4].
DELIMITER //

DROP TRIGGER IF EXISTS update_stok_penjualan //
CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    -- Kurangi stok produk secara otomatis
    UPDATE produk 
    SET stok = stok - NEW.jumlah 
    WHERE id_produk = NEW.id_produk;
    
    -- Catat perubahan persediaan ke tabel log_stok secara otomatis[cite: 4]
    INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan, tanggal)
    VALUES (NEW.id_produk, -NEW.jumlah, 'KELUAR', CONCAT('Pengurangan stok otomatis dari transaksi penjualan ID: ', NEW.id_penjualan), NOW());
END //

DELIMITER ;


-- =====================================================================
-- 1. PENGUJIAN STORED FUNCTION
-- =====================================================================
-- Menguji hitung_total dan hitung_diskon langsung via SELECT
SELECT 
    'PRD001' AS id_produk,
    14500000.00 AS harga_satuan,
    2 AS jumlah,
    hitung_total(14500000.00, 2) AS total_kotor,
    hitung_diskon(hitung_total(14500000.00, 2)) AS diskon_didapat,
    (hitung_total(14500000.00, 2) - hitung_diskon(hitung_total(14500000.00, 2))) AS total_bayar;


-- =====================================================================
-- 2. PENGUJIAN TRIGGER (VALIDASI & AUTOMATISASI)
-- =====================================================================

-- Buat header penjualan sementara untuk uji coba detail
INSERT INTO penjualan (id_penjualan, tanggal, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES ('TRX_TEST', NOW(), 'PLG001', 'PGW002', 250000.00, 0.00, 250000.00);

-- A. UJI COBA GAGAL: Membeli produk dengan jumlah melebihi stok (Misal Mouse PRD002 pesan 100 padahal stok 50)[cite: 4]
-- (Harus memunculkan error: "Gagal: Stok produk tidak mencukupi...")
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX_TEST', 'PRD002', 100, 250000.00, 25000000.00);

-- B. UJI COBA GAGAL: Membeli produk dengan jumlah negatif/nol[cite: 4]
-- (Harus memunculkan error: "Gagal: Jumlah pembelian harus lebih dari nol...")
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX_TEST', 'PRD002', 0, 250000.00, 0.00);

-- C. UJI COBA GAGAL: Membeli produk yang tidak terdaftar[cite: 4]
-- (Harus memunculkan error: "Gagal: Produk tidak terdaftar...")
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX_TEST', 'PRD999', 1, 100000.00, 100000.00);

-- D. UJI COBA BERHASIL: Pembelian normal dengan jumlah tersedia (Misal Mouse PRD002 sebanyak 2 unit)[cite: 4]
INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX_TEST', 'PRD002', 2, 250000.00, 500000.00);

-- Verifikasi hasil akhir: Cek apakah stok berkurang otomatis & log_stok tercatat[cite: 4]
SELECT * FROM produk WHERE id_produk = 'PRD002';
SELECT * FROM log_stok ORDER BY id_log DESC LIMIT 2;

-- Bersihkan data uji coba jika diperlukan
DELETE FROM detail_penjualan WHERE id_penjualan = 'TRX_TEST';
DELETE FROM penjualan WHERE id_penjualan = 'TRX_TEST';