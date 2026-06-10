package com.assessment.repository;

import com.assessment.model.TestAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TestAssignmentRepository extends JpaRepository<TestAssignment, Long> {
    List<TestAssignment> findBySchoolId(Long schoolId);
    List<TestAssignment> findByStudentAuthUserId(String studentId);
    List<TestAssignment> findByCategoryId(Long categoryId);

    @Query("SELECT a FROM TestAssignment a WHERE (a.school.id = :schoolId OR a.student.authUserId = :studentId) AND a.active = true AND (a.windowEnd IS NULL OR a.windowEnd >= :now)")
    List<TestAssignment> findActiveForStudent(@Param("schoolId") Long schoolId, @Param("studentId") String studentId, @Param("now") LocalDateTime now);
}
