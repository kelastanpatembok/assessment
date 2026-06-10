package com.assessment.repository;

import com.assessment.model.CfitDescription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CfitDescriptionRepository extends JpaRepository<CfitDescription, Long> {
    Optional<CfitDescription> findByScoreMinLessThanEqualAndScoreMaxGreaterThanEqual(int score, int score2);
}
