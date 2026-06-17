package com.assessment.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class PasswordGenerationServiceTest {

    private static final String AMBIGUOUS_CHARS = "0Ol1I";
    private static final int PASSWORD_LENGTH = 8;

    private PasswordGenerationService service;

    @BeforeEach
    void setUp() {
        service = new PasswordGenerationService();
    }

    // --- Length requirement (Requirement 5.2) ---

    @Test
    void generatedPassword_shouldBeExactly8CharactersLong() {
        List<String> passwords = service.generateSecurePasswords(50);
        for (String password : passwords) {
            assertThat(password).hasSize(PASSWORD_LENGTH);
        }
    }

    // --- Character composition requirements (Requirement 5.3) ---

    @Test
    void generatedPassword_shouldContainAtLeastOneUppercaseLetter() {
        List<String> passwords = service.generateSecurePasswords(50);
        for (String password : passwords) {
            boolean hasUppercase = password.chars().anyMatch(Character::isUpperCase);
            assertThat(hasUppercase)
                    .as("Password '%s' should contain at least one uppercase letter", password)
                    .isTrue();
        }
    }

    @Test
    void generatedPassword_shouldContainAtLeastOneLowercaseLetter() {
        List<String> passwords = service.generateSecurePasswords(50);
        for (String password : passwords) {
            boolean hasLowercase = password.chars().anyMatch(Character::isLowerCase);
            assertThat(hasLowercase)
                    .as("Password '%s' should contain at least one lowercase letter", password)
                    .isTrue();
        }
    }

    @Test
    void generatedPassword_shouldContainAtLeastOneDigit() {
        List<String> passwords = service.generateSecurePasswords(50);
        for (String password : passwords) {
            boolean hasDigit = password.chars().anyMatch(Character::isDigit);
            assertThat(hasDigit)
                    .as("Password '%s' should contain at least one digit", password)
                    .isTrue();
        }
    }

    // --- Ambiguous character exclusion (Requirement 5.4) ---

    @Test
    void generatedPassword_shouldNotContainAmbiguousCharacters() {
        List<String> passwords = service.generateSecurePasswords(100);
        for (String password : passwords) {
            for (char ambiguous : AMBIGUOUS_CHARS.toCharArray()) {
                assertThat(password)
                        .as("Password '%s' should not contain ambiguous character '%c'", password, ambiguous)
                        .doesNotContain(String.valueOf(ambiguous));
            }
        }
    }

    @Test
    void generatedPassword_shouldNotContainZeroOrCapitalO() {
        List<String> passwords = service.generateSecurePasswords(100);
        for (String password : passwords) {
            assertThat(password).doesNotContain("0").doesNotContain("O");
        }
    }

    @Test
    void generatedPassword_shouldNotContainLowercaseLOrCapitalI() {
        List<String> passwords = service.generateSecurePasswords(100);
        for (String password : passwords) {
            assertThat(password).doesNotContain("l").doesNotContain("I");
        }
    }

    @Test
    void generatedPassword_shouldNotContainDigitOne() {
        List<String> passwords = service.generateSecurePasswords(100);
        for (String password : passwords) {
            assertThat(password).doesNotContain("1");
        }
    }

    // --- Uniqueness within a batch (Requirement 5.5) ---

    @ParameterizedTest
    @ValueSource(ints = {1, 10, 50, 100, 500})
    void generatedPasswords_shouldAllBeUniqueWithinBatch(int count) {
        List<String> passwords = service.generateSecurePasswords(count);
        Set<String> unique = new HashSet<>(passwords);
        assertThat(unique).hasSize(count);
    }

    // --- Correct count returned ---

    @ParameterizedTest
    @ValueSource(ints = {1, 5, 25, 100, 500})
    void generateSecurePasswords_shouldReturnExactlyRequestedCount(int count) {
        List<String> passwords = service.generateSecurePasswords(count);
        assertThat(passwords).hasSize(count);
    }

    // --- Only alphanumeric characters (no special chars) ---

    @Test
    void generatedPassword_shouldContainOnlyAlphanumericCharacters() {
        List<String> passwords = service.generateSecurePasswords(100);
        for (String password : passwords) {
            assertThat(password)
                    .as("Password '%s' should only contain alphanumeric characters", password)
                    .matches("[A-Za-z0-9]+");
        }
    }
}
