package com.assessment.repository;

import com.assessment.model.AssessmentUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AssessmentUserRepository extends JpaRepository<AssessmentUser, String>, JpaSpecificationExecutor<AssessmentUser> {
    List<AssessmentUser> findByRole(String role);
    List<AssessmentUser> findBySchoolId(Long schoolId);
    List<AssessmentUser> findByAfiliatorId(String afiliatorId);
    Optional<AssessmentUser> findByUsername(String username);
    Optional<AssessmentUser> findByEmail(String email);
    List<AssessmentUser> findTop50ByUsernameContainingIgnoreCaseOrNameContainingIgnoreCase(String username, String name);
}
