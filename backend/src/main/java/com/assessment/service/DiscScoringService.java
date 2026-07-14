package com.assessment.service;

import com.assessment.exception.BadRequestException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.DiscDifConversion;
import com.assessment.model.DiscLeastConversion;
import com.assessment.model.DiscMostConversion;
import com.assessment.model.DiscPatternProfile;
import com.assessment.model.DiscQuestion;
import com.assessment.model.DiscResult;
import com.assessment.repository.DiscDifConversionRepository;
import com.assessment.repository.DiscLeastConversionRepository;
import com.assessment.repository.DiscMostConversionRepository;
import com.assessment.repository.DiscPatternProfileRepository;
import com.assessment.repository.DiscQuestionRepository;
import com.assessment.repository.DiscResultRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DiscScoringService {

    private static final int MOST_LEAST_MIN_RAW = 0;
    private static final int MOST_LEAST_MAX_RAW = 20;
    private static final int DIF_MIN_RAW = -22;
    private static final int DIF_MAX_RAW = 22;

    private final DiscQuestionRepository discQuestionRepository;
    private final DiscMostConversionRepository discMostConversionRepository;
    private final DiscLeastConversionRepository discLeastConversionRepository;
    private final DiscDifConversionRepository discDifConversionRepository;
    private final DiscPatternProfileRepository discPatternProfileRepository;
    private final DiscPatternClassifier discPatternClassifier;
    private final DiscResultRepository discResultRepository;
    private final ObjectMapper objectMapper;

    public record DiscAnswerDto(int blockNo, int mostItemNo, int leastItemNo) {}

    private record ConvertedScores(BigDecimal d, BigDecimal i, BigDecimal s, BigDecimal c) {}

    @Transactional
    @SneakyThrows
    public DiscResult scoreAndSave(String authUserId, String studentName, String schoolName,
                                   Long assignmentId, List<DiscAnswerDto> answers) {

        // Guard against incomplete submissions: a client-side bug silently
        // dropping one block (e.g. a form field not yet flushed to the DOM
        // at submit time) would otherwise still tally and score normally,
        // just on fewer than 24 blocks, producing a plausible-looking but
        // wrong result with no visible error.
        long expectedBlocks = discQuestionRepository.findByActiveTrueOrderByBlockNoAscItemNoAsc().stream()
                .map(DiscQuestion::getBlockNo)
                .distinct()
                .count();
        if (answers.size() != expectedBlocks) {
            throw new BadRequestException(
                    "Jawaban tidak lengkap: diterima " + answers.size() + " dari " + expectedBlocks + " kelompok soal");
        }

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

        // Step 3 — Convert each line's raw D/I/S/C independently (each
        // dimension is its own lookup against that line's shared table —
        // NOT a combined 4-key row), then classify into one of 40 patterns.
        ConvertedScores mostConv = convertMost(dMost, iMost, sMost, cMost);
        ConvertedScores leastConv = convertLeast(dLeast, iLeast, sLeast, cLeast);
        ConvertedScores difConv = convertDif(dDif, iDif, sDif, cDif);

        DiscPatternProfile mostProfile = lookupPattern(discPatternClassifier.classify(
                mostConv.d(), mostConv.i(), mostConv.s(), mostConv.c()));
        DiscPatternProfile leastProfile = lookupPattern(discPatternClassifier.classify(
                leastConv.d(), leastConv.i(), leastConv.s(), leastConv.c()));
        DiscPatternProfile difProfile = lookupPattern(discPatternClassifier.classify(
                difConv.d(), difConv.i(), difConv.s(), difConv.c()));

        // Step 4 — Build and save DiscResult. The DIF pattern is the
        // headline "Kepribadian Asli / Sesungguhnya" result; MOST/LEAST are
        // the "Saat di Publik" / "Saat Mendapat Tekanan" personas.
        String answersJson = objectMapper.writeValueAsString(answers);

        DiscResult result = DiscResult.builder()
                .authUserId(authUserId)
                .studentName(studentName)
                .schoolName(schoolName)
                .assignmentId(assignmentId)
                .dMost(dMost).iMost(iMost).sMost(sMost).cMost(cMost)
                .dLeast(dLeast).iLeast(iLeast).sLeast(sLeast).cLeast(cLeast)
                .dDif(dDif).iDif(iDif).sDif(sDif).cDif(cDif)
                .mostKey(mostProfile.getTypeKey())
                .leastKey(leastProfile.getTypeKey())
                .difKey(difProfile.getTypeKey())
                .mostProfileTitle(mostProfile.getTitle())
                .mostProfileTraits(mostProfile.getTraits())
                .leastProfileTitle(leastProfile.getTitle())
                .leastProfileTraits(leastProfile.getTraits())
                .profileTitle(difProfile.getTitle())
                .profileDesc(difProfile.getDescription())
                .difProfileTraits(difProfile.getTraits())
                .jobRecommendations(difProfile.getJobRecommendations())
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

    private ConvertedScores convertMost(int d, int i, int s, int c) {
        DiscMostConversion cd = discMostConversionRepository.findById(clamp(d, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscMostConversion row for raw=" + (clamp(d, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        DiscMostConversion ci = discMostConversionRepository.findById(clamp(i, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscMostConversion row for raw=" + (clamp(i, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        DiscMostConversion cs = discMostConversionRepository.findById(clamp(s, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscMostConversion row for raw=" + (clamp(s, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        DiscMostConversion cc = discMostConversionRepository.findById(clamp(c, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscMostConversion row for raw=" + (clamp(c, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        return new ConvertedScores(cd.getDConv(), ci.getIConv(), cs.getSConv(), cc.getCConv());
    }

    private ConvertedScores convertLeast(int d, int i, int s, int c) {
        DiscLeastConversion cd = discLeastConversionRepository.findById(clamp(d, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscLeastConversion row for raw=" + (clamp(d, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        DiscLeastConversion ci = discLeastConversionRepository.findById(clamp(i, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscLeastConversion row for raw=" + (clamp(i, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        DiscLeastConversion cs = discLeastConversionRepository.findById(clamp(s, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscLeastConversion row for raw=" + (clamp(s, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        DiscLeastConversion cc = discLeastConversionRepository.findById(clamp(c, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscLeastConversion row for raw=" + (clamp(c, MOST_LEAST_MIN_RAW, MOST_LEAST_MAX_RAW))));
        return new ConvertedScores(cd.getDConv(), ci.getIConv(), cs.getSConv(), cc.getCConv());
    }

    private ConvertedScores convertDif(int d, int i, int s, int c) {
        DiscDifConversion cd = discDifConversionRepository.findById(clamp(d, DIF_MIN_RAW, DIF_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscDifConversion row for raw=" + (clamp(d, DIF_MIN_RAW, DIF_MAX_RAW))));
        DiscDifConversion ci = discDifConversionRepository.findById(clamp(i, DIF_MIN_RAW, DIF_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscDifConversion row for raw=" + (clamp(i, DIF_MIN_RAW, DIF_MAX_RAW))));
        DiscDifConversion cs = discDifConversionRepository.findById(clamp(s, DIF_MIN_RAW, DIF_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscDifConversion row for raw=" + (clamp(s, DIF_MIN_RAW, DIF_MAX_RAW))));
        DiscDifConversion cc = discDifConversionRepository.findById(clamp(c, DIF_MIN_RAW, DIF_MAX_RAW))
                .orElseThrow(() -> new ResourceNotFoundException("Missing DiscDifConversion row for raw=" + (clamp(c, DIF_MIN_RAW, DIF_MAX_RAW))));
        return new ConvertedScores(cd.getDConv(), ci.getIConv(), cs.getSConv(), cc.getCConv());
    }

    // Raw tallies can exceed the source conversion table's range in extreme,
    // rarely-seen cases (e.g. picking one category as MOST on every block) —
    // clamp to the table's boundary row rather than fail, matching how norm
    // tables are conventionally extrapolated at the extremes.
    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }

    private DiscPatternProfile lookupPattern(int patternIndex) {
        return discPatternProfileRepository.findByPatternIndex(patternIndex)
                .orElseThrow(() -> new ResourceNotFoundException("Unknown DISC pattern index: " + patternIndex));
    }
}
