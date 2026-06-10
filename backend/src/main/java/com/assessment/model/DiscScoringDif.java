package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "disc_scoring_dif")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DiscScoringDif {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Long id;
    @Column(name = "d_score") private Integer dScore;
    @Column(name = "i_score") private Integer iScore;
    @Column(name = "s_score") private Integer sScore;
    @Column(name = "c_score") private Integer cScore;
    @Column(nullable = false, length = 10) private String key;
}
