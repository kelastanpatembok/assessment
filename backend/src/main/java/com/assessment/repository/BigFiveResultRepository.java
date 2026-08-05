package com.assessment.repository;

import com.assessment.model.BigFiveResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BigFiveResultRepository extends JpaRepository<BigFiveResult, Long> {
    Optional<BigFiveResult> findByAuthUserId(String authUserId);
}
