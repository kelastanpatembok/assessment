package com.assessment.service;

import com.assessment.exception.ConflictException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.School;
import com.assessment.repository.SchoolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SchoolService {

    private final SchoolRepository schoolRepository;

    public record SchoolRequest(
            String name,
            String address,
            String city,
            String province,
            String phone,
            String email
    ) {}

    @Transactional
    public School createSchool(SchoolRequest req) {
        schoolRepository.findByName(req.name()).ifPresent(s -> {
            throw new ConflictException("School with name '" + req.name() + "' already exists");
        });
        School school = School.builder()
                .name(req.name())
                .address(req.address())
                .city(req.city())
                .province(req.province())
                .phone(req.phone())
                .email(req.email())
                .build();
        return schoolRepository.save(school);
    }

    @Transactional
    public School updateSchool(Long id, SchoolRequest req) {
        School school = getSchool(id);
        schoolRepository.findByName(req.name()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new ConflictException("School with name '" + req.name() + "' already exists");
            }
        });
        school.setName(req.name());
        school.setAddress(req.address());
        school.setCity(req.city());
        school.setProvince(req.province());
        school.setPhone(req.phone());
        school.setEmail(req.email());
        return schoolRepository.save(school);
    }

    @Transactional(readOnly = true)
    public School getSchool(Long id) {
        return schoolRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("School not found: " + id));
    }

    @Transactional(readOnly = true)
    public List<School> getAllSchools() {
        return schoolRepository.findAll();
    }

    @Transactional
    public void deleteSchool(Long id) {
        School school = getSchool(id);
        schoolRepository.delete(school);
    }
}
