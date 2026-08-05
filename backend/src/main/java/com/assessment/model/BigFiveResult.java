package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "big5_results")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BigFiveResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "auth_user_id", nullable = false, unique = true, length = 64)
    private String authUserId;

    @Column(name = "openness", nullable = false, precision = 6, scale = 2)
    private BigDecimal openness;

    @Column(name = "conscientiousness", nullable = false, precision = 6, scale = 2)
    private BigDecimal conscientiousness;

    @Column(name = "extraversion", nullable = false, precision = 6, scale = 2)
    private BigDecimal extraversion;

    @Column(name = "agreeableness", nullable = false, precision = 6, scale = 2)
    private BigDecimal agreeableness;

    @Column(name = "neuroticism", nullable = false, precision = 6, scale = 2)
    private BigDecimal neuroticism;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String answers;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;
}
