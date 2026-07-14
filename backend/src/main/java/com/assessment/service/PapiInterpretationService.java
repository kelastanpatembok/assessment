package com.assessment.service;

import com.assessment.model.PapiDescription;
import com.assessment.model.PapiResult;
import com.assessment.repository.PapiDescriptionRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Computes PAPI trait interpretation at read time (not denormalized into
 * papi_results at submit time, unlike Holland/DISC) so that when
 * papi_descriptions is later replaced with the psychologist-verified manual,
 * every existing result reflects the update immediately with no re-migration —
 * see backend/scripts/initial-setup.sh for the placeholder-data caveat.
 */
@Service
@RequiredArgsConstructor
public class PapiInterpretationService {

    // Canonical trait order — matches CLAUDE.md's papi_results column order.
    private static final List<String> TRAIT_ORDER = List.of(
            "G", "N", "A", "P", "X", "B", "O", "Z", "K", "F",
            "L", "I", "T", "V", "S", "R", "D", "E", "C", "W");

    // Each of the 20 traits is the chosen option in exactly 9 of the 90 forced-choice
    // pairs, so raw scores range 0-9; scores at or above the midpoint read as "high".
    private static final int HIGH_BAND_THRESHOLD = 5;

    private final PapiDescriptionRepository papiDescriptionRepository;
    private final ObjectMapper objectMapper;

    public record TraitDetail(String traitCode, String traitName, int score, String description,
                               String band, String bandText) {}

    @SneakyThrows
    public List<TraitDetail> interpret(PapiResult result) {
        Map<String, Integer> scores = objectMapper.readValue(
                result.getTraitScores(),
                objectMapper.getTypeFactory().constructMapType(Map.class, String.class, Integer.class));

        return TRAIT_ORDER.stream()
                .map(code -> {
                    int score = scores.getOrDefault(code, 0);
                    PapiDescription desc = papiDescriptionRepository.findByTraitCode(code).orElse(null);
                    boolean high = score >= HIGH_BAND_THRESHOLD;
                    return new TraitDetail(
                            code,
                            desc != null ? desc.getTraitName() : code,
                            score,
                            desc != null ? desc.getDescription() : null,
                            high ? "TINGGI" : "RENDAH",
                            desc != null ? (high ? desc.getHighDesc() : desc.getLowDesc()) : null);
                })
                .toList();
    }
}
