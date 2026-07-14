package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.CfitDescription;
import com.assessment.model.CfitQuestion;
import com.assessment.model.CfitResult;
import com.assessment.repository.CfitDescriptionRepository;
import com.assessment.repository.CfitQuestionRepository;
import com.assessment.repository.CfitResultRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class CfitScoringService {

    private final CfitQuestionRepository cfitQuestionRepository;
    private final CfitDescriptionRepository cfitDescriptionRepository;
    private final CfitResultRepository cfitResultRepository;
    private final ObjectMapper objectMapper;

    // answers: the letter(s) the student picked for this item. Subtest 2 (Classification)
    // requires exactly 2 letters; every other subtest requires exactly 1.
    public record CfitAnswerDto(int subtestNo, int itemNo, List<String> answers) {}

    @Transactional
    @SneakyThrows
    public CfitResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                   Long assignmentId, List<CfitAnswerDto> answers) {

        // Step 1 — Score per subtest
        Map<Integer, Integer> subtestScores = new HashMap<>(Map.of(1, 0, 2, 0, 3, 0, 4, 0));

        for (CfitAnswerDto answer : answers) {
            List<CfitQuestion> subtestQuestions = cfitQuestionRepository
                    .findBySubtestNoAndActiveTrueOrderByItemNoAsc(answer.subtestNo());
            CfitQuestion question = subtestQuestions.stream()
                    .filter(q -> q.getItemNo() == answer.itemNo())
                    .findFirst()
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "CFIT question not found: subtest=" + answer.subtestNo()
                                    + " item=" + answer.itemNo()));
            if (isCorrect(question, answer.answers())) {
                subtestScores.merge(answer.subtestNo(), 1, Integer::sum);
            }
        }

        int sub1 = subtestScores.getOrDefault(1, 0);
        int sub2 = subtestScores.getOrDefault(2, 0);
        int sub3 = subtestScores.getOrDefault(3, 0);
        int sub4 = subtestScores.getOrDefault(4, 0);

        // Step 2 — Total score
        int total = sub1 + sub2 + sub3 + sub4;

        // Step 3 — IQ score from description table
        CfitDescription desc = cfitDescriptionRepository
                .findByScoreMinLessThanEqualAndScoreMaxGreaterThanEqual(total, total)
                .orElse(null);
        int iqScore = desc != null && desc.getIqMin() != null ? desc.getIqMin() : 0;
        String category = desc != null ? desc.getCategory() : null;
        String description = desc != null ? desc.getDescription() : null;

        // Step 4 — Save and return result
        String answersJson = objectMapper.writeValueAsString(answers);

        CfitResult result = CfitResult.builder()
                .authUserId(authUserId)
                .studentName(studentName)
                .schoolName(schoolName)
                .assignmentId(assignmentId)
                .sub1Score(sub1)
                .sub2Score(sub2)
                .sub3Score(sub3)
                .sub4Score(sub4)
                .totalScore(total)
                .iqScore(iqScore)
                .category(category)
                .description(description)
                .answers(answersJson)
                .completedAt(LocalDateTime.now())
                .build();

        return cfitResultRepository.save(result);
    }

    // Subtest 2 (Classification) needs both correctAnswer and correctAnswer2 selected
    // (order-independent, no extras); every other subtest needs exactly correctAnswer.
    private boolean isCorrect(CfitQuestion question, List<String> submitted) {
        if (submitted == null) return false;
        Set<String> given = new HashSet<>();
        for (String s : submitted) {
            if (s != null) given.add(s.toLowerCase());
        }
        if (question.getCorrectAnswer2() != null) {
            Set<String> expected = Set.of(
                    question.getCorrectAnswer().toLowerCase(),
                    question.getCorrectAnswer2().toLowerCase());
            return given.equals(expected);
        }
        return given.size() == 1 && given.contains(question.getCorrectAnswer().toLowerCase());
    }
}
