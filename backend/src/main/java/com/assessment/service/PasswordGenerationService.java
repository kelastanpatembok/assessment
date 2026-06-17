package com.assessment.service;

import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class PasswordGenerationService {

    private static final String UPPERCASE = "ABCDEFGHJKLMNPQRSTUVWXYZ"; // excludes I, O
    private static final String LOWERCASE = "abcdefghijkmnopqrstuvwxyz"; // excludes l, o
    private static final String DIGITS = "23456789"; // excludes 0, 1
    private static final String ALL_CHARS = UPPERCASE + LOWERCASE + DIGITS;
    private static final int PASSWORD_LENGTH = 8;

    private final SecureRandom random = new SecureRandom();

    /**
     * Generates a list of unique secure passwords.
     *
     * @param count number of passwords to generate
     * @return list of unique passwords, each exactly 8 characters long
     */
    public List<String> generateSecurePasswords(int count) {
        Set<String> passwords = new HashSet<>();
        while (passwords.size() < count) {
            String password = generateSinglePassword();
            passwords.add(password);
        }
        return new ArrayList<>(passwords);
    }

    private String generateSinglePassword() {
        StringBuilder sb = new StringBuilder(PASSWORD_LENGTH);

        // Ensure at least one of each required character type
        sb.append(UPPERCASE.charAt(random.nextInt(UPPERCASE.length())));
        sb.append(LOWERCASE.charAt(random.nextInt(LOWERCASE.length())));
        sb.append(DIGITS.charAt(random.nextInt(DIGITS.length())));

        // Fill remaining positions with random chars from the full set
        for (int i = 3; i < PASSWORD_LENGTH; i++) {
            sb.append(ALL_CHARS.charAt(random.nextInt(ALL_CHARS.length())));
        }

        // Shuffle to avoid predictable character positions
        return shuffleString(sb.toString());
    }

    private String shuffleString(String input) {
        char[] chars = input.toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char temp = chars[i];
            chars[i] = chars[j];
            chars[j] = temp;
        }
        return new String(chars);
    }
}
