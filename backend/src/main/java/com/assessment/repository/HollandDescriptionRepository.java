package com.assessment.repository;

import com.assessment.model.HollandDescription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HollandDescriptionRepository extends JpaRepository<HollandDescription, Long> {
    Optional<HollandDescription> findByRiasecType(String riasecType);
    List<HollandDescription> findAll();
}
