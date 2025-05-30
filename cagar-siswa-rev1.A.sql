-------------------------------------------------------------------------
------------------------  CAGAR SISWA REV1.A  ---------------------------
-------------------------------------------------------------------------
-- Hapus database jika sudah ada (hati-hati di production)
DROP DATABASE IF EXISTS cagarsiswasatu;
CREATE DATABASE cagarsiswasatu;
USE cagarsiswasatu;

--------------------------------------   
-- 1. DATA MASTER
--------------------------------------

-- Tahun Pelajaran
CREATE TABLE IF NOT EXISTS tahun_pelajaran (
    id_tahun_pelajaran INT PRIMARY KEY AUTO_INCREMENT,
    tahun_awal YEAR NOT NULL,
    tahun_akhir YEAR NOT NULL,
    semester ENUM('Ganjil', 'Genap') NOT NULL,
    status_aktif BOOLEAN DEFAULT FALSE,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (tahun_awal, tahun_akhir, semester)
) ENGINE=InnoDB;

-- Jurusan
CREATE TABLE IF NOT EXISTS jurusan (
    id_jurusan INT PRIMARY KEY AUTO_INCREMENT,
    kode_jurusan VARCHAR(10) UNIQUE NOT NULL,
    nama_jurusan VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Guru
CREATE TABLE IF NOT EXISTS guru (
    id_guru INT PRIMARY KEY AUTO_INCREMENT,
    nip VARCHAR(20) UNIQUE NOT NULL,
    nama_guru VARCHAR(100) NOT NULL,
    jenis_kelamin ENUM('L', 'P') NOT NULL,
    alamat TEXT,
    no_telp VARCHAR(15),
    email VARCHAR(100),
    status_aktif BOOLEAN DEFAULT TRUE,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Poin Pelanggaran
CREATE TABLE IF NOT EXISTS poin_pelanggaran (
    id_poin_pelanggaran INT PRIMARY KEY AUTO_INCREMENT,
    kode_pelanggaran VARCHAR(10) UNIQUE NOT NULL,
    nama_pelanggaran VARCHAR(100) NOT NULL,
    kategori ENUM('Ringan', 'Sedang', 'Berat') NOT NULL,
    bobot INT NOT NULL CHECK (bobot BETWEEN 1 AND 100),
    deskripsi TEXT,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Poin Prestasi
CREATE TABLE IF NOT EXISTS poin_prestasi (
    id_poin_prestasi INT PRIMARY KEY AUTO_INCREMENT,
    kode_prestasi VARCHAR(10) UNIQUE NOT NULL,
    nama_prestasi VARCHAR(100) NOT NULL,
    kategori ENUM('Baik', 'Sangat Baik', 'Luar Biasa') NOT NULL,
    bobot INT NOT NULL CHECK (bobot BETWEEN 1 AND 100),
    deskripsi TEXT,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Surat Pelanggaran
CREATE TABLE IF NOT EXISTS surat_pelanggaran (
    id_surat_pelanggaran INT PRIMARY KEY AUTO_INCREMENT,
    jenis_surat ENUM('Peringatan', 'SP1', 'SP2', 'SP3') NOT NULL,
    min_poin INT NOT NULL,
    max_poin INT NOT NULL,
    deskripsi TEXT,
    konsekuensi TEXT,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Kelas
CREATE TABLE IF NOT EXISTS kelas (
    id_kelas INT PRIMARY KEY AUTO_INCREMENT,
    id_jurusan INT NOT NULL,
    id_tahun_pelajaran INT NOT NULL,
    tingkat INT NOT NULL CHECK (tingkat BETWEEN 1 AND 4),
    nama_kelas VARCHAR(20) NOT NULL,
    wali_kelas INT,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_jurusan) REFERENCES jurusan(id_jurusan) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_tahun_pelajaran) REFERENCES tahun_pelajaran(id_tahun_pelajaran) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (wali_kelas) REFERENCES guru(id_guru) ON UPDATE CASCADE ON DELETE SET NULL,
    UNIQUE KEY (id_tahun_pelajaran, tingkat, nama_kelas)
) ENGINE=InnoDB;

-- Siswa
CREATE TABLE IF NOT EXISTS siswa (
    id_siswa INT PRIMARY KEY AUTO_INCREMENT,
    nis VARCHAR(20) UNIQUE NOT NULL,
    nisn VARCHAR(20) UNIQUE NOT NULL,
    nama_siswa VARCHAR(100) NOT NULL,
    jenis_kelamin ENUM('L', 'P') NOT NULL,
    tempat_lahir VARCHAR(50) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    alamat TEXT,
    no_telp VARCHAR(15),
    id_kelas INT NOT NULL,
    total_poin_pelanggaran INT DEFAULT 0,
    total_poin_prestasi INT DEFAULT 0,
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kelas) REFERENCES kelas(id_kelas) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

--------------------------------------   
-- 2. DATA TRANSAKSI
--------------------------------------

-- Prestasi
CREATE TABLE IF NOT EXISTS prestasi (
    id_prestasi INT PRIMARY KEY AUTO_INCREMENT,
    id_siswa INT NOT NULL,
    id_poin_prestasi INT NOT NULL,
    id_guru INT NOT NULL,
    tanggal_prestasi DATE NOT NULL,
    keterangan TEXT,
    dokumen_path VARCHAR(255),
    status_verifikasi ENUM('Menunggu', 'Diterima', 'Ditolak') DEFAULT 'Menunggu',
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_siswa) REFERENCES siswa(id_siswa) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_poin_prestasi) REFERENCES poin_prestasi(id_poin_prestasi) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_guru) REFERENCES guru(id_guru) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Pelanggaran
CREATE TABLE IF NOT EXISTS pelanggaran (
    id_pelanggaran INT PRIMARY KEY AUTO_INCREMENT,
    id_siswa INT NOT NULL,
    id_poin_pelanggaran INT NOT NULL,
    id_guru INT NOT NULL,
    tanggal_pelanggaran DATE NOT NULL,
    keterangan TEXT,
    lokasi VARCHAR(100),
    status_verifikasi ENUM('Menunggu', 'Diterima', 'Ditolak') DEFAULT 'Menunggu',
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_siswa) REFERENCES siswa(id_siswa) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_poin_pelanggaran) REFERENCES poin_pelanggaran(id_poin_pelanggaran) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_guru) REFERENCES guru(id_guru) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tindak Lanjut
CREATE TABLE IF NOT EXISTS tindak_lanjut (
    id_tindak_lanjut INT PRIMARY KEY AUTO_INCREMENT,
    id_pelanggaran INT NOT NULL,
    id_surat_pelanggaran INT,
    id_guru_penangan INT NOT NULL,
    tanggal_penanganan DATE NOT NULL,
    jenis_penanganan ENUM('Pembinaan', 'Sanksi', 'Lainnya') NOT NULL,
    deskripsi_penanganan TEXT,
    hasil TEXT,
    status ENUM('Belum Selesai', 'Selesai') DEFAULT 'Belum Selesai',
    tanggal_dibuat DATETIME DEFAULT CURRENT_TIMESTAMP,
    tanggal_diupdate DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pelanggaran) REFERENCES pelanggaran(id_pelanggaran) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_surat_pelanggaran) REFERENCES surat_pelanggaran(id_surat_pelanggaran) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (id_guru_penangan) REFERENCES guru(id_guru) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;


