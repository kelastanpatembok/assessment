package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "disc_personality_profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscPersonalityProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "most_key", nullable = false, length = 10)
    private String mostKey;

    @Column(name = "least_key", nullable = false, length = 10)
    private String leastKey;

    @Column(name = "dif_key", nullable = false, length = 10)
    private String difKey;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;
}
