package com.assessment.repository;

import com.assessment.model.DiscLeastConversion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DiscLeastConversionRepository extends JpaRepository<DiscLeastConversion, Integer> {
}
