package com.assessment.repository;

import com.assessment.model.PapiResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PapiResultRepository extends JpaRepository<PapiResult, Long> {
    Optional<PapiResult> findByAuthUserId(String authUserId);
    List<PapiResult> findByAssignmentId(Long assignmentId);
}