--------------------------------------   
-- 3. TABEL RIWAYAT (untuk trigger)
--------------------------------------
CREATE TABLE IF NOT EXISTS riwayat_pelanggaran (
    id_riwayat INT PRIMARY KEY AUTO_INCREMENT,
    id_pelanggaran INT NOT NULL,
    id_siswa INT NOT NULL,
    aksi VARCHAR(20) NOT NULL,
    tanggal_aksi DATETIME NOT NULL,
    FOREIGN KEY (id_pelanggaran) REFERENCES pelanggaran(id_pelanggaran) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_siswa) REFERENCES siswa(id_siswa) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS riwayat_prestasi (
    id_riwayat INT PRIMARY KEY AUTO_INCREMENT,
    id_prestasi INT NOT NULL,
    id_siswa INT NOT NULL,
    aksi VARCHAR(20) NOT NULL,
    tanggal_aksi DATETIME NOT NULL,
    FOREIGN KEY (id_prestasi) REFERENCES prestasi(id_prestasi) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_siswa) REFERENCES siswa(id_siswa) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS riwayat_surat (
    id_riwayat INT PRIMARY KEY AUTO_INCREMENT,
    id_tindak_lanjut INT NOT NULL,
    id_siswa INT NOT NULL,
    jenis_surat ENUM('Peringatan', 'SP1', 'SP2', 'SP3') NOT NULL,
    tanggal_surat DATETIME NOT NULL,
    FOREIGN KEY (id_tindak_lanjut) REFERENCES tindak_lanjut(id_tindak_lanjut) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_siswa) REFERENCES siswa(id_siswa) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

