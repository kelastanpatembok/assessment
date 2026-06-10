-- V8: Representative sample seed data (all editable via superadmin CRUD)
-- Provides enough rows to run the tests end-to-end without real data.

-- ============================================================
-- TEST CATEGORIES
-- ============================================================
INSERT INTO test_categories (name, slug, description, tests, price, is_active) VALUES
  ('Paket Lengkap', 'paket-lengkap', 'DISC + Holland + PAPI + CFIT + IST', ARRAY['disc','holland','papi','cfit','ist'], 350000, true),
  ('Paket Kepribadian', 'paket-kepribadian', 'DISC + Holland + PAPI', ARRAY['disc','holland','papi'], 150000, true),
  ('Paket IQ', 'paket-iq', 'CFIT + IST', ARRAY['cfit','ist'], 200000, true),
  ('DISC Saja', 'disc-only', 'Tes DISC', ARRAY['disc'], 75000, true),
  ('IST Saja', 'ist-only', 'Tes IQ IST', ARRAY['ist'], 125000, true);

-- ============================================================
-- FEE CONFIG (default global)
-- ============================================================
INSERT INTO fee_config (category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct) VALUES
  (NULL, 150000, 20, 10, 70);

-- ============================================================
-- DISC: 24 question blocks (4 statements each: D, I, S, C)
-- ============================================================
INSERT INTO disc_questions (block_no, item_no, category, statement) VALUES
  (1, 1, 'D', 'Saya suka memimpin dan mengambil keputusan'),
  (1, 2, 'I', 'Saya mudah bergaul dan memengaruhi orang lain'),
  (1, 3, 'S', 'Saya setia dan sabar dalam mengerjakan tugas'),
  (1, 4, 'C', 'Saya cermat dan teliti dalam segala hal'),

  (2, 1, 'D', 'Saya berani menghadapi tantangan baru'),
  (2, 2, 'I', 'Saya antusias dalam kegiatan kelompok'),
  (2, 3, 'S', 'Saya menyelesaikan pekerjaan dengan konsisten'),
  (2, 4, 'C', 'Saya mengikuti prosedur dengan ketat'),

  (3, 1, 'D', 'Saya tidak suka mengalah dalam debat'),
  (3, 2, 'I', 'Saya senang menjadi pusat perhatian'),
  (3, 3, 'S', 'Saya mendukung orang lain dengan tulus'),
  (3, 4, 'C', 'Saya sangat memperhatikan detail'),

  (4, 1, 'D', 'Saya cepat dalam mengambil tindakan'),
  (4, 2, 'I', 'Saya suka berbicara di depan umum'),
  (4, 3, 'S', 'Saya lebih suka rutinitas yang teratur'),
  (4, 4, 'C', 'Saya suka menganalisis sebelum bertindak'),

  (5, 1, 'D', 'Saya selalu ingin hasil terbaik'),
  (5, 2, 'I', 'Saya mudah bersemangat dan optimis'),
  (5, 3, 'S', 'Saya tidak terburu-buru dalam bekerja'),
  (5, 4, 'C', 'Saya suka membuat perencanaan yang rinci'),

  (6, 1, 'D', 'Saya tegas dalam mempertahankan pendapat'),
  (6, 2, 'I', 'Saya mudah membangun hubungan baru'),
  (6, 3, 'S', 'Saya menghargai keharmonisan tim'),
  (6, 4, 'C', 'Saya mengandalkan data dan fakta'),

  (7, 1, 'D', 'Saya suka kompetisi dan tantangan'),
  (7, 2, 'I', 'Saya menghibur orang di sekitar saya'),
  (7, 3, 'S', 'Saya membantu orang lain dengan senang hati'),
  (7, 4, 'C', 'Saya menghindari kesalahan dengan hati-hati'),

  (8, 1, 'D', 'Saya tidak mudah menyerah'),
  (8, 2, 'I', 'Saya ekspresif dalam mengungkapkan perasaan'),
  (8, 3, 'S', 'Saya lebih suka kerja tim daripada individu'),
  (8, 4, 'C', 'Saya butuh waktu untuk mempertimbangkan keputusan');

