package com.assessment.repository;

import com.assessment.model.DiscDifConversion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DiscDifConversionRepository extends JpaRepository<DiscDifConversion, Integer> {
}
