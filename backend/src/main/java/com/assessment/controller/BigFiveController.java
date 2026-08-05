package com.assessment.controller;

import com.assessment.dto.BigFiveResultDto;
import com.assessment.model.BigFiveResult;
import com.assessment.repository.BigFiveResultRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.BigFiveInterpretationService;
import com.assessment.service.BigFiveItemBank;
import com.assessment.service.BigFiveScoringService;
import com.assessment.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/big5")
@RequiredArgsConstructor
public class BigFiveController {

    private final BigFiveScoringService scoringService;
    private final BigFiveInterpretationService interpretationService;
    private final BigFiveResultRepository resultRepository;

    public record BigFiveQuestion(int no, String statement) {}

    /** Public — serves the free quiz items to unauthenticated visitors. */
    @GetMapping("/questions")
    public List<BigFiveQuestion> questions() {
        return BigFiveItemBank.ITEMS.stream()
            .map(i -> new BigFiveQuestion(i.no(), i.statement()))
            .toList();
    }

    /** Public — computes the result without persisting anything. */
    @PostMapping("/submit")
    public ResponseEntity<BigFiveResultDto> submit(@RequestBody Map<String, Integer> answers) {
        return ResponseEntity.ok(interpretationService.interpret(scoringService.score(answers)));
    }

    /** Authenticated — persists the result for the current user. */
    @PostMapping("/save")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<BigFiveResultDto> save(@RequestBody Map<String, Integer> answers) {
        Map<String, Double> raw = scoringService.score(answers);
        String userId = CurrentUser.userId();

        BigFiveResult entity = resultRepository.findByAuthUserId(userId).orElseGet(() ->
            BigFiveResult.builder().authUserId(userId).build());
        entity.setOpenness(BigDecimal.valueOf(raw.get("O")));
        entity.setConscientiousness(BigDecimal.valueOf(raw.get("C")));
        entity.setExtraversion(BigDecimal.valueOf(raw.get("E")));
        entity.setAgreeableness(BigDecimal.valueOf(raw.get("A")));
        entity.setNeuroticism(BigDecimal.valueOf(raw.get("N")));
        entity.setAnswers(toJson(answers));
        if (entity.getCompletedAt() == null) {
            entity.setCompletedAt(LocalDateTime.now());
        }
        resultRepository.save(entity);

        return ResponseEntity.ok(interpretationService.interpret(raw));
    }

    /** Authenticated — the current user's saved result. */
    @GetMapping("/result/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<BigFiveResultDto> myResult() {
        BigFiveResult entity = resultRepository.findByAuthUserId(CurrentUser.userId())
            .orElseThrow(() -> new ResourceNotFoundException("Hasil tes belum tersimpan."));
        Map<String, Double> raw = new LinkedHashMap<>();
        raw.put("O", entity.getOpenness().doubleValue());
        raw.put("C", entity.getConscientiousness().doubleValue());
        raw.put("E", entity.getExtraversion().doubleValue());
        raw.put("A", entity.getAgreeableness().doubleValue());
        raw.put("N", entity.getNeuroticism().doubleValue());
        return ResponseEntity.ok(interpretationService.interpret(raw));
    }

    private String toJson(Map<String, Integer> answers) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Integer> e : answers.entrySet()) {
            if (!first) sb.append(",");
            sb.append("\"").append(e.getKey()).append("\":").append(e.getValue());
            first = false;
        }
        return sb.append("}").toString();
    }
}
