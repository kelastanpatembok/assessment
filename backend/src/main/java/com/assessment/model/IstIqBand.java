package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ist_iq_bands")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstIqBand {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "wert_min", nullable = false) private Integer wertMin;
    @Column(name = "wert_max", nullable = false) private Integer wertMax;
    @Column(name = "iq_min", nullable = false)   private Integer iqMin;
    @Column(name = "iq_max", nullable = false)   private Integer iqMax;

    @Column(length = 50)
    private String category;
}
