package com.assessment.service;

import com.assessment.exception.BadRequestException;
import com.assessment.service.BigFiveItemBank.BigFiveItem;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class BigFiveScoringService {

    private static final int ITEMS_PER_TRAIT = 6;
    private static final int MAX_SCORE = ITEMS_PER_TRAIT * 5;

    /**
     * Scores the quick Big Five quiz.
     *
     * @param answers map of item number -> Likert value (1..5)
     * @return raw percentage (0-100) per trait: O, C, E, A, N
     */
    public Map<String, Double> score(Map<String, Integer> answers) {
        if (answers == null || answers.size() != BigFiveItemBank.ITEMS.size()) {
            throw new BadRequestException("Harap jawab seluruh pertanyaan sebelum melihat hasil.");
        }

        Map<String, Integer> sums = new HashMap<>(Map.of("O", 0, "C", 0, "E", 0, "A", 0, "N", 0));

        for (BigFiveItem item : BigFiveItemBank.ITEMS) {
            Integer raw = answers.get(String.valueOf(item.no()));
            if (raw == null || raw < 1 || raw > 5) {
                throw new BadRequestException("Jawaban tidak valid pada pertanyaan nomor " + item.no() + ".");
            }
            int scored = item.reversed() ? 6 - raw : raw;
            sums.merge(item.trait(), scored, Integer::sum);
        }

        Map<String, Double> percents = new HashMap<>();
        for (Map.Entry<String, Integer> e : sums.entrySet()) {
            double pct = Math.round((e.getValue() * 1000.0) / MAX_SCORE) / 10.0;
            percents.put(e.getKey(), pct);
        }
        return percents;
    }
}
