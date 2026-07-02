package com.assessment.service;

import com.assessment.model.ActivityLog;
import com.assessment.repository.ActivityLogRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActivityLogService {

    private final ActivityLogRepository activityLogRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public void logEvent(String authUserId, String testType, String eventType,
                         Map<String, Object> metadata) {
        try {
            String metadataJson = metadata != null ? objectMapper.writeValueAsString(metadata) : null;
            ActivityLog log = ActivityLog.builder()
                    .authUserId(authUserId)
                    .testType(testType)
                    .eventType(eventType)
                    .metadata(metadataJson)
                    .build();
            activityLogRepository.save(log);
        } catch (Exception ex) {
            log.warn("Failed to persist activity log: user={}, testType={}, eventType={}", authUserId, testType, eventType, ex);
        }
    }

    @Transactional
    public void logCredentialGeneration(
        String adminUsername,
        String schoolName,
        String testCategory,
        int count
    ) {
        try {
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
                    .authUserId("system")
                    .testType("credential")
                    .eventType("GENERATE")
                    .metadata(metadataJson)
                    .build();
            activityLogRepository.save(log);
        } catch (Exception ex) {
            log.warn("Failed to persist credential generation log: admin={}, school={}, category={}", adminUsername, schoolName, testCategory, ex);
        }
    }
}
