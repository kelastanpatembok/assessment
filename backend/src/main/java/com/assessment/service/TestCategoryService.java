package com.assessment.service;

import com.assessment.exception.ConflictException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.TestCategory;
import com.assessment.repository.TestCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TestCategoryService {

    private final TestCategoryRepository testCategoryRepository;

    public record TestCategoryRequest(
            String name,
            String slug,
            String description,
            String[] tests,
            BigDecimal price,
            boolean active
    ) {}

    @Transactional
    public TestCategory create(TestCategoryRequest req) {
        testCategoryRepository.findBySlug(req.slug()).ifPresent(c -> {
            throw new ConflictException("TestCategory with slug '" + req.slug() + "' already exists");
        });
        TestCategory category = TestCategory.builder()
                .name(req.name())
                .slug(req.slug())
                .description(req.description())
                .tests(req.tests())
                .price(req.price())
                .active(req.active())
                .build();
        return testCategoryRepository.save(category);
    }

    @Transactional
    public TestCategory update(Long id, TestCategoryRequest req) {
        TestCategory category = getById(id);
        testCategoryRepository.findBySlug(req.slug()).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new ConflictException("TestCategory with slug '" + req.slug() + "' already exists");
            }
        });
        category.setName(req.name());
        category.setSlug(req.slug());
        category.setDescription(req.description());
        category.setTests(req.tests());
        category.setPrice(req.price());
        category.setActive(req.active());
        return testCategoryRepository.save(category);
    }

    @Transactional(readOnly = true)
    public TestCategory getById(Long id) {
        return testCategoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("TestCategory not found: " + id));
    }

    @Transactional(readOnly = true)
    public TestCategory getBySlug(String slug) {
        return testCategoryRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("TestCategory not found: " + slug));
    }

    @Transactional(readOnly = true)
    public List<TestCategory> getAll() {
        return testCategoryRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<TestCategory> getActive() {
        return testCategoryRepository.findByActiveTrue();
    }

    @Transactional
    public void delete(Long id) {
        TestCategory category = getById(id);
        testCategoryRepository.delete(category);
    }
}
