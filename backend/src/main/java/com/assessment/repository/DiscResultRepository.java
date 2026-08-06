package com.assessment.repository;

import com.assessment.model.DiscResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface DiscResultRepository extends JpaRepository<DiscResult, Long>, JpaSpecificationExecutor<DiscResult> {
    Optional<DiscResult> findByAuthUserId(String authUserId);
    List<DiscResult> findByAssignmentId(Long assignmentId);
    List<DiscResult> findByAssignmentIdIn(Collection<Long> assignmentIds);
}
