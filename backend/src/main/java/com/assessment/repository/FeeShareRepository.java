package com.assessment.repository;

import com.assessment.model.FeeShare;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FeeShareRepository extends JpaRepository<FeeShare, Long> {
    List<FeeShare> findByStudentId(String studentId);
    List<FeeShare> findByAfiliatorId(String afiliatorId);
    List<FeeShare> findByGurubkId(String gurubkId);
    List<FeeShare> findByCategoryId(Long categoryId);
}
