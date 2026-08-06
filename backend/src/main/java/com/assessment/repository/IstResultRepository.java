package com.assessment.repository;

import com.assessment.model.IstResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface IstResultRepository extends JpaRepository<IstResult, Long>, JpaSpecificationExecutor<IstResult> {
    Optional<IstResult> findByAuthUserId(String authUserId);
    List<IstResult> findByAssignmentId(Long assignmentId);
    List<IstResult> findByAssignmentIdIn(Collection<Long> assignmentIds);
}
