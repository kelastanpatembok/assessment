package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.School;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.SchoolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final AssessmentUserRepository userRepository;
    private final SchoolRepository schoolRepository;

    @Transactional
    public AssessmentUser provisionProfile(String authUserId, String name, String email,
                                           String username, String role) {
        return userRepository.findById(authUserId).orElseGet(() -> {
            AssessmentUser user = AssessmentUser.builder()
                    .authUserId(authUserId)
                    .name(name)
                    .email(email)
                    .username(username)
                    .role(role)
                    .build();
            return userRepository.save(user);
        });
    }

    @Transactional(readOnly = true)
    public AssessmentUser getProfile(String authUserId) {
        return userRepository.findById(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + authUserId));
    }

    @Transactional
    public AssessmentUser updateProfileSchool(String authUserId, Long schoolId) {
        AssessmentUser user = getProfile(authUserId);
        School school = schoolRepository.findById(schoolId)
                .orElseThrow(() -> new ResourceNotFoundException("School not found: " + schoolId));
        user.setSchool(school);
        return userRepository.save(user);
    }

    @Transactional(readOnly = true)
    public List<AssessmentUser> getAllByRole(String role) {
        return userRepository.findByRole(role);
    }

    @Transactional(readOnly = true)
    public List<AssessmentUser> getAllBySchool(Long schoolId) {
        return userRepository.findBySchoolId(schoolId);
    }

    @Transactional(readOnly = true)
    public List<AssessmentUser> getAllByAfiliator(String afiliatorId) {
        return userRepository.findByAfiliatorId(afiliatorId);
    }
}
