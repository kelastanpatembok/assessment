package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "holland_descriptions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HollandDescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "riasec_type", nullable = false, unique = true, length = 1)
    private String riasecType;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String characteristics;

    @Column(columnDefinition = "TEXT")
    private String strengths;

    @Column(columnDefinition = "TEXT")
    private String weaknesses;

    @Column(name = "job_match", columnDefinition = "TEXT")
    private String jobMatch;
}
