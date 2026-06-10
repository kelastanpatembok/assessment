package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;

@Entity
@Table(name = "ist_results")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "auth_user_id", nullable = false, unique = true, length = 64)
    private String authUserId;

    @Column(name = "student_name") private String studentName;
    @Column(name = "school_name")  private String schoolName;
    @Column(name = "assignment_id") private Long assignmentId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "subtest_scores", columnDefinition = "jsonb", nullable = false)
    private String subtestScores;

    @Column(name = "total_wert") private Integer totalWert;
    @Column(name = "iq_score")   private Integer iqScore;
    @Column(name = "iq_category", length = 50) private String iqCategory;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String answers;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;
}
