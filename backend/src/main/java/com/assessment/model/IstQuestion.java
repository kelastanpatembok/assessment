package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;
import java.util.Map;

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

    // Stem image — used by FA/WU (image-based subtests); null for text subtests.
    @Column(name = "image_url", length = 500)
    private String imageUrl;

    // Text MC options (lettered map), used by SE/WA/AN/GE/RA/ME when they have options.
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> options;

    // Positional array of option image paths, used by FA/WU — letter derived from
    // array index (0 -> a, 1 -> b, ...), same convention as cfit_questions.option_images.
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "option_images", columnDefinition = "jsonb")
    private List<String> optionImages;

    @Column(name = "correct_answer", length = 20)
    private String correctAnswer;

    @Column(name = "time_limit_sec")
    private Integer timeLimitSec;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