--------------------------------------   
-- 4. INSERT DUMMY
--------------------------------------

-- 1. Insert Tahun Pelajaran
INSERT INTO tahun_pelajaran (tahun_awal, tahun_akhir, semester, status_aktif) VALUES
(2023, 2024, 'Ganjil', TRUE),
(2023, 2024, 'Genap', FALSE),
(2024, 2025, 'Ganjil', FALSE);

-- 2. Insert Jurusan
INSERT INTO jurusan (kode_jurusan, nama_jurusan, deskripsi) VALUES
('TKJ', 'Teknik Komputer dan Jaringan', 'Jurusan yang mempelajari tentang jaringan komputer dan perangkatnya'),
('RPL', 'Rekayasa Perangkat Lunak', 'Jurusan yang mempelajari tentang pengembangan perangkat lunak'),
('MM', 'Multimedia', 'Jurusan yang mempelajari tentang desain grafis dan produksi multimedia');

-- 3. Insert Guru
INSERT INTO guru (nip, nama_guru, jenis_kelamin, alamat, no_telp, email) VALUES
('1965123120001', 'Dr. Ahmad Sanusi, M.Pd', 'L', 'Jl. Pendidikan No. 1', '08123456781', 'ahmad.sanusi@smk.edu'),
('1970031520002', 'Drs. Budi Santoso', 'L', 'Jl. Guru No. 2', '08123456782', 'budi.santoso@smk.edu'),
('1985112020003', 'Siti Aminah, S.Pd', 'P', 'Jl. Pelajar No. 3', '08123456783', 'siti.aminah@smk.edu');

-- 4. Insert Poin Pelanggaran
INSERT INTO poin_pelanggaran (kode_pelanggaran, nama_pelanggaran, kategori, bobot, deskripsi) VALUES
('P001', 'Terlambat masuk sekolah', 'Ringan', 5, 'Siswa datang terlambat lebih dari 15 menit'),
('P002', 'Tidak memakai seragam lengkap', 'Sedang', 10, 'Siswa tidak memakai atribut lengkap sesuai ketentuan'),
('P003', 'Membawa HP saat ulangan', 'Berat', 25, 'Siswa ketahuan menggunakan HP saat ulangan');

-- 5. Insert Poin Prestasi
INSERT INTO poin_prestasi (kode_prestasi, nama_prestasi, kategori, bobot, deskripsi) VALUES
('PR001', 'Juara 1 Lomba Tingkat Kabupaten', 'Luar Biasa', 30, 'Memenangkan lomba tingkat kabupaten/kota'),
('PR002', 'Juara 2 Lomba Tingkat Sekolah', 'Sangat Baik', 20, 'Memenangkan lomba tingkat sekolah'),
('PR003', 'Siswa Teladan Kelas', 'Baik', 15, 'Dipilih sebagai siswa teladan di kelasnya');

-- 6. Insert Surat Pelanggaran
INSERT INTO surat_pelanggaran (jenis_surat, min_poin, max_poin, deskripsi, konsekuensi) VALUES
('Peringatan', 10, 25, 'Surat peringatan pertama', 'Panggilan orang tua dan pembinaan'),
('SP1', 26, 50, 'Surat Peringatan 1', 'Panggilan orang tua dan skorsing 1 hari'),
('SP2', 51, 75, 'Surat Peringatan 2', 'Panggilan orang tua dan skorsing 3 hari');

