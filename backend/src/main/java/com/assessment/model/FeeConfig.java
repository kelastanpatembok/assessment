package com.assessment.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fee_config")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeeConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", unique = true)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private TestCategory category;

    @Column(name = "student_fee", nullable = false, precision = 14, scale = 2)
    private BigDecimal studentFee;

    @Column(name = "afiliator_share_pct", nullable = false, precision = 5, scale = 2)
    private BigDecimal afiliatorSharePct;

    @Column(name = "gurubk_share_pct", nullable = false, precision = 5, scale = 2)
    private BigDecimal gurubkSharePct;

    @Column(name = "platform_share_pct", nullable = false, precision = 5, scale = 2)
    private BigDecimal platformSharePct;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
