package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "cfit_descriptions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CfitDescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "score_min", nullable = false) private Integer scoreMin;
    @Column(name = "score_max", nullable = false) private Integer scoreMax;
    @Column(name = "iq_min") private Integer iqMin;
    @Column(name = "iq_max") private Integer iqMax;

    @Column(length = 50)
    private String category;

    @Column(columnDefinition = "TEXT")
    private String description;
}
