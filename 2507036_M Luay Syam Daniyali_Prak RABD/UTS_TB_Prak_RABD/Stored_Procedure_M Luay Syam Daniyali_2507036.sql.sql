-- =====================================================================
-- TUGAS 4: IMPLEMENTASI STORED PROCEDURE (PERTEMUAN 4)
-- =====================================================================

-- Ubah delimiter sementara untuk mendefinisikan blok procedure
DELIMITER //

-- 1. Membuat Stored Procedure: SP_Tampil_Produk
-- Fungsi: Menampilkan seluruh data produk
CREATE PROCEDURE SP_Tampil_Produk()
BEGIN
    SELECT * FROM produk;
END //

-- 2. Membuat Stored Procedure: SP_Tambah_Produk
-- Fungsi: Menambahkan produk baru menggunakan parameter
-- Ubah delimiter dulu di baris paling atas
DELIMITER //

CREATE PROCEDURE SP_Tambah_Produk(
    IN p_id_produk VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_kategori VARCHAR(50),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    INSERT INTO produk (id_produk, nama_produk, kategori, harga, stok)
    VALUES (p_id_produk, p_nama_produk, p_kategori, p_harga, p_stok);
END //

DELIMITER ;

-- 3. Membuat Stored Procedure: SP_Ubah_Harga
-- Fungsi: Mengubah harga produk berdasarkan ID produk dan harga baru
DELIMITER //

CREATE PROCEDURE SP_Ubah_Harga(
    IN p_id_produk VARCHAR(10),
    IN p_harga_baru DECIMAL(12,2)
)
BEGIN
    UPDATE produk 
    SET harga = p_harga_baru 
    WHERE id_produk = p_id_produk;
END //

DELIMITER ;



-- =====================================================================
-- PENGUJIAN STORED PROCEDURE
-- =====================================================================

-- 1. Menguji SP_Tampil_Produk
CALL SP_Tampil_Produk();

-- 2. Menguji SP_Tambah_Produk (Memasukkan produk baru 'PRD011')[cite: 4]
CALL SP_Tambah_Produk('PRD011', 'SSD NVMe 1TB', 'Aksesoris', 1100000.00, 20);

-- 3. Menguji SP_Ubah_Harga (Mengubah harga PRD011 menjadi Rp1.050.000,00)[cite: 4]
CALL SP_Ubah_Harga('PRD011', 1050000.00);

-- Verifikasi hasil perubahan data dengan SELECT biasa
SELECT * FROM produk WHERE id_produk = 'PRD011';

-- Menghapus procedure sesuai instruksi kerja[cite: 4]
DROP PROCEDURE IF EXISTS SP_Tampil_Produk;