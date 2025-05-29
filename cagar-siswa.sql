---------------------------------------------------------------------
--- CAGAR-SISWA [CA]]tatan pelan[GAR]an dan presta[SI] si[SWA] ------
---------------------------------------------------------------------
-- 1. Hapus database jika sudah ada (opsional)
DROP DATABASE IF EXISTS cagarsiswa;
CREATE DATABASE cagarsiswa;
USE cagarsiswa;

-- Nonaktifkan foreign key checks sementara untuk menghindari error urutan
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Tabel Master Sekolah
CREATE TABLE jurusan (
    id_jurusan INT PRIMARY KEY AUTO_INCREMENT,
    kode_jurusan VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE tingkat_kelas (
    id_tingkat INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(20) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tahun_ajaran (
    id_ta INT PRIMARY KEY AUTO_INCREMENT,
    tahun_awal YEAR NOT NULL,
    tahun_akhir YEAR NOT NULL,
    nama VARCHAR(9) GENERATED ALWAYS AS (CONCAT(tahun_awal,'/',tahun_akhir)) STORED,
    status_aktif BOOLEAN DEFAULT FALSE,
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tahun CHECK (tahun_akhir = tahun_awal + 1)
);

CREATE TABLE semester (
    id_semester INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(10) NOT NULL,
    status_aktif BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE guru (
    nip VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    gender ENUM('L','P') NOT NULL,
    telepon VARCHAR(15),
    email VARCHAR(100),
    alamat TEXT,
    id_jurusan INT,
    jabatan VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_jurusan) REFERENCES jurusan(id_jurusan)
);

CREATE TABLE kelas (
    id_kelas INT PRIMARY KEY AUTO_INCREMENT,
    id_jurusan INT NOT NULL,
    id_tingkat INT NOT NULL,
    nama VARCHAR(20) NOT NULL,
    kapasitas INT DEFAULT 40,
    wali_kelas_nip VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_jurusan) REFERENCES jurusan(id_jurusan),
    FOREIGN KEY (id_tingkat) REFERENCES tingkat_kelas(id_tingkat),
    FOREIGN KEY (wali_kelas_nip) REFERENCES guru(nip)
);

-- 3. Tabel Master Siswa
CREATE TABLE siswa (
    nis VARCHAR(20) PRIMARY KEY,
    nisn VARCHAR(20) UNIQUE,
    nama VARCHAR(100) NOT NULL,
    gender ENUM('L','P') NOT NULL,
    tgl_lahir DATE NOT NULL,
    tempat_lahir VARCHAR(50),
    alamat TEXT,
    telepon VARCHAR(15),
    email VARCHAR(100),
    id_kelas INT NOT NULL,
    id_ta INT NOT NULL,
    status ENUM('aktif','lulus','mutasi','dropout') DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kelas) REFERENCES kelas(id_kelas),
    FOREIGN KEY (id_ta) REFERENCES tahun_ajaran(id_ta)
);

