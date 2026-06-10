package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.PapiQuestion;
import com.assessment.model.PapiResult;
import com.assessment.repository.PapiDescriptionRepository;
import com.assessment.repository.PapiQuestionRepository;
import com.assessment.repository.PapiResultRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PapiScoringService {

    private final PapiQuestionRepository papiQuestionRepository;
    private final PapiDescriptionRepository papiDescriptionRepository;
    private final PapiResultRepository papiResultRepository;
    private final ObjectMapper objectMapper;

    public record PapiAnswerDto(int pairNo, String chosenLetter) {}

    @Transactional
    @SneakyThrows
    public PapiResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                   Long assignmentId, List<PapiAnswerDto> answers) {

        // Step 1 — Tally trait scores
        Map<String, Integer> traitScores = new HashMap<>();

        for (PapiAnswerDto answer : answers) {
            List<PapiQuestion> pairQuestions = papiQuestionRepository
                    .findByPairNoOrderByItemLetterAsc(answer.pairNo());
            PapiQuestion chosen = pairQuestions.stream()
                    .filter(q -> q.getItemLetter().equalsIgnoreCase(answer.chosenLetter()))
                    .findFirst()
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "PAPI question not found: pair=" + answer.pairNo()
                                    + " letter=" + answer.chosenLetter()));
            traitScores.merge(chosen.getTraitCode(), 1, Integer::sum);
        }

        // Step 2 — Serialize trait scores to JSON
        String traitScoresJson = objectMapper.writeValueAsString(traitScores);
        String answersJson = objectMapper.writeValueAsString(answers);

        // Step 3 — Save and return result
        PapiResult result = PapiResult.builder()
                .authUserId(authUserId)
                .studentName(studentName)
                .schoolName(schoolName)
                .assignmentId(assignmentId)
                .traitScores(traitScoresJson)
                .answers(answersJson)
                .completedAt(LocalDateTime.now())
                .build();

        return papiResultRepository.save(result);
    }
}
