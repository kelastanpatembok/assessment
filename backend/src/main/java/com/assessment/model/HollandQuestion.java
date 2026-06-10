package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "holland_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HollandQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "group_code", nullable = false, length = 3)
    private String groupCode;

    @Column(name = "item_no", nullable = false)
    private Integer itemNo;

    @Column(name = "riasec_type", nullable = false, length = 1)
    private String riasecType;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String statement;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
