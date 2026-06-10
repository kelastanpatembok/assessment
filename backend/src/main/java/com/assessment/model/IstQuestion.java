package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "ist_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "subtest_code", nullable = false, length = 3)
    private String subtestCode;

    @Column(name = "item_no", nullable = false)
    private Integer itemNo;

    @Column(name = "question_text", columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String options;

    @Column(name = "correct_answer", length = 20)
    private String correctAnswer;

    @Column(name = "time_limit_sec")
    private Integer timeLimitSec;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
