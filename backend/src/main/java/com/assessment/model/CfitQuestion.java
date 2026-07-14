package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "cfit_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CfitQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "subtest_no", nullable = false)
    private Integer subtestNo;

    @Column(name = "item_no", nullable = false)
    private Integer itemNo;

    // Nullable — Subtest 2 (Classification) items have no stem image, only option images.
    @Column(name = "stem_image_url", length = 500)
    private String stemImageUrl;

    // Positional array of option image paths; the option "letter" is derived from the
    // array index (0 -> a, 1 -> b, ...), matching the legacy soal_i_q_s.opsi convention.
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "option_images", columnDefinition = "jsonb", nullable = false)
    private List<String> optionImages;

    @Column(name = "correct_answer", nullable = false, length = 1)
    private String correctAnswer;

    // Subtest 2 only: the second required correct letter (student must pick both).
    @Column(name = "correct_answer2", length = 1)
    private String correctAnswer2;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
