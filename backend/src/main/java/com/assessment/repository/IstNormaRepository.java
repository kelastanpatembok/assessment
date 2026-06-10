package com.assessment.repository;

import com.assessment.model.IstNorma;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface IstNormaRepository extends JpaRepository<IstNorma, Long> {
    Optional<IstNorma> findBySubtestCodeAndRawScore(String subtestCode, int rawScore);
    List<IstNorma> findBySubtestCode(String subtestCode);
}