-- ============================================================
-- DISC SCORING TABLES (sample subset for D/I/S/C quadrants)
-- A complete table would have all permutations; this covers the main ones
-- ============================================================
INSERT INTO disc_scoring_most (d_score, i_score, s_score, c_score, key) VALUES
  (1,0,0,0,'D'), (0,1,0,0,'I'), (0,0,1,0,'S'), (0,0,0,1,'C'),
  (1,1,0,0,'DI'), (1,0,1,0,'DS'), (1,0,0,1,'DC'),
  (0,1,1,0,'IS'), (0,1,0,1,'IC'), (0,0,1,1,'SC'),
  (1,1,1,0,'DIS'), (1,1,0,1,'DIC'), (1,0,1,1,'DSC'), (0,1,1,1,'ISC'),
  (1,1,1,1,'X'), (0,0,0,0,'X');

INSERT INTO disc_scoring_least (d_score, i_score, s_score, c_score, key) VALUES
  (1,0,0,0,'D'), (0,1,0,0,'I'), (0,0,1,0,'S'), (0,0,0,1,'C'),
  (1,1,0,0,'DI'), (1,0,1,0,'DS'), (1,0,0,1,'DC'),
  (0,1,1,0,'IS'), (0,1,0,1,'IC'), (0,0,1,1,'SC'),
  (1,1,1,0,'DIS'), (1,1,0,1,'DIC'), (1,0,1,1,'DSC'), (0,1,1,1,'ISC'),
  (1,1,1,1,'X'), (0,0,0,0,'X');

INSERT INTO disc_scoring_dif (d_score, i_score, s_score, c_score, key) VALUES
  (1,0,0,0,'D'), (0,1,0,0,'I'), (0,0,1,0,'S'), (0,0,0,1,'C'),
  (1,1,0,0,'DI'), (1,0,1,0,'DS'), (1,0,0,1,'DC'),
  (0,1,1,0,'IS'), (0,1,0,1,'IC'), (0,0,1,1,'SC'),
  (1,1,1,0,'DIS'), (1,1,0,1,'DIC'), (1,0,1,1,'DSC'), (0,1,1,1,'ISC'),
  (1,1,1,1,'X'), (0,0,0,0,'X');

-- DISC personality profiles (sample)
INSERT INTO disc_personality_profiles (most_key, least_key, dif_key, title, description) VALUES
  ('D','S','D','Pengendali','Tipe dominan yang menyukai kontrol dan hasil cepat. Tegas, berorientasi tujuan, dan kompetitif.'),
  ('I','C','I','Influencer','Komunikatif, antusias, dan persuasif. Menyukai interaksi sosial dan memotivasi orang lain.'),
  ('S','D','S','Pendukung','Sabar, setia, dan konsisten. Lebih menyukai stabilitas dan bekerja dalam tim yang harmonis.'),
  ('C','I','C','Analis','Cermat, sistematis, dan berorientasi kualitas. Mengandalkan data dan prosedur dalam bekerja.'),
  ('DI','SC','D','Pemimpin Dinamis','Kombinasi dominan dan pengaruh — pemimpin yang energik dan menginspirasi.'),
  ('IS','DC','I','Konsultan Empatik','Ramah dan suportif, mahir membangun relasi dan mendukung orang lain.'),
  ('SC','DI','S','Pelaksana Teliti','Stabil dan hati-hati, bekerja dengan metodis dan terstruktur.'),
  ('DC','IS','C','Strategis','Analitis dan tegas, menetapkan standar tinggi dan memastikan kepatuhan prosedur.'),
  ('X','X','X','Seimbang','Profil yang seimbang di semua dimensi — fleksibel dalam berbagai situasi.');

