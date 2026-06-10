package com.assessment.service;

import com.assessment.exception.BadRequestException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.FeeConfig;
import com.assessment.model.FeeShare;
import com.assessment.model.TestCategory;
import com.assessment.repository.FeeConfigRepository;
import com.assessment.repository.FeeShareRepository;
import com.assessment.repository.TestCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FeeService {

    private final FeeConfigRepository feeConfigRepository;
    private final FeeShareRepository feeShareRepository;
    private final TestCategoryRepository testCategoryRepository;

    @Transactional(readOnly = true)
    public List<FeeConfig> getAllConfigs() {
        return feeConfigRepository.findAll();
    }

    @Transactional(readOnly = true)
    public FeeConfig getConfig(Long categoryId) {
        if (categoryId != null) {
            return feeConfigRepository.findByCategoryId(categoryId)
                    .orElseGet(() -> feeConfigRepository.findByCategoryIsNull()
                            .orElseThrow(() -> new ResourceNotFoundException("No fee config found")));
        }
        return feeConfigRepository.findByCategoryIsNull()
                .orElseThrow(() -> new ResourceNotFoundException("No global fee config found"));
    }

    @Transactional
    public FeeConfig updateConfig(Long categoryId, BigDecimal studentFee, BigDecimal afiliatorPct,
                                   BigDecimal gurubkPct, BigDecimal platformPct) {
        FeeConfig config;
        if (categoryId != null) {
            TestCategory category = testCategoryRepository.findById(categoryId)
                    .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + categoryId));
            config = feeConfigRepository.findByCategoryId(categoryId).orElseGet(() ->
                    FeeConfig.builder().category(category).build());
        } else {
            config = feeConfigRepository.findByCategoryIsNull().orElseGet(() ->
                    FeeConfig.builder().build());
        }

        BigDecimal hundred = BigDecimal.valueOf(100);
        BigDecimal total = afiliatorPct.add(gurubkPct).add(platformPct);
        if (total.compareTo(hundred) > 0) {
            throw new BadRequestException("Share percentages exceed 100%");
        }

        config.setStudentFee(studentFee);
        config.setAfiliatorSharePct(afiliatorPct);
        config.setGurubkSharePct(gurubkPct);
        config.setPlatformSharePct(platformPct);
        return feeConfigRepository.save(config);
    }

    @Transactional(readOnly = true)
    public List<FeeShare> getSharesForStudent(String studentId) {
        return feeShareRepository.findByStudentId(studentId);
    }

    @Transactional(readOnly = true)
    public List<FeeShare> getSharesForAfiliator(String afiliatorId) {
        return feeShareRepository.findByAfiliatorId(afiliatorId);
    }

    @Transactional(readOnly = true)
    public BigDecimal getTotalShareForAfiliator(String afiliatorId) {
        return feeShareRepository.findByAfiliatorId(afiliatorId).stream()
                .map(FeeShare::getAfiliatorShare)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
