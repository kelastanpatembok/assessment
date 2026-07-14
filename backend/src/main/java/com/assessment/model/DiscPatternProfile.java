package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

// One of the 40 classic DISC patterns (see db/migration/V11, transcribed
// from the "Def" tab). patternIndex (1-40) is what DiscPatternClassifier
// resolves a converted D/I/S/C quadruple to.
@Entity
@Table(name = "disc_pattern_profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscPatternProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "pattern_index", nullable = false, unique = true)
    private Integer patternIndex;

    @Column(name = "type_key", nullable = false, length = 30)
    private String typeKey;

    @Column(nullable = false, length = 100)
    private String title;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private String traits;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "job_recommendations", nullable = false, columnDefinition = "TEXT")
    private String jobRecommendations;
}
