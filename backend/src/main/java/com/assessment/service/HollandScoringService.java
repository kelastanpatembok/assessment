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
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class HollandScoringService {

    private final HollandQuestionRepository hollandQuestionRepository;
    private final HollandDescriptionRepository hollandDescriptionRepository;
    private final HollandResultRepository hollandResultRepository;
    private final ObjectMapper objectMapper;

    public record HollandAnswerDto(long questionId, int score) {}

    @Transactional
    @SneakyThrows
    public HollandResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                      Long assignmentId, List<HollandAnswerDto> answers) {

        // Step 1 — Accumulate RIASEC totals
        Map<String, Integer> totals = new HashMap<>(Map.of(
                "R", 0, "I", 0, "A", 0, "S", 0, "E", 0, "C", 0));

        for (HollandAnswerDto answer : answers) {
            HollandQuestion question = hollandQuestionRepository.findById(answer.questionId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Holland question not found: " + answer.questionId()));
            String type = question.getRiasecType().toUpperCase();
            totals.merge(type, answer.score(), Integer::sum);
        }

        // Step 2 — Sort types by score descending, take top 3
        List<Map.Entry<String, Integer>> sorted = totals.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue(Comparator.reverseOrder())
                        .thenComparing(Map.Entry.comparingByKey()))
                .toList();

        String type1 = sorted.get(0).getKey();
        String type2 = sorted.get(1).getKey();
        String type3 = sorted.get(2).getKey();
        String hollandCode = type1 + type2 + type3;

        // Step 3 — Look up description for type1
        HollandDescription desc = hollandDescriptionRepository.findByRiasecType(type1).orElse(null);
        String type1Name = desc != null ? desc.getName() : "?";
        String type1Desc = desc != null ? desc.getDescription() : null;

        // Step 4 — Save and return result
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
                .type2(type2)
                .type3(type3)
                .hollandCode(hollandCode)
                .type1Name(type1Name)
                .type1Desc(type1Desc)
                .answers(answersJson)
                .completedAt(LocalDateTime.now())
                .build();

        return hollandResultRepository.save(result);
    }
}
