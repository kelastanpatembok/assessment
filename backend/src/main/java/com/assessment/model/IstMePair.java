package com.assessment.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "ist_me_pairs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IstMePair {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "item_no", nullable = false, unique = true)
    private Integer itemNo;

    @Column(nullable = false, length = 100) private String word1;
    @Column(nullable = false, length = 100) private String word2;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String options;

    @Column(name = "correct_answer", nullable = false, length = 50)
    private String correctAnswer;
}
