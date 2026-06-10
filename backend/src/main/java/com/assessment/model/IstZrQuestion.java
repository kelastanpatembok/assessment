package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ist_zr_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstZrQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "item_no", nullable = false, unique = true)
    private Integer itemNo;

    @Column(name = "sequence_text", nullable = false, columnDefinition = "TEXT")
    private String sequenceText;

    @Column(name = "correct_answer", nullable = false)
    private Integer correctAnswer;
}
