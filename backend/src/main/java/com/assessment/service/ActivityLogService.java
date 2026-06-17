package com.assessment.service;

import com.assessment.model.ActivityLog;
import com.assessment.repository.ActivityLogRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ActivityLogService {

    private final ActivityLogRepository activityLogRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    @SneakyThrows
    public void logEvent(String authUserId, String testType, String eventType,
                         Map<String, Object> metadata) {
        String metadataJson = metadata != null ? objectMapper.writeValueAsString(metadata) : null;
        ActivityLog log = ActivityLog.builder()
                .authUserId(authUserId)
                .testType(testType)
                .eventType(eventType)
                .metadata(metadataJson)
                .build();
        activityLogRepository.save(log);
    }

    @Transactional
    @SneakyThrows
    public void logCredentialGeneration(
        String adminUsername,
        String schoolName,
        String testCategory,
        int count
    ) {
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("adminUsername", adminUsername);
        metadata.put("schoolName", schoolName);
        metadata.put("testCategory", testCategory);
        metadata.put("count", count);
        metadata.put("description", String.format(
            "Generated %d student credentials for %s - %s (by %s)",
            count,
            schoolName,
            testCategory,
            adminUsername
        ));

        String metadataJson = objectMapper.writeValueAsString(metadata);
        ActivityLog log = ActivityLog.builder()
                .authUserId("system") // system-level operation, not tied to a user
                .testType("CREDENTIAL_GENERATION")
                .eventType("GENERATE")
                .metadata(metadataJson)
                .build();
        activityLogRepository.save(log);
    }
}
