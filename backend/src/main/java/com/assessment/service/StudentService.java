package com.assessment.service;

import com.assessment.client.AuthClient;
import com.assessment.exception.BadRequestException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.FeeConfig;
import com.assessment.model.FeeShare;
import com.assessment.model.School;
import com.assessment.model.TestCategory;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.FeeConfigRepository;
import com.assessment.repository.FeeShareRepository;
import com.assessment.repository.SchoolRepository;
import com.assessment.repository.TestCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
@RequiredArgsConstructor
public class StudentService {

    private final AuthClient authClient;
    private final ProfileService profileService;
    private final AssessmentUserRepository userRepository;
    private final FeeConfigRepository feeConfigRepository;
    private final FeeShareRepository feeShareRepository;
    private final SchoolRepository schoolRepository;
    private final TestCategoryRepository testCategoryRepository;

    @Transactional
    public AssessmentUser createStudent(String username, String email, String password,
                                        String name, Long schoolId, String afiliatorId,
                                        Long categoryId) {
        AuthClient.AuthRegisterResponse response = authClient.register(username, email, password, name, "siswa");
        String authUserId = response.user().id();

        AssessmentUser user = profileService.provisionProfile(authUserId, name, email, username, "siswa");

        School school = schoolRepository.findById(schoolId)
                .orElseThrow(() -> new ResourceNotFoundException("School not found: " + schoolId));
        user.setSchool(school);
        user.setAfiliatorId(afiliatorId);
        user = userRepository.save(user);

        String gurubkId = profileService.getAllBySchool(schoolId).stream()
                .filter(u -> "gurubk".equals(u.getRole()))
                .map(AssessmentUser::getAuthUserId)
                .findFirst()
                .orElse(null);

        FeeConfig config = feeConfigRepository.findByCategoryId(categoryId)
                .orElseGet(() -> feeConfigRepository.findByCategoryIsNull()
                        .orElseThrow(() -> new BadRequestException("No fee config found for category or global")));

        TestCategory category = testCategoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + categoryId));

        BigDecimal total = config.getStudentFee();
        BigDecimal afiliatorShare = total.multiply(config.getAfiliatorSharePct())
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal gurubkShare = total.multiply(config.getGurubkSharePct())
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal platformShare = total.multiply(config.getPlatformSharePct())
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

        FeeShare feeShare = FeeShare.builder()
                .studentId(authUserId)
                .category(category)
                .afiliatorId(afiliatorId)
                .gurubkId(gurubkId)
                .totalFee(total)
                .afiliatorShare(afiliatorShare)
                .gurubkShare(gurubkShare)
                .platformShare(platformShare)
                .build();
        feeShareRepository.save(feeShare);

        return user;
    }

    @Transactional
    public AssessmentUser createCounselor(String username, String email, String password,
                                          String name, Long schoolId) {
        AuthClient.AuthRegisterResponse response = authClient.register(username, email, password, name, "gurubk");
        String authUserId = response.user().id();

        AssessmentUser user = profileService.provisionProfile(authUserId, name, email, username, "gurubk");

        School school = schoolRepository.findById(schoolId)
                .orElseThrow(() -> new ResourceNotFoundException("School not found: " + schoolId));
        user.setSchool(school);
        return userRepository.save(user);
    }

    @Transactional
    public AssessmentUser createAfiliator(String username, String email, String password, String name) {
        AuthClient.AuthRegisterResponse response = authClient.register(username, email, password, name, "afiliator");
        String authUserId = response.user().id();
        return profileService.provisionProfile(authUserId, name, email, username, "afiliator");
    }
}
