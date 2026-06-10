package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "disc_questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiscQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "block_no", nullable = false)
    private Integer blockNo;

    @Column(name = "item_no", nullable = false)
    private Integer itemNo;

    @Column(nullable = false, length = 1)
    private String category;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String statement;

    @Column(name = "is_active", nullable = false)
    private boolean active;
}
