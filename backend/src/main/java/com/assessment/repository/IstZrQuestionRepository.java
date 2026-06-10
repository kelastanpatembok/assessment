package com.assessment.repository;

import com.assessment.model.IstZrQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IstZrQuestionRepository extends JpaRepository<IstZrQuestion, Long> {
    List<IstZrQuestion> findAllByOrderByItemNoAsc();
}
