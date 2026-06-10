package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.IstIqBand;
import com.assessment.model.IstMePair;
import com.assessment.model.IstNorma;
import com.assessment.model.IstQuestion;
import com.assessment.model.IstResult;
import com.assessment.model.IstWuQuestion;
import com.assessment.model.IstZrQuestion;
import com.assessment.repository.IstIqBandRepository;
import com.assessment.repository.IstMePairRepository;
import com.assessment.repository.IstNormaRepository;
import com.assessment.repository.IstQuestionRepository;
import com.assessment.repository.IstResultRepository;
import com.assessment.repository.IstWuQuestionRepository;
import com.assessment.repository.IstZrQuestionRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class IstScoringService {

    private final IstQuestionRepository istQuestionRepository;
    private final IstZrQuestionRepository istZrQuestionRepository;
    private final IstWuQuestionRepository istWuQuestionRepository;
    private final IstMePairRepository istMePairRepository;
    private final IstNormaRepository istNormaRepository;
    private final IstIqBandRepository istIqBandRepository;
    private final IstResultRepository istResultRepository;
    private final ObjectMapper objectMapper;

    public record IstItemAnswer(int itemNo, String answer) {}
    public record IstSubtestAnswers(String subtestCode, List<IstItemAnswer> items) {}

    @Transactional
    @SneakyThrows
    public IstResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                  Long assignmentId, List<IstSubtestAnswers> subtests) {

        // Step 1 — Score each subtest
        Map<String, Integer> rawScores = new LinkedHashMap<>();
        Map<String, Integer> wertScores = new LinkedHashMap<>();

        for (IstSubtestAnswers subtest : subtests) {
            String code = subtest.subtestCode().toUpperCase();
            int raw = scoreSubtest(code, subtest.items());
            rawScores.put(code, raw);
        }

        // Step 2 — Look up Wert for each subtest
        for (Map.Entry<String, Integer> entry : rawScores.entrySet()) {
            String code = entry.getKey();
            int raw = entry.getValue();
            int wert = istNormaRepository.findBySubtestCodeAndRawScore(code, raw)
                    .map(IstNorma::getWert)
                    .orElse(Math.min(raw, 10));
            wertScores.put(code, wert);
        }

        // Step 3 — Total Wert
        int totalWert = wertScores.values().stream().mapToInt(Integer::intValue).sum();

        // Step 4 — IQ band lookup
        IstIqBand band = istIqBandRepository.findByWert(totalWert).orElse(null);
        int iqScore = band != null ? band.getIqMin() : 0;
        String iqCategory = band != null ? band.getCategory() : null;

        // Step 5 — Build subtestScores JSON: {"SE":{"raw":X,"wert":Y},...}
        Map<String, Map<String, Integer>> subtestScoresMap = new LinkedHashMap<>();
        for (String code : rawScores.keySet()) {
            subtestScoresMap.put(code, Map.of(
                    "raw", rawScores.get(code),
                    "wert", wertScores.getOrDefault(code, 0)));
        }
        String subtestScoresJson = objectMapper.writeValueAsString(subtestScoresMap);
        String answersJson = objectMapper.writeValueAsString(subtests);

        // Step 6 — Save and return
        IstResult result = IstResult.builder()
                .authUserId(authUserId)
                .studentName(studentName)
                .schoolName(schoolName)
                .assignmentId(assignmentId)
                .subtestScores(subtestScoresJson)
                .totalWert(totalWert)
                .iqScore(iqScore)
                .iqCategory(iqCategory)
                .answers(answersJson)
                .completedAt(LocalDateTime.now())
                .build();

        return istResultRepository.save(result);
    }

    private int scoreSubtest(String code, List<IstItemAnswer> items) {
        return switch (code) {
            case "SE", "WA", "AN", "GE", "RA", "FA" -> scoreStandard(code, items);
            case "ZR" -> scoreZr(items);
            case "WU" -> scoreWu(items);
            case "ME" -> scoreMe(items);
            default -> 0;
        };
    }

    private int scoreStandard(String code, List<IstItemAnswer> items) {
        List<IstQuestion> questions = istQuestionRepository
                .findBySubtestCodeAndActiveTrueOrderByItemNoAsc(code);
        Map<Integer, IstQuestion> byItem = new HashMap<>();
        for (IstQuestion q : questions) byItem.put(q.getItemNo(), q);

        int score = 0;
        for (IstItemAnswer item : items) {
            IstQuestion q = byItem.get(item.itemNo());
            if (q != null && q.getCorrectAnswer() != null
                    && item.answer().trim().equalsIgnoreCase(q.getCorrectAnswer().trim())) {
                score++;
            }
        }
        return score;
    }

    private int scoreZr(List<IstItemAnswer> items) {
        List<IstZrQuestion> questions = istZrQuestionRepository.findAllByOrderByItemNoAsc();
        Map<Integer, IstZrQuestion> byItem = new HashMap<>();
        for (IstZrQuestion q : questions) byItem.put(q.getItemNo(), q);

        int score = 0;
        for (IstItemAnswer item : items) {
            IstZrQuestion q = byItem.get(item.itemNo());
            if (q == null) continue;
            try {
                int given = Integer.parseInt(item.answer().trim());
                if (given == q.getCorrectAnswer()) score++;
            } catch (NumberFormatException ignored) {}
        }
        return score;
    }

    private int scoreWu(List<IstItemAnswer> items) {
        List<IstWuQuestion> questions = istWuQuestionRepository.findAllByOrderByItemNoAsc();
        Map<Integer, IstWuQuestion> byItem = new HashMap<>();
        for (IstWuQuestion q : questions) byItem.put(q.getItemNo(), q);

        int score = 0;
        for (IstItemAnswer item : items) {
            IstWuQuestion q = byItem.get(item.itemNo());
            if (q != null && item.answer().trim().toUpperCase()
                    .equals(q.getCorrectAnswer().toUpperCase())) {
                score++;
            }
        }
        return score;
    }

    private int scoreMe(List<IstItemAnswer> items) {
        List<IstMePair> pairs = istMePairRepository.findAllByOrderByItemNoAsc();
        Map<Integer, IstMePair> byItem = new HashMap<>();
        for (IstMePair p : pairs) byItem.put(p.getItemNo(), p);

        int score = 0;
        for (IstItemAnswer item : items) {
            IstMePair p = byItem.get(item.itemNo());
            if (p != null && item.answer().trim()
                    .equalsIgnoreCase(p.getCorrectAnswer().trim())) {
                score++;
            }
        }
        return score;
    }
}
