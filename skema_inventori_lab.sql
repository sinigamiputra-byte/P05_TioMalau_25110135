-- =====================================================================
-- Skema dan data contoh: Sistem Inventori Laboratorium
-- Praktikum Pertemuan 5 - Pemrograman Aplikasi Client Server
-- Jalankan pada database yang sedang DIPILIH di phpMyAdmin.
-- PERINGATAN: lima tabel di bawah akan dihapus lalu dibuat ulang.
-- =====================================================================

DROP TABLE IF EXISTS detail_peminjaman;
DROP TABLE IF EXISTS peminjaman;
DROP TABLE IF EXISTS pengguna;
DROP TABLE IF EXISTS barang;
DROP TABLE IF EXISTS kategori;

-- ---------------------------------------------------------------------
-- 1. Tabel master
-- ---------------------------------------------------------------------
CREATE TABLE kategori (
    id_kategori   INT         NOT NULL AUTO_INCREMENT,
    nama_kategori VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_kategori),
    CONSTRAINT nama_kategori UNIQUE (nama_kategori)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE barang (
    kode_barang     VARCHAR(20)  NOT NULL,
    nama_barang     VARCHAR(100) NOT NULL,
    id_kategori     INT          NOT NULL,
    jumlah_tersedia INT          NOT NULL DEFAULT 0,
    keterangan      VARCHAR(255) NULL,
    PRIMARY KEY (kode_barang),
    CONSTRAINT chk_barang_jumlah CHECK (jumlah_tersedia >= 0),
    CONSTRAINT fk_barang_kategori FOREIGN KEY (id_kategori)
        REFERENCES kategori (id_kategori)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE pengguna (
    id_pengguna   INT          NOT NULL AUTO_INCREMENT,
    username      VARCHAR(30)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nama_lengkap  VARCHAR(100) NOT NULL,
    peran         ENUM('admin', 'petugas') NOT NULL DEFAULT 'petugas',
    aktif         TINYINT(1)   NOT NULL DEFAULT 1,
    dibuat_pada   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_pengguna),
    CONSTRAINT uq_pengguna_username UNIQUE (username)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. Tabel transaksi
-- ---------------------------------------------------------------------
CREATE TABLE peminjaman (
    id_peminjaman   INT          NOT NULL AUTO_INCREMENT,
    nomor_transaksi VARCHAR(20)  NOT NULL,
    nama_peminjam   VARCHAR(100) NOT NULL,
    tanggal_pinjam  DATE         NOT NULL,
    tanggal_kembali DATE         NULL,
    status          ENUM('DIPINJAM', 'DIKEMBALIKAN') NOT NULL DEFAULT 'DIPINJAM',
    id_pengguna     INT          NOT NULL,
    PRIMARY KEY (id_peminjaman),
    CONSTRAINT uq_peminjaman_nomor UNIQUE (nomor_transaksi),
    CONSTRAINT chk_peminjaman_tanggal
        CHECK (tanggal_kembali IS NULL OR tanggal_kembali >= tanggal_pinjam),
    CONSTRAINT fk_peminjaman_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES pengguna (id_pengguna)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE detail_peminjaman (
    id_detail     INT         NOT NULL AUTO_INCREMENT,
    id_peminjaman INT         NOT NULL,
    kode_barang   VARCHAR(20) NOT NULL,
    jumlah        INT         NOT NULL,
    PRIMARY KEY (id_detail),
    CONSTRAINT uq_detail_barang UNIQUE (id_peminjaman, kode_barang),
    CONSTRAINT chk_detail_jumlah CHECK (jumlah > 0),
    CONSTRAINT fk_detail_peminjaman FOREIGN KEY (id_peminjaman)
        REFERENCES peminjaman (id_peminjaman)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_barang FOREIGN KEY (kode_barang)
        REFERENCES barang (kode_barang)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. Data contoh
-- ---------------------------------------------------------------------
INSERT INTO kategori (id_kategori, nama_kategori) VALUES (1, 'Perangkat Input');

INSERT INTO kategori (id_kategori, nama_kategori) VALUES
    (2, 'Kabel dan Konektor'),
    (3, 'Perangkat Jaringan'),
    (4, 'Alat Ukur');

INSERT INTO barang (kode_barang, nama_barang, id_kategori, jumlah_tersedia, keterangan) VALUES
    ('BRG-001', 'Keyboard USB',        1, 10, 'Rak A1'),
    ('BRG-002', 'Mouse USB',           1,  8, 'Rak A1'),
    ('BRG-003', 'Kabel HDMI 1,5 m',    2, 12, 'Rak A2'),
    ('BRG-004', 'Kabel UTP Cat6 5 m',  2, 20, 'Rak A2'),
    ('BRG-005', 'Switch 8 Port',       3,  4, 'Lemari B'),
    ('BRG-006', 'Access Point',        3,  2, 'Lemari B'),
    ('BRG-007', 'Multimeter Digital',  4,  5, 'Lemari C'),
    ('BRG-008', 'LAN Tester',          4,  0, 'Sedang diperbaiki');

INSERT INTO pengguna (username, password_hash, nama_lengkap, peran) VALUES
    ('admin',  'BELUM_DIATUR_P14', 'Administrator Lab', 'admin'),
    ('petugas1', 'BELUM_DIATUR_P14', 'Petugas Lab Satu',  'petugas');

INSERT INTO peminjaman (nomor_transaksi, nama_peminjam, tanggal_pinjam, tanggal_kembali, status, id_pengguna) VALUES
    ('PJM-0001', 'Andi Pratama', '2026-10-05', '2026-10-07', 'DIKEMBALIKAN', 2),
    ('PJM-0002', 'Siti Rahma',   '2026-10-08', NULL,         'DIPINJAM',     2),
    ('PJM-0003', 'Budi Santoso', '2026-10-09', NULL,         'DIPINJAM',     1);

INSERT INTO detail_peminjaman (id_peminjaman, kode_barang, jumlah) VALUES
    (1, 'BRG-007', 1),
    (1, 'BRG-004', 2),
    (2, 'BRG-001', 2),
    (2, 'BRG-002', 2),
    (3, 'BRG-005', 1);