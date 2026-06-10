package com.assessment.repository;

import com.assessment.model.DiscPersonalityProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DiscPersonalityProfileRepository extends JpaRepository<DiscPersonalityProfile, Long> {
    Optional<DiscPersonalityProfile> findByMostKeyAndLeastKeyAndDifKey(String mostKey, String leastKey, String difKey);
}
