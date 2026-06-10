package com.assessment.repository;

import com.assessment.model.DiscScoringDif;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DiscScoringDifRepository extends JpaRepository<DiscScoringDif, Long> {

    @Query("SELECT s FROM DiscScoringDif s WHERE s.dScore = :d AND s.iScore = :i AND s.sScore = :sv AND s.cScore = :c")
    Optional<DiscScoringDif> findByScores(@Param("d") int d, @Param("i") int i, @Param("sv") int s, @Param("c") int c);
}
