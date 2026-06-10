package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ist_norma")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstNorma {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "subtest_code", nullable = false, length = 3)
    private String subtestCode;

    @Column(name = "raw_score", nullable = false)
    private Integer rawScore;

    @Column(nullable = false)
    private Integer wert;
}