-- 7. Insert Kelas (setelah ada tahun pelajaran, jurusan, dan guru)
INSERT INTO kelas (id_jurusan, id_tahun_pelajaran, tingkat, nama_kelas, wali_kelas) VALUES
(1, 1, 1, 'TKJ 1', 1),  -- Jurusan TKJ, Tahun Pelajaran 2023/2024 Ganjil, Wali kelas Dr. Ahmad
(2, 1, 2, 'RPL 2', 2),  -- Jurusan RPL, Tahun Pelajaran 2023/2024 Ganjil, Wali kelas Drs. Budi
(3, 1, 3, 'MM 3', 3);  -- Jurusan MM, Tahun Pelajaran 2023/2024 Ganjil, Wali kelas Siti Aminah

-- 8. Insert Siswa (setelah ada kelas)
INSERT INTO siswa (nis, nisn, nama_siswa, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_telp, id_kelas) VALUES
('S001', '1234567890', 'Andi Wijaya', 'L', 'Jakarta', '2007-05-10', 'Jl. Merdeka No. 10', '08123456801', 1),
('S002', '1234567891', 'Budi Hartono', 'L', 'Bandung', '2007-06-15', 'Jl. Pahlawan No. 20', '08123456802', 1),
('S003', '1234567892', 'Citra Dewi', 'P', 'Surabaya', '2006-12-20', 'Jl. Kenangan No. 30', '08123456803', 2),
('S004', '1234567893', 'Dina Amelia', 'P', 'Yogyakarta', '2006-11-05', 'Jl. Cendrawasih No. 40', '08123456804', 2),
('S005', '1234567894', 'Eko Pratama', 'L', 'Semarang', '2005-08-25', 'Jl. Mawar No. 50', '08123456805', 3),
('S006', '1234567895', 'Fitriani', 'P', 'Malang', '2005-09-30', 'Jl. Melati No. 60', '08123456806', 3);

-- 9. Insert Pelanggaran (akan mengaktifkan trigger after_pelanggaran_insert)
INSERT INTO pelanggaran (id_siswa, id_poin_pelanggaran, id_guru, tanggal_pelanggaran, keterangan, lokasi, status_verifikasi) VALUES
(1, 1, 1, '2023-07-10', 'Terlambat 20 menit', 'Gerbang Sekolah', 'Diterima'),
(2, 2, 2, '2023-07-12', 'Tidak memakai dasi dan topi', 'Lapangan Upacara', 'Diterima'),
(3, 3, 3, '2023-07-15', 'Ketahuan menggunakan HP saat ulangan matematika', 'Ruang Kelas', 'Diterima'),
(1, 2, 1, '2023-08-05', 'Tidak memakai kaos kaki', 'Ruang Kelas', 'Diterima'),
(4, 1, 2, '2023-08-10', 'Terlambat 25 menit', 'Gerbang Sekolah', 'Diterima');

-- 10. Insert Prestasi (akan mengaktifkan trigger after_prestasi_insert)
INSERT INTO prestasi (id_siswa, id_poin_prestasi, id_guru, tanggal_prestasi, keterangan, dokumen_path, status_verifikasi) VALUES
(5, 1, 3, '2023-08-20', 'Juara 1 Lomba Web Design Kabupaten', '/dokumen/prestasi1.pdf', 'Diterima'),
(6, 2, 1, '2023-09-05', 'Juara 2 Lomba Cerdas Cermat Sekolah', '/dokumen/prestasi2.pdf', 'Diterima'),
(3, 3, 2, '2023-09-10', 'Dipilih sebagai siswa teladan bulan September', '/dokumen/prestasi3.pdf', 'Diterima'),
(2, 2, 3, '2023-10-15', 'Juara 2 Lomba Desain Poster Sekolah', '/dokumen/prestasi4.pdf', 'Diterima');

