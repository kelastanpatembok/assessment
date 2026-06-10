package com.assessment.repository;

import com.assessment.model.PapiQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PapiQuestionRepository extends JpaRepository<PapiQuestion, Long> {
    List<PapiQuestion> findByActiveTrueOrderByPairNoAscItemLetterAsc();
    List<PapiQuestion> findByPairNoOrderByItemLetterAsc(Integer pairNo);
}
