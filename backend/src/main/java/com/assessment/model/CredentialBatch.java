package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "credential_batches")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CredentialBatch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "test_assignment_id", nullable = false)
    private Long testAssignmentId;

    @Column(name = "school_id")
    private Long schoolId;

    @Column(name = "school_name", nullable = false, length = 200)
    private String schoolName;

    @Column(name = "category_name", nullable = false, length = 100)
    private String categoryName;

    @Column(name = "credential_count", nullable = false)
    private int credentialCount;

    @Column(name = "pdf_filename", nullable = false, length = 300)
    private String pdfFilename;

    @Column(name = "generated_by", nullable = false, length = 100)
    private String generatedBy;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void prePersist() {
        createdAt = LocalDateTime.now();
    }
}