-- 11. Insert Tindak Lanjut (akan mengaktifkan trigger after_tindak_lanjut_insert jika ada surat)
INSERT INTO tindak_lanjut (id_pelanggaran, id_surat_pelanggaran, id_guru_penangan, tanggal_penanganan, jenis_penanganan, deskripsi_penanganan, hasil, status) VALUES
(3, 1, 1, '2023-07-16', 'Pembinaan', 'Pembinaan tentang kejujuran akademik', 'Siswa menyadari kesalahan dan berjanji tidak mengulangi', 'Selesai'),
(1, NULL, 2, '2023-07-11', 'Pembinaan', 'Pembinaan tentang kedisiplinan waktu', 'Siswa berjanji akan lebih disiplin', 'Selesai'),
(2, NULL, 3, '2023-07-13', 'Sanksi', 'Membersihkan kelas selama 3 hari', 'Siswa telah menjalani sanksi dengan baik', 'Selesai'),
(3, 1, 1, '2023-07-17', 'Sanksi', 'Skorsing 1 hari', 'Siswa telah menjalani skorsing', 'Selesai'),
(4, NULL, 2, '2023-08-06', 'Pembinaan', 'Pembinaan tentang kedisiplinan seragam', 'Siswa memahami pentingnya seragam lengkap', 'Selesai');

--------------------------------------   
-- 5. TRIGGER
--------------------------------------

DELIMITER //

-- Trigger untuk mencatat pelanggaran dan update poin siswa
CREATE TRIGGER after_pelanggaran_insert
AFTER INSERT ON pelanggaran
FOR EACH ROW
BEGIN
    -- Catat riwayat
    INSERT INTO riwayat_pelanggaran (id_pelanggaran, id_siswa, aksi, tanggal_aksi)
    VALUES (NEW.id_pelanggaran, NEW.id_siswa, 'INSERT', NOW());
    
    -- Update total poin pelanggaran siswa jika status diterima
    IF NEW.status_verifikasi = 'Diterima' THEN
        UPDATE siswa s
        JOIN poin_pelanggaran pp ON NEW.id_poin_pelanggaran = pp.id_poin_pelanggaran
        SET s.total_poin_pelanggaran = s.total_poin_pelanggaran + pp.bobot
        WHERE s.id_siswa = NEW.id_siswa;
    END IF;
END//
   
-- Trigger untuk update pelanggaran --
CREATE TRIGGER after_pelanggaran_update
AFTER UPDATE ON pelanggaran
FOR EACH ROW
BEGIN
    -- Catat riwayat
    INSERT INTO riwayat_pelanggaran (id_pelanggaran, id_siswa, aksi, tanggal_aksi)
    VALUES (NEW.id_pelanggaran, NEW.id_siswa, 'UPDATE', NOW());
    
    -- Jika status verifikasi berubah
    IF OLD.status_verifikasi != NEW.status_verifikasi THEN
        IF NEW.status_verifikasi = 'Diterima' THEN
            -- Tambahkan poin jika baru diterima
            UPDATE siswa s
            JOIN poin_pelanggaran pp ON NEW.id_poin_pelanggaran = pp.id_poin_pelanggaran
            SET s.total_poin_pelanggaran = s.total_poin_pelanggaran + pp.bobot
            WHERE s.id_siswa = NEW.id_siswa;
        ELSEIF OLD.status_verifikasi = 'Diterima' THEN
            -- Kurangi poin jika sebelumnya diterima sekarang tidak
            UPDATE siswa s
            JOIN poin_pelanggaran pp ON NEW.id_poin_pelanggaran = pp.id_poin_pelanggaran
            SET s.total_poin_pelanggaran = s.total_poin_pelanggaran - pp.bobot
            WHERE s.id_siswa = NEW.id_siswa;
        END IF;
    END IF;
END//

-- Trigger untuk mencatat prestasi dan update poin siswa
CREATE TRIGGER after_prestasi_insert
AFTER INSERT ON prestasi
FOR EACH ROW
BEGIN
    -- Catat riwayat
    INSERT INTO riwayat_prestasi (id_prestasi, id_siswa, aksi, tanggal_aksi)
    VALUES (NEW.id_prestasi, NEW.id_siswa, 'INSERT', NOW());
    
    -- Update total poin prestasi siswa jika status diterima
    IF NEW.status_verifikasi = 'Diterima' THEN
        UPDATE siswa s
        JOIN poin_prestasi pp ON NEW.id_poin_prestasi = pp.id_poin_prestasi
        SET s.total_poin_prestasi = s.total_poin_prestasi + pp.bobot
        WHERE s.id_siswa = NEW.id_siswa;
    END IF;
