package com.assessment.repository;

import com.assessment.model.CfitResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CfitResultRepository extends JpaRepository<CfitResult, Long> {
    Optional<CfitResult> findByAuthUserId(String authUserId);
    List<CfitResult> findByAssignmentId(Long assignmentId);
}
