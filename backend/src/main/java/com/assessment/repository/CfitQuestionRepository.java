package com.assessment.repository;

import com.assessment.model.CfitQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CfitQuestionRepository extends JpaRepository<CfitQuestion, Long> {
    List<CfitQuestion> findByActiveTrueOrderBySubtestNoAscItemNoAsc();
    List<CfitQuestion> findBySubtestNoAndActiveTrueOrderByItemNoAsc(Integer subtestNo);
}
