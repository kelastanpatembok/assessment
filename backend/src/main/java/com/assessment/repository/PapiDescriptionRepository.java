package com.assessment.repository;

import com.assessment.model.PapiDescription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PapiDescriptionRepository extends JpaRepository<PapiDescription, Long> {
    Optional<PapiDescription> findByTraitCode(String traitCode);
    List<PapiDescription> findAll();
}
