package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "papi_descriptions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PapiDescription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "trait_code", nullable = false, unique = true, length = 2)
    private String traitCode;

    @Column(name = "trait_name", nullable = false, length = 100)
    private String traitName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "high_desc", columnDefinition = "TEXT")
    private String highDesc;

    @Column(name = "low_desc", columnDefinition = "TEXT")
    private String lowDesc;
}