-- ============================================================
-- HOLLAND: 6 types, and sample questions for R1-C3 groups
-- ============================================================
INSERT INTO holland_descriptions (riasec_type, name, description, careers) VALUES
  ('R','Realistic (Realistis)','Menyukai pekerjaan dengan tangan, alat, mesin, atau di luar ruangan. Praktis dan fisik.','Teknisi, Mekanik, Insinyur, Pertanian, Konstruksi'),
  ('I','Investigative (Investigatif)','Analitis, intelektual, suka memecahkan masalah ilmiah. Berorientasi riset.','Ilmuwan, Peneliti, Programmer, Dokter, Analis Data'),
  ('A','Artistic (Artistik)','Kreatif, imajinatif, ekspresif. Menyukai seni, musik, sastra, dan desain.','Desainer, Seniman, Penulis, Musisi, Aktor'),
  ('S','Social (Sosial)','Peduli pada orang lain, suka membantu dan mengajar. Berorientasi layanan.','Guru, Konselor, Pekerja Sosial, Perawat, HRD'),
  ('E','Enterprising (Kewirausahaan)','Suka memimpin, memengaruhi, dan berwirausaha. Kompetitif dan ambisius.','Manajer, Pengusaha, Politisi, Sales, Marketing'),
  ('C','Conventional (Konvensional)','Terorganisir, detail, mengikuti prosedur. Suka data dan administrasi.','Akuntan, Administrasi, Analis Keuangan, Arsiparis');

-- Sample Holland questions — R1 group (Realistic type 1)
INSERT INTO holland_questions (group_code, item_no, riasec_type, statement) VALUES
  ('R1',  1,'R','Saya senang bekerja dengan peralatan tangan atau mesin'),
  ('R1',  2,'R','Saya menikmati pekerjaan fisik di luar ruangan'),
  ('R1',  3,'R','Saya tertarik pada perbaikan kendaraan atau elektronik'),
  ('R1',  4,'R','Saya suka membangun atau merakit sesuatu'),
  ('R1',  5,'R','Saya nyaman bekerja dengan hewan atau tanaman'),
  ('R1',  6,'R','Saya lebih suka bertindak daripada merencanakan'),
  ('R1',  7,'R','Saya menikmati kegiatan bertahan hidup di alam'),
  ('R1',  8,'R','Saya suka bekerja dengan bahan-bahan fisik seperti kayu atau logam'),
  ('R1',  9,'R','Saya tertarik pada pekerjaan konstruksi atau pertanian'),
  ('R1', 10,'R','Saya senang memperbaiki barang-barang yang rusak'),
  ('R1', 11,'R','Saya lebih suka pekerjaan nyata daripada pekerjaan abstrak'),
-- I1 group
  ('I1',  1,'I','Saya senang membaca jurnal ilmiah atau artikel riset'),
  ('I1',  2,'I','Saya menikmati memecahkan masalah matematika yang sulit'),
  ('I1',  3,'I','Saya tertarik pada percobaan dan eksperimen'),
  ('I1',  4,'I','Saya suka menganalisis data untuk menemukan pola'),
  ('I1',  5,'I','Saya tertarik pada cara kerja teknologi terbaru'),
  ('I1',  6,'I','Saya senang belajar tentang fenomena alam'),
  ('I1',  7,'I','Saya menikmati debat ilmiah atau diskusi logis'),
  ('I1',  8,'I','Saya tertarik pada penelitian medis atau biologi'),
  ('I1',  9,'I','Saya suka mencari solusi kreatif untuk masalah teknis'),
  ('I1', 10,'I','Saya senang bekerja dengan komputer dan pemrograman'),
  ('I1', 11,'I','Saya tertarik pada astronomi atau fisika'),
-- A1 group
  ('A1',  1,'A','Saya suka menggambar atau melukis'),
  ('A1',  2,'A','Saya menikmati bermain musik'),
  ('A1',  3,'A','Saya tertarik pada dunia seni dan pertunjukan'),
  ('A1',  4,'A','Saya suka menulis cerita atau puisi'),
  ('A1',  5,'A','Saya menikmati desain grafis atau fotografi'),
  ('A1',  6,'A','Saya senang bereksplorasi dengan ide-ide kreatif'),
  ('A1',  7,'A','Saya tertarik pada dunia mode atau desain interior'),
  ('A1',  8,'A','Saya suka akting atau tampil di panggung'),
  ('A1',  9,'A','Saya menikmati menonton film seni atau teater'),
  ('A1', 10,'A','Saya tertarik pada kerajinan tangan atau seni rupa'),
  ('A1', 11,'A','Saya lebih suka ekspresi bebas daripada aturan ketat'),
-- S1 group
  ('S1',  1,'S','Saya menikmati membantu teman yang kesulitan'),
  ('S1',  2,'S','Saya tertarik pada pekerjaan sosial atau sukarela'),
  ('S1',  3,'S','Saya senang mengajar atau melatih orang lain'),
  ('S1',  4,'S','Saya peduli pada kesejahteraan masyarakat'),
  ('S1',  5,'S','Saya menikmati konseling atau mendengarkan curahan hati'),
  ('S1',  6,'S','Saya tertarik pada pekerjaan kemanusiaan'),
  ('S1',  7,'S','Saya senang bekerja dalam tim yang kolaboratif'),
  ('S1',  8,'S','Saya tertarik pada pendidikan anak atau remaja'),
  ('S1',  9,'S','Saya suka menciptakan lingkungan yang nyaman bagi orang lain'),
  ('S1', 10,'S','Saya menikmati kegiatan komunitas dan sosial'),
  ('S1', 11,'S','Saya tertarik pada perawatan kesehatan atau terapi'),
-- E1 group
  ('E1',  1,'E','Saya suka memimpin sebuah proyek atau tim'),
  ('E1',  2,'E','Saya menikmati persuasi dan negosiasi'),
  ('E1',  3,'E','Saya tertarik pada dunia bisnis dan kewirausahaan'),
  ('E1',  4,'E','Saya senang mengambil risiko yang terukur'),
  ('E1',  5,'E','Saya menikmati kompetisi dan pencapaian target'),
  ('E1',  6,'E','Saya tertarik pada strategi pemasaran'),
  ('E1',  7,'E','Saya suka membuat keputusan besar'),
  ('E1',  8,'E','Saya tertarik pada karier di manajemen atau kepemimpinan'),
  ('E1',  9,'E','Saya senang berbicara di depan publik'),
  ('E1', 10,'E','Saya menikmati memotivasi dan menginspirasi orang lain'),
  ('E1', 11,'E','Saya tertarik pada investasi atau keuangan bisnis'),
-- C1 group
  ('C1',  1,'C','Saya suka bekerja dengan angka dan data'),
  ('C1',  2,'C','Saya menikmati pengarsipan dan pengorganisasian berkas'),
  ('C1',  3,'C','Saya tertarik pada akuntansi atau keuangan'),
  ('C1',  4,'C','Saya senang mengikuti prosedur dengan ketat'),
  ('C1',  5,'C','Saya menikmati pekerjaan yang membutuhkan ketelitian tinggi'),
  ('C1',  6,'C','Saya tertarik pada administrasi atau manajemen kantor'),
  ('C1',  7,'C','Saya suka membuat laporan dan dokumentasi'),
  ('C1',  8,'C','Saya menikmati bekerja dengan spreadsheet atau database'),
  ('C1',  9,'C','Saya tertarik pada pekerjaan analisis atau audit'),
  ('C1', 10,'C','Saya senang mengikuti jadwal dan rencana'),
  ('C1', 11,'C','Saya lebih suka pekerjaan terstruktur daripada fleksibel');

-- ============================================================
-- PAPI KOSTICK: 20 traits, 90 pairs
-- Traits: N,G,A,L,P,I,T,V,X,S,B,O,R,D,C,E,K,F,W,Z
-- ============================================================
INSERT INTO papi_descriptions (trait_code, trait_name, description, high_desc, low_desc) VALUES
  ('N','Kebutuhan atas Aturan','Kepatuhan terhadap aturan dan prosedur','Sangat patuh pada aturan','Cenderung fleksibel terhadap aturan'),
  ('G','Peran Pemimpin yang Aktif','Inisiatif memimpin secara aktif','Pemimpin yang tegas dan direktif','Lebih suka mengikuti daripada memimpin'),
  ('A','Kebutuhan Persetujuan','Butuh penerimaan dari orang lain','Sangat butuh pujian dan persetujuan','Tidak terlalu mempedulikan pendapat orang'),
  ('L','Kepemimpinan','Kemampuan memimpin','Pemimpin alami yang dihormati','Lebih nyaman sebagai anggota tim'),
  ('P','Kecepatan Kerja','Tempo pengerjaan tugas','Bekerja dengan tempo cepat dan energik','Bekerja dengan tenang dan hati-hati'),
  ('I','Kerapian & Ketelitian','Detail dan presisi dalam bekerja','Sangat rapi dan teliti','Lebih fokus pada gambaran besar'),
  ('T','Orientasi Tugas','Dedikasi terhadap penyelesaian tugas','Sangat berorientasi pada hasil tugas','Lebih memprioritaskan orang daripada tugas'),
  ('V','Ketangguhan Mental','Ketabahan menghadapi tekanan','Sangat tangguh menghadapi kritik','Lebih sensitif terhadap tekanan'),
  ('X','Kebutuhan Bervariasi','Preferensi terhadap keberagaman','Menikmati variasi dan perubahan','Lebih suka rutinitas yang konsisten'),
  ('S','Empati Sosial','Kepekaan terhadap perasaan orang lain','Sangat peka terhadap perasaan orang lain','Cenderung objektif dan kurang sensitif'),
  ('B','Keterampilan Sosial','Kemampuan bersosialisasi','Sangat mudah bergaul dan terbuka','Lebih nyaman sendiri atau dalam kelompok kecil'),
  ('O','Peran Pengasuhan','Keinginan membimbing dan memelihara','Sangat nurturing dan supportif','Lebih fokus pada diri sendiri'),
  ('R','Pemikiran Teoritis','Kemampuan berpikir abstrak','Sangat analitis dan teoritis','Lebih praktis dan konkret'),
  ('D','Kebutuhan Otonomi','Preferensi untuk bekerja mandiri','Sangat menyukai kebebasan dan independensi','Lebih suka arahan dan struktur jelas'),
  ('C','Kepercayaan Diri','Keyakinan pada kemampuan diri','Sangat percaya diri dan asertif','Lebih hati-hati dan ragu-ragu'),
  ('E','Kontrol Emosi','Kemampuan mengelola emosi','Sangat tenang dan stabil secara emosional','Lebih ekspresif dan reaktif'),
  ('K','Kerja Keras','Dedikasi dan ketekunan','Sangat rajin dan pantang menyerah','Lebih santai dan tidak terlalu ambisius'),
  ('F','Fleksibilitas','Kemampuan menyesuaikan diri','Sangat adaptif terhadap perubahan','Lebih terstruktur dan kurang fleksibel'),
  ('W','Orientasi Penghargaan','Motivasi oleh pengakuan','Sangat termotivasi oleh penghargaan eksternal','Lebih termotivasi oleh kepuasan internal'),
  ('Z','Ketegasan','Ketegasan dalam mengambil sikap','Sangat tegas dan langsung','Lebih diplomatis dan tidak langsung');

-- PAPI questions (90 pairs of statements, A and B)
-- Sample 20 pairs covering all 20 traits (one pair each)
INSERT INTO papi_questions (pair_no, item_letter, trait_code, statement) VALUES
  (1,'A','N','Saya selalu mengikuti peraturan yang ada'),
  (1,'B','D','Saya lebih suka bekerja dengan cara saya sendiri'),
  (2,'A','G','Saya sering mengambil inisiatif memimpin kelompok'),
  (2,'B','O','Saya lebih suka mendukung dan membimbing orang lain'),
  (3,'A','A','Saya butuh pujian agar bisa bekerja dengan baik'),
  (3,'B','C','Saya yakin dengan kemampuan saya tanpa perlu dipuji'),
  (4,'A','L','Saya merasa nyaman ketika harus memimpin orang lain'),
  (4,'B','S','Saya lebih suka memastikan semua orang merasa nyaman'),
  (5,'A','P','Saya mengerjakan banyak hal dengan cepat'),
  (5,'B','I','Saya mengerjakan setiap hal dengan sangat teliti'),
  (6,'A','T','Saya fokus menyelesaikan tugas sebelum beristirahat'),
  (6,'B','B','Saya senang mengobrol dengan rekan kerja saat bekerja'),
  (7,'A','V','Saya tidak mudah terpuruk oleh kritik'),
  (7,'B','E','Saya bisa mengendalikan emosi dalam situasi sulit'),
  (8,'A','X','Saya senang mencoba cara-cara baru dalam bekerja'),
  (8,'B','F','Saya dengan mudah menyesuaikan diri dengan perubahan'),
  (9,'A','S','Saya peka terhadap perasaan orang-orang di sekitar saya'),
  (9,'B','R','Saya lebih suka berpikir secara analitis dan teoritis'),
  (10,'A','B','Saya mudah berteman dengan orang baru'),
  (10,'B','W','Saya butuh pengakuan atas kerja keras saya'),
  (11,'A','N','Saya percaya prosedur ada untuk diikuti'),
  (11,'B','X','Saya suka variasi dalam pekerjaan'),
  (12,'A','G','Saya sering jadi orang yang mengambil kendali'),
  (12,'B','K','Saya siap bekerja lebih keras dari orang lain'),
  (13,'A','T','Hasil pekerjaan adalah prioritas utama saya'),
  (13,'B','O','Memastikan tim saya bahagia adalah prioritas saya'),
  (14,'A','P','Saya suka bekerja dalam tempo yang cepat'),
  (14,'B','E','Saya jarang membiarkan emosi mempengaruhi keputusan'),
  (15,'A','L','Saya senang diberi tanggung jawab besar'),
  (15,'B','D','Saya lebih produktif tanpa pengawasan'),
  (16,'A','I','Saya memeriksa ulang pekerjaan saya berkali-kali'),
  (16,'B','C','Saya percaya bahwa ragu-ragu itu merugikan'),
  (17,'A','V','Saya tetap fokus meskipun banyak hambatan'),
  (17,'B','A','Saya butuh dukungan emosional dari rekan kerja'),
  (18,'A','R','Saya senang mendiskusikan teori dan konsep abstrak'),
  (18,'B','S','Saya lebih tertarik pada perasaan dan hubungan'),
  (19,'A','F','Saya bisa mengubah rencana kapan saja jika perlu'),
  (19,'B','N','Saya lebih suka mengikuti jadwal yang sudah ada'),
  (20,'A','W','Saya sangat menghargai penghargaan dari atasan'),
  (20,'B','K','Saya tidak berhenti bekerja sampai selesai');

-- ============================================================
-- CFIT: 4 subtests, sample questions (text-based for dev)
-- ============================================================
INSERT INTO cfit_questions (subtest_no, item_no, question_text, options, correct_answer) VALUES
  (1, 1, 'Pilih gambar yang melanjutkan pola deretan berikut: Segitiga → Persegi → Pentagon → ?',
   '{"A":"Hexagon","B":"Lingkaran","C":"Bintang","D":"Segitiga"}', 'A'),
  (1, 2, 'Mana yang tidak termasuk dalam kelompok: Merah, Biru, Hijau, Keras?',
   '{"A":"Merah","B":"Biru","C":"Hijau","D":"Keras"}', 'D'),
  (1, 3, 'Pola: 2, 4, 8, 16, ... Angka selanjutnya adalah?',
   '{"A":"24","B":"32","C":"20","D":"18"}', 'B'),
  (2, 1, 'Jika semua kucing adalah hewan, dan semua hewan bernapas, maka kucing...',
   '{"A":"tidak bernapas","B":"adalah hewan saja","C":"bernapas","D":"bukan hewan"}', 'C'),
  (2, 2, 'Mana yang memiliki hubungan sama dengan: Panas : Dingin',
   '{"A":"Gelap : Malam","B":"Terang : Siang","C":"Hitam : Putih","D":"Langit : Biru"}', 'C'),
  (3, 1, 'Sebuah bujur sangkar dengan sisi 6 cm memiliki luas?',
   '{"A":"12 cm2","B":"24 cm2","C":"36 cm2","D":"18 cm2"}', 'C'),
  (3, 2, 'Jika 5 pekerja bisa menyelesaikan pekerjaan dalam 8 hari, berapa lama 10 pekerja?',
   '{"A":"16 hari","B":"4 hari","C":"8 hari","D":"2 hari"}', 'B'),
  (4, 1, 'Antonim dari kata RAMAH adalah...',
   '{"A":"Sopan","B":"Kasar","C":"Tenang","D":"Bijaksana"}', 'B'),
  (4, 2, 'Sinonim dari kata CERDAS adalah...',
   '{"A":"Bodoh","B":"Lambat","C":"Pandai","D":"Malas"}', 'C');

-- CFIT descriptions
INSERT INTO cfit_descriptions (score_min, score_max, iq_min, iq_max, category, description) VALUES
  (36, 45, 130, 145, 'Sangat Tinggi', 'Kemampuan intelektual sangat superior. Cepat dalam memproses informasi dan memecahkan masalah.'),
  (28, 35, 115, 129, 'Tinggi', 'Kemampuan intelektual di atas rata-rata. Mampu berpikir abstrak dengan baik.'),
  (20, 27, 90, 114, 'Rata-rata', 'Kemampuan intelektual rata-rata. Mampu menangani tugas sehari-hari dengan baik.'),
  (12, 19, 70, 89, 'Rendah', 'Kemampuan intelektual di bawah rata-rata. Memerlukan dukungan tambahan.'),
  (0, 11, 50, 69, 'Sangat Rendah', 'Kemampuan intelektual jauh di bawah rata-rata. Perlu evaluasi mendalam.');

-- ============================================================
-- IST: subtest norma (sample raw_score → wert mapping for SE)
-- ============================================================
INSERT INTO ist_questions (subtest_code, item_no, question_text, correct_answer) VALUES
  -- SE: Satzergänzung (sentence completion) — free-text concept answer
  ('SE', 1, 'Pohon memiliki ___ seperti manusia memiliki tulang.', 'batang'),
  ('SE', 2, 'Buku adalah untuk membaca seperti pensil adalah untuk ___.', 'menulis'),
  ('SE', 3, 'Air mengalir ke bawah karena ___.', 'gravitasi'),
  ('SE', 4, 'Matahari terbit di ___ dan terbenam di ___.', 'timur'),
  ('SE', 5, 'Manusia bernapas menggunakan ___.', 'paru-paru'),
  -- WA: Wortauswahl (word choice) — pick word that completes analogy
  ('WA', 1, 'Dokter : Rumah Sakit = Guru : ?',
   'Sekolah'),
  ('WA', 2, 'Pensil : Menulis = Pisau : ?',
   'Memotong'),
  ('WA', 3, 'Panas : Api = Dingin : ?',
   'Es'),
  -- AN: Analogien (analogies)
  ('AN', 1, 'Kuda : Berkuda = Sepeda : ?', 'Bersepeda'),
  ('AN', 2, 'Buku : Perpustakaan = Lukisan : ?', 'Museum'),
  -- GE: Gemeinsamkeiten (commonalities) — what do three words have in common
  ('GE', 1, 'Anjing, Kucing, Kelinci — apa persamaannya?', 'hewan peliharaan'),
  ('GE', 2, 'Merah, Biru, Hijau — apa persamaannya?', 'warna'),
  -- RA: Rechenaufgaben (arithmetic)
  ('RA', 1, '25 + 37 = ?', '62'),
  ('RA', 2, '144 ÷ 12 = ?', '12'),
  ('RA', 3, '15 × 8 = ?', '120'),
  -- FA: Figurenauswahl (figure selection) — visual/pattern
  ('FA', 1, 'Mana gambar yang tidak sesuai dengan pola lainnya? (A-D)', 'D');

-- ZR: number sequence
INSERT INTO ist_zr_questions (item_no, sequence_text, correct_answer) VALUES
  (1, '2, 4, 6, 8, ?', 10),
  (2, '3, 6, 12, 24, ?', 48),
  (3, '100, 90, 80, 70, ?', 60),
  (4, '1, 1, 2, 3, 5, 8, ?', 13);

-- WU: sentence true/false
INSERT INTO ist_wu_questions (item_no, statement, correct_answer) VALUES
  (1, 'Semua mamalia adalah hewan berdarah panas', 'BENAR'),
  (2, 'Jakarta adalah ibu kota Jawa Barat', 'SALAH'),
  (3, 'Air mendidih pada suhu 100 derajat Celsius pada tekanan standar', 'BENAR'),
  (4, 'Bumi mengelilingi Matahari dalam waktu 365 hari', 'BENAR');

-- ME: word-pair memory
INSERT INTO ist_me_pairs (item_no, word1, word2, options, correct_answer) VALUES
  (1, 'Meja', 'Kursi', '{"A":"Kursi","B":"Lemari","C":"Sofa","D":"Kasur"}', 'Kursi'),
  (2, 'Buku', 'Pensil', '{"A":"Penghapus","B":"Pensil","C":"Pulpen","D":"Kertas"}', 'Pensil'),
  (3, 'Langit', 'Biru', '{"A":"Putih","B":"Abu-abu","C":"Biru","D":"Hitam"}', 'Biru'),
  (4, 'Ayam', 'Telur', '{"A":"Daging","B":"Susu","C":"Telur","D":"Anak ayam"}', 'Telur');

-- IST norma (SE subtest, sample mapping)
INSERT INTO ist_norma (subtest_code, raw_score, wert) VALUES
  ('SE', 0, 1), ('SE', 1, 2), ('SE', 2, 3), ('SE', 3, 4), ('SE', 4, 5),
  ('SE', 5, 6), ('SE', 6, 7), ('SE', 7, 8), ('SE', 8, 9), ('SE', 9, 10),
  ('SE',10,11), ('SE',11,12), ('SE',12,13), ('SE',13,14), ('SE',14,15),
  ('WA', 0, 1), ('WA', 1, 2), ('WA', 2, 3), ('WA', 3, 4), ('WA', 4, 5),
  ('WA', 5, 6), ('WA', 6, 7), ('WA', 7, 8), ('WA', 8, 9), ('WA', 9, 10),
  ('AN', 0, 1), ('AN', 1, 2), ('AN', 2, 3), ('AN', 3, 4), ('AN', 4, 5),
  ('AN', 5, 6), ('AN', 6, 7), ('AN', 7, 8), ('AN', 8, 9), ('AN', 9, 10),
  ('GE', 0, 1), ('GE', 1, 2), ('GE', 2, 3), ('GE', 3, 4), ('GE', 4, 5),
  ('GE', 5, 6), ('GE', 6, 7), ('GE', 7, 8), ('GE', 8, 9), ('GE', 9, 10),
  ('RA', 0, 1), ('RA', 1, 2), ('RA', 2, 3), ('RA', 3, 4), ('RA', 4, 5),
  ('RA', 5, 6), ('RA', 6, 7), ('RA', 7, 8), ('RA', 8, 9), ('RA', 9, 10),
  ('ZR', 0, 1), ('ZR', 1, 2), ('ZR', 2, 3), ('ZR', 3, 4), ('ZR', 4, 5),
  ('ZR', 5, 6), ('ZR', 6, 7), ('ZR', 7, 8), ('ZR', 8, 9), ('ZR', 9, 10),
  ('FA', 0, 1), ('FA', 1, 2), ('FA', 2, 3), ('FA', 3, 4), ('FA', 4, 5),
  ('FA', 5, 6), ('FA', 6, 7), ('FA', 7, 8), ('FA', 8, 9), ('FA', 9, 10),
  ('WU', 0, 1), ('WU', 1, 2), ('WU', 2, 3), ('WU', 3, 4), ('WU', 4, 5),
  ('WU', 5, 6), ('WU', 6, 7), ('WU', 7, 8), ('WU', 8, 9), ('WU', 9, 10),
  ('ME', 0, 1), ('ME', 1, 2), ('ME', 2, 3), ('ME', 3, 4), ('ME', 4, 5),
  ('ME', 5, 6), ('ME', 6, 7), ('ME', 7, 8), ('ME', 8, 9), ('ME', 9, 10);

-- IST IQ bands (total wert → IQ range)
INSERT INTO ist_iq_bands (wert_min, wert_max, iq_min, iq_max, category) VALUES
  (100, 999, 130, 145, 'Sangat Tinggi'),
  (80,  99, 115, 129, 'Di Atas Rata-rata'),
  (55,  79, 90, 114, 'Rata-rata'),
  (35,  54, 70,  89, 'Di Bawah Rata-rata'),
  (0,   34, 50,  69, 'Rendah');
