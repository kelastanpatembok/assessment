package com.assessment.dto;

import java.util.Map;

public record DashboardDTO(
    long totalStudents,
    long completedTests,
    double averageIq,
    Map<String, Long> discProfileDistribution,
    Map<String, Long> hollandTypeDistribution
) {}
