## CAGAR-SISWA Rev1.A
###### [Ca]tatan Pelang[gar]an dan Presta[si] Ssi[swa] Rev1.A
#### Skema SQL :
````
TABEL UTAMA
─────────────────────────────────────────────────────────────────────
1. tahun_pelajaran
   ├─ id_tahun_pelajaran (PK)
   ├─ tahun_awal
   ├─ tahun_akhir
   ├─ semester
   └─ status_aktif

2. jurusan
   ├─ id_jurusan (PK)
   ├─ kode_jurusan
   ├─ nama_jurusan
   └─ deskripsi

3. guru
   ├─ id_guru (PK)
   ├─ nip
   ├─ nama_guru
   ├─ jenis_kelamin
   ├─ alamat
   ├─ no_telp
   ├─ email
   └─ status_aktif

4. poin_pelanggaran
   ├─ id_poin_pelanggaran (PK)
   ├─ kode_pelanggaran
   ├─ nama_pelanggaran
   ├─ kategori
   ├─ bobot
   └─ deskripsi

5. poin_prestasi
   ├─ id_poin_prestasi (PK)
   ├─ kode_prestasi
   ├─ nama_prestasi
   ├─ kategori
   ├─ bobot
   └─ deskripsi

6. surat_pelanggaran
   ├─ id_surat_pelanggaran (PK)
   ├─ jenis_surat
   ├─ min_poin
   ├─ max_poin
   ├─ deskripsi
   └─ konsekuensi

7. kelas
   ├─ id_kelas (PK)
   ├─ id_jurusan (FK → jurusan)
   ├─ id_tahun_pelajaran (FK → tahun_pelajaran)
   ├─ tingkat
   ├─ nama_kelas
   └─ wali_kelas (FK → guru)

8. siswa
   ├─ id_siswa (PK)
   ├─ nis
   ├─ nisn
   ├─ nama_siswa
   ├─ jenis_kelamin
   ├─ tempat_lahir
   ├─ tanggal_lahir
   ├─ alamat
   ├─ no_telp
   ├─ id_kelas (FK → kelas)
   ├─ total_poin_pelanggaran
   └─ total_poin_prestasi

TABEL TRANSAKSI
─────────────────────────────────────────────────────────────────────
9. pelanggaran
   ├─ id_pelanggaran (PK)
   ├─ id_siswa (FK → siswa)
   ├─ id_poin_pelanggaran (FK → poin_pelanggaran)
   ├─ id_guru (FK → guru)
   ├─ tanggal_pelanggaran
   ├─ keterangan
   ├─ lokasi
   └─ status_verifikasi

10. prestasi
    ├─ id_prestasi (PK)
    ├─ id_siswa (FK → siswa)
    ├─ id_poin_prestasi (FK → poin_prestasi)
    ├─ id_guru (FK → guru)
    ├─ tanggal_prestasi
    ├─ keterangan
    ├─ dokumen_path
    └─ status_verifikasi

11. tindak_lanjut
    ├─ id_tindak_lanjut (PK)
    ├─ id_pelanggaran (FK → pelanggaran)
    ├─ id_surat_pelanggaran (FK → surat_pelanggaran)
    ├─ id_guru_penangan (FK → guru)
    ├─ tanggal_penanganan
    ├─ jenis_penanganan
    ├─ deskripsi_penanganan
    ├─ hasil
    └─ status

TABEL RIWAYAT (untuk trigger)
─────────────────────────────────────────────────────────────────────
12. riwayat_pelanggaran
    ├─ id_riwayat (PK)
    ├─ id_pelanggaran (FK → pelanggaran)
    ├─ id_siswa (FK → siswa)
    ├─ aksi
    └─ tanggal_aksi

13. riwayat_prestasi
    ├─ id_riwayat (PK)
    ├─ id_prestasi (FK → prestasi)
    ├─ id_siswa (FK → siswa)
    ├─ aksi
    └─ tanggal_aksi

14. riwayat_surat
    ├─ id_riwayat (PK)
    ├─ id_tindak_lanjut (FK → tindak_lanjut)
    ├─ id_siswa (FK → siswa)
    ├─ jenis_surat
    └─ tanggal_surat

VIEW (LAPORAN)
─────────────────────────────────────────────────────────────────────
1. rekap_pelanggaran_kelas
2. rekap_prestasi_kelas
3. rekap_siswa
4. rekap_pelanggaran_bulanan
5. rekap_prestasi_bulanan

RELASI UTAMA
─────────────────────────────────────────────────────────────────────
1. tahun_pelajaran (1) → (n) kelas
2. jurusan (1) → (n) kelas
3. guru (1) → (n) kelas (sebagai wali kelas)
4. guru (1) → (n) pelanggaran (sebagai pencatat)
5. guru (1) → (n) prestasi (sebagai pencatat)
6. guru (1) → (n) tindak_lanjut (sebagai penanggung jawab)
7. kelas (1) → (n) siswa
8. siswa (1) → (n) pelanggaran
9. siswa (1) → (n) prestasi
10. poin_pelanggaran (1) → (n) pelanggaran
11. poin_prestasi (1) → (n) prestasi
12. pelanggaran (1) → (n) tindak_lanjut
13. surat_pelanggaran (1) → (n) tindak_lanjut
````

#### Uji Coba :
````
SELECT * FROM riwayat_pelanggaran;
SELECT * FROM riwayat_prestasi;
SELECT * FROM riwayat_surat;
SELECT nis, nama_siswa, total_poin_pelanggaran, total_poin_prestasi FROM siswa;
````
