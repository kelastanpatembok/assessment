package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.common.Specs;
import com.assessment.dto.PageResponse;
import com.assessment.model.School;
import com.assessment.repository.SchoolRepository;
import com.assessment.service.SchoolService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/schools")
@RequiredArgsConstructor
public class SchoolController {

    private final SchoolService schoolService;
    private final SchoolRepository schoolRepository;

    record SchoolRequest(String name, String address, String city, String province, String phone, String email) {}

    @PostMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<School> create(@RequestBody SchoolRequest req) {
        School school = schoolService.createSchool(
                new SchoolService.SchoolRequest(req.name(), req.address(), req.city(), req.province(), req.phone(), req.email()));
        return ResponseEntity.ok(school);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<?> list(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order) {
        Specification<School> spec = Specs.like(search, "name", "address", "city", "province");
        if (Paging.paginated(page, size)) {
            Page<School> result = schoolRepository.findAll(spec,
                    Paging.pageable(page, size, sort, order, "name", "name", "city", "province", "createdAt"));
            return ResponseEntity.ok(PageResponse.from(result));
        }
        return ResponseEntity.ok(schoolService.getAllSchools());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<School> get(@PathVariable Long id) {
        return ResponseEntity.ok(schoolService.getSchool(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<School> update(@PathVariable Long id, @RequestBody SchoolRequest req) {
        School school = schoolService.updateSchool(id,
                new SchoolService.SchoolRequest(req.name(), req.address(), req.city(), req.province(), req.phone(), req.email()));
        return ResponseEntity.ok(school);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        schoolService.deleteSchool(id);
        return ResponseEntity.noContent().build();
    }
}
