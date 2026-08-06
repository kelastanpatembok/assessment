package com.assessment.repository;

import com.assessment.model.School;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SchoolRepository extends JpaRepository<School, Long>, JpaSpecificationExecutor<School> {
    List<School> findByProvince(String province);
    Optional<School> findByName(String name);
}
