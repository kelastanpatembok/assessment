package com.assessment.service;

import java.util.List;

/**
 * Item bank for the free Big Five (OCEAN) quick quiz.
 *
 * This is a self-report exploration quiz for the public free-user funnel,
 * not a clinical instrument. Each item maps to one of the five traits and
 * roughly half are reverse-scored to reduce response bias.
 */
public final class BigFiveItemBank {

    public record BigFiveItem(int no, String trait, boolean reversed, String statement) {}

    private BigFiveItemBank() {}

    public static final List<BigFiveItem> ITEMS = List.of(
        new BigFiveItem(1,  "O", false, "Saya menikmati mengeksplorasi ide-ide baru."),
        new BigFiveItem(2,  "O", true,  "Saya lebih nyaman dengan rutinitas yang sudah pasti."),
        new BigFiveItem(3,  "O", false, "Saya tertarik pada seni, musik, dan keindahan."),
        new BigFiveItem(4,  "O", false, "Saya sering berpikir secara imajinatif dan kreatif."),
        new BigFiveItem(5,  "O", false, "Saya penasaran dengan hal-hal yang belum saya kenal."),
        new BigFiveItem(6,  "O", true,  "Saya lebih suka hal-hal yang sederhana dan sudah dikenal."),
        new BigFiveItem(7,  "C", false, "Saya selalu menyelesaikan tugas tepat waktu."),
        new BigFiveItem(8,  "C", false, "Saya cenderung rapi dan terorganisir."),
        new BigFiveItem(9,  "C", true,  "Saya sering menunda pekerjaan sampai menit terakhir."),
        new BigFiveItem(10, "C", false, "Saya merencanakan sesuatu sebelum memulainya."),
        new BigFiveItem(11, "C", true,  "Saya mudah kehilangan fokus pada satu hal."),
        new BigFiveItem(12, "C", false, "Saya bertanggung jawab atas setiap hal yang saya kerjakan."),
        new BigFiveItem(13, "E", false, "Saya merasa berenergi saat berada di banyak orang."),
        new BigFiveItem(14, "E", true,  "Saya lebih suka diam dan menyendiri dalam kumpulan orang."),
        new BigFiveItem(15, "E", false, "Saya mudah memulai percakapan dengan orang baru."),
        new BigFiveItem(16, "E", true,  "Saya lebih nyaman bekerja sendiri daripada berkelompok."),
        new BigFiveItem(17, "E", false, "Saya menikmati menjadi pusat perhatian."),
        new BigFiveItem(18, "E", true,  "Saya merasa lelah setelah bersosialisasi terlalu lama."),
        new BigFiveItem(19, "A", false, "Saya mudah memahami perasaan orang lain."),
        new BigFiveItem(20, "A", false, "Saya lebih memilih bekerja sama daripada berkompetisi."),
        new BigFiveItem(21, "A", true,  "Saya cenderung kritis terhadap pendapat orang lain."),
        new BigFiveItem(22, "A", false, "Saya berusaha membantu orang lain yang membutuhkan."),
        new BigFiveItem(23, "A", false, "Saya umumnya mempercayai niat baik orang lain."),
        new BigFiveItem(24, "A", true,  "Dalam persaingan, saya lebih mementingkan diri sendiri."),
        new BigFiveItem(25, "N", false, "Saya mudah merasa cemas terhadap hal-hal kecil."),
        new BigFiveItem(26, "N", true,  "Saya tetap tenang saat menghadapi tekanan."),
        new BigFiveItem(27, "N", false, "Perasaan saya mudah berubah-ubah."),
        new BigFiveItem(28, "N", false, "Saya sering mengkhawatirkan masa depan."),
        new BigFiveItem(29, "N", true,  "Saya jarang merasa sedih atau putus asa."),
        new BigFiveItem(30, "N", false, "Saya mudah tersinggung oleh kritik.")
    );
}
