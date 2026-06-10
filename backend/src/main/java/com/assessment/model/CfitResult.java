package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;

@Entity
@Table(name = "cfit_results")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CfitResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "auth_user_id", nullable = false, unique = true, length = 64)
    private String authUserId;

    @Column(name = "student_name") private String studentName;
    @Column(name = "school_name")  private String schoolName;
    @Column(name = "assignment_id") private Long assignmentId;

    @Column(name = "sub1_score") private Integer sub1Score;
    @Column(name = "sub2_score") private Integer sub2Score;
    @Column(name = "sub3_score") private Integer sub3Score;
    @Column(name = "sub4_score") private Integer sub4Score;
    @Column(name = "total_score") private Integer totalScore;
    @Column(name = "iq_score") private Integer iqScore;

    @Column(length = 50)
    private String category;

    @Column(columnDefinition = "TEXT")
    private String description;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String answers;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;
}
