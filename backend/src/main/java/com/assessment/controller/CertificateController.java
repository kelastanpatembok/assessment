package com.assessment.controller;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.Certificate;
import com.assessment.model.CfitResult;
import com.assessment.model.DiscResult;
import com.assessment.model.HollandResult;
import com.assessment.model.IstResult;
import com.assessment.model.PapiResult;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.CertificateRepository;
import com.assessment.repository.CfitResultRepository;
import com.assessment.repository.DiscResultRepository;
import com.assessment.repository.HollandResultRepository;
import com.assessment.repository.IstResultRepository;
import com.assessment.repository.PapiResultRepository;
import com.assessment.security.CurrentUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/certificates")
@RequiredArgsConstructor
public class CertificateController {

    private static final Set<String> KNOWN_TESTS = Set.of("disc", "holland", "papi", "cfit", "ist");

    private final DiscResultRepository discResultRepository;
    private final HollandResultRepository hollandResultRepository;
    private final PapiResultRepository papiResultRepository;
    private final CfitResultRepository cfitResultRepository;
    private final IstResultRepository istResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final CertificateRepository certificateRepository;

    public record CertificateView(String testType, String storageKey, String url, String createdAt) {
        static CertificateView from(Certificate c) {
            return new CertificateView(
                    c.getTestType(),
                    c.getStorageKey(),
                    "/api/storage/content/" + c.getStorageKey(),
                    c.getCreatedAt() != null ? c.getCreatedAt().toString() : null
            );
        }
    }

    public record CreateCertificateRequest(String testType, String storageKey) {}

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CertificateView> create(@RequestBody CreateCertificateRequest req) {
        String testType = req.testType() == null ? "" : req.testType().toLowerCase().trim();
        String storageKey = req.storageKey() == null ? "" : req.storageKey().trim();
        if (!KNOWN_TESTS.contains(testType)) {
            throw new IllegalArgumentException("Test type tidak dikenal: " + req.testType());
        }
        if (!validStorageKey(storageKey)) {
            throw new IllegalArgumentException("Storage key tidak valid");
        }
        Certificate existing = certificateRepository
                .findByAuthUserIdAndTestType(CurrentUser.userId(), testType).orElse(null);
        Certificate certificate;
        if (existing != null) {
            existing.setStorageKey(storageKey);
            certificate = certificateRepository.save(existing);
        } else {
            certificate = certificateRepository.save(Certificate.builder()
                    .authUserId(CurrentUser.userId())
                    .testType(testType)
                    .storageKey(storageKey)
                    .build());
        }
        return ResponseEntity.ok(CertificateView.from(certificate));
    }

    @GetMapping("/mine")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<List<CertificateView>> mine() {
        List<CertificateView> views = certificateRepository
                .findByAuthUserIdOrderByCreatedAtDesc(CurrentUser.userId())
                .stream().map(CertificateView::from).toList();
        return ResponseEntity.ok(views);
    }

    @GetMapping("/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
    public ResponseEntity<List<CertificateView>> forStudent(@PathVariable String authUserId) {
        List<CertificateView> views = certificateRepository
                .findByAuthUserIdOrderByCreatedAtDesc(authUserId)
                .stream().map(CertificateView::from).toList();
        return ResponseEntity.ok(views);
    }

    private static boolean validStorageKey(String key) {
        if (key.isEmpty() || key.length() > 255) return false;
        return java.util.Arrays.stream(key.split("/"))
                .allMatch(seg -> !seg.isEmpty() && seg.length() <= 120
                        && seg.chars().allMatch(ch ->
                                Character.isLetterOrDigit(ch) || ch == '-' || ch == '_' || ch == '.'));
    }

    @GetMapping("/disc/{authUserId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> discCertificate(@PathVariable String authUserId) {
        assertOwnershipOrAdmin(authUserId);
        DiscResult result = discResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No DISC result for: " + authUserId));
        AssessmentUser user = assessmentUserRepository.findById(authUserId).orElse(null);
        return ResponseEntity.ok(Map.of("result", result, "profile", user != null ? user : Map.of()));
    }

    @GetMapping("/holland/{authUserId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> hollandCertificate(@PathVariable String authUserId) {
        assertOwnershipOrAdmin(authUserId);
        HollandResult result = hollandResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No Holland result for: " + authUserId));
        AssessmentUser user = assessmentUserRepository.findById(authUserId).orElse(null);
        return ResponseEntity.ok(Map.of("result", result, "profile", user != null ? user : Map.of()));
    }

    @GetMapping("/papi/{authUserId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> papiCertificate(@PathVariable String authUserId) {
        assertOwnershipOrAdmin(authUserId);
        PapiResult result = papiResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No PAPI result for: " + authUserId));
        AssessmentUser user = assessmentUserRepository.findById(authUserId).orElse(null);
        return ResponseEntity.ok(Map.of("result", result, "profile", user != null ? user : Map.of()));
    }

    @GetMapping("/cfit/{authUserId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> cfitCertificate(@PathVariable String authUserId) {
        assertOwnershipOrAdmin(authUserId);
        CfitResult result = cfitResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No CFIT result for: " + authUserId));
        AssessmentUser user = assessmentUserRepository.findById(authUserId).orElse(null);
        return ResponseEntity.ok(Map.of("result", result, "profile", user != null ? user : Map.of()));
    }

    @GetMapping("/ist/{authUserId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> istCertificate(@PathVariable String authUserId) {
        assertOwnershipOrAdmin(authUserId);
        IstResult result = istResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No IST result for: " + authUserId));
        AssessmentUser user = assessmentUserRepository.findById(authUserId).orElse(null);
        return ResponseEntity.ok(Map.of("result", result, "profile", user != null ? user : Map.of()));
    }

    // SISWA may only access their own certificate; admin/gurubk/afiliator may access any.
    private void assertOwnershipOrAdmin(String authUserId) {
        String role = CurrentUser.role();
        if ("siswa".equalsIgnoreCase(role) && !CurrentUser.userId().equals(authUserId)) {
            throw new org.springframework.security.access.AccessDeniedException(
                    "Students may only access their own certificates");
        }
    }
}
