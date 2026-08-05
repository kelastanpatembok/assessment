package com.assessment.dto;

import java.util.List;

public record BigFiveResultDto(
        String headline,
        double openness,
        double conscientiousness,
        double extraversion,
        double agreeableness,
        double neuroticism,
        List<Trait> traits
) {
    public record Trait(String key, String label, double value, String level, String description) {}
}
