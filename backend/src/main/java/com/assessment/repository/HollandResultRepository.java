package com.assessment.repository;

import com.assessment.model.HollandResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HollandResultRepository extends JpaRepository<HollandResult, Long> {
    Optional<HollandResult> findByAuthUserId(String authUserId);
    List<HollandResult> findByAssignmentId(Long assignmentId);
}
