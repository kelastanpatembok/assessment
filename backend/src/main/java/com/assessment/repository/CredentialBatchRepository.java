package com.assessment.repository;

import com.assessment.model.CredentialBatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CredentialBatchRepository extends JpaRepository<CredentialBatch, Long>, JpaSpecificationExecutor<CredentialBatch> {
    List<CredentialBatch> findByTestAssignmentIdOrderByCreatedAtDesc(Long testAssignmentId);
    List<CredentialBatch> findAllByOrderByCreatedAtDesc();
    Optional<CredentialBatch> findFirstByTestAssignmentIdOrderByCreatedAtDesc(Long testAssignmentId);
}
