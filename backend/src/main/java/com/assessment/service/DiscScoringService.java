package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.DiscPersonalityProfile;
import com.assessment.model.DiscQuestion;
import com.assessment.model.DiscResult;
import com.assessment.repository.DiscPersonalityProfileRepository;
import com.assessment.repository.DiscQuestionRepository;
import com.assessment.repository.DiscResultRepository;
import com.assessment.repository.DiscScoringDifRepository;
import com.assessment.repository.DiscScoringLeastRepository;
import com.assessment.repository.DiscScoringMostRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DiscScoringService {

    private final DiscQuestionRepository discQuestionRepository;
    private final DiscScoringMostRepository discScoringMostRepository;
    private final DiscScoringLeastRepository discScoringLeastRepository;
    private final DiscScoringDifRepository discScoringDifRepository;
    private final DiscPersonalityProfileRepository discPersonalityProfileRepository;
    private final DiscResultRepository discResultRepository;
    private final ObjectMapper objectMapper;

    public record DiscAnswerDto(int blockNo, int mostItemNo, int leastItemNo) {}

    @Transactional
    @SneakyThrows
    public DiscResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                   Long assignmentId, List<DiscAnswerDto> answers) {

        // Step 1 — Tally MOST and LEAST counts per D/I/S/C
        int dMost = 0, iMost = 0, sMost = 0, cMost = 0;
        int dLeast = 0, iLeast = 0, sLeast = 0, cLeast = 0;

        for (DiscAnswerDto answer : answers) {
            DiscQuestion mostQ = findQuestion(answer.blockNo(), answer.mostItemNo());
            switch (mostQ.getCategory().toUpperCase()) {
                case "D" -> dMost++;
                case "I" -> iMost++;
                case "S" -> sMost++;
                case "C" -> cMost++;
            }

            DiscQuestion leastQ = findQuestion(answer.blockNo(), answer.leastItemNo());
            switch (leastQ.getCategory().toUpperCase()) {
                case "D" -> dLeast++;
                case "I" -> iLeast++;
                case "S" -> sLeast++;
                case "C" -> cLeast++;
            }
        }

        // Step 2 — Compute DIF
        int dDif = dMost - dLeast;
        int iDif = iMost - iLeast;
        int sDif = sMost - sLeast;
        int cDif = cMost - cLeast;

        // Step 3 — Determine keys for MOST, LEAST, DIF
        String mostKey = resolveMostKey(dMost, iMost, sMost, cMost);
        String leastKey = resolveLeastKey(dLeast, iLeast, sLeast, cLeast);
        String difKey = resolveDifKey(dDif, iDif, sDif, cDif);

        // Step 4 — Look up personality profile
        DiscPersonalityProfile profile = discPersonalityProfileRepository
                .findByMostKeyAndLeastKeyAndDifKey(mostKey, leastKey, difKey)
                .orElseGet(() -> DiscPersonalityProfile.builder()
                        .mostKey(mostKey).leastKey(leastKey).difKey(difKey)
                        .title("Profil Beragam")
                        .description("Kombinasi unik dari beberapa dimensi kepribadian.")
                        .build());

        // Step 5 — Build and save DiscResult
        String answersJson = objectMapper.writeValueAsString(answers);

        DiscResult result = DiscResult.builder()
                .authUserId(authUserId)
                .studentName(studentName)
                .schoolName(schoolName)
                .assignmentId(assignmentId)
                .dMost(dMost).iMost(iMost).sMost(sMost).cMost(cMost)
                .dLeast(dLeast).iLeast(iLeast).sLeast(sLeast).cLeast(cLeast)
                .dDif(dDif).iDif(iDif).sDif(sDif).cDif(cDif)
                .mostKey(mostKey)
                .leastKey(leastKey)
                .difKey(difKey)
                .profileTitle(profile.getTitle())
                .profileDesc(profile.getDescription())
                .answers(answersJson)
                .completedAt(LocalDateTime.now())
                .build();

        return discResultRepository.save(result);
    }

    private DiscQuestion findQuestion(int blockNo, int itemNo) {
        return discQuestionRepository.findByBlockNoOrderByItemNoAsc(blockNo).stream()
                .filter(q -> q.getItemNo() == itemNo)
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "DISC question not found: block=" + blockNo + " item=" + itemNo));
    }

    private String resolveMostKey(int d, int i, int s, int c) {
        int max = Math.max(Math.max(d, i), Math.max(s, c));
        String computed = buildTiedKey(d, i, s, c, max);
        return discScoringMostRepository
                .findByScores(flag(d, max), flag(i, max), flag(s, max), flag(c, max))
                .map(row -> row.getKey())
                .orElse(computed.isEmpty() ? "X" : computed);
    }

    private String resolveLeastKey(int d, int i, int s, int c) {
        int max = Math.max(Math.max(d, i), Math.max(s, c));
        String computed = buildTiedKey(d, i, s, c, max);
        return discScoringLeastRepository
                .findByScores(flag(d, max), flag(i, max), flag(s, max), flag(c, max))
                .map(row -> row.getKey())
                .orElse(computed.isEmpty() ? "X" : computed);
    }

    private String resolveDifKey(int d, int i, int s, int c) {
        int max = Math.max(Math.max(d, i), Math.max(s, c));
        String computed = buildTiedKey(d, i, s, c, max);
        return discScoringDifRepository
                .findByScores(flag(d, max), flag(i, max), flag(s, max), flag(c, max))
                .map(row -> row.getKey())
                .orElse(computed.isEmpty() ? "X" : computed);
    }

    // Returns 1 if score == max, 0 otherwise — used as the DB lookup key
    private int flag(int score, int max) {
        return score == max ? 1 : 0;
    }

    // Builds a string like "D", "DI", "DISC" from tied positions, in alphabetical order
    private String buildTiedKey(int d, int i, int s, int c, int max) {
        StringBuilder sb = new StringBuilder();
        if (d == max) sb.append("D");
        if (i == max) sb.append("I");
        if (s == max) sb.append("S");
        if (c == max) sb.append("C");
        return sb.toString();
    }
}
