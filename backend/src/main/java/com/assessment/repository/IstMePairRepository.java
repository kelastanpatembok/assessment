package com.assessment.repository;

import com.assessment.model.IstMePair;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IstMePairRepository extends JpaRepository<IstMePair, Long> {
    List<IstMePair> findAllByOrderByItemNoAsc();
}
