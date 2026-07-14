package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

// Same shape as DiscMostConversion, separate table because the LEAST line's
// conversion values differ from MOST's for the same raw count.
@Entity
@Table(name = "disc_least_conversion")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscLeastConversion {
    @Id
    @Column(name = "raw_value")
    private Integer rawValue;

    @Column(name = "d_conv") private java.math.BigDecimal dConv;
    @Column(name = "i_conv") private java.math.BigDecimal iConv;
    @Column(name = "s_conv") private java.math.BigDecimal sConv;
    @Column(name = "c_conv") private java.math.BigDecimal cConv;
}
