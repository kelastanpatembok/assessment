package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fee_shares")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeeShare {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false, length = 64)
    private String studentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private TestCategory category;

    @Column(name = "afiliator_id", length = 64)
    private String afiliatorId;

    @Column(name = "gurubk_id", length = 64)
    private String gurubkId;

    @Column(name = "total_fee", nullable = false, precision = 14, scale = 2)
    private BigDecimal totalFee;

    @Column(name = "afiliator_share", nullable = false, precision = 14, scale = 2)
    private BigDecimal afiliatorShare;

    @Column(name = "gurubk_share", nullable = false, precision = 14, scale = 2)
    private BigDecimal gurubkShare;

    @Column(name = "platform_share", nullable = false, precision = 14, scale = 2)
    private BigDecimal platformShare;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void prePersist() {
        createdAt = LocalDateTime.now();
    }
}
