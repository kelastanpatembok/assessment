package com.assessment.service;

import com.assessment.dto.BigFiveResultDto;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Builds the shareable result presentation for the free Big Five quiz.
 *
 * Kept deliberately non-clinical: results are framed as self-exploration.
 * "Stabilitas Emosi" is displayed as the inverse of raw neuroticism so a
 * higher bar always reads as the healthier direction.
 */
@Service
public class BigFiveInterpretationService {

    private static final List<DisplayTrait> DISPLAY_TRAITS = List.of(
        new DisplayTrait("openness", "Keterbukaan", "O", null),
        new DisplayTrait("conscientiousness", "Ketelitian", "C", null),
        new DisplayTrait("extraversion", "Ekstroversi", "E", null),
        new DisplayTrait("agreeableness", "Keramahan", "A", null),
        new DisplayTrait("neuroticism", "Stabilitas Emosi", "N", true)
    );

    private record DisplayTrait(String key, String label, String code, Boolean invert) {}

    public BigFiveResultDto interpret(Map<String, Double> raw) {
        Map<String, Double> display = new LinkedHashMap<>();
        for (DisplayTrait t : DISPLAY_TRAITS) {
            double value = raw.get(t.code());
            display.put(t.key(), t.invert() != null && t.invert() ? Math.max(0, 100 - value) : value);
        }

        String headline = archetype(display);
        List<BigFiveResultDto.Trait> traits = DISPLAY_TRAITS.stream()
            .map(t -> toTrait(t, display))
            .toList();

        return new BigFiveResultDto(
            headline,
            raw.get("O"),
            raw.get("C"),
            raw.get("E"),
            raw.get("A"),
            raw.get("N"),
            traits
        );
    }

    public BigFiveResultDto.Trait toTrait(DisplayTrait t, Map<String, Double> display) {
        double value = display.get(t.key());
        String level = level(value);
        String description = description(t.label(), level);
        return new BigFiveResultDto.Trait(t.key(), t.label(), value, level, description);
    }

    private String level(double value) {
        if (value < 40) return "Rendah";
        if (value > 60) return "Tinggi";
        return "Sedang";
    }

    private String description(String label, String level) {
        return switch (label) {
            case "Keterbukaan" -> switch (level) {
                case "Rendah" -> "Anda merasa nyaman dengan hal-hal yang pasti dan teruji.";
                case "Tinggi" -> "Anda senang menjelajahi ide, pengalaman, dan kemungkinan baru.";
                default -> "Anda terbuka pada hal baru, namun tetap menikmati kenyamanan rutinitas.";
            };
            case "Ketelitian" -> switch (level) {
                case "Rendah" -> "Anda lebih spontan dan fleksibel dalam mengatur waktu.";
                case "Tinggi" -> "Anda terencana, teratur, dan dapat diandalkan.";
                default -> "Anda cukup teratur, meski kadang menyesuaikan rencana.";
            };
            case "Ekstroversi" -> switch (level) {
                case "Rendah" -> "Anda lebih tenang dan mengisi energi dari dalam diri.";
                case "Tinggi" -> "Anda bergairah dalam pergaulan dan mudah terhubung dengan orang lain.";
                default -> "Anda seimbang antara waktu bersama orang lain dan waktu sendiri.";
            };
            case "Keramahan" -> switch (level) {
                case "Rendah" -> "Anda cenderung terus terang dan mengutamakan ketegasan.";
                case "Tinggi" -> "Anda empatik, kooperatif, dan peduli pada orang lain.";
                default -> "Anda ramah, namun tetap menjaga batasan.";
            };
            default -> switch (level) {
                case "Rendah" -> "Anda cukup peka terhadap tekanan dan perubahan suasana hati.";
                case "Tinggi" -> "Anda tenang, tabah, dan tidak mudah goyah oleh tekanan.";
                default -> "Anda umumnya tenang, dengan sesekali merasa cemas.";
            };
        };
    }

    private String archetype(Map<String, Double> display) {
        Map.Entry<String, Double> top = display.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .orElseThrow();
        return switch (top.getKey()) {
            case "openness" -> "Sang Penjelajah Ide";
            case "conscientiousness" -> "Sang Perencana";
            case "extraversion" -> "Sang Penghubung";
            case "agreeableness" -> "Sang Pendukung";
            default -> "Sang Penyeimbang";
        };
    }
}
