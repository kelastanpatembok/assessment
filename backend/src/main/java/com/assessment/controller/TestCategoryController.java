package com.assessment.controller;

import com.assessment.model.TestCategory;
import com.assessment.service.TestCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/test-categories")
@RequiredArgsConstructor
public class TestCategoryController {

    private final TestCategoryService testCategoryService;

    record TestCategoryRequest(String name, String slug, String description,
                               String[] tests, BigDecimal price, boolean active) {}

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<TestCategory>> list() {
        return ResponseEntity.ok(testCategoryService.getActive());
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<TestCategory> get(@PathVariable Long id) {
        return ResponseEntity.ok(testCategoryService.getById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<TestCategory> create(@RequestBody TestCategoryRequest req) {
        TestCategory category = testCategoryService.create(
                new TestCategoryService.TestCategoryRequest(
                        req.name(), req.slug(), req.description(), req.tests(), req.price(), req.active()));
        return ResponseEntity.ok(category);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<TestCategory> update(@PathVariable Long id, @RequestBody TestCategoryRequest req) {
        TestCategory category = testCategoryService.update(id,
                new TestCategoryService.TestCategoryRequest(
                        req.name(), req.slug(), req.description(), req.tests(), req.price(), req.active()));
        return ResponseEntity.ok(category);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        testCategoryService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
