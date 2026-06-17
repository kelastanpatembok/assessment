package com.assessment.service;

import com.assessment.model.ActivityLog;
import com.assessment.repository.ActivityLogRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class ActivityLogServiceTest {

    @Mock
    private ActivityLogRepository activityLogRepository;

    private ActivityLogService activityLogService;

    @BeforeEach
    void setUp() {
        ObjectMapper objectMapper = new ObjectMapper();
        activityLogService = new ActivityLogService(activityLogRepository, objectMapper);
    }

    // --- logCredentialGeneration tests ---

    @Test
    void logCredentialGeneration_shouldCreateActivityLogWithCorrectMetadata() throws Exception {
        String adminUsername = "admin123";
        String schoolName = "SMA Jakarta";
        String testCategory = "Holland";
        int count = 50;

        activityLogService.logCredentialGeneration(adminUsername, schoolName, testCategory, count);

        ArgumentCaptor<ActivityLog> logCaptor = ArgumentCaptor.forClass(ActivityLog.class);
        verify(activityLogRepository).save(logCaptor.capture());

        ActivityLog savedLog = logCaptor.getValue();
        assertThat(savedLog).isNotNull();
        assertThat(savedLog.getAuthUserId()).isEqualTo("system");
        assertThat(savedLog.getTestType()).isEqualTo("CREDENTIAL_GENERATION");
        assertThat(savedLog.getEventType()).isEqualTo("GENERATE");
    }

    @Test
    void logCredentialGeneration_shouldFormatDescriptionCorrectly() throws Exception {
        String adminUsername = "admin123";
        String schoolName = "SMA Jakarta";
        String testCategory = "Holland";
        int count = 50;

        activityLogService.logCredentialGeneration(adminUsername, schoolName, testCategory, count);

        ArgumentCaptor<ActivityLog> logCaptor = ArgumentCaptor.forClass(ActivityLog.class);
        verify(activityLogRepository).save(logCaptor.capture());

        ActivityLog savedLog = logCaptor.getValue();
        ObjectMapper objectMapper = new ObjectMapper();
        @SuppressWarnings("unchecked")
        Map<String, Object> metadata = objectMapper.readValue(savedLog.getMetadata(), Map.class);

        String expectedDescription = "Generated 50 student credentials for SMA Jakarta - Holland (by admin123)";
        assertThat(metadata.get("description")).isEqualTo(expectedDescription);
    }

    @Test
    void logCredentialGeneration_shouldIncludeAllRequiredMetadataFields() throws Exception {
        String adminUsername = "admin456";
        String schoolName = "SMA Surabaya";
        String testCategory = "DISC";
        int count = 100;

        activityLogService.logCredentialGeneration(adminUsername, schoolName, testCategory, count);

        ArgumentCaptor<ActivityLog> logCaptor = ArgumentCaptor.forClass(ActivityLog.class);
        verify(activityLogRepository).save(logCaptor.capture());

        ActivityLog savedLog = logCaptor.getValue();
        ObjectMapper objectMapper = new ObjectMapper();
        @SuppressWarnings("unchecked")
        Map<String, Object> metadata = objectMapper.readValue(savedLog.getMetadata(), Map.class);

        assertThat(metadata)
                .containsKeys("adminUsername", "schoolName", "testCategory", "count", "description")
                .containsEntry("adminUsername", adminUsername)
                .containsEntry("schoolName", schoolName)
                .containsEntry("testCategory", testCategory)
                .containsEntry("count", count);
    }

    @Test
    void logCredentialGeneration_shouldHandleCredentialCountOf1() throws Exception {
        activityLogService.logCredentialGeneration("admin", "School", "Test", 1);

        ArgumentCaptor<ActivityLog> logCaptor = ArgumentCaptor.forClass(ActivityLog.class);
        verify(activityLogRepository).save(logCaptor.capture());

        ActivityLog savedLog = logCaptor.getValue();
        ObjectMapper objectMapper = new ObjectMapper();
        @SuppressWarnings("unchecked")
        Map<String, Object> metadata = objectMapper.readValue(savedLog.getMetadata(), Map.class);

        assertThat(metadata.get("count")).isEqualTo(1);
        String description = (String) metadata.get("description");
        assertThat(description).contains("Generated 1 student credentials");
    }

    @Test
    void logCredentialGeneration_shouldHandleCredentialCountOf500() throws Exception {
        activityLogService.logCredentialGeneration("admin", "School", "Test", 500);

        ArgumentCaptor<ActivityLog> logCaptor = ArgumentCaptor.forClass(ActivityLog.class);
        verify(activityLogRepository).save(logCaptor.capture());

        ActivityLog savedLog = logCaptor.getValue();
        ObjectMapper objectMapper = new ObjectMapper();
        @SuppressWarnings("unchecked")
        Map<String, Object> metadata = objectMapper.readValue(savedLog.getMetadata(), Map.class);

        assertThat(metadata.get("count")).isEqualTo(500);
        String description = (String) metadata.get("description");
        assertThat(description).contains("Generated 500 student credentials");
    }

    @Test
    void logCredentialGeneration_shouldHandleSpecialCharactersInSchoolName() throws Exception {
        String schoolName = "SMA \"Negeri 1\" - Jakarta";
        String testCategory = "Test's Category";

        activityLogService.logCredentialGeneration("admin", schoolName, testCategory, 25);

        ArgumentCaptor<ActivityLog> logCaptor = ArgumentCaptor.forClass(ActivityLog.class);
        verify(activityLogRepository).save(logCaptor.capture());

        ActivityLog savedLog = logCaptor.getValue();
        ObjectMapper objectMapper = new ObjectMapper();
        @SuppressWarnings("unchecked")
        Map<String, Object> metadata = objectMapper.readValue(savedLog.getMetadata(), Map.class);

        assertThat(metadata.get("schoolName")).isEqualTo(schoolName);
        assertThat(metadata.get("testCategory")).isEqualTo(testCategory);
    }

    @Test
    void logCredentialGeneration_shouldPersistToRepository() throws Exception {
        activityLogService.logCredentialGeneration("admin", "School", "Category", 10);

        verify(activityLogRepository).save(any(ActivityLog.class));
    }
}
