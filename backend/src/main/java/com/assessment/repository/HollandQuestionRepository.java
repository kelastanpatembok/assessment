package com.assessment.repository;

import com.assessment.model.HollandQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HollandQuestionRepository extends JpaRepository<HollandQuestion, Long> {
    List<HollandQuestion> findByActiveTrueOrderByRoundAscRiasecTypeAscItemNoAsc();
    List<HollandQuestion> findByRoundAndRiasecTypeOrderByItemNoAsc(Integer round, String riasecType);
}
