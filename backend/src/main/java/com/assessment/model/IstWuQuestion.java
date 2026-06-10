package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ist_wu_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstWuQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "item_no", nullable = false, unique = true)
    private Integer itemNo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String statement;

    @Column(name = "correct_answer", nullable = false, length = 10)
    private String correctAnswer;
}
