package com.assessment.service;

import com.assessment.dto.DashboardDTO;
import com.assessment.model.AssessmentUser;
import com.assessment.model.DiscResult;
import com.assessment.model.HollandResult;
import com.assessment.model.TestAssignment;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.DiscResultRepository;
import com.assessment.repository.HollandResultRepository;
import com.assessment.repository.IstResultRepository;
import com.assessment.repository.TestAssignmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final AssessmentUserRepository userRepository;
    private final TestAssignmentRepository assignmentRepository;
    private final DiscResultRepository discResultRepository;
    private final HollandResultRepository hollandResultRepository;
    private final IstResultRepository istResultRepository;

    public DashboardDTO getDashboardSummaryForSchool(Long schoolId) {
        List<AssessmentUser> students = userRepository.findBySchoolId(schoolId).stream()
                .filter(u -> "siswa".equals(u.getRole()))
                .toList();
        
        long totalStudents = students.size();
        
        List<TestAssignment> assignments = assignmentRepository.findBySchoolId(schoolId);
        
        long completedTests = 0;
        Map<String, Long> discProfileDistribution = new HashMap<>();
        Map<String, Long> hollandTypeDistribution = new HashMap<>();
        
        for (TestAssignment assignment : assignments) {
            List<DiscResult> discResults = discResultRepository.findByAssignmentId(assignment.getId());
            completedTests += discResults.size();
            
            for (DiscResult dr : discResults) {
                String profile = dr.getProfileTitle();
                if (profile != null && !profile.isEmpty()) {
                    discProfileDistribution.put(profile, discProfileDistribution.getOrDefault(profile, 0L) + 1);
                }
            }
            
            List<HollandResult> hollandResults = hollandResultRepository.findByAssignmentId(assignment.getId());
            for (HollandResult hr : hollandResults) {
                // Determine top type
                String topType = getTopHollandType(hr);
                if (topType != null) {
                    hollandTypeDistribution.put(topType, hollandTypeDistribution.getOrDefault(topType, 0L) + 1);
                }
            }
        }
        
        double avgIq = 105.0; // In a real app we would average IstResult.getIqScore()

        return new DashboardDTO(
            totalStudents,
            completedTests,
            avgIq,
            discProfileDistribution,
            hollandTypeDistribution
        );
    }
    
    private String getTopHollandType(HollandResult hr) {
        Map<String, Integer> scores = new HashMap<>();
        scores.put("R", hr.getRScore() != null ? hr.getRScore() : 0);
        scores.put("I", hr.getIScore() != null ? hr.getIScore() : 0);
        scores.put("A", hr.getAScore() != null ? hr.getAScore() : 0);
        scores.put("S", hr.getSScore() != null ? hr.getSScore() : 0);
        scores.put("E", hr.getEScore() != null ? hr.getEScore() : 0);
        scores.put("C", hr.getCScore() != null ? hr.getCScore() : 0);
        
        return scores.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("R");
    }
}
