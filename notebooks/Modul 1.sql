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

-- Topik 2: Common Table Expressions (CTE)

-- Langkah 1: Buat Tabel pelanggan dan pesanan
create table pelanggan (
	id_pelanggan int primary key,
	nama_pelanggan varchar(50),
	kota varchar(50)
);
create table pesanan (
	id_pesanan int primary key,
	id_pelanggan int,
	jumlah_pembelian int
);
-- Langkah 2: Isi Data ke Tabel
insert into pelanggan (id_pelanggan, nama_pelanggan, kota) values
(1, 'Andi', 'Jakarta'),
(2, 'Budi', 'Bandung'),
(3, 'Cici', 'Jakarta'),
(4, 'Dodi', 'Surabaya');
insert into pesanan (id_pesanan, id_pelanggan, jumlah_pembelian) values
(101, 1, 150),
(102, 2, 80),
(103, 1, 100),
(104, 3, 250),
(105, 4, 90),
(106, 3, 50);
-- Kita ingin mengetahui nama pelanggan dan total pembelian untuk pelanggan yang total belanjanya di atas 100.
-- Langkah 3: Selesaikan dengan CTE
with total_pembelian_per_pelanggan as (
	-- Hitung total pembelian untuk setiap pelanggan
	select
		id_pelanggan,
		sum(jumlah_pembelian) as total_belanja
	from pesanan
	group by id_pelanggan
)
-- Gabungkan dengan tabel pelanggan dan filter hasilnya
select
	p.nama_pelanggan,
	tpp.total_belanja
from total_pembelian_per_pelanggan tpp
join pelanggan p on tpp.id_pelanggan = p.id_pelanggan
where tpp.total_belanja > 100;
-- Menggunakan beberapa CTE sekaligus
-- Masalah baru: Temukan pelanggan dari 'Jakarta' yang total belanjanya di atas 200
with pelanggan_jakarta as (
	--- CTE 1: Filter pelanggan yang hanya dari Jakarta
	select id_pelanggan, nama_pelanggan
	from pelanggan
	where kota = 'Jakarta'
), total_pembelian as (
	-- CTE 2: Hitung total pembelian untuk semua pelanggan
	select
		id_pelanggan,
		sum(jumlah_pembelian) as total_belanja
	from pesanan
	group by id_pelanggan
)
-- Query utama: Gabungkan kedua CTE
select
	pj.nama_pelanggan,
	tp.total_belanja
from pelanggan_jakarta pj
join total_pembelian tp on pj.id_pelanggan = tp.id_pelanggan
where tp.total_belanja > 200;

-- Topik 3: Optimasi Query & Indexing

-- 1. Memahami EXPLAIN PLAN
-- Langkah 1: Jalankan EXPLAIN ANALYZE pada Query
explain analyze
select
	p.nama_pelanggan,
	ps.jumlah_pembelian
from pelanggan p
join pesanan ps on p.id_pelanggan = ps.id_pelanggan
where ps.id_pelanggan = 3;

-- 3. Membuat Index untuk Mempercepat Query
-- Langkah 2: Buat Index pada Kolom Foreign Key
create index idx_pesanan_id_pelanggan on pesanan(id_pelanggan);
-- Langkah 3: Jalankan Ulang EXPLAIN ANALYZE
explain analyze
select
	p.nama_pelanggan,
	ps.jumlah_pembelian
from pelanggan p
join pesanan ps on p.id_pelanggan = ps.id_pelanggan
where ps.id_pelanggan = 3;