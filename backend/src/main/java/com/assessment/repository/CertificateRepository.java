package com.assessment.repository;

import com.assessment.model.Certificate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CertificateRepository extends JpaRepository<Certificate, Long> {

    List<Certificate> findByAuthUserIdOrderByCreatedAtDesc(String authUserId);

    Optional<Certificate> findByAuthUserIdAndTestType(String authUserId, String testType);
}
