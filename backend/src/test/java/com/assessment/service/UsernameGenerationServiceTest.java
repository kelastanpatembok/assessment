package com.assessment.service;

import com.assessment.client.AuthServiceClient;
import com.assessment.exception.UsernameGenerationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.when;

/**
 * Unit tests for UsernameGenerationService.
 * 
 * Validates: Requirements 3, 10
 * 
 * Tests cover:
 * - Sequential username generation with pattern
 * - Pattern component validation
 * - Uniqueness checking against auth service
 * - Conflict resolution with sequence increment
 * - Error handling
 */
@ExtendWith(MockitoExtension.class)
class UsernameGenerationServiceTest {

    @Mock
    private AuthServiceClient authServiceClient;

    private UsernameGenerationService service;

    @BeforeEach
    void setUp() {
        service = new UsernameGenerationService(authServiceClient);
    }

    // --- Basic sequential username generation ---

    @Test
    void generateUniqueUsernames_shouldGenerateSequentialUsernames() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 5);

        assertThat(usernames).containsExactly(
                "SCHOOL_TEST_001",
                "SCHOOL_TEST_002",
                "SCHOOL_TEST_003",
                "SCHOOL_TEST_004",
                "SCHOOL_TEST_005"
        );
    }

    @Test
    void generateUniqueUsernames_shouldFormatSequenceNumbersWithLeadingZeros() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SC", "TS", 15);

        assertThat(usernames).hasSize(15);
        assertThat(usernames.get(0)).isEqualTo("SC_TS_001");
        assertThat(usernames.get(8)).isEqualTo("SC_TS_009");
        assertThat(usernames.get(9)).isEqualTo("SC_TS_010");
        assertThat(usernames.get(14)).isEqualTo("SC_TS_015");
    }

    // --- Pattern validation ---

    @Test
    void generateUniqueUsernames_shouldRejectNullSchoolCode() {
        assertThatThrownBy(() -> service.generateUniqueUsernames(null, "TEST", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("schoolCode cannot be null or empty");
    }

    @Test
    void generateUniqueUsernames_shouldRejectEmptySchoolCode() {
        assertThatThrownBy(() -> service.generateUniqueUsernames("", "TEST", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("schoolCode cannot be null or empty");
    }

    @Test
    void generateUniqueUsernames_shouldRejectNullTestCode() {
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOOL", null, 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("testCode cannot be null or empty");
    }

    @Test
    void generateUniqueUsernames_shouldRejectEmptyTestCode() {
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOOL", "", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("testCode cannot be null or empty");
    }

    // --- Pattern component length validation ---

    @Test
    void generateUniqueUsernames_shouldRejectSchoolCodeExceedingMaxLength() {
        String tooLongCode = "SCHOOLCODETOLONG"; // 16 chars, max is 10
        assertThatThrownBy(() -> service.generateUniqueUsernames(tooLongCode, "TEST", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("schoolCode exceeds maximum length of 10 characters");
    }

    @Test
    void generateUniqueUsernames_shouldRejectTestCodeExceedingMaxLength() {
        String tooLongCode = "TESTCODETOLONG"; // 14 chars, max is 10
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOOL", tooLongCode, 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("testCode exceeds maximum length of 10 characters");
    }

    @Test
    void generateUniqueUsernames_shouldAcceptPatternComponentsAtMaxLength() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        String maxCode = "ABCDEFGHIJ"; // exactly 10 chars
        List<String> usernames = service.generateUniqueUsernames(maxCode, maxCode, 3);

        assertThat(usernames).hasSize(3);
        assertThat(usernames.get(0)).isEqualTo("ABCDEFGHIJ_ABCDEFGHIJ_001");
    }

    // --- Pattern component character validation ---

    @Test
    void generateUniqueUsernames_shouldRejectSchoolCodeWithInvalidCharacters() {
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOO-OL", "TEST", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("schoolCode contains invalid characters")
                .hasMessageContaining("Only alphanumeric characters and underscores are allowed");
    }

    @Test
    void generateUniqueUsernames_shouldRejectTestCodeWithInvalidCharacters() {
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOOL", "TEST@CODE", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("testCode contains invalid characters")
                .hasMessageContaining("Only alphanumeric characters and underscores are allowed");
    }

    @Test
    void generateUniqueUsernames_shouldRejectPatternWithSpecialCharacters() {
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOOL!", "TEST", 5))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("contains invalid characters");
    }

    @Test
    void generateUniqueUsernames_shouldAcceptAlphanumericPatternComponents() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("ABC123", "XYZ789", 2);

        assertThat(usernames).containsExactly(
                "ABC123_XYZ789_001",
                "ABC123_XYZ789_002"
        );
    }

    @Test
    void generateUniqueUsernames_shouldAcceptUnderscoreInPatternComponents() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL_A", "TEST_1", 2);

        assertThat(usernames).containsExactly(
                "SCHOOL_A_TEST_1_001",
                "SCHOOL_A_TEST_1_002"
        );
    }

    // --- Uniqueness validation ---

    @Test
    void generateUniqueUsernames_shouldReturnExistingUsernamesWhenNoneConflict() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 10);

        assertThat(usernames).hasSize(10);
        Set<String> uniqueSet = new HashSet<>(usernames);
        assertThat(uniqueSet).hasSize(10);
    }

    // --- Conflict resolution ---

    @Test
    void generateUniqueUsernames_shouldResolveConflictsByIncrementingSequence() {
        // Simulate that first 3 usernames already exist
        Set<String> existing = new HashSet<>();
        existing.add("SCHOOL_TEST_001");
        existing.add("SCHOOL_TEST_002");
        existing.add("SCHOOL_TEST_003");
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(existing);

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 5);

        assertThat(usernames).hasSize(5);
        // When conflict on 001, starts looking from offset 6 -> finds 006
        // When conflict on 002, starts looking from offset 7 -> finds 007
        // When conflict on 003, starts looking from offset 8 -> finds 008
        // 004 and 005 are available as requested
        assertThat(usernames).containsExactly(
                "SCHOOL_TEST_006", // 001 conflict resolved to 006
                "SCHOOL_TEST_007", // 002 conflict resolved to 007
                "SCHOOL_TEST_008", // 003 conflict resolved to 008
                "SCHOOL_TEST_004", // 004 not in conflict
                "SCHOOL_TEST_005"  // 005 not in conflict
        );
    }

    @Test
    void generateUniqueUsernames_shouldResolveMultipleConflictsByIncrementingSequence() {
        // Existing usernames that conflict with initial generation
        Set<String> existing = new HashSet<>();
        existing.add("SCHOOL_TEST_001");
        existing.add("SCHOOL_TEST_002");
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(existing);

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 3);

        assertThat(usernames).hasSize(3);
        // First candidate (001) conflicts -> finds 004 (starting from offset 4)
        // Second candidate (002) conflicts -> finds 005 (starting from offset 5)
        // Third candidate (003) is available -> uses 003
        assertThat(usernames).containsExactly(
                "SCHOOL_TEST_004", // 001 conflict resolved
                "SCHOOL_TEST_005", // 002 conflict resolved
                "SCHOOL_TEST_003"  // 003 not in conflict
        );
    }

    @Test
    void generateUniqueUsernames_shouldHandleConflictWithGapsInSequence() {
        // Simulate scattered conflicts
        Set<String> existing = new HashSet<>();
        existing.add("SCHOOL_TEST_002");
        existing.add("SCHOOL_TEST_004");
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(existing);

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 4);

        assertThat(usernames).hasSize(4);
        // 001: no conflict -> 001
        // 002: conflict -> resolves to next available (005 starting from 5)
        // 003: no conflict -> 003
        // 004: conflict -> resolves to next available (006 starting from 6)
        assertThat(usernames).containsExactly(
                "SCHOOL_TEST_001",
                "SCHOOL_TEST_005",
                "SCHOOL_TEST_003",
                "SCHOOL_TEST_006"
        );
    }

    @Test
    void generateUniqueUsernames_shouldThrowExceptionIfCannotResolveConflictWithin1000Attempts() {
        // Create a set of existing usernames that fills up conflict resolution space
        Set<String> existing = new HashSet<>();
        for (int i = 1; i <= 1050; i++) {
            existing.add(String.format("SCHOOL_TEST_%03d", i));
        }
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(existing);

        // Request 50 usernames when all 001-050 and 051-1100 are taken
        assertThatThrownBy(() -> service.generateUniqueUsernames("SCHOOL", "TEST", 50))
                .isInstanceOf(UsernameGenerationException.class)
                .hasMessageContaining("Could not generate unique username after 1000 attempts");
    }

    // --- Correct count returned ---

    @ParameterizedTest
    @ValueSource(ints = {1, 5, 10, 100, 500})
    void generateUniqueUsernames_shouldReturnExactlyRequestedCount(int count) {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", count);

        assertThat(usernames).hasSize(count);
    }

    // --- All usernames unique ---

    @ParameterizedTest
    @ValueSource(ints = {1, 5, 10, 50, 100})
    void generateUniqueUsernames_shouldReturnAllUniqueUsernames(int count) {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", count);

        Set<String> uniqueSet = new HashSet<>(usernames);
        assertThat(uniqueSet).hasSize(count);
    }

    // --- Case sensitivity ---

    @Test
    void generateUniqueUsernames_shouldPreservePatternComponentCase() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("ScHoOL", "TeSt", 2);

        assertThat(usernames).containsExactly(
                "ScHoOL_TeSt_001",
                "ScHoOL_TeSt_002"
        );
    }

    @Test
    void generateUniqueUsernames_shouldHandleLowercasePatternComponents() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("school", "test", 2);

        assertThat(usernames).containsExactly(
                "school_test_001",
                "school_test_002"
        );
    }

    // --- Single username generation ---

    @Test
    void generateUniqueUsernames_shouldHandleSingleUsernameGeneration() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 1);

        assertThat(usernames).hasSize(1).containsExactly("SCHOOL_TEST_001");
    }

    // --- Large batch generation ---

    @Test
    void generateUniqueUsernames_shouldHandleLargeBatch() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL", "TEST", 500);

        assertThat(usernames).hasSize(500);
        Set<String> uniqueSet = new HashSet<>(usernames);
        assertThat(uniqueSet).hasSize(500);
        assertThat(usernames.get(0)).isEqualTo("SCHOOL_TEST_001");
        assertThat(usernames.get(499)).isEqualTo("SCHOOL_TEST_500");
    }

    // --- Edge cases with underscores ---

    @Test
    void generateUniqueUsernames_shouldHandlePatternComponentStartingWithUnderscore() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("_SCHOOL", "_TEST", 2);

        assertThat(usernames).containsExactly(
                "_SCHOOL__TEST_001",
                "_SCHOOL__TEST_002"
        );
    }

    @Test
    void generateUniqueUsernames_shouldHandlePatternComponentEndingWithUnderscore() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCHOOL_", "TEST_", 2);

        // When combined: "SCHOOL_" + "_" + "TEST_" + "_" + sequence = "SCHOOL__TEST__sequence"
        assertThat(usernames).containsExactly(
                "SCHOOL__TEST__001",
                "SCHOOL__TEST__002"
        );
    }

    @Test
    void generateUniqueUsernames_shouldHandleMultipleConsecutiveUnderscores() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("SCH__OOL", "TE__ST", 2);

        assertThat(usernames).containsExactly(
                "SCH__OOL_TE__ST_001",
                "SCH__OOL_TE__ST_002"
        );
    }

    // --- Single character codes ---

    @Test
    void generateUniqueUsernames_shouldHandleSingleCharacterPatternComponents() {
        when(authServiceClient.checkUsernamesExist(anyList())).thenReturn(new HashSet<>());

        List<String> usernames = service.generateUniqueUsernames("S", "T", 3);

        assertThat(usernames).containsExactly(
                "S_T_001",
                "S_T_002",
                "S_T_003"
        );
    }
}
