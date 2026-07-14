package com.assessment.controller;

import com.assessment.exception.BadRequestException;
import com.assessment.repository.CfitResultRepository;
import com.assessment.repository.DiscResultRepository;
import com.assessment.repository.HollandResultRepository;
import com.assessment.repository.IstResultRepository;
import com.assessment.repository.PapiResultRepository;
import com.assessment.security.CurrentUser;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Lets a student wipe their own result for one instrument so they can retake
 * it while manually testing a flow — there's no "no retake" rule to protect
 * here since it only ever touches the caller's own row.
 *
 * Gated behind app.dev-tools-enabled (default true); set to false wherever
 * this app runs somewhere retakes should actually be disallowed.
 */
@RestController
@RequestMapping("/dev")
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.dev-tools-enabled", havingValue = "true", matchIfMissing = true)
public class DevToolsController {

    private final DiscResultRepository discResultRepository;
    private final HollandResultRepository hollandResultRepository;
    private final PapiResultRepository papiResultRepository;
    private final CfitResultRepository cfitResultRepository;
    private final IstResultRepository istResultRepository;

    @DeleteMapping("/results/{testKey}")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Void> clearOwnResult(@PathVariable String testKey) {
        String userId = CurrentUser.userId();
        switch (testKey) {
            case "disc" -> discResultRepository.findByAuthUserId(userId).ifPresent(discResultRepository::delete);
            case "holland" -> hollandResultRepository.findByAuthUserId(userId).ifPresent(hollandResultRepository::delete);
            case "papi" -> papiResultRepository.findByAuthUserId(userId).ifPresent(papiResultRepository::delete);
            case "cfit" -> cfitResultRepository.findByAuthUserId(userId).ifPresent(cfitResultRepository::delete);
            case "ist" -> istResultRepository.findByAuthUserId(userId).ifPresent(istResultRepository::delete);
            default -> throw new BadRequestException("Unknown test key: " + testKey);
        }
        return ResponseEntity.noContent().build();
    }
}
