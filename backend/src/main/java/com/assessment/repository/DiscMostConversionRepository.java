package com.assessment.repository;

import com.assessment.model.DiscMostConversion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DiscMostConversionRepository extends JpaRepository<DiscMostConversion, Integer> {
}
