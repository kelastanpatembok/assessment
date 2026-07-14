package com.assessment.repository;

import com.assessment.model.DiscPatternProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DiscPatternProfileRepository extends JpaRepository<DiscPatternProfile, Long> {
    Optional<DiscPatternProfile> findByPatternIndex(Integer patternIndex);
}