-- 4. Tabel Master Poin
CREATE TABLE kategori_prestasi (
    id_kategori_prestasi INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE prestasi (
    id_prestasi INT PRIMARY KEY AUTO_INCREMENT,
    id_kategori_prestasi INT,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    poin INT NOT NULL CHECK (poin > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kategori_prestasi) REFERENCES kategori_prestasi(id_kategori_prestasi)
);

CREATE TABLE kategori_pelanggaran (
    id_kategori_pelanggaran INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    tingkat ENUM('ringan','sedang','berat') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pelanggaran (
    id_pelanggaran INT PRIMARY KEY AUTO_INCREMENT,
    id_kategori_pelanggaran INT,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    poin INT NOT NULL CHECK (poin > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_kategori_pelanggaran) REFERENCES kategori_pelanggaran(id_kategori_pelanggaran)
);

-- 5. Tabel Master Tindak Lanjut
CREATE TABLE reward (
    id_reward INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    poin_min INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE penanganan (
    id_penanganan INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    poin_min INT NOT NULL,
    poin_max INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Tabel Transaksi
CREATE TABLE riwayat_prestasi (
    id_riwayat_prestasi INT PRIMARY KEY AUTO_INCREMENT,
    nis VARCHAR(20) NOT NULL,
    id_prestasi INT NOT NULL,
    id_semester INT NOT NULL,
    id_ta INT NOT NULL,
    tanggal DATE NOT NULL,
    keterangan TEXT,
    poin INT NOT NULL,
    disetujui_oleh VARCHAR(20),
    status ENUM('pending','disetujui','ditolak') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (nis) REFERENCES siswa(nis),
    FOREIGN KEY (id_prestasi) REFERENCES prestasi(id_prestasi),
    FOREIGN KEY (id_semester) REFERENCES semester(id_semester),
    FOREIGN KEY (id_ta) REFERENCES tahun_ajaran(id_ta),
    FOREIGN KEY (disetujui_oleh) REFERENCES guru(nip)
);

CREATE TABLE riwayat_pelanggaran (
    id_riwayat_pelanggaran INT PRIMARY KEY AUTO_INCREMENT,
    nis VARCHAR(20) NOT NULL,
    id_pelanggaran INT NOT NULL,
    id_semester INT NOT NULL,
    id_ta INT NOT NULL,
    tanggal DATE NOT NULL,
    keterangan TEXT,
    poin INT NOT NULL,
    dilaporkan_oleh VARCHAR(20),
    status ENUM('pending','diverifikasi','ditolak') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (nis) REFERENCES siswa(nis),
    FOREIGN KEY (id_pelanggaran) REFERENCES pelanggaran(id_pelanggaran),
    FOREIGN KEY (id_semester) REFERENCES semester(id_semester),
    FOREIGN KEY (id_ta) REFERENCES tahun_ajaran(id_ta),
    FOREIGN KEY (dilaporkan_oleh) REFERENCES guru(nip)
);

CREATE TABLE tindak_lanjut (
    id_tindak_lanjut INT PRIMARY KEY AUTO_INCREMENT,
    nis VARCHAR(20) NOT NULL,
    id_riwayat_pelanggaran INT,
    id_penanganan INT,
    tanggal DATE NOT NULL,
    keterangan TEXT,
    ditangani_oleh VARCHAR(20),
    status ENUM('pending','proses','selesai') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (nis) REFERENCES siswa(nis),
    FOREIGN KEY (id_riwayat_pelanggaran) REFERENCES riwayat_pelanggaran(id_riwayat_pelanggaran),
    FOREIGN KEY (id_penanganan) REFERENCES penanganan(id_penanganan),
    FOREIGN KEY (ditangani_oleh) REFERENCES guru(nip)
);

CREATE TABLE pemberian_reward (
    id_pemberian_reward INT PRIMARY KEY AUTO_INCREMENT,
    nis VARCHAR(20) NOT NULL,
    id_reward INT NOT NULL,
    tanggal DATE NOT NULL,
    keterangan TEXT,
    diberikan_oleh VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nis) REFERENCES siswa(nis),
    FOREIGN KEY (id_reward) REFERENCES reward(id_reward),
    FOREIGN KEY (diberikan_oleh) REFERENCES guru(nip)
);

CREATE TABLE mutasi (
    id_mutasi INT PRIMARY KEY AUTO_INCREMENT,
    nis VARCHAR(20) NOT NULL,
    jenis ENUM('naik_kelas','tinggal_kelas','mutasi_masuk','mutasi_keluar','lulus','dropout') NOT NULL,
    tanggal DATE NOT NULL,
    id_kelas_baru INT,
    id_ta_baru INT,
    keterangan TEXT,
    dibuat_oleh VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (nis) REFERENCES siswa(nis),
    FOREIGN KEY (id_kelas_baru) REFERENCES kelas(id_kelas),
    FOREIGN KEY (id_ta_baru) REFERENCES tahun_ajaran(id_ta),
    FOREIGN KEY (dibuat_oleh) REFERENCES guru(nip)
);

-- 7. Insert Data Master
-- Jurusan
INSERT INTO jurusan (kode_jurusan, nama, deskripsi) VALUES
('TKJ', 'Teknik Komputer dan Jaringan', 'Jurusan yang mempelajari tentang jaringan komputer dan perangkat keras'),
('RPL', 'Rekayasa Perangkat Lunak', 'Jurusan yang mempelajari tentang pemrograman dan pengembangan software'),
('MM', 'Multimedia', 'Jurusan yang mempelajari tentang desain grafis dan produksi multimedia'),
('AK', 'Akuntansi', 'Jurusan yang mempelajari tentang keuangan dan akuntansi'),
('TP', 'Teknik Pemesinan', 'Jurusan yang mempelajari tentang mesin dan perbengkelan');

-- Tingkat Kelas
INSERT INTO tingkat_kelas (nama, deskripsi) VALUES
('X', 'Kelas 10'),
('XI', 'Kelas 11'),
('XII', 'Kelas 12');

-- Tahun Ajaran
INSERT INTO tahun_ajaran (tahun_awal, tahun_akhir, status_aktif, tanggal_mulai, tanggal_selesai) VALUES
(2023, 2024, TRUE, '2023-07-15', '2024-06-15'),
(2022, 2023, FALSE, '2022-07-15', '2023-06-15'),
(2021, 2022, FALSE, '2021-07-15', '2022-06-15');

-- Semester
INSERT INTO semester (nama, status_aktif) VALUES
('Ganjil', TRUE),
('Genap', FALSE),
('Ganjil', FALSE),
('Genap', FALSE);

-- Guru
INSERT INTO guru (nip, nama, gender, telepon, email, id_jurusan, jabatan) VALUES
('198001012003121001', 'Dr. Ahmad S.Pd, M.Kom', 'L', '081234567890', 'ahmad@smk.example.com', 2, 'Kepala Sekolah'),
('198102022003121002', 'Budi Santoso, S.Kom', 'L', '081234567891', 'budi@smk.example.com', 1, 'Wali Kelas'),
('198203032003122003', 'Citra Dewi, S.Pd', 'P', '081234567892', 'citra@smk.example.com', 2, 'Wali Kelas'),
('198304042003122004', 'Diana Putri, S.E', 'P', '081234567893', 'diana@smk.example.com', 4, 'Wali Kelas'),
('198405052003121005', 'Eko Prasetyo, S.T', 'L', '081234567894', 'eko@smk.example.com', 3, 'Wali Kelas');

-- Kelas
INSERT INTO kelas (id_jurusan, id_tingkat, nama, wali_kelas_nip) VALUES
(1, 1, 'X-TKJ-1', '198102022003121002'),
(1, 1, 'X-TKJ-2', NULL),
(2, 1, 'X-RPL-1', '198203032003122003'),
(2, 2, 'XI-RPL-1', NULL),
(3, 3, 'XII-MM-1', '198405052003121005'),
(4, 2, 'XI-AK-1', '198304042003122004');

-- Kategori Prestasi
INSERT INTO kategori_prestasi (nama, deskripsi) VALUES
('Akademik', 'Prestasi di bidang akademik'),
('Non-Akademik', 'Prestasi di bidang non-akademik'),
('Sosial', 'Prestasi di bidang sosial kemasyarakatan'),
('Seni', 'Prestasi di bidang seni dan budaya'),
('Olahraga', 'Prestasi di bidang olahraga');

-- Prestasi
INSERT INTO prestasi (id_kategori_prestasi, nama, deskripsi, poin) VALUES
(1, 'Juara 1 Kelas', 'Mendapatkan peringkat 1 di kelas', 50),
(1, 'Juara 2 Kelas', 'Mendapatkan peringkat 2 di kelas', 40),
(1, 'Juara 3 Kelas', 'Mendapatkan peringkat 3 di kelas', 30),
(2, 'Juara 1 Lomba Coding', 'Memenangkan lomba coding tingkat sekolah', 100),
(2, 'Juara 2 Lomba Coding', 'Juara kedua lomba coding tingkat sekolah', 80),
(3, 'Pengurus OSIS', 'Aktif sebagai pengurus OSIS selama 1 tahun', 60),
(4, 'Juara 1 Lomba Melukis', 'Memenangkan lomba melukis tingkat kota', 120),
(5, 'Juara 1 Lomba Basket', 'Memenangkan lomba basket antar sekolah', 150);

-- Kategori Pelanggaran
INSERT INTO kategori_pelanggaran (nama, deskripsi, tingkat) VALUES
('Keterlambatan', 'Terlambat datang ke sekolah', 'ringan'),
('Seragam', 'Tidak memakai seragam sesuai aturan', 'ringan'),
('Perilaku', 'Perilaku tidak sopan', 'sedang'),
('Bolos', 'Tidak masuk tanpa keterangan', 'berat'),
('Kekerasan', 'Melakukan tindak kekerasan', 'berat');

-- Pelanggaran
INSERT INTO pelanggaran (id_kategori_pelanggaran, nama, deskripsi, poin) VALUES
(1, 'Terlambat < 15 menit', 'Terlambat kurang dari 15 menit', 5),
(1, 'Terlambat > 15 menit', 'Terlambat lebih dari 15 menit', 10),
(2, 'Seragam tidak lengkap', 'Tidak memakai atribut lengkap', 10),
(2, 'Baju tidak dimasukkan', 'Baju tidak dimasukkan untuk siswa putra', 5),
(3, 'Berkata kasar', 'Mengucapkan kata-kata tidak sopan', 20),
(4, 'Bolos 1 jam pelajaran', 'Tidak mengikuti 1 jam pelajaran tanpa keterangan', 30),
(4, 'Bolos 1 hari', 'Tidak masuk sekolah tanpa keterangan', 50),
(5, 'Berkelahi', 'Terlibat perkelahian', 100);

-- Reward
INSERT INTO reward (nama, deskripsi, poin_min) VALUES
('Piagam Penghargaan', 'Piagam penghargaan untuk poin prestasi mencapai 100', 100),
('Beasiswa Prestasi', 'Beasiswa untuk poin prestasi mencapai 300', 300),
('Bebas Ujian', 'Bebas ujian akhir untuk poin prestasi mencapai 500', 500),
('Study Tour', 'Mendapatkan study tour untuk poin prestasi mencapai 200', 200);

-- Penanganan
INSERT INTO penanganan (nama, deskripsi, poin_min, poin_max) VALUES
('Peringatan Lisan', 'Peringatan secara lisan oleh wali kelas', 20, 50),
('Peringatan Tertulis', 'Surat peringatan dari sekolah', 50, 100),
('Pemanggilan Orang Tua', 'Orang tua dipanggil ke sekolah', 100, 200),
('Skorsing', 'Tidak boleh mengikuti pelajaran selama 1-3 hari', 200, NULL);

-- Siswa
INSERT INTO siswa (nis, nisn, nama, gender, tgl_lahir, tempat_lahir, id_kelas, id_ta) VALUES
('S001', '1234567890', 'Andi Wijaya', 'L', '2007-05-10', 'Jakarta', 1, 1),
('S002', '1234567891', 'Bella Putri', 'P', '2007-08-15', 'Bandung', 1, 1),
('S003', '1234567892', 'Cahyo Pratama', 'L', '2007-03-22', 'Surabaya', 3, 1),
('S004', '1234567893', 'Dina Amelia', 'P', '2006-11-30', 'Yogyakarta', 4, 1),
('S005', '1234567894', 'Eko Nugroho', 'L', '2006-09-05', 'Semarang', 5, 1),
('S006', '1234567895', 'Fira Anjani', 'P', '2005-12-12', 'Malang', 6, 1);

-- Riwayat Prestasi
INSERT INTO riwayat_prestasi (nis, id_prestasi, id_semester, id_ta, tanggal, keterangan, poin, disetujui_oleh, status)
VALUES 
('S001', 1, 1, 1, '2023-08-20', 'Juara 1 Kelas X-TKJ-1 Semester Ganjil', 50, '198001012003121001', 'disetujui'),
('S002', 2, 1, 1, '2023-08-20', 'Juara 2 Kelas X-TKJ-1 Semester Ganjil', 40, '198001012003121001', 'disetujui'),
('S003', 4, 1, 1, '2023-09-15', 'Juara 1 Lomba Coding Sekolah', 100, '198203032003122003', 'disetujui'),
('S004', 6, 1, 1, '2023-10-10', 'Pengurus OSIS aktif', 60, '198203032003122003', 'disetujui'),
('S005', 8, 1, 1, '2023-11-05', 'Juara 1 Basket Antar Sekolah', 150, '198405052003121005', 'disetujui');

-- Riwayat Pelanggaran
INSERT INTO riwayat_pelanggaran (nis, id_pelanggaran, id_semester, id_ta, tanggal, keterangan, poin, dilaporkan_oleh, status)
VALUES 
('S001', 1, 1, 1, '2023-08-22', 'Terlambat 10 menit', 5, '198102022003121002', 'diverifikasi'),
('S001', 3, 1, 1, '2023-09-10', 'Tidak memakai dasi', 10, '198102022003121002', 'diverifikasi'),
('S003', 5, 1, 1, '2023-10-05', 'Berkata kasar kepada teman', 20, '198203032003122003', 'diverifikasi'),
('S006', 7, 1, 1, '2023-11-12', 'Bolos sekolah tanpa keterangan', 50, '198304042003122004', 'diverifikasi');


-- 8. Views
CREATE VIEW view_ringkasan_poin_siswa AS
SELECT 
    s.nis, 
    s.nama, 
    k.nama AS kelas, 
    j.nama AS jurusan,
    t.nama AS tingkat,
    ta.nama AS tahun_ajaran,
    sm.nama AS semester,
    COALESCE((
        SELECT SUM(rp.poin) 
        FROM riwayat_prestasi rp 
        WHERE rp.nis = s.nis 
        AND rp.id_semester = sm.id_semester 
        AND rp.id_ta = ta.id_ta
        AND rp.status = 'disetujui'
    ), 0) AS total_poin_prestasi,
    COALESCE((
        SELECT SUM(rl.poin) 
        FROM riwayat_pelanggaran rl 
        WHERE rl.nis = s.nis 
        AND rl.id_semester = sm.id_semester 
        AND rl.id_ta = ta.id_ta
        AND rl.status = 'diverifikasi'
    ), 0) AS total_poin_pelanggaran,
    COALESCE((
        SELECT SUM(rp.poin) 
        FROM riwayat_prestasi rp 
        WHERE rp.nis = s.nis 
        AND rp.id_semester = sm.id_semester 
        AND rp.id_ta = ta.id_ta
        AND rp.status = 'disetujui'
    ), 0) - COALESCE((
        SELECT SUM(rl.poin) 
        FROM riwayat_pelanggaran rl 
        WHERE rl.nis = s.nis 
        AND rl.id_semester = sm.id_semester 
        AND rl.id_ta = ta.id_ta
        AND rl.status = 'diverifikasi'
    ), 0) AS total_poin_bersih
FROM 
    siswa s
JOIN kelas k ON s.id_kelas = k.id_kelas
JOIN jurusan j ON k.id_jurusan = j.id_jurusan
JOIN tingkat_kelas t ON k.id_tingkat = t.id_tingkat
JOIN tahun_ajaran ta ON s.id_ta = ta.id_ta
JOIN semester sm ON sm.status_aktif = TRUE;

CREATE VIEW view_riwayat_lengkap_siswa AS
SELECT 
    s.nis,
    s.nama AS nama_siswa,
    k.nama AS kelas,
    j.nama AS jurusan,
    'Prestasi' AS jenis,
    p.nama AS aktivitas,
    p.poin,
    rp.tanggal,
    rp.keterangan,
    sm.nama AS semester,
    ta.nama AS tahun_ajaran,
    g.nama AS disetujui_oleh
FROM 
    siswa s
JOIN riwayat_prestasi rp ON s.nis = rp.nis
JOIN prestasi p ON rp.id_prestasi = p.id_prestasi
JOIN kelas k ON s.id_kelas = k.id_kelas
JOIN jurusan j ON k.id_jurusan = j.id_jurusan
JOIN semester sm ON rp.id_semester = sm.id_semester
JOIN tahun_ajaran ta ON rp.id_ta = ta.id_ta
LEFT JOIN guru g ON rp.disetujui_oleh = g.nip
WHERE rp.status = 'disetujui'

UNION ALL

SELECT 
    s.nis,
    s.nama AS nama_siswa,
    k.nama AS kelas,
    j.nama AS jurusan,
    'Pelanggaran' AS jenis,
    pl.nama AS aktivitas,
    -pl.poin AS poin,
    rl.tanggal,
    rl.keterangan,
    sm.nama AS semester,
    ta.nama AS tahun_ajaran,
    g.nama AS dilaporkan_oleh
FROM 
    siswa s
JOIN riwayat_pelanggaran rl ON s.nis = rl.nis
JOIN pelanggaran pl ON rl.id_pelanggaran = pl.id_pelanggaran
JOIN kelas k ON s.id_kelas = k.id_kelas
JOIN jurusan j ON k.id_jurusan = j.id_jurusan
JOIN semester sm ON rl.id_semester = sm.id_semester
JOIN tahun_ajaran ta ON rl.id_ta = ta.id_ta
LEFT JOIN guru g ON rl.dilaporkan_oleh = g.nip
WHERE rl.status = 'diverifikasi'
ORDER BY nis, tanggal DESC;

CREATE VIEW view_rekap_kelas AS
SELECT 
    k.id_kelas,
    k.nama AS kelas,
    j.nama AS jurusan,
    t.nama AS tingkat,
    ta.nama AS tahun_ajaran,
    COUNT(s.nis) AS jumlah_siswa,
    AVG((
        SELECT COALESCE(SUM(rp.poin), 0)
        FROM riwayat_prestasi rp 
        WHERE rp.nis = s.nis 
        AND rp.id_ta = ta.id_ta
        AND rp.status = 'disetujui'
    ) - (
        SELECT COALESCE(SUM(rl.poin), 0)
        FROM riwayat_pelanggaran rl 
        WHERE rl.nis = s.nis 
        AND rl.id_ta = ta.id_ta
        AND rl.status = 'diverifikasi'
    )) AS rata_poin_bersih,
    (
        SELECT COUNT(pr.id_pemberian_reward)
        FROM pemberian_reward pr
        JOIN siswa s2 ON pr.nis = s2.nis
        WHERE s2.id_kelas = k.id_kelas
        AND s2.id_ta = ta.id_ta
    ) AS jumlah_reward,
    (
        SELECT COUNT(tl.id_tindak_lanjut)
        FROM tindak_lanjut tl
        JOIN siswa s3 ON tl.nis = s3.nis
        WHERE s3.id_kelas = k.id_kelas
        AND s3.id_ta = ta.id_ta
    ) AS jumlah_tindak_lanjut
FROM 
    kelas k
JOIN jurusan j ON k.id_jurusan = j.id_jurusan
JOIN tingkat_kelas t ON k.id_tingkat = t.id_tingkat
JOIN siswa s ON k.id_kelas = s.id_kelas
JOIN tahun_ajaran ta ON s.id_ta = ta.id_ta
GROUP BY k.id_kelas, k.nama, j.nama, t.nama, ta.nama;

USE cagarsiswa;
-- 9. Triggers
DELIMITER //

CREATE TRIGGER after_tahun_ajaran_insert
BEFORE INSERT ON tahun_ajaran
FOR EACH ROW
BEGIN
    -- Hanya boleh ada satu tahun ajaran aktif
    IF NEW.status_aktif = TRUE THEN
        UPDATE tahun_ajaran SET status_aktif = FALSE WHERE status_aktif = TRUE;
    END IF;
END//

CREATE TRIGGER after_semester_insert
BEFORE INSERT ON semester
FOR EACH ROW
BEGIN
    -- Hanya boleh ada satu semester aktif
    IF NEW.status_aktif = TRUE THEN
        UPDATE semester SET status_aktif = FALSE WHERE status_aktif = TRUE;
    END IF;
END//

CREATE TRIGGER after_riwayat_prestasi_insert
AFTER INSERT ON riwayat_prestasi
FOR EACH ROW
BEGIN
    -- Jika prestasi disetujui, cek reward
    IF NEW.status = 'disetujui' THEN
        CALL sp_generate_reward(NEW.nis);
    END IF;
END//

CREATE TRIGGER after_riwayat_pelanggaran_insert
AFTER INSERT ON riwayat_pelanggaran
FOR EACH ROW
BEGIN
    -- Jika pelanggaran diverifikasi, cek penanganan
    IF NEW.status = 'diverifikasi' THEN
        CALL sp_generate_penanganan(NEW.nis);
    END IF;
END//

CREATE TRIGGER before_riwayat_prestasi_update
BEFORE UPDATE ON riwayat_prestasi
FOR EACH ROW
BEGIN
    -- Jika status berubah menjadi disetujui, cek reward
    IF NEW.status = 'disetujui' AND OLD.status != 'disetujui' THEN
        CALL sp_generate_reward(NEW.nis);
    END IF;
END//

CREATE TRIGGER before_riwayat_pelanggaran_update
BEFORE UPDATE ON riwayat_pelanggaran
FOR EACH ROW
BEGIN
    -- Jika status berubah menjadi diverifikasi, cek penanganan
    IF NEW.status = 'diverifikasi' AND OLD.status != 'diverifikasi' THEN
        CALL sp_generate_penanganan(NEW.nis);
    END IF;
END//

DELIMITER ;

-- 10. Stored Procedures
DELIMITER //

CREATE PROCEDURE sp_naik_kelas(
    IN p_nis VARCHAR(20),
    IN p_id_kelas_baru INT,
    IN p_id_ta_baru INT,
    IN p_dibuat_oleh VARCHAR(20)
)
BEGIN
    DECLARE v_id_kelas_lama INT;
    DECLARE v_id_tingkat_lama INT;
    DECLARE v_id_tingkat_baru INT;
    
    -- Dapatkan data kelas lama
    SELECT s.id_kelas, k.id_tingkat INTO v_id_kelas_lama, v_id_tingkat_lama
    FROM siswa s
    JOIN kelas k ON s.id_kelas = k.id_kelas
    WHERE s.nis = p_nis;
    
    -- Dapatkan tingkat kelas baru
    SELECT id_tingkat INTO v_id_tingkat_baru
    FROM kelas
    WHERE id_kelas = p_id_kelas_baru;
    
    -- Validasi kenaikan kelas
    IF v_id_tingkat_baru <= v_id_tingkat_lama THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Tidak bisa naik kelas ke tingkat yang sama atau lebih rendah';
    END IF;
    
    -- Update kelas siswa
    UPDATE siswa 
    SET id_kelas = p_id_kelas_baru, 
        id_ta = p_id_ta_baru,
        updated_at = NOW()
    WHERE nis = p_nis;
    
    -- Catat mutasi
    INSERT INTO mutasi (nis, jenis, tanggal, id_kelas_baru, id_ta_baru, keterangan, dibuat_oleh)
    VALUES (p_nis, 'naik_kelas', CURDATE(), p_id_kelas_baru, p_id_ta_baru,
            'Kenaikan kelas berdasarkan sistem poin', p_dibuat_oleh);
    
    SELECT CONCAT('Siswa dengan NIS ', p_nis, ' berhasil naik kelas') AS hasil;
END //

CREATE PROCEDURE sp_generate_reward(IN p_nis VARCHAR(20))
BEGIN
    DECLARE v_total_poin INT;
    
    -- Hitung total poin prestasi
    SELECT COALESCE(SUM(poin), 0) INTO v_total_poin
    FROM riwayat_prestasi
    WHERE nis = p_nis
    AND status = 'disetujui';
    
    -- Berikan reward yang memenuhi syarat dan belum diberikan
    INSERT INTO pemberian_reward (nis, id_reward, tanggal)
    SELECT p_nis, r.id_reward, CURDATE()
    FROM reward r
    WHERE v_total_poin >= r.poin_min
    AND NOT EXISTS (
        SELECT 1 FROM pemberian_reward pr 
        WHERE pr.nis = p_nis 
        AND pr.id_reward = r.id_reward
    );
    
    SELECT CONCAT('Generate reward untuk siswa ', p_nis, ' selesai') AS hasil;
END //

CREATE PROCEDURE sp_generate_penanganan(IN p_nis VARCHAR(20))
BEGIN
    DECLARE v_total_poin INT;
    
    -- Hitung total poin pelanggaran
    SELECT COALESCE(SUM(poin), 0) INTO v_total_poin
    FROM riwayat_pelanggaran
    WHERE nis = p_nis
    AND status = 'diverifikasi';
    
    -- Berikan penanganan yang memenuhi syarat
    INSERT INTO tindak_lanjut (nis, id_penanganan, tanggal, status)
    SELECT p_nis, p.id_penanganan, CURDATE(), 'pending'
    FROM penanganan p
    WHERE v_total_poin >= p.poin_min
    AND (p.poin_max IS NULL OR v_total_poin <= p.poin_max)
    AND NOT EXISTS (
        SELECT 1 FROM tindak_lanjut tl
        WHERE tl.nis = p_nis
        AND tl.id_penanganan = p.id_penanganan
        AND tl.status != 'selesai'
    );
    
    SELECT CONCAT('Generate penanganan untuk siswa ', p_nis, ' selesai') AS hasil;
END //

DELIMITER ;
