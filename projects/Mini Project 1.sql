-- Mini Project 1

-- Analisis Pertumbuhan Pelanggan & Pendapatan Bulanan

/* Skenario Bisnis
Saya adalah seorang Data Analyst di sebuah perusahaan e-commerce. Tim marketing ingin memahami dua hal penting setiap bulannya:
1. Berapa banyak pelanggan bari (pelanggan yang melakukan transaksi pertama kali) yang berhasil didapatkan setiap bulan?
2. Bagaimana pertumbuhan pendapatan (revenue growth) dari bulan ke bulan?
*/
drop table if exists transaksi;

-- Langkah 1: Persiapan Data
create table transaksi (
	id_transaksi serial primary key,
	id_pelanggan int,
	tanggal_transaksi date,
	jumlah int
);
insert into transaksi (id_pelanggan, tanggal_transaksi, jumlah) values
(1, '2023-01-15', 100),
(2, '2023-01-20', 150),
(1, '2023-02-10', 50),
(3, '2023-02-25', 200),
(4, '2023-03-05', 120),
(2, '2023-03-12', 100), 
(3, '2023-03-20', 80),
(5, '2023-03-22', 110),
(1, '2023-04-02', 70);

-- Langkah 2: Membuat Query Analisis
with
-- CTE 1: Menandai transaksi pertama untuk setiap pelanggan
transaksi_pertama as (
	select
		id_pelanggan,
		tanggal_transaksi,
		-- Memberi nomor urut 1 untuk transaksi paling awal setiap pelanggan
		row_number() over(partition by id_pelanggan order by tanggal_transaksi) as urutan_transaksi
	from transaksi
),
-- CTE 2: Menghitung jumlah pelanggan baru per bulan
pelanggan_baru_per_bulan as (
	select
		-- Mengambil bulan dari tanggal transaksi pertama
		date_trunc('month', tanggal_transaksi)::date as bulan,
		count(id_pelanggan) as jumlah_pelanggan_baru
	from transaksi_pertama 
	where urutan_transaksi = 1 -- Hanya ambil yang merupakan transaksi pertama
	group by bulan
),
-- CTE 3: Menghitung total pendapatan per bulan
pendapatan_per_bulan as (
	select
		date_trunc('month', tanggal_transaksi)::date as bulan,
		sum(jumlah) as total_pendapatan
	from transaksi
	group by bulan
)
-- Query Utama: Menggabungkan semua CTE dan menghitung pertumbuhan
select
	pdp.bulan,
	pdp.total_pendapatan,
	-- Mengambil data pendapatan bulan sebelumnya menggunakan LAG()
	lag(pdp.total_pendapatan, 1, 0) over (order by pdp.bulan) as pendapatan_bulan_sebelumnya,
	case
		when lag(pdp.total_pendapatan, 1, 0) over (order by pdp.bulan) = 0 then null
		else round(
		(pdp.total_pendapatan - lag(pdp.total_pendapatan, 1, 0) over (order by pdp.bulan)) * 100.0 /
		lag(pdp.total_pendapatan, 1, 0) over (order by pdp.bulan),
		2)
	end as pertumbuhan_pendapatan_persen,
	coalesce(pbp.jumlah_pelanggan_baru, 0) as jumlah_pelanggan_baru
from pendapatan_per_bulan pdp
left join pelanggan_baru_per_bulan pbp on pdp.bulan = pbp.bulan 
order by pdp.bulan;