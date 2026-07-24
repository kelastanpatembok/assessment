-- V21: Replace ALL remaining IST placeholder question content with real content
-- transcribed from the physical test booklet (~/Downloads/Soal IST — 18 photographed
-- pages, one instruction/example page + one item page per subtest except ME which has
-- an extra memorization-list page) and the real answer key (docs/ist-result.docx /
-- "KUNCI JAWABAN IST (2).docx").
--
-- SE/WA/AN (V18) and FA/WU (V17) already had real structure + real per-item answers,
-- just placeholder text/options — this migration replaces that text with the real
-- transcribed sentences/options. GE/RA/ZR/ME were still the tiny 2-4 item V8 samples
-- (wrong item numbering, fabricated content) — this migration replaces them with the
-- complete, correctly-numbered real item sets.
--
-- Every numeric answer below (RA, ZR) was independently re-derived from the transcribed
-- word problem / sequence and cross-checked against the docx answer key — all 20 RA
-- items and 12 of 20 ZR items matched exactly by direct calculation, giving high
-- confidence the remaining transcriptions are accurate too.
--
-- Two documented exceptions (NOT fully verified against an original source — flagged
-- here and in docs/todo-ist-test.md, same "ship with a documented gap" pattern used for
-- CFIT's IQ band labels):
--   1. GE (61-76) has no answer key anywhere (ist-result.docx has no GE column, and GE
--      is free-text "find the word that covers both" — there's no fixed single answer).
--      correct_answer below is a reasonable single-word guess, not sourced. Scoring for
--      GE was already a known gap (see "GE tiered scoring" section, untouched here).
--   2. ME (157-176) — the booklet page only shows the real 5-category/25-word
--      memorization list plus 2 worked examples (letters Q and Z), not the actual list
--      of which letter is asked in each of the 20 real items. The per-item ANSWER
--      LETTER (a-e) below is real (from the docx), but which specific word/letter each
--      item asks about is a reconstruction: each category is used exactly 4 times
--      (matching the real answer distribution) with 4 of its 5 real words, assigned in
--      answer order. The word list, item format, and per-item correct category are all
--      real; only the exact letter-to-item-number pairing is inferred.

-- ============================================================
-- SE (01-20) — sentence completion, real sentences + options
-- ============================================================
DELETE FROM ist_questions WHERE subtest_code = 'SE';
INSERT INTO ist_questions (subtest_code, item_no, question_text, options, correct_answer) VALUES
('SE', 1, 'Pengaruh seseorang terhadap orang lain seharusnya bergantung pada ......',
 '{"A":"kekuasaan","B":"bujukan","C":"kekayaan","D":"keberanian","E":"kewibawaan"}', 'E'),
('SE', 2, 'Lawan "hemat" ialah ......',
 '{"A":"murah","B":"kikir","C":"boros","D":"bernilai","E":"kaya"}', 'C'),
('SE', 3, '...... tidak termasuk cuaca',
 '{"A":"angin puyuh","B":"halilintar","C":"salju","D":"gempa bumi","E":"kabut"}', 'D'),
('SE', 4, 'Lawannya "setia" ialah ......',
 '{"A":"cinta","B":"benci","C":"persahabatan","D":"khianat","E":"permusuhan"}', 'D'),
('SE', 5, 'Seekor kuda selalu mempunyai ......',
 '{"A":"kandang","B":"ladam","C":"pelana","D":"kuku","E":"surai"}', 'D'),
('SE', 6, 'Seorang paman ...... lebih tua dari kemenakannya.',
 '{"A":"jarang","B":"biasanya","C":"selalu","D":"tidak pernah","E":"kadang-kadang"}', 'B'),
('SE', 7, 'Pada jumlah yang sama, nilai kalori yang tertinggi terdapat pada ......',
 '{"A":"ikan","B":"daging","C":"lemak","D":"tahu","E":"sayuran"}', 'C'),
('SE', 8, 'Pada suatu pertandingan selalu terdapat ......',
 '{"A":"lawan","B":"wasit","C":"penonton","D":"sorak","E":"kemenangan"}', 'A'),
('SE', 9, 'Suatu pernyataan yang belum dipastikan dikatakan sebagai pernyataan yang ......',
 '{"A":"paradoks","B":"tergesa-gesa","C":"mempunyai arti rangkap","D":"menyesatkan","E":"hipotesis"}', 'E'),
('SE', 10, 'Pada sepatu selalu terdapat ......',
 '{"A":"kulit","B":"sol","C":"tali sepatu","D":"gesper","E":"lidah"}', 'B'),
('SE', 11, 'Suatu ...... tidak menyangkut persoalan pencegahan kecelakaan.',
 '{"A":"lampu lalu lintas","B":"kacamata pelindung","C":"kotak PPPK","D":"tanda peringatan","E":"palang kereta api"}', 'C'),
('SE', 12, 'Lembar kertas uang Rp. 50.000,- mempunyai panjang ...... cm.',
 '{"A":"20","B":"29","C":"17","D":"15","E":"24"}', 'D'),
('SE', 13, 'Seseorang yang bersikap menyangsikan setiap kemajuan ialah seorang yang ......',
 '{"A":"demokratis","B":"radikal","C":"liberal","D":"konservatif","E":"anarkis"}', 'D'),
('SE', 14, 'Lawannya "tidak pernah" ialah ......',
 '{"A":"sering","B":"kadang-kadang","C":"jarang","D":"kerap kali","E":"selalu"}', 'E'),
('SE', 15, 'Jarak antara Jakarta - Surabaya kira-kira ...... km.',
 '{"A":"650","B":"1000","C":"800","D":"600","E":"950"}', 'C'),
('SE', 16, 'Untuk dapat membuat nada yang rendah dan mendalam, kita memerlukan banyak ......',
 '{"A":"kekuatan","B":"peranan","C":"ayunan","D":"berat","E":"suara"}', 'A'),
('SE', 17, 'Ayah ...... lebih berpengalaman dari pada anaknya,',
 '{"A":"selalu","B":"biasanya","C":"jauh","D":"jarang","E":"pada dasarnya"}', 'B'),
('SE', 18, 'Di antara kota-kota berikut ini, maka kota ...... letaknya paling selatan.',
 '{"A":"Jakarta","B":"Bandung","C":"Cirebon","D":"Semarang","E":"Surabaya"}', 'B'),
('SE', 19, 'Jika kita mengetahui jumlah presentase nomor-nomor lotere yang tidak menang, maka kita dapat menghitung ......',
 '{"A":"jumlah nomor yang menang","B":"pajak lotere","C":"kemungkinan menang","D":"jumlah pengikut","E":"tinggi keuntungan"}', 'C'),
('SE', 20, 'Seorang anak yang berumur 10 tahun tingginya rata-rata ...... cm.',
 '{"A":"150","B":"130","C":"110","D":"105","E":"115"}', 'B');

-- ============================================================
-- WA (21-40) — odd-one-out; the booklet gives only 5 option words per item, no
-- separate stem sentence (the instruction page's rule is the shared stem).
-- ============================================================
DELETE FROM ist_questions WHERE subtest_code = 'WA';
INSERT INTO ist_questions (subtest_code, item_no, question_text, options, correct_answer) VALUES
('WA', 21, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"Lingkaran","B":"panah","C":"elips","D":"busur","E":"lengkungan"}', 'B'),
('WA', 22, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"mengetuk","B":"memaki","C":"menjahit","D":"menggergaji","E":"memukul"}', 'B'),
('WA', 23, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"lebar","B":"keliling","C":"luas","D":"isi","E":"panjang"}', 'D'),
('WA', 24, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"mengikat","B":"menyatukan","C":"melepaskan","D":"mengaitkan","E":"Melekatkan"}', 'C'),
('WA', 25, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"arah","B":"timur","C":"perjalanan","D":"tujuan","E":"selatan"}', 'C'),
('WA', 26, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"jarak","B":"perpisahan","C":"tugas","D":"batas","E":"perceraian"}', 'C'),
('WA', 27, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"saringan","B":"kelambu","C":"payung","D":"tapisan","E":"jala"}', 'C'),
('WA', 28, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"putih","B":"pucat","C":"buram","D":"kasar","E":"berkilauan"}', 'D'),
('WA', 29, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"otobis","B":"pesawat terbang","C":"sepeda motor","D":"sepeda","E":"kapal api"}', 'D'),
('WA', 30, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"biola","B":"seruling","C":"klarinet","D":"terompet","E":"saxophon"}', 'A'),
('WA', 31, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"bergelombang","B":"kasar","C":"berduri","D":"licin","E":"lurus"}', 'E'),
('WA', 32, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"jam","B":"kompas","C":"penunjuk jalan","D":"bintang pari","E":"arah"}', 'A'),
('WA', 33, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"kebijaksanaan","B":"pendidikan","C":"perencanaan","D":"penempatan","E":"pengerahan"}', 'A'),
('WA', 34, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"bermotor","B":"berjalan","C":"berlayar","D":"bersepeda","E":"berkuda"}', 'B'),
('WA', 35, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"gambar","B":"lukisan","C":"potret","D":"patung","E":"ukiran"}', 'C'),
('WA', 36, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"panjang","B":"lonjong","C":"runcing","D":"bulat","E":"bersudut"}', 'D'),
('WA', 37, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"kunci","B":"palang pintu","C":"gerendel","D":"gunting","E":"obeng"}', 'D'),
('WA', 38, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"jembatan","B":"batas","C":"perkawinan","D":"pagar","E":"masyarakat"}', 'B'),
('WA', 39, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"mengetam","B":"memahat","C":"mengasah","D":"melicinkan","E":"menggosok"}', 'B'),
('WA', 40, 'Manakah dari kelima kata berikut yang TIDAK memiliki kesamaan dengan keempat kata lainnya?',
 '{"A":"batu","B":"baja","C":"bulu","D":"karet","E":"kayu"}', 'E');

-- ============================================================
-- AN (41-60) — verbal analogies "kata1 : kata2 = kata3 : ?"
-- ============================================================
DELETE FROM ist_questions WHERE subtest_code = 'AN';
INSERT INTO ist_questions (subtest_code, item_no, question_text, options, correct_answer) VALUES
('AN', 41, 'Menemukan : menghilangkan = Mengingat : ?',
 '{"A":"menghapal","B":"mengenai","C":"melupakan","D":"berpikir","E":"memimpikan"}', 'C'),
('AN', 42, 'Bunga : jambangan = Burung : ?',
 '{"A":"sarang","B":"langit","C":"pagar","D":"pohon","E":"sangkar"}', 'E'),
('AN', 43, 'Kereta api : rel = Otobis : ?',
 '{"A":"roda","B":"poros","C":"ban","D":"jalan raya","E":"kecepatan"}', 'D'),
('AN', 44, 'Perak : emas = Cincin : ?',
 '{"A":"arloji","B":"berlian","C":"permata","D":"gelang","E":"platina"}', 'D'),
('AN', 45, 'Lingkaran : bola = Bujur sangkar : ?',
 '{"A":"bentuk","B":"gambar","C":"segi empat","D":"kubus","E":"piramida"}', 'D'),
('AN', 46, 'Saran : keputusan = Merundingkan : ?',
 '{"A":"menawarkan","B":"menentukan","C":"menilai","D":"menimbang","E":"merenungkan"}', 'A'),
('AN', 47, 'Lidah : asam = Hidung : ?',
 '{"A":"mencium","B":"bernapas","C":"mengecap","D":"tengik","E":"asin"}', 'D'),
('AN', 48, 'Darah : pembuluh = Air : ?',
 '{"A":"pintu air","B":"sungai","C":"talang","D":"hujan","E":"ember"}', 'B'),
('AN', 49, 'Saraf : penyalur = Pupil : ?',
 '{"A":"penyinaran","B":"mata","C":"melihat","D":"cahaya","E":"pelindung"}', 'E'),
('AN', 50, 'Pengantar surat : pengantar telegram = Pandai besi : ?',
 '{"A":"palu godam","B":"pedagang besi","C":"api","D":"tukang emas","E":"besi tempa"}', 'D'),
('AN', 51, 'Buta : warna = Tuli : ?',
 '{"A":"pendengaran","B":"mendengar","C":"nada","D":"kata","E":"telinga"}', 'C'),
('AN', 52, 'Makanan : bumbu = Ceramah : ?',
 '{"A":"penghinaan","B":"pidato","C":"kelakar","D":"kesan","E":"ayat"}', 'C'),
('AN', 53, 'Marah : emosi = Duka cita : ?',
 '{"A":"suka cita","B":"sakit hati","C":"suasana hati","D":"sedih","E":"rindu"}', 'C'),
('AN', 54, 'Mantel : jubah = wool : ?',
 '{"A":"bahan sandang","B":"domba","C":"sutra","D":"jas","E":"tekstil"}', 'C'),
('AN', 55, 'Ketinggian puncak : tekanan udara = ketinggian nada : ?',
 '{"A":"garpu tala","B":"sopran","C":"nyanyian","D":"panjang senar","E":"suara"}', 'D'),
('AN', 56, 'Negara : revolusi = Hidup : ?',
 '{"A":"biologi","B":"keturunan","C":"mutasi","D":"seleksi","E":"ilmu hewan"}', 'C'),
('AN', 57, 'Kekurangan : penemuan = Panas : ?',
 '{"A":"haus","B":"khatulistiwa","C":"es","D":"matahari","E":"dingin"}', 'C'),
('AN', 58, 'Kayu : diketam = Besi : ?',
 '{"A":"dipalu","B":"digergaji","C":"dituang","D":"dikikir","E":"ditempa"}', 'D'),
('AN', 59, 'Olahragawan : lembing = Cendikiawan : ?',
 '{"A":"perpustakaan","B":"penelitian","C":"karya","D":"studi","E":"mikroskop"}', 'E'),
('AN', 60, 'Keledai : kuda pacuan = pembakaran : ?',
 '{"A":"pemadam api","B":"obor","C":"letupan","D":"korek api","E":"lautan api"}', 'E');

-- ============================================================
-- GE (61-76) — "carilah satu kata yang meliputi pengertian kedua kata" (free text).
-- correct_answer here is a best-guess single accepted word — NOT sourced from an
-- official key (none exists; ist-result.docx has no GE column). See header note.
-- ============================================================
DELETE FROM ist_questions WHERE subtest_code = 'GE';
INSERT INTO ist_questions (subtest_code, item_no, question_text, correct_answer) VALUES
('GE', 61, 'mawar - melati', 'bunga'),
('GE', 62, 'mata - telinga', 'panca indera'),
('GE', 63, 'gula - intan', 'kristal'),
('GE', 64, 'hujan - salju', 'presipitasi'),
('GE', 65, 'pengantar surat - telepon', 'komunikasi'),
('GE', 66, 'kamera - kacamata', 'lensa'),
('GE', 67, 'lambung - usus', 'organ pencernaan'),
('GE', 68, 'banyak - sedikit', 'jumlah'),
('GE', 69, 'telur - benih', 'awal kehidupan'),
('GE', 70, 'bendera - lencana', 'lambang'),
('GE', 71, 'rumput - gajah', 'makhluk hidup'),
('GE', 72, 'ember - kantong', 'wadah'),
('GE', 73, 'awal - akhir', 'waktu'),
('GE', 74, 'kikir - boros', 'sifat'),
('GE', 75, 'penawaran - permintaan', 'ekonomi'),
('GE', 76, 'atas - bawah', 'arah');

-- ============================================================
-- RA (77-96) — arithmetic word problems, real text + real numeric answers.
-- Every answer below was independently re-derived from the word problem and matches
-- the docx key exactly (documented in the migration header).
-- ============================================================
DELETE FROM ist_questions WHERE subtest_code = 'RA';
INSERT INTO ist_questions (subtest_code, item_no, question_text, correct_answer) VALUES
('RA', 77, 'Jika seorang anak memiliki 50 rupiah dan memberikan 15 rupiah kepada orang lain, berapa rupiahkah yang masih tinggal padanya?', '35'),
('RA', 78, 'Berapa km-kah yang dapat ditempuh oleh kereta api dalam waktu 7 jam, jika kecepatannya 40 km/jam?', '280'),
('RA', 79, '15 peti buah-buahan beratnya 250 kg dan setiap peti kosong beratnya 3 kg, berapakah berat buah-buahan itu?', '205'),
('RA', 80, 'Seseorang mempunyai persediaan rumput yang cukup untuk 7 ekor kuda selama 78 hari. Berapa harikah persediaan itu cukup untuk 21 ekor kuda?', '26'),
('RA', 81, '3 batang coklat harganya Rp. 5,- Berapa batangkah yang dapat kita beli dengan Rp. 50,-?', '30'),
('RA', 82, 'Seseorang dapat berjalan 1,75 m dalam waktu ¼ detik. Berapa meterkah yang dapat ia tempuh dalam waktu 10 detik?', '70'),
('RA', 83, 'Jika sebuah batu terletak 15 m disebelah selatan dari sebatang pohon dan pohon itu berada 30 m disebelah selatan dari sebuah rumah, berapa meterkah jarak antara batu dan rumah itu?', '45'),
('RA', 84, 'Jika 4½ m bahan sandang harganya Rp. 90,- berapa rupiahkah harganya 2½ m?', '50'),
('RA', 85, '7 orang dapat menyelesaikan sesuatu pekerjaan dalam 6 hari. Berapa orangkah yang diperlukan untuk menyelesaikan pekerjaan itu dalam setengah hari?', '84'),
('RA', 86, 'Karena dipanaskan, kawat yang panjangnya 48 cm akan mengembang menjadi 52 cm. Setelah pemanasan, berapakah panjangnya kawat yang berukuran 72 cm?', '78'),
('RA', 87, 'Suatu pabrik dapat menghasilkan 304 batang pinsil dalam waktu 8 jam. Berapa batangkah dihasilkan dalam waktu setengah jam?', '19'),
('RA', 88, 'Untuk suatu campuran diperlukan 2 bagian perak dan 3 bagian timah. Berapa gramkah perak yang diperlukan untuk mendapatkan campuran itu yang beratnya 15 gram?', '6'),
('RA', 89, 'Untuk setiap Rp. 3,- yang dimiliki Sidin, Hamid memiliki Rp. 5,- Jika mereka bersama mempunyai Rp. 120,- berapa rupiahkah yang dimiliki Hamid?', '75'),
('RA', 90, 'Mesin A menenun 60 m kain, sedangkan mesin B menenun 40 m dalam waktu yang sama. Berapa meterkah yang ditenun mesin A, jika mesin B menenun 60 m?', '90'),
('RA', 91, 'Seseorang membelikan 1/10 dari uangnya untuk perangko dan 4 kali jumlah itu untuk alat tulis. Sisa uangnya masih Rp. 60,- Berapa rupiahkah uangnya semula?', '120'),
('RA', 92, 'Didalam dua peti terdapat 43 buah piring. Di dalam satu peti terdapat 9 buah piring lebih banyak dari pada peti yang lain. Berapa piring terdapat didalam peti yang paling kecil?', '17'),
('RA', 93, 'Suatu lembaran kain yang panjangnya 60 cm harus dibagi sedemikian rupa sehingga panjangnya satu bagian ialah 2/3 dari bagian yang lain. Berapa panjangnya bagian yang terpendek?', '24'),
('RA', 94, 'Suatu perusahaan mengekspor ¾ dari hasil produksinya dan menjual 4/5 dari sisa itu di dalam Negeri. Berapa % kah hasil produksi yang masih tinggal?', '5'),
('RA', 95, 'Jika suatu botol berisi anggur hanya 7/8 bagian dan harganya ialah Rp. 84,- berapakah harga anggur itu jika botol itu hanya terisi ½ penuh?', '48'),
('RA', 96, 'Di dalam suatu keluarga setiap anak perempuan mempunyai jumlah saudara laki-laki dan perempuan yang sama, dan setiap anak laki-laki mempunyai dua kali lebih banyak saudara perempuan dari pada saudara laki-laki. Berapa anak laki-lakikah yang terdapat didalam keluarga itu?', '3');

-- ============================================================
-- ZR (97-116) — number sequences, own table. sequence_text is the 7 shown numbers;
-- correct_answer is the "?" — 12 of 20 independently re-derived and all matched the
-- docx key exactly (documented in the migration header); the rest transcribed from the
-- same clearly-legible grid.
-- ============================================================
DELETE FROM ist_zr_questions;
INSERT INTO ist_zr_questions (item_no, sequence_text, correct_answer) VALUES
(97, '6, 9, 12, 15, 18, 21, 24, ?', 27),
(98, '15, 16, 18, 19, 21, 22, 24, ?', 25),
(99, '19, 18, 22, 21, 25, 24, 28, ?', 27),
(100, '16, 12, 17, 13, 18, 14, 19, ?', 15),
(101, '2, 4, 8, 10, 20, 22, 44, ?', 46),
(102, '15, 13, 16, 12, 17, 11, 18, ?', 10),
(103, '25, 22, 11, 33, 30, 15, 45, ?', 42),
(104, '49, 51, 54, 27, 9, 11, 14, ?', 7),
(105, '2, 3, 1, 3, 4, 2, 4, ?', 5),
(106, '19, 17, 20, 16, 21, 15, 22, ?', 14),
(107, '94, 92, 46, 44, 22, 20, 10, ?', 8),
(108, '5, 8, 9, 8, 11, 12, 11, ?', 14),
(109, '12, 15, 19, 23, 28, 33, 39, ?', 45),
(110, '7, 5, 10, 7, 21, 17, 68, ?', 63),
(111, '11, 15, 18, 9, 13, 16, 8, ?', 12),
(112, '3, 8, 15, 24, 35, 48, 63, ?', 80),
(113, '4, 5, 7, 4, 8, 13, 7, ?', 14),
(114, '8, 5, 15, 18, 6, 3, 9, ?', 12),
(115, '15, 6, 18, 10, 30, 23, 69, ?', 63),
(116, '5, 35, 28, 4, 11, 77, 70, ?', 10);

-- ============================================================
-- ME (157-176) — real 5-category memorization word list (see frontend for the
-- untimed-then-3-minute study phase), real per-item answer category, RECONSTRUCTED
-- letter-to-item mapping (see header note #2 — the answer letters are real, the exact
-- word each item asks about is inferred to fit the real per-item answer).
-- ============================================================
DELETE FROM ist_questions WHERE subtest_code = 'ME';
INSERT INTO ist_questions (subtest_code, item_no, question_text, options, correct_answer) VALUES
('ME', 157, 'Kata yang mempunyai huruf permulaan "Q" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'D'),
('ME', 158, 'Kata yang mempunyai huruf permulaan "M" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'E'),
('ME', 159, 'Kata yang mempunyai huruf permulaan "W" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'B'),
('ME', 160, 'Kata yang mempunyai huruf permulaan "S" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'A'),
('ME', 161, 'Kata yang mempunyai huruf permulaan "I" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'C'),
('ME', 162, 'Kata yang mempunyai huruf permulaan "L" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'A'),
('ME', 163, 'Kata yang mempunyai huruf permulaan "A" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'D'),
('ME', 164, 'Kata yang mempunyai huruf permulaan "R" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'E'),
('ME', 165, 'Kata yang mempunyai huruf permulaan "E" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'C'),
('ME', 166, 'Kata yang mempunyai huruf permulaan "J" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'B'),
('ME', 167, 'Kata yang mempunyai huruf permulaan "K" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'B'),
('ME', 168, 'Kata yang mempunyai huruf permulaan "F" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'A'),
('ME', 169, 'Kata yang mempunyai huruf permulaan "B" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'E'),
('ME', 170, 'Kata yang mempunyai huruf permulaan "T" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'C'),
('ME', 171, 'Kata yang mempunyai huruf permulaan "O" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'D'),
('ME', 172, 'Kata yang mempunyai huruf permulaan "C" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'B'),
('ME', 173, 'Kata yang mempunyai huruf permulaan "Z" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'E'),
('ME', 174, 'Kata yang mempunyai huruf permulaan "Y" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'A'),
('ME', 175, 'Kata yang mempunyai huruf permulaan "N" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'C'),
('ME', 176, 'Kata yang mempunyai huruf permulaan "G" adalah suatu ......',
 '{"A":"bunga","B":"perkakas","C":"burung","D":"kesenian","E":"binatang"}', 'D');
