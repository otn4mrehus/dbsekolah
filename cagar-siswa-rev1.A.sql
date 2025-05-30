-------------------------------------------------------------------------
------------------------  CAGAR SISWA REV1.A  ---------------------------
-------------------------------------------------------------------------
-- Hapus database jika sudah ada (hati-hati di production)
DROP DATABASE IF EXISTS cagarsiswasatu;
CREATE DATABASE cagarsiswasatu;
USE cagarsiswasatu;

-- 1. DATA MASTER

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

-- 2. DATA TRANSAKSI

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

-- 3. TABEL RIWAYAT (untuk trigger)

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

-- 4. TRIGGER

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

-- Trigger untuk update pelanggaran
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
