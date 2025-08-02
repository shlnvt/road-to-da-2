-- Modul 1: Advanced SQL & Database Managementalter

-- Topik 1: Window Functionsalter

-- Bagian 1: Fungsi Peringkat (RANK, DENSE_RANK, ROW_NUMBER)
-- Langkah 1: Buat Tabel nilai_siswa
create table nilai_siswa (
	nama_siswa varchar(50),
	nilai int
);
-- Langkah 2: Isi Data ke Tabel
insert into nilai_siswa (nama_siswa, nilai) values
('Andi', 90),
('Budi', 85),
('Cici', 90),
('Dodi', 80);
-- a. ROW_NUMBER()
select
	nama_siswa,
	nilai,
	row_number() over (order by nilai desc) as urutan
from nilai_siswa;
-- b. RANK()
select
	nama_siswa,
	nilai,
	rank() over (order by nilai desc) as peringkat
from nilai_siswa;
-- c. DENSE_RANK()
select
	nama_siswa,
	nilai,
	dense_rank() over (order by nilai desc) as peringkat_padat
from nilai_siswa;

-- Bagian 2: Agregat Berjalan & Perbandingan Baris
-- Langkah 3: Buat Tabel penjualan_harian
create table penjualan_harian (
	tanggal DATE,
	penjualan int
);
-- Langkah 4: Isi Data Penjualan
insert into penjualan_harian (tanggal, penjualan) values
('2023-01-01', 100),
('2023-01-02', 150),
('2023-01-03', 120),
('2023-01-04', 200);
-- a. Running Total (Total Berjalan)
select
	tanggal,
	penjualan,
	sum(penjualan) over (order by tanggal) as running_total
from penjualan_harian;
-- b. Moving Average (Rata-rata Bergerak)
select
	tanggal,
	penjualan,
	avg(penjualan) over (
		order by tanggal
		rows between 2 preceding and current row
	) as moving_avg_3_hari
from penjualan_harian;
-- c.LAG() - Membandingkan Data Sebelumnya
select
	tanggal,
	penjualan,
	lag(penjualan, 1, 0) over (order by tanggal) as penjualan_kemarin
from penjualan_harian;
-- d. LEAD() - Membandingkan dengan Data Berikutnya
select
	tanggal,
	penjualan,
	lead(penjualan, 1) over (order by tanggal) as penjualan_besok
from penjualan_harian;