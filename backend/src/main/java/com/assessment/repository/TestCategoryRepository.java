package com.assessment.repository;

import com.assessment.model.TestCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TestCategoryRepository extends JpaRepository<TestCategory, Long>, JpaSpecificationExecutor<TestCategory> {
    Optional<TestCategory> findBySlug(String slug);
    List<TestCategory> findByActiveTrue();
}
