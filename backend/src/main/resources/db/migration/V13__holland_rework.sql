-- V13: Rework Holland RIASEC to match the official instrument (docs/Holland.pdf)
-- and the result-processing logic in docs/Holland-result.xlsm (tab INDIVIDUAL, G10:L34).
--
-- Supersedes the placeholder schema/seed from V3__holland.sql + V8__seed_sample_data.sql:
-- those only ever seeded 1 of 18 sections and 6 bare-bones descriptions. This migration
-- drops and rebuilds holland_questions/holland_descriptions/holland_results with the real
-- 3-round x 6-type x 11-item structure and full description content, and clears the fake
-- holland_results rows seeded by V9__seed_evaluasi_2026.sql.

DROP TABLE IF EXISTS holland_results;
DROP TABLE IF EXISTS holland_questions;
DROP TABLE IF EXISTS holland_descriptions;

-- Holland questions: 3 rounds x 6 RIASEC types x 11 statements = 198 rows
-- round 1 = Minat (Interest), round 2 = Kemampuan (Ability), round 3 = Pilihan Karir (Career choice)
-- Each round has its own 5-point Likert scale + instruction text (hardcoded in the frontend wizard,
-- since it's fixed per round and identical across all 6 types within that round — see Holland.pdf).
CREATE TABLE holland_questions (
    id           BIGSERIAL PRIMARY KEY,
    round        SMALLINT NOT NULL CHECK (round BETWEEN 1 AND 3),
    riasec_type  VARCHAR(1) NOT NULL CHECK (riasec_type IN ('R','I','A','S','E','C')),
    item_no      SMALLINT NOT NULL CHECK (item_no BETWEEN 1 AND 11),
    statement    TEXT NOT NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(round, riasec_type, item_no)
);

CREATE INDEX idx_holland_q_round_type ON holland_questions(round, riasec_type);

INSERT INTO holland_questions (round, riasec_type, item_no, statement) VALUES
(1, 'R', 1, 'Belajar di sekolah kejuruan'),
(1, 'R', 2, 'Mengecat rumah'),
(1, 'R', 3, 'Membuat perabotan sendiri'),
(1, 'R', 4, 'Memasang/memperbaiki saluran ledeng'),
(1, 'R', 5, 'Instalasi listrik'),
(1, 'R', 6, 'Merawat kebun'),
(1, 'R', 7, 'Reparasi alat-alat (misalnya: radio, TV, mobil)'),
(1, 'R', 8, 'Membongkar-pasang jendela'),
(1, 'R', 9, 'Mengemudikan traktor dan mesin berat lain'),
(1, 'R', 10, 'Bekerja di peternakan'),
(1, 'R', 11, 'Mengawasi perbaikan jalan'),
(1, 'I', 1, 'Mempelajari alam semesta'),
(1, 'I', 2, 'Ikut terlibat dalam penelitian ilmiah'),
(1, 'I', 3, 'Kursus analisis dampak lingkungan'),
(1, 'I', 4, 'Mempelajari genetika'),
(1, 'I', 5, 'Mengurai dan mencari penyelesaian dari persoalan yang kompleks'),
(1, 'I', 6, 'Bekerja di lembaga ilmu pengetahuan'),
(1, 'I', 7, 'Mempelajari sistem informasi'),
(1, 'I', 8, 'Mengikuti temuan mutakhir dalam bidang ilmu pengetahuan di media'),
(1, 'I', 9, 'Mengetahui struktur kimia obat-obatan'),
(1, 'I', 10, 'Menganalisis peluang bisnis'),
(1, 'I', 11, 'Membuat desain program komputer'),
(1, 'A', 1, 'Mendekorasi ruangan sehingga menarik'),
(1, 'A', 2, 'Kursus fotografi'),
(1, 'A', 3, 'Merancang panggung pertunjukan'),
(1, 'A', 4, 'Membuat aransemen musik'),
(1, 'A', 5, 'Belajar landscape'),
(1, 'A', 6, 'Menulis puisi atau cerpen'),
(1, 'A', 7, 'Menggambar ilustrasi untuk cerita pendek'),
(1, 'A', 8, 'Membaca tuntas karya sastra'),
(1, 'A', 9, 'Mengedit tulisan bukan ilmiah'),
(1, 'A', 10, 'Membuat desain grafis'),
(1, 'A', 11, 'Menggambar komik'),
(1, 'S', 1, 'Memberikan konsultasi keluarga'),
(1, 'S', 2, 'Aktif di LSM bidang sosial'),
(1, 'S', 3, 'Mengikuti seminar pendidikan'),
(1, 'S', 4, 'Mempelajari sosiologi'),
(1, 'S', 5, 'Menyelenggarakan kegiatan amal'),
(1, 'S', 6, 'Membantu menyelesaikan pertikaian'),
(1, 'S', 7, 'Mengajar di sekolah atau perguruan tinggi'),
(1, 'S', 8, 'Mempelajari retardasi mental'),
(1, 'S', 9, 'Bekerja di bagian SDM'),
(1, 'S', 10, 'Mengkoordinir kegiatan sosial'),
(1, 'S', 11, 'Aktif mengikuti organisasi massa'),
(1, 'E', 1, 'Memimpin kerja kelompok (team)'),
(1, 'E', 2, 'Menjadi pengurus asosiasi dagang'),
(1, 'E', 3, 'Menjual produk baru'),
(1, 'E', 4, 'Pengurus partai politik'),
(1, 'E', 5, 'Usaha wiraswasta'),
(1, 'E', 6, 'Mengembangkan organisasi'),
(1, 'E', 7, 'Menyakinkan orang lain'),
(1, 'E', 8, 'Mewujudkan ide baru dalam suatu bidang'),
(1, 'E', 9, 'Menanamkan modal (investasi) di dunia usaha'),
(1, 'E', 10, 'Mencari kesempatan dan peluang usaha baru'),
(1, 'E', 11, 'Mengatasi tantangan baru'),
(1, 'C', 1, 'Membuat catatan pemasukan dan pengeluaran secara teliti'),
(1, 'C', 2, 'Belajar akuntansi'),
(1, 'C', 3, 'Memeriksa catatan/dokumen'),
(1, 'C', 4, 'Bekerja sesuai prosedur'),
(1, 'C', 5, 'Menginventaris barang-barang'),
(1, 'C', 6, 'Membuat perhitungan rugi/laba usaha'),
(1, 'C', 7, 'Menyimpan dan menata dokumen'),
(1, 'C', 8, 'Meneliti laporan secara detil'),
(1, 'C', 9, 'Bertugas di perpustakaan'),
(1, 'C', 10, 'Menjadi bendahara organisasi'),
(1, 'C', 11, 'Meneliti kualitas produk'),
(2, 'R', 1, 'Memperbaiki perangkat listrik yang rusak'),
(2, 'R', 2, 'Membuat bangunan sederhana, semisal pagar'),
(2, 'R', 3, 'Memasang tegel'),
(2, 'R', 4, 'Memasang rangka pintu dan jendela'),
(2, 'R', 5, 'Membetulkan genting bocor atau pecah'),
(2, 'R', 6, 'Memasang instalasi listrik'),
(2, 'R', 7, 'Memelihara tanaman'),
(2, 'R', 8, 'Berternak (misalnya: unggas, ikan, anjing, dll.)'),
(2, 'R', 9, 'Membuat galian dengan cangkul'),
(2, 'R', 10, 'Menata kebun'),
(2, 'R', 11, 'Memperbaiki komponen mobil (mis: karburator, speedometer, dll.)'),
(2, 'I', 1, 'Melakukan analisis data statistik'),
(2, 'I', 2, 'Memahami fungsi DNA'),
(2, 'I', 3, 'Membuat rancangan penelitian'),
(2, 'I', 4, 'Memahami bagaimana jaringan rusak tumbuh kembali'),
(2, 'I', 5, 'Melakukan pemetaan'),
(2, 'I', 6, 'Memahami fungsi lapisan ozon'),
(2, 'I', 7, 'Menjelaskan mengapa obat tertentu berbahaya'),
(2, 'I', 8, 'Menyebutkan zat-zat berbahaya bagi lingkungan'),
(2, 'I', 9, 'Memahami terjadinya pergeseran budaya'),
(2, 'I', 10, 'Menggunakan logika matematika untuk persoalan teknis'),
(2, 'I', 11, 'Memahami berkembangbiaknya benda mikroskopis'),
(2, 'A', 1, 'Menggambar manusia dengan indah'),
(2, 'A', 2, 'Membuat desain ruang pameran'),
(2, 'A', 3, 'Membuat aransemen musik sederhana'),
(2, 'A', 4, 'Memainkan alat musik'),
(2, 'A', 5, 'Melukiskan peristiwa sederhana menjadi menarik'),
(2, 'A', 6, 'Merancang ruang dan perabot sehingga bercitarasa seni'),
(2, 'A', 7, 'Mengambil foto artistik'),
(2, 'A', 8, 'Memainkan peran dalam sandiwara'),
(2, 'A', 9, 'Menyanyi dalam paduan 3 suara atau lebih'),
(2, 'A', 10, 'Merancang bahan sehingga menjadi busana yang modis'),
(2, 'A', 11, 'Memadukan warna sehingga serasi'),
(2, 'S', 1, 'Mendengarkan keluhan akan persoalan orang lain hingga tuntas'),
(2, 'S', 2, 'Memberikan saran dan nasehat bagi orang lain'),
(2, 'S', 3, 'Menggalang dana sosial'),
(2, 'S', 4, 'Memahami sudut pandang orang lain'),
(2, 'S', 5, 'Mudah memancing pembicaraan'),
(2, 'S', 6, 'Mengundang pendapat yang berbeda'),
(2, 'S', 7, 'Mengajar di kelas'),
(2, 'S', 8, 'Menjadi fasilitator diskusi'),
(2, 'S', 9, 'Membimbing belajar siswa/mahasiswa'),
(2, 'S', 10, 'Menjadi pengurus RT'),
(2, 'S', 11, 'Menyelenggarakan kegiatan sosial bagi karyawan'),
(2, 'E', 1, 'Mencari peluang usaha baru'),
(2, 'E', 2, 'Membuka kesempatan kerja'),
(2, 'E', 3, 'Menjalankan usaha sampingan secara legal'),
(2, 'E', 4, 'Menyelenggarakan promosi produk baru'),
(2, 'E', 5, 'Meyakinkan orang akan pentingnya suatu hal'),
(2, 'E', 6, 'Memimpin kelompok kerja'),
(2, 'E', 7, 'Menjadi pembicara dalam seminar'),
(2, 'E', 8, 'Memanfaatkan hubungan dengan pihak lain (networking)'),
(2, 'E', 9, 'Memotivasi orang untuk mencapai target'),
(2, 'E', 10, 'Menghadapi customer complain dengan baik'),
(2, 'E', 11, 'Mengemas hal/barang biasa sehingga mempunyai nilai jual'),
(2, 'C', 1, 'Mencatat dengan teliti nota masuk dan keluar'),
(2, 'C', 2, 'Membuat jadwal kegiatan secara detil'),
(2, 'C', 3, 'Melakukan surat menyurat resmi'),
(2, 'C', 4, 'Membaca dan mengoreksi artikel/tulisan sehingga bebas dari kesalahan'),
(2, 'C', 5, 'Mengorganisasikan dokumen dengan rapi'),
(2, 'C', 6, 'Menganalisis data keuangan'),
(2, 'C', 7, 'Bekerja dengan tabel-tabel dan angka'),
(2, 'C', 8, 'Menghitung deretan angka-angka dengan cermat'),
(2, 'C', 9, 'Melakukan pekerjaan yang melibatkan banyak pengetikan'),
(2, 'C', 10, 'Menjaga kerapian dan keteraturan ruang kerja'),
(2, 'C', 11, 'Menyiapkan acara rapat/seminar sehingga tertib'),
(3, 'R', 1, 'Ahli pertukangan'),
(3, 'R', 2, 'Petani'),
(3, 'R', 3, 'Montir'),
(3, 'R', 4, 'Ahli percetakan/offset'),
(3, 'R', 5, 'Ahli instalasi listrik'),
(3, 'R', 6, 'Ahli tanaman hias dan holtikultura'),
(3, 'R', 7, 'Ahli pemetaan'),
(3, 'R', 8, 'Insinyur mesin'),
(3, 'R', 9, 'Ahli radio komunikasi'),
(3, 'R', 10, 'Insinyur penerbangan'),
(3, 'R', 11, 'Insinyur perminyakan'),
(3, 'I', 1, 'Ahli ekonomi'),
(3, 'I', 2, 'Ahli meteorologi dan geofisika'),
(3, 'I', 3, 'Ahli mikrobiologi'),
(3, 'I', 4, 'Ahli rekayasa genetika'),
(3, 'I', 5, 'Programmer komputer'),
(3, 'I', 6, 'Analis Dampak Lingkungan (AMDAL)'),
(3, 'I', 7, 'Ahli manajemen limbah'),
(3, 'I', 8, 'Peneliti (sosial maupun eksakta)'),
(3, 'I', 9, 'Dokter-spesialis'),
(3, 'I', 10, 'Manajer Penelitian dan Pengembangan'),
(3, 'I', 11, 'Ahli konservasi tanah/lingkungan'),
(3, 'A', 1, 'Sutradara film atau drama'),
(3, 'A', 2, 'Komposer'),
(3, 'A', 3, 'Arsitek'),
(3, 'A', 4, 'Redaktur majalah'),
(3, 'A', 5, 'Penyair'),
(3, 'A', 6, 'Guru seni (musik, tari, sastra, atau senirupa)'),
(3, 'A', 7, 'Illustrator'),
(3, 'A', 8, 'Seniman'),
(3, 'A', 9, 'Perancang interior'),
(3, 'A', 10, 'Disainer iklan (copywriter)'),
(3, 'A', 11, 'Perancang landscape'),
(3, 'S', 1, 'Psikolog'),
(3, 'S', 2, 'Perawat'),
(3, 'S', 3, 'Ulama/pendeta'),
(3, 'S', 4, 'Konselor (guru bimbingan dan penyuluhan, konselor perkawinan, dll.)'),
(3, 'S', 5, 'Guru sekolah umum'),
(3, 'S', 6, 'Aktifis LSM'),
(3, 'S', 7, 'Ahli kosmetik'),
(3, 'S', 8, 'Direktur lembaga kesejahteraan sosial'),
(3, 'S', 9, 'Direktur organisasi kemasyarakatan'),
(3, 'S', 10, 'Peneliti makanan dan obat'),
(3, 'S', 11, 'Ahli perkembangan anak'),
(3, 'E', 1, 'Pialang saham'),
(3, 'E', 2, 'Manajer sebuah perusahaan'),
(3, 'E', 3, 'Insinyur logistik'),
(3, 'E', 4, 'Penjual asuransi'),
(3, 'E', 5, 'Manajer bisnis eceran'),
(3, 'E', 6, 'Akuntan pajak'),
(3, 'E', 7, 'Pengacara perusahaan'),
(3, 'E', 8, 'Manajer layanan pelanggan'),
(3, 'E', 9, 'Kepala maintenance (perawatan fasilitas)'),
(3, 'E', 10, 'Ahli pembelian alat berat (procurement)'),
(3, 'E', 11, 'Manajer kredit dan penagihan'),
(3, 'C', 1, 'Pegawai kantor pajak'),
(3, 'C', 2, 'Analis kredit'),
(3, 'C', 3, 'Pegawai bagian penggajian'),
(3, 'C', 4, 'Ahli pergudangan'),
(3, 'C', 5, 'Sekretaris'),
(3, 'C', 6, 'Pegawai pencatatan medis'),
(3, 'C', 7, 'Analis investasi'),
(3, 'C', 8, 'Ahli pemrosesan data'),
(3, 'C', 9, 'Pustakawan (librarian)'),
(3, 'C', 10, 'Kasir'),
(3, 'C', 11, 'Akuntan');

-- Holland description table: one row per RIASEC type, full content
-- (Deskripsi / Karakter / Kelebihan / Kelemahan / Job Match) as used by the
-- INDIVIDUAL!G15:K15 VLOOKUPs in Holland-result.xlsm against the 'blanda' named range.
CREATE TABLE holland_descriptions (
    id           BIGSERIAL PRIMARY KEY,
    riasec_type  VARCHAR(1) NOT NULL UNIQUE CHECK (riasec_type IN ('R','I','A','S','E','C')),
    name         VARCHAR(50) NOT NULL,   -- Realistic | Investigative | Artistic | Social | Enterprising | Conventional
    description  TEXT,
    characteristics TEXT,               -- Karakter
    strengths    TEXT,                  -- Kelebihan
    weaknesses   TEXT,                  -- Kelemahan
    job_match    TEXT                   -- Job Match
);

INSERT INTO holland_descriptions (riasec_type, name, description, characteristics, strengths, weaknesses, job_match) VALUES
('R', 'Realistic', 'Tipe R mengacu pada individu yang memiliki minat utama dalam pekerjaan yang melibatkan aktivitas fisik, keterampilan praktis, dan interaksi dengan lingkungan fisik. Orang-orang dengan tipe ini cenderung merasa nyaman dalam pekerjaan yang memerlukan penggunaan tangan, keterampilan teknis, dan tugas yang bersifat konkret. Individu tipe Realistic memiliki ciri-ciri seperti kemampuan untuk memecahkan masalah fisik, ketertarikan pada mekanik, konstruksi, perbaikan, serta minat pada pekerjaan yang melibatkan alat, mesin, dan bahan fisik. Mereka sering mengejar karier di bidang-bidang seperti konstruksi, manufaktur, teknik, pertanian, atau bidang-bidang yang membutuhkan keterampilan praktis dan tugas fisik.', '1. Aktivitas Fisik: Orang tipe R lebih suka pekerjaan yang melibatkan aktivitas fisik, seperti bekerja dengan alat, mesin, atau bahan fisik.
2. Keterampilan Praktis: Mereka memiliki keterampilan praktis yang kuat, yang meliputi kemampuan dalam penggunaan alat, peralatan, dan perbaikan.
3. Ketertarikan pada Masalah Konkrit: Mereka lebih cenderung tertarik pada masalah yang memiliki solusi konkret, seperti memecahkan masalah mekanis atau konstruksi.
4. Tindakan dan Kepemimpinan: Orang tipe R memiliki sifat tindakan dan kepemimpinan. Mereka merasa nyaman dalam situasi yang memerlukan pengambilan keputusan cepat dan tanggung jawab.
5. Ketertarikan pada Alam: Banyak dari mereka memiliki ketertarikan alam dan lingkungan luar ruangan, serta bekerja di lingkungan yang melibatkan aktivitas di luar ruangan.', '1. Keterampilan Praktis: Mereka memiliki keterampilan praktis yang kuat, yang bisa sangat berharga dalam berbagai pekerjaan dan situasi.
2. Kemampuan Problem Solving: Kemampuan mereka dalam memecahkan masalah konkrit dan teknis dapat membantu mereka menjadi solvers yang andal dalam berbagai konteks.
3. Tindakan dan Kepemimpinan: Sifat tindakan dan kepemimpinan mereka membuat mereka efektif dalam situasi-situasi yang memerlukan pengambilan keputusan cepat dan penyelesaian masalah.
4. Keterampilan Fisik: Keterampilan fisik dan tugas praktis yang mereka kuasai membuat mereka ideal untuk pekerjaan yang memerlukan interaksi langsung dengan bahan fisik atau lingkungan.', '1. Keterbatasan Pilihan Karier: Keterbatasan dalam minat utama mereka (fokus pada aktivitas fisik dan praktis) dapat membuat pilihan karier mereka kurang beragam.
2. Ketidakcocokan dengan Pekerjaan Lain: Mereka mungkin merasa kurang cocok dalam pekerjaan yang sangat abstrak, intelektual, atau berorientasi sosial.
3. Keterbatasan dalam Pekerjaan Kreatif: Pekerjaan yang sangat kreatif mungkin tidak sesuai dengan minat utama mereka, karena tipe R lebih cenderung berfokus pada tugas fisik.', '1. Tukang Kayu: Pekerjaan ini memungkinkan mereka untuk menggunakan keterampilan praktis mereka dalam pembuatan atau perbaikan berbagai produk kayu.
2. Mekanik: Mekanik mobil atau mesin memberikan kesempatan untuk memperbaiki dan merawat kendaraan atau peralatan.
3. Teknisi Mesin: Teknisi mesin terlibat dalam perawatan dan perbaikan mesin industri.
4. Pekerja Konstruksi: Pekerja konstruksi bertanggung jawab untuk membangun atau merenovasi bangunan.
5. Petugas Keamanan: Petugas keamanan bank atau properti mengawasi keamanan fisik suatu tempat.
6. Petani: Pekerjaan di bidang pertanian memungkinkan mereka untuk berinteraksi dengan alam dan tanah.
7. Petugas Teknologi Informasi (TI): Di bidang TI, mereka dapat terlibat dalam pemeliharaan perangkat keras dan jaringan.
8. Petugas Pemeliharaan Fasilitas: Pekerjaan ini melibatkan perawatan fisik fasilitas dan bangunan.
9. Petugas Layanan Teknis: Mereka dapat membantu pelanggan dalam mengatasi masalah teknis terkait produk atau layanan.
10. Petugas Logistik: Pekerjaan ini melibatkan manajemen pasokan dan peralatan.'),
('I', 'Investigative', 'Tipe I memiliki minat utama dalam pekerjaan yang melibatkan investigasi, penelitian, analisis, serta pemecahan masalah intelektual. Mereka cenderung mencari pemahaman yang mendalam dan logis dalam berbagai aspek pekerjaan dan lingkungan mereka', '1. Kecenderungan Analitis: Orang dengan tipe I cenderung memiliki kemampuan analitis yang kuat. Mereka suka menyusun data, mengidentifikasi pola, dan mengeksplorasi hubungan yang kompleks.
2. Ketertarikan pada Penelitian: Tipe I memiliki ketertarikan yang tinggi pada penelitian ilmiah dan analisis data. Mereka senang mencari fakta dan informasi.
3. Kemampuan Berpikir Logis: Mereka sering memiliki kemampuan berpikir logis dan pemikiran kritis yang baik. Hal ini memungkinkan mereka untuk memecahkan masalah yang rumit dengan efektif.
4. Pencarian Pengetahuan: Orang tipe I cenderung ingin mengeksplorasi dan memahami dunia dengan lebih mendalam. Mereka tertarik pada ilmu pengetahuan, teknologi, dan bidang yang memerlukan pemahaman teknis.
5. Keinginan untuk Mengeksplorasi: Mereka sering memiliki dorongan untuk menjelajahi ide-ide baru dan konsep yang kompleks, serta mengejar pemahaman yang lebih dalam tentang berbagai subjek.
6. Minat pada Keakuratan dan Kepastian: Mereka menghargai akurasi, kepastian, dan pemahaman yang tepat dalam pekerjaan dan penelitian mereka.
7. Kemampuan Berpikir Kreatif: Selain berpikir logis, beberapa individu tipe I juga memiliki kemampuan berpikir kreatif, yang mereka terapkan untuk menemukan solusi yang inovatif.', '1. Kemampuan Analitis: Mereka memiliki kemampuan analitis yang kuat, yang membuat mereka ahli dalam pemecahan masalah yang rumit.
2. Pemahaman yang Mendalam: Tipe I cenderung memahami isu-isu dengan lebih mendalam dan detail, yang dapat berkontribusi pada penemuan dan penelitian ilmiah.
3. Pengetahuan Teknis: Mereka sering memiliki pengetahuan teknis dan ilmiah yang kuat, yang dapat diaplikasikan dalam berbagai konteks.', '1. Terlalu Analitis: Mereka mungkin terjebak dalam analisis yang berlebihan dan kesulitan mengambil keputusan karena ingin memeriksa semua aspek.
2. Kurang Fleksibilitas: Terkadang, mereka mungkin kurang fleksibel dalam berurusan dengan tugas-tugas praktis yang memerlukan kecepatan dan respons cepat.', '1. Ilmuwan: Ilmuwan melakukan penelitian ilmiah dan eksperimen untuk meningkatkan pemahaman kita tentang dunia.
2. Peneliti Pasar: Peneliti pasar mengumpulkan dan menganalisis data konsumen untuk membantu perusahaan dalam pengambilan keputusan bisnis.
3. Insinyur: Insinyur merancang, mengembangkan, dan memelihara berbagai sistem dan teknologi.
4. Dokter atau Ahli Kesehatan: Profesional kesehatan melakukan diagnosis, penelitian, dan pengobatan penyakit.
5. Ahli Forensik: Ahli forensik mengumpulkan bukti dan menganalisis data dalam penyelidikan kejahatan.
6. Analisis Data: Analis data bekerja dengan data untuk mengidentifikasi tren, pola, dan wawasan yang dapat membantu pengambilan keputusan.
7. Programmer Komputer: Programmer mengembangkan dan mengkode perangkat lunak komputer.
8. Pengajar atau Profesor: Pengajar dan profesor dapat terlibat dalam penelitian dan pembelajaran di berbagai disiplin ilmu.
9. Dosen Peneliti: Dosen peneliti di perguruan tinggi melakukan penelitian dan mengajar di bidang akademik.'),
('A', 'Artistic', 'Tipe A memiliki minat utama dalam pekerjaan yang melibatkan ekspresi kreatif, seni visual atau pertunjukan, serta imajinasi. Individu dengan tipe A cenderung mengejar pekerjaan yang memungkinkan mereka untuk mengungkapkan diri mereka melalui seni, desain, musik, atau bentuk-bentuk kreativitas lainnya.', '1. Ekspresi Kreatif: Orang dengan tipe A memiliki kemampuan untuk berekspresi secara kreatif melalui berbagai media, termasuk seni visual, musik, seni pertunjukan, atau penulisan.
2. Imajinasi yang Kuat: Mereka sering memiliki imajinasi yang kaya dan mampu berpikir kreatif menciptakan ide-ide baru.
3. Kesenian dan Seni Visual: Tipe A cenderung memiliki minat dalam seni visual seperti lukisan, fotografi, desain grafis, atau seni pertunjukan seperti teater, tari, atau musik.
4. Kemampuan Menghasilkan Karya: Mereka bisa menciptakan karya seni, baik itu melalui media fisik atau karya yang bisa diapresiasi, seperti karya seni rupa, karya sastra, atau pertunjukan.
5. Minat dalam Penciptaan dan Desain: Individu tipe A cenderung tertarik pada proses kreatif, termasuk desain, pembuatan, atau pengembangan ide baru.
6. Sensitivitas terhadap Emosi: Mereka sering memiliki sensitivitas terhadap emosi dan ekspresi perasaan, yang dapat tercermin dalam karya seni mereka.', '1. Kreativitas yang Kuat: Individu tipe Artistic sering memiliki tingkat kreativitas yang tinggi, yang memungkinkan mereka untuk menghasilkan karya seni yang unik dan inovatif.
2. Ekspresi Diri yang Bebas: Mereka dapat mengekspresikan diri dengan bebas melalui karya seni mereka, yang dapat memberikan kepuasan pribadi.
3. Imajinasi yang Kaya: Mereka memiliki imajinasi yang kaya, yang memungkinkan mereka untuk berpikir di luar kotak dan menciptakan ide-ide baru.
4. Sensitivitas terhadap Emosi: Tipe Artistic sering memiliki tingkat sensitivitas yang tinggi terhadap emosi, yang dapat membantu mereka menciptakan karya yang menggugah perasaan.
5. Kemampuan untuk Berpikir Kreatif: Mereka memiliki kemampuan untuk berpikir kreatif dan menemukan solusi yang inovatif untuk masalah.', '1. Ketidak patuhan: Seringkali merasa terlalu bebas dalam berekspresi sehingga kurang peduli dengan tata aturan yang berlaku.

2. Resiko Ketidakstabilan Emosi: Keterbatasan dalam menuangkan ide atau respon yang tidak diharapkan dari lingkungan atas karya yang dihasilkan

3. Kesulitan dalam Penerimaan Kritik: Beberapa individu tipe Artistic mungkin sulit menerima kritik terhadap karya seni mereka, karena karya tersebut sering memiliki nilai emosional yang tinggi.', '1. Periklanan dan Pemasaran: Pekerjaan di bidang periklanan dan pemasaran memerlukan kemampuan kreatif dalam merancang kampanye iklan, materi promosi, atau strategi pemasaran yang menarik.
2. Desain Interior: Desainer interior menciptakan ruang yang estetis dan fungsional untuk klien mereka, menggabungkan kreativitas dengan aspek-aspek praktis.
3. Desain Mode: Meskipun terkait dengan seni, desain mode juga melibatkan aspek fungsional dan komersial, yang dapat menarik bagi individu tipe Artistic.
4. Arsitek: Arsitek merancang bangunan dan struktur dengan mempertimbangkan aspek estetika dan fungsionalitas.
5. Desain Produk: Desainer produk menciptakan produk yang menggabungkan desain estetis dengan fungsi yang baik.
6. Penulisan Kreatif: Menulis bukan hanya tentang seni sastra, tetapi juga mencakup bidang seperti penulisan konten pemasaran, penulisan skenario, atau penulisan skripsi.
7. Fotografi: Selain seni, fotografi juga memiliki aplikasi dalam bidang seperti jurnalisme, periklanan, dan fotografi pernikahan.
8. Konsultan Kreatif: Menawarkan layanan konsultasi kreatif untuk berbagai perusahaan atau individu yang membutuhkan ide-ide inovatif.
9. Desain Grafis: Desain grafis digunakan dalam berbagai konteks, termasuk media, perusahaan, dan desain web.
10. Pekerjaan di Industri Hiburan: Pekerjaan di bidang hiburan seperti penyutradaraan, penulisan naskah, dan perencanaan acara memungkinkan individu untuk mengekspresikan kreativitas mereka.
11. Jurnalis Foto: Fotografer yang berfokus pada jurnalisme foto dapat menggabungkan kreativitas dengan pelaporan berita.
12. Pekerjaan di Bidang Sains dan Teknologi: Terkadang, tipe Artistic dapat menemukan cara untuk mengintegrasikan kreativitas mereka dalam pekerjaan ilmiah atau teknis, seperti komunikasi ilmiah atau desain interaksi pengguna (UI/UX).
13. Pekerjaan di Bidang Desain Permainan: Industri game menggabungkan unsur-unsur kreatif dengan teknologi dan interaktivitas.
14. Kurator Museum: Mereka dapat berkontribusi pada pengaturan pameran dan interpretasi seni di museum.'),
('S', 'Social', 'Tipe S memiliki minat utama dalam pekerjaan yang melibatkan interaksi sosial, keterlibatan dengan orang lain, dan pelayanan masyarakat. Mereka cenderung mencari pekerjaan yang memungkinkan mereka untuk berhubungan dengan orang lain, memberikan dukungan, dan berpartisipasi dalam kegiatan yang bersifat sosial.', '1. Kemampuan Komunikasi yang Baik: Individu tipe S cenderung memiliki kemampuan komunikasi yang kuat, yang memungkinkan mereka untuk berinteraksi dengan orang lain dengan efektif.
2. Kemampuan Empati: Mereka sering memiliki kemampuan empati yang baik, yang memungkinkan mereka untuk memahami perasaan dan kebutuhan orang lain.
3. Keterlibatan dalam Pelayanan Masyarakat: Tipe S cenderung tertarik pada pekerjaan yang melibatkan pelayanan masyarakat, seperti pekerjaan di sektor non-profit atau organisasi amal.
4. Keterlibatan dalam Pekerjaan Sosial: Individu dengan tipe S mungkin tertarik pada pekerjaan sosial seperti konselor, terapis, pekerja sosial, atau guru.
5. Pekerjaan yang Melibatkan Kolaborasi: Mereka sering mencari pekerjaan yang melibatkan kerja sama tim dan kolaborasi dengan orang lain.
6. Pembangunan Hubungan: Tipe S cenderung memprioritaskan pembangunan hubungan sosial yang kuat dalam pekerjaan mereka.
7. Pekerjaan dalam Pelayanan Kesehatan: Beberapa individu tipe S mungkin tertarik pada pekerjaan dalam bidang kesehatan, seperti perawat, dokter, atau terapis fisik.
8. Kesediaan untuk Membantu Orang Lain: Mereka cenderung bersedia untuk memberikan dukungan dan membantu orang lain dalam berbagai konteks.', '1. Kemampuan Komunikasi yang Kuat: Individu tipe S sering memiliki kemampuan komunikasi yang baik, yang memungkinkan mereka untuk berinteraksi dengan orang lain secara efektif.
2. Kemampuan Empati: Mereka cenderung memiliki tingkat empati yang tinggi, sehingga dapat memahami dan merespons perasaan serta kebutuhan orang lain dengan baik.
3. Keterampilan dalam Membangun Hubungan: Tipe S sering memiliki kemampuan yang baik dalam membangun hubungan sosial yang kuat dan positif.
4. Pengalaman dalam Pekerjaan Sosial: Mereka mungkin memiliki pengalaman atau pengetahuan yang kuat dalam bidang pekerjaan sosial, yang dapat menjadi aset dalam berbagai pekerjaan.
5. Kemauan untuk Membantu Orang Lain: Mereka memiliki kesediaan yang tinggi untuk memberikan dukungan, membantu, dan melayani orang lain.', '1. Terlalu Sensitif terhadap Perasaan Orang Lain: Terkadang, individu tipe S dapat menjadi terlalu sensitif terhadap perasaan orang lain, yang dapat mengganggu keputusan atau tindakan yang obyektif.
2. Kesulitan dalam Mengelola Konflik: Mereka mungkin menghindari konflik atau memiliki kesulitan dalam mengelolanya, terutama jika itu melibatkan orang-orang yang mereka pedulikan.
3. Keterbatasan dalam Pengambilan Keputusan yang Berfokus pada Bisnis: Dalam konteks bisnis, mereka mungkin perlu bekerja untuk menjaga keseimbangan antara empati dan pengambilan keputusan yang rasional.', '1. Manajemen Sumber Daya Manusia (HR): Dalam peran HR, mereka dapat membantu membangun budaya organisasi yang mendukung kesejahteraan karyawan dan kolaborasi.
2. Pengembangan Produk dan Layanan Pelanggan: Berfokus pada pengembangan produk atau layanan yang memenuhi kebutuhan pelanggan dan berinteraksi dengan pelanggan untuk memahami umpan balik mereka.
3. Pekerjaan dalam Pengajaran atau Pelatihan: Mereka dapat menjadi instruktur atau pelatih dalam berbagai konteks, membagikan pengetahuan dan keterampilan mereka kepada orang lain.
4. Manajemen Acara: Mengatur dan mengelola acara-acara seperti konferensi, seminar, atau acara budaya.
5. Bisnis Kewirausahaan: Berbisnis sendiri dalam bidang yang menawarkan produk atau layanan yang memberikan manfaat sosial atau mempromosikan hubungan positif.
6. Manajemen Proyek: Memimpin dan mengelola proyek-proyek dengan fokus pada kolaborasi dan interaksi sosial.
7. Pekerjaan di Sektor Pariwisata: Pekerjaan yang melibatkan pengaturan perjalanan, resepsi tamu, atau promosi destinasi.
8. Manajemen Restoran atau Hotel: Berfokus pada pelayanan pelanggan dan memastikan pengalaman positif bagi tamu.
9. Pekerjaan di Pelayanan Kesehatan Non-Klinis: Peran seperti manajer pelayanan kesehatan atau administrator rumah sakit.
10. Bidang Konseling Karier: Membantu individu dalam pengambilan keputusan karier dan pengembangan profesional.'),
('E', 'Enterprising', 'Tipe E memiliki minat utama dalam pekerjaan yang melibatkan kepemimpinan, inisiatif, wirausaha, serta kemampuan berkomunikasi dan mempengaruhi orang lain. Orang-orang dengan tipe E cenderung mencari peluang untuk berinteraksi dengan orang lain, memimpin, memotivasi, dan mencapai tujuan karier atau bisnis.', '1. Kemampuan Berbicara dan Memimpin: Orang dengan tipe E memiliki kemampuan komunikasi yang kuat dan cenderung merasa nyaman dalam situasi kepemimpinan.
2. Kreativitas dalam Bisnis: Mereka sering memiliki jiwa wirausaha dan dapat mengidentifikasi peluang bisnis serta mengembangkan ide-ide inovatif.
3. Pengambilan Risiko yang Terkontrol: Individu tipe E cenderung bersedia mengambil risiko yang terkendali dan melihat peluang dalam situasi yang lain mungkin anggap berisiko.
4. Negosiasi dan Penjualan: Mereka sering memiliki keterampilan dalam negosiasi, penjualan, dan mempengaruhi orang lain untuk mencapai tujuan bersama.
5. Keinginan untuk Sukses Bisnis: Tipe E cenderung berorientasi pada kesuksesan dalam bisnis dan berpikir strategis dalam mencapai tujuan karier mereka.
6. Inisiatif: Mereka cenderung aktif mengambil inisiatif dalam situasi pekerjaan dan bisnis.
7. Kesadaran akan Peluang: Tipe E dapat dengan cepat mengidentifikasi peluang dalam lingkungan mereka dan bergerak untuk memanfaatkannya.
8. Keterampilan dalam Manajemen dan Organisasi: Mereka mungkin memiliki kemampuan manajemen yang kuat, baik dalam mengatur bisnis mereka sendiri maupun dalam mengelola tim atau proyek.', '1. Kepemimpinan yang Kuat: Individu tipe E sering memiliki kemampuan kepemimpinan yang kuat, yang memungkinkan mereka untuk memotivasi orang lain dan mencapai tujuan bersama.
2. Wirausaha dan Inovatif: Mereka cenderung memiliki bakat wirausaha dan kemampuan untuk mengidentifikasi peluang bisnis serta mengembangkan ide-ide inovatif.
3. Kemampuan Komunikasi yang Kuat: Tipe E memiliki kemampuan komunikasi yang baik, yang memungkinkan mereka untuk berinteraksi dengan orang lain dengan efektif.
4. Kemampuan Negosiasi dan Penjualan: Mereka sering memiliki keterampilan negosiasi dan penjualan yang berguna dalam berbagai konteks profesional.
5. Kesadaran akan Peluang: Individu tipe E cenderung peka terhadap peluang dan bisa mengambil tindakan untuk memanfaatkannya.
6. Inisiatif: Mereka memiliki inisiatif dan kemauan untuk mengambil tindakan dalam mencapai tujuan mereka.', '1. Terlalu  Kompetitif: Tipe E mungkin menjadi sangat kompetitif dalam mencapai tujuan mereka, yang dapat mengarah pada tekanan dan stres yang tinggi.
2. Resiko yang Tinggi: Karena kecenderungan untuk mengambil risiko, individu tipe E mungkin menghadapi risiko finansial atau profesional yang tinggi dalam usaha bisnis.
3. Kurangnya Kesabaran: Mereka mungkin kurang sabar dalam menghadapi situasi yang memerlukan waktu yang lebih lama untuk mencapai hasil yang diharapkan.', '1. Pengusaha: Berbisnis sendiri dan mengembangkan perusahaan atau startup.
2. Manajer Proyek: Memimpin dan mengelola proyek-proyek yang melibatkan berbagai orang dan sumber daya.
3. Pemasar: Merencanakan, mengembangkan, dan mengimplementasikan strategi pemasaran untuk produk atau layanan.
4. Pengembang Bisnis: Bertanggung jawab untuk mengidentifikasi peluang bisnis, mengembangkan strategi pertumbuhan, dan memperluas bisnis.
5. Manajer Tim: Memimpin dan mengelola tim dalam organisasi.
6. Sales Manager: Bertanggung jawab atas manajemen penjualan dan pengembangan strategi penjualan.
7. Konsultan Bisnis: Memberikan konsultasi kepada perusahaan atau individu dalam berbagai aspek bisnis.
8. Wirausaha Sosial: Memadukan tujuan bisnis dengan tujuan sosial dalam usaha mereka.
9. Dosen Bisnis: Mengajar dan memberikan pengetahuan bisnis kepada mahasiswa atau peserta pelatihan.
10. Broker Keuangan: Membantu individu dan perusahaan dalam pengelolaan keuangan dan investasi.'),
('C', 'Conventional', 'Tipe C memiliki minat utama dalam pekerjaan yang melibatkan pengaturan, pengendalian, dan pematuhan terhadap aturan, prosedur, dan standar yang telah ditetapkan. Mereka cenderung mencari pekerjaan yang memerlukan ketelitian, perencanaan, dan pemantauan untuk mencapai tujuan yang telah ditetapkan.', '1. Kemampuan Organisasi: Individu tipe C cenderung memiliki kemampuan organisasi yang baik, yang memungkinkan mereka untuk mengatur dan mengelola informasi, tugas, dan proses dengan efisien.
2. Kemampuan Pemecahan Masalah: Mereka sering memiliki kemampuan untuk mengidentifikasi masalah dan mengembangkan solusi yang sistematis.
3. Ketelitian dan Kepedulian terhadap Detail: Tipe C cenderung sangat peduli terhadap detail dan akan bekerja dengan teliti untuk memastikan tugas dan pekerjaan mereka dilakukan dengan benar.
4. Pentingnya Aturan dan Prosedur: Mereka sangat memperhatikan aturan, prosedur, dan standar yang telah ditetapkan, dan cenderung mematuhi mereka dengan ketat.
5. Ketertarikan dalam Bidang Keuangan dan Akuntansi: Beberapa individu tipe C mungkin tertarik pada pekerjaan dalam bidang keuangan, akuntansi, atau administrasi.
6. Keterampilan dalam Pengelolaan Data: Mereka sering memiliki keterampilan dalam pengumpulan, analisis, dan presentasi data.
7. Keinginan untuk Menghindari Resiko: Tipe C cenderung memilih pekerjaan yang memiliki tingkat risiko yang rendah dan lebih dapat diandalkan.
8. Penghargaan terhadap Rutinitas: Mereka sering merasa nyaman dengan rutinitas dan pekerjaan yang memiliki tugas-tugas yang terstruktur.', '1. Kemampuan Organisasi yang Kuat: Individu tipe C memiliki kemampuan organisasi yang sangat baik, yang memungkinkan mereka mengatur tugas dan proses dengan efisien.
2. Ketelitian yang Tinggi: Mereka sangat peduli terhadap detail dan akan bekerja dengan sangat teliti untuk memastikan pekerjaan dilakukan dengan benar.
3. Pemecahan Masalah yang Sistematis: Tipe C cenderung mendekati masalah dengan cara yang sistematis dan mengembangkan solusi yang terstruktur.
4. Kepatuhan terhadap Aturan dan Prosedur: Mereka sangat mematuhi aturan, prosedur, dan standar yang ditetapkan.
5. Ketertarikan pada Bidang Keuangan: Beberapa individu tipe C mungkin memiliki minat yang kuat dalam bidang keuangan, akuntansi, dan administrasi.', '1. Keterbatasan dalam Kreativitas: Terlalu fokus pada rutinitas dan aturan tertentu dapat membatasi kreativitas dan inovasi.
2. Kesulitan dalam Menghadapi Perubahan: Tipe C mungkin kesulitan beradaptasi dengan perubahan atau situasi yang tidak terstruktur.
3. Penghindaran Risiko Berlebihan: Mereka cenderung menghindari risiko secara berlebihan, yang dapat menghambat pengembangan karier atau pertumbuhan bisnis.
4. Kesulitan dalam Berinteraksi dengan Situasi Sosial yang Tidak Terstruktur: Tipe C mungkin merasa tidak nyaman dalam situasi sosial yang tidak terstruktur atau mengharuskan improvisasi.', '1. Akuntan: Memproses laporan keuangan, mengaudit, dan mengelola informasi keuangan.
2. Administrator Bisnis: Bertanggung jawab atas manajemen operasional, administrasi, dan perencanaan bisnis.
3. Petugas Data Entry: Memasukkan dan mengelola data dalam basis data atau sistem informasi.
4. Pegawai Keuangan: Mengelola aspek keuangan perusahaan, termasuk anggaran, pelaporan, dan analisis keuangan.
5. Manajer Proyek: Mengelola proyek-proyek dengan mengatur dan mengawasi setiap tahapan.
6. Manajer Operasi: Bertanggung jawab atas operasi harian perusahaan dan pengelolaan staf.
7. Asisten Eksekutif: Mendukung eksekutif dalam tugas-tugas administrasi dan pengelolaan jadwal.
8. Koordinator Acara: Mengorganisasi dan mengelola acara-acara khusus atau konferensi.
9. Spesialis Data Analisis: Menganalisis data untuk menghasilkan wawasan yang mendukung pengambilan keputusan.
10. Auditor: Memeriksa dan mengaudit catatan keuangan dan proses bisnis untuk memastikan kepatuhan dan akurasi.');

-- Holland results: raw RIASEC totals (sum of all 33 items per type across the 3 rounds,
-- each item scored 1-5) plus the top-2 interpretation, computed and denormalized at submit
-- time by HollandScoringService — same convention as disc_results/DiscScoringService.
CREATE TABLE holland_results (
    id              BIGSERIAL PRIMARY KEY,
    auth_user_id    VARCHAR(64) NOT NULL UNIQUE REFERENCES assessment_users(auth_user_id),
    student_name    VARCHAR(255),
    school_name     VARCHAR(255),
    assignment_id   BIGINT REFERENCES test_assignments(id),

    r_score INT NOT NULL DEFAULT 0,
    i_score INT NOT NULL DEFAULT 0,
    a_score INT NOT NULL DEFAULT 0,
    s_score INT NOT NULL DEFAULT 0,
    e_score INT NOT NULL DEFAULT 0,
    c_score INT NOT NULL DEFAULT 0,

    -- top 2 types by total score (RIASEC order R,I,A,S,E,C breaks ties)
    type1            VARCHAR(1),
    type1_name       VARCHAR(50),
    type1_description TEXT,
    type1_characteristics   TEXT,
    type1_strengths   TEXT,
    type1_weaknesses  TEXT,
    type1_job_match   TEXT,

    type2            VARCHAR(1),
    type2_name       VARCHAR(50),
    type2_description TEXT,
    type2_characteristics   TEXT,
    type2_strengths   TEXT,
    type2_weaknesses  TEXT,
    type2_job_match   TEXT,

    holland_code    VARCHAR(2),   -- e.g. "RI"

    answers         JSONB,
    completed_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