END//

-- Trigger untuk update prestasi
CREATE TRIGGER after_prestasi_update
AFTER UPDATE ON prestasi
FOR EACH ROW
BEGIN
    -- Catat riwayat
    INSERT INTO riwayat_prestasi (id_prestasi, id_siswa, aksi, tanggal_aksi)
    VALUES (NEW.id_prestasi, NEW.id_siswa, 'UPDATE', NOW());
    
    -- Jika status verifikasi berubah
    IF OLD.status_verifikasi != NEW.status_verifikasi THEN
        IF NEW.status_verifikasi = 'Diterima' THEN
            -- Tambahkan poin jika baru diterima
            UPDATE siswa s
            JOIN poin_prestasi pp ON NEW.id_poin_prestasi = pp.id_poin_prestasi
            SET s.total_poin_prestasi = s.total_poin_prestasi + pp.bobot
            WHERE s.id_siswa = NEW.id_siswa;
        ELSEIF OLD.status_verifikasi = 'Diterima' THEN
            -- Kurangi poin jika sebelumnya diterima sekarang tidak
            UPDATE siswa s
            JOIN poin_prestasi pp ON NEW.id_poin_prestasi = pp.id_poin_prestasi
            SET s.total_poin_prestasi = s.total_poin_prestasi - pp.bobot
            WHERE s.id_siswa = NEW.id_siswa;
        END IF;
    END IF;
END//

-- Trigger untuk mencatat surat pelanggaran
CREATE TRIGGER after_tindak_lanjut_insert
AFTER INSERT ON tindak_lanjut
FOR EACH ROW
BEGIN
    IF NEW.id_surat_pelanggaran IS NOT NULL THEN
        INSERT INTO riwayat_surat (id_tindak_lanjut, id_siswa, jenis_surat, tanggal_surat)
        SELECT 
            NEW.id_tindak_lanjut, 
            p.id_siswa, 
            sp.jenis_surat, 
            NOW()
        FROM 
            pelanggaran p
        JOIN 
            surat_pelanggaran sp ON NEW.id_surat_pelanggaran = sp.id_surat_pelanggaran
        WHERE 
            p.id_pelanggaran = NEW.id_pelanggaran;
    END IF;
END//

DELIMITER ;

-- 5. VIEWS (LAPORAN)

-- Rekap Pelanggaran Per Kelas/Jurusan
CREATE OR REPLACE VIEW rekap_pelanggaran_kelas AS
SELECT 
    k.id_kelas, 
    k.nama_kelas, 
    j.nama_jurusan,
    COUNT(p.id_pelanggaran) AS total_pelanggaran,
    SUM(pp.bobot) AS total_poin,
    tp.tahun_awal,
    tp.tahun_akhir,
    tp.semester
FROM 
    kelas k
JOIN 
    jurusan j ON k.id_jurusan = j.id_jurusan
JOIN 
    siswa s ON s.id_kelas = k.id_kelas
LEFT JOIN 
    pelanggaran p ON p.id_siswa = s.id_siswa AND p.status_verifikasi = 'Diterima'
LEFT JOIN 
    poin_pelanggaran pp ON p.id_poin_pelanggaran = pp.id_poin_pelanggaran
JOIN
    tahun_pelajaran tp ON k.id_tahun_pelajaran = tp.id_tahun_pelajaran
GROUP BY 
    k.id_kelas, j.id_jurusan, tp.id_tahun_pelajaran;

-- Rekap Prestasi Per Kelas/Jurusan
CREATE OR REPLACE VIEW rekap_prestasi_kelas AS
SELECT 
    k.id_kelas, 
    k.nama_kelas, 
    j.nama_jurusan,
    COUNT(pr.id_prestasi) AS total_prestasi,
    SUM(pp.bobot) AS total_poin,
    tp.tahun_awal,
    tp.tahun_akhir,
    tp.semester
