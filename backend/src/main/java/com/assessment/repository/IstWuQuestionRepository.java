package com.assessment.repository;

import com.assessment.model.IstWuQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IstWuQuestionRepository extends JpaRepository<IstWuQuestion, Long> {
    List<IstWuQuestion> findAllByOrderByItemNoAsc();
}
