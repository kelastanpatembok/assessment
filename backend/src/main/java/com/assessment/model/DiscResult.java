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
public class DiscResult {

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

    @Column(name = "most_key", length = 10)  private String mostKey;
    @Column(name = "least_key", length = 10) private String leastKey;
    @Column(name = "dif_key", length = 10)   private String difKey;

    @Column(name = "profile_title", length = 100) private String profileTitle;
    @Column(name = "profile_desc", columnDefinition = "TEXT") private String profileDesc;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String answers;

    @Column(name = "completed_at", nullable = false)
    private LocalDateTime completedAt;
}
