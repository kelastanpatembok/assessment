package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

// Same shape as DiscMostConversion, but rawValue ranges -22..22 since DIF is
// MOST minus LEAST per dimension and can go negative.
@Entity
@Table(name = "disc_dif_conversion")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscDifConversion {
    @Id
    @Column(name = "raw_value")
    private Integer rawValue;

    @Column(name = "d_conv") private java.math.BigDecimal dConv;
    @Column(name = "i_conv") private java.math.BigDecimal iConv;
    @Column(name = "s_conv") private java.math.BigDecimal sConv;
    @Column(name = "c_conv") private java.math.BigDecimal cConv;
}
