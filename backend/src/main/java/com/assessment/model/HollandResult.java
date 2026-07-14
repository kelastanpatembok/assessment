package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;

@Entity
@Table(name = "holland_results")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HollandResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "auth_user_id", nullable = false, unique = true, length = 64)
    private String authUserId;

    @Column(name = "student_name") private String studentName;
    @Column(name = "school_name")  private String schoolName;
    @Column(name = "assignment_id") private Long assignmentId;

    @Column(name = "r_score") private Integer rScore;
    @Column(name = "i_score") private Integer iScore;
    @Column(name = "a_score") private Integer aScore;
    @Column(name = "s_score") private Integer sScore;
    @Column(name = "e_score") private Integer eScore;
    @Column(name = "c_score") private Integer cScore;

    @Column(name = "type1", length = 1) private String type1;
    @Column(name = "type1_name", length = 50) private String type1Name;
    @Column(name = "type1_description", columnDefinition = "TEXT") private String type1Description;
    @Column(name = "type1_characteristics", columnDefinition = "TEXT") private String type1Characteristics;
    @Column(name = "type1_strengths", columnDefinition = "TEXT") private String type1Strengths;
    @Column(name = "type1_weaknesses", columnDefinition = "TEXT") private String type1Weaknesses;
    @Column(name = "type1_job_match", columnDefinition = "TEXT") private String type1JobMatch;

    @Column(name = "type2", length = 1) private String type2;
    @Column(name = "type2_name", length = 50) private String type2Name;
    @Column(name = "type2_description", columnDefinition = "TEXT") private String type2Description;
    @Column(name = "type2_characteristics", columnDefinition = "TEXT") private String type2Characteristics;
    @Column(name = "type2_strengths", columnDefinition = "TEXT") private String type2Strengths;
    @Column(name = "type2_weaknesses", columnDefinition = "TEXT") private String type2Weaknesses;
    @Column(name = "type2_job_match", columnDefinition = "TEXT") private String type2JobMatch;

    @Column(name = "holland_code", length = 2) private String hollandCode;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String answers;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;
}
