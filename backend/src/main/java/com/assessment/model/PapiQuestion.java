package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "papi_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PapiQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "pair_no", nullable = false)
    private Integer pairNo;

    @Column(name = "item_letter", nullable = false, length = 1)
    private String itemLetter;

    @Column(name = "trait_code", nullable = false, length = 2)
    private String traitCode;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String statement;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
