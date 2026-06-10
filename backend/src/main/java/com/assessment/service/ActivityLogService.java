package com.assessment.service;

import com.assessment.model.ActivityLog;
import com.assessment.repository.ActivityLogRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
}