FROM 
    kelas k
JOIN 
    jurusan j ON k.id_jurusan = j.id_jurusan
JOIN 
    siswa s ON s.id_kelas = k.id_kelas
LEFT JOIN 
    prestasi pr ON pr.id_siswa = s.id_siswa AND pr.status_verifikasi = 'Diterima'
LEFT JOIN 
    poin_prestasi pp ON pr.id_poin_prestasi = pp.id_poin_prestasi
JOIN
    tahun_pelajaran tp ON k.id_tahun_pelajaran = tp.id_tahun_pelajaran
GROUP BY 
    k.id_kelas, j.id_jurusan, tp.id_tahun_pelajaran;

-- Rekap Pelanggaran/Prestasi Siswa
CREATE OR REPLACE VIEW rekap_siswa AS
SELECT 
    s.id_siswa,
    s.nis,
    s.nama_siswa,
    k.nama_kelas,
    j.nama_jurusan,
    (SELECT COUNT(id_pelanggaran) FROM pelanggaran WHERE id_siswa = s.id_siswa AND status_verifikasi = 'Diterima') AS total_pelanggaran,
    s.total_poin_pelanggaran,
    (SELECT COUNT(id_prestasi) FROM prestasi WHERE id_siswa = s.id_siswa AND status_verifikasi = 'Diterima') AS total_prestasi,
    s.total_poin_prestasi,
    tp.tahun_awal,
    tp.tahun_akhir,
    tp.semester
FROM 
    siswa s
JOIN 
    kelas k ON s.id_kelas = k.id_kelas
JOIN 
    jurusan j ON k.id_jurusan = j.id_jurusan
JOIN
    tahun_pelajaran tp ON k.id_tahun_pelajaran = tp.id_tahun_pelajaran;

-- Rekap Pelanggaran Bulanan
CREATE OR REPLACE VIEW rekap_pelanggaran_bulanan AS
SELECT 
    YEAR(p.tanggal_pelanggaran) AS tahun,
    MONTH(p.tanggal_pelanggaran) AS bulan,
    k.nama_kelas,
    j.nama_jurusan,
    COUNT(p.id_pelanggaran) AS jumlah_pelanggaran,
    SUM(pp.bobot) AS total_poin
FROM 
    pelanggaran p
JOIN 
    siswa s ON p.id_siswa = s.id_siswa
JOIN 
    kelas k ON s.id_kelas = k.id_kelas
JOIN 
    jurusan j ON k.id_jurusan = j.id_jurusan
JOIN 
    poin_pelanggaran pp ON p.id_poin_pelanggaran = pp.id_poin_pelanggaran
WHERE 
    p.status_verifikasi = 'Diterima'
GROUP BY 
    YEAR(p.tanggal_pelanggaran), 
    MONTH(p.tanggal_pelanggaran),
    k.id_kelas,
    j.id_jurusan;

-- Rekap Prestasi Bulanan
CREATE OR REPLACE VIEW rekap_prestasi_bulanan AS
SELECT 
    YEAR(pr.tanggal_prestasi) AS tahun,
    MONTH(pr.tanggal_prestasi) AS bulan,
    k.nama_kelas,
    j.nama_jurusan,
    COUNT(pr.id_prestasi) AS jumlah_prestasi,
    SUM(pp.bobot) AS total_poin
FROM 
    prestasi pr
JOIN 
    siswa s ON pr.id_siswa = s.id_siswa
JOIN 
    kelas k ON s.id_kelas = k.id_kelas
JOIN 
    jurusan j ON k.id_jurusan = j.id_jurusan
JOIN 
    poin_prestasi pp ON pr.id_poin_prestasi = pp.id_poin_prestasi
WHERE 
    pr.status_verifikasi = 'Diterima'
GROUP BY 
    YEAR(pr.tanggal_prestasi), 
    MONTH(pr.tanggal_prestasi),
    k.id_kelas,
    j.id_jurusan;
