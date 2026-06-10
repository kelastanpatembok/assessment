package com.assessment.repository;

import com.assessment.model.IstIqBand;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IstIqBandRepository extends JpaRepository<IstIqBand, Long> {
    @Query("SELECT b FROM IstIqBand b WHERE b.wertMin <= :wert AND b.wertMax >= :wert")
    Optional<IstIqBand> findByWert(@Param("wert") int wert);
}
