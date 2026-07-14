package com.assessment.repository;

import com.assessment.model.CredentialBatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CredentialBatchRepository extends JpaRepository<CredentialBatch, Long> {
    List<CredentialBatch> findByTestAssignmentIdOrderByCreatedAtDesc(Long testAssignmentId);
    List<CredentialBatch> findAllByOrderByCreatedAtDesc();
}
