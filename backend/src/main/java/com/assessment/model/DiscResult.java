package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;

@Entity
@Table(name = "disc_results")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscResult implements HasAssignmentId {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "auth_user_id", nullable = false, unique = true, length = 64)
    private String authUserId;

    @Column(name = "student_name")
    private String studentName;

    @Column(name = "school_name")
    private String schoolName;

    @Column(name = "assignment_id")
    private Long assignmentId;

    @Column(name = "d_most") private Integer dMost;
    @Column(name = "i_most") private Integer iMost;
    @Column(name = "s_most") private Integer sMost;
    @Column(name = "c_most") private Integer cMost;
    @Column(name = "d_least") private Integer dLeast;
    @Column(name = "i_least") private Integer iLeast;
    @Column(name = "s_least") private Integer sLeast;
    @Column(name = "c_least") private Integer cLeast;
    @Column(name = "d_dif") private Integer dDif;
    @Column(name = "i_dif") private Integer iDif;
    @Column(name = "s_dif") private Integer sDif;
    @Column(name = "c_dif") private Integer cDif;

    // Converted (normalized) D/I/S/C values — what the classic DISC line
    // graphs plot (GRAPH 1 MOST / GRAPH 2 LEAST / GRAPH 3 CHANGE on the
    // Psikogram report), not the raw tallies above.
    @Column(name = "most_d_conv") private java.math.BigDecimal mostDConv;
    @Column(name = "most_i_conv") private java.math.BigDecimal mostIConv;
    @Column(name = "most_s_conv") private java.math.BigDecimal mostSConv;
    @Column(name = "most_c_conv") private java.math.BigDecimal mostCConv;
    @Column(name = "least_d_conv") private java.math.BigDecimal leastDConv;
    @Column(name = "least_i_conv") private java.math.BigDecimal leastIConv;
    @Column(name = "least_s_conv") private java.math.BigDecimal leastSConv;
    @Column(name = "least_c_conv") private java.math.BigDecimal leastCConv;
    @Column(name = "dif_d_conv") private java.math.BigDecimal difDConv;
    @Column(name = "dif_i_conv") private java.math.BigDecimal difIConv;
    @Column(name = "dif_s_conv") private java.math.BigDecimal difSConv;
    @Column(name = "dif_c_conv") private java.math.BigDecimal difCConv;

    @Column(name = "most_key", length = 30)  private String mostKey;
    @Column(name = "least_key", length = 30) private String leastKey;
    @Column(name = "dif_key", length = 30)   private String difKey;

    // DIF pattern ("Kepribadian Asli / Sesungguhnya") — the headline result
    @Column(name = "profile_title", length = 100) private String profileTitle;
    @Column(name = "profile_desc", columnDefinition = "TEXT") private String profileDesc;
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "dif_profile_traits", columnDefinition = "jsonb")
    private String difProfileTraits;
    @Column(name = "job_recommendations", columnDefinition = "TEXT") private String jobRecommendations;

    // MOST pattern ("Kepribadian Saat di Publik")
    @Column(name = "most_profile_title", length = 100) private String mostProfileTitle;
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "most_profile_traits", columnDefinition = "jsonb")
    private String mostProfileTraits;

    // LEAST pattern ("Kepribadian Saat Mendapat Tekanan")
    @Column(name = "least_profile_title", length = 100) private String leastProfileTitle;
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "least_profile_traits", columnDefinition = "jsonb")
    private String leastProfileTraits;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String answers;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;
}
