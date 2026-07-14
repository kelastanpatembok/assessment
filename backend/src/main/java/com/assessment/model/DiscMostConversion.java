package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

// Converts a raw MOST tally (0-24, clamped to the 0-20 table range) for one
// D/I/S/C dimension into its normalized value — one independent lookup per
// dimension, not a combined 4-key row. See db/migration/V11 for the source.
@Entity
@Table(name = "disc_most_conversion")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscMostConversion {
    @Id
    @Column(name = "raw_value")
    private Integer rawValue;

    @Column(name = "d_conv") private java.math.BigDecimal dConv;
    @Column(name = "i_conv") private java.math.BigDecimal iConv;
    @Column(name = "s_conv") private java.math.BigDecimal sConv;
    @Column(name = "c_conv") private java.math.BigDecimal cConv;
}
