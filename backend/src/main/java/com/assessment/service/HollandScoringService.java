package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.HollandDescription;
import com.assessment.model.HollandQuestion;
import com.assessment.model.HollandResult;
import com.assessment.repository.HollandDescriptionRepository;
import com.assessment.repository.HollandQuestionRepository;
import com.assessment.repository.HollandResultRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class HollandScoringService {

    // Canonical RIASEC order — also the tie-break order when two types
    // score equally, matching the column order (G:L) in Holland-result.xlsm.
    private static final List<String> RIASEC_ORDER = List.of("R", "I", "A", "S", "E", "C");

    private final HollandQuestionRepository hollandQuestionRepository;
    private final HollandDescriptionRepository hollandDescriptionRepository;
    private final HollandResultRepository hollandResultRepository;
    private final ObjectMapper objectMapper;

    public record HollandAnswerDto(long questionId, int score) {}

    @Transactional
    @SneakyThrows
    public HollandResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                      Long assignmentId, List<HollandAnswerDto> answers) {

        // Step 1 — Accumulate RIASEC totals: total_R = sum of all r1_*, r2_*, r3_*
        // answers (33 items, 1-5 each) across all 3 rounds, and likewise for I/A/S/E/C.
        Map<String, Integer> totals = new LinkedHashMap<>();
        RIASEC_ORDER.forEach(t -> totals.put(t, 0));

        for (HollandAnswerDto answer : answers) {
            HollandQuestion question = hollandQuestionRepository.findById(answer.questionId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Holland question not found: " + answer.questionId()));
            String type = question.getRiasecType().toUpperCase();
            totals.merge(type, answer.score(), Integer::sum);
        }

        // Step 2 — Sort types by total descending; ties broken by RIASEC order. Top 2 form the code.
        List<String> sorted = RIASEC_ORDER.stream()
                .sorted((a, b) -> {
                    int cmp = totals.get(b) - totals.get(a);
                    return cmp != 0 ? cmp : RIASEC_ORDER.indexOf(a) - RIASEC_ORDER.indexOf(b);
                })
                .toList();

        String type1 = sorted.get(0);
        String type2 = sorted.get(1);
        String hollandCode = type1 + type2;

        HollandDescription desc1 = hollandDescriptionRepository.findByRiasecType(type1).orElse(null);
        HollandDescription desc2 = hollandDescriptionRepository.findByRiasecType(type2).orElse(null);

        // Step 3 — Save raw totals + top-2 interpretation, denormalized at submit time
        // (same convention as DiscScoringService — see DiscPatternClassifier usage in DiscController).
        String answersJson = objectMapper.writeValueAsString(answers);

        HollandResult result = HollandResult.builder()
                .authUserId(authUserId)
                .studentName(studentName)
                .schoolName(schoolName)
                .assignmentId(assignmentId)
                .rScore(totals.get("R"))
                .iScore(totals.get("I"))
                .aScore(totals.get("A"))
                .sScore(totals.get("S"))
                .eScore(totals.get("E"))
                .cScore(totals.get("C"))
                .type1(type1)
                .type1Name(desc1 != null ? desc1.getName() : null)
                .type1Description(desc1 != null ? desc1.getDescription() : null)
                .type1Characteristics(desc1 != null ? desc1.getCharacteristics() : null)
                .type1Strengths(desc1 != null ? desc1.getStrengths() : null)
                .type1Weaknesses(desc1 != null ? desc1.getWeaknesses() : null)
                .type1JobMatch(desc1 != null ? desc1.getJobMatch() : null)
                .type2(type2)
                .type2Name(desc2 != null ? desc2.getName() : null)
                .type2Description(desc2 != null ? desc2.getDescription() : null)
                .type2Characteristics(desc2 != null ? desc2.getCharacteristics() : null)
                .type2Strengths(desc2 != null ? desc2.getStrengths() : null)
                .type2Weaknesses(desc2 != null ? desc2.getWeaknesses() : null)
                .type2JobMatch(desc2 != null ? desc2.getJobMatch() : null)
                .hollandCode(hollandCode)
                .answers(answersJson)
                .completedAt(LocalDateTime.now())
                .build();

        return hollandResultRepository.save(result);
    }
}
