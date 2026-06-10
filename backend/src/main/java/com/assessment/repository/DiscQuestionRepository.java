package com.assessment.repository;

import com.assessment.model.DiscQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DiscQuestionRepository extends JpaRepository<DiscQuestion, Long> {
    List<DiscQuestion> findByActiveTrueOrderByBlockNoAscItemNoAsc();
    List<DiscQuestion> findByBlockNoOrderByItemNoAsc(Integer blockNo);
}
