package com.clinical.records.controller;

import com.clinical.records.dto.ApiResponse;
import com.clinical.records.dto.DashboardStatsDTO;
import com.clinical.records.entity.Patient;
import com.clinical.records.service.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<DashboardStatsDTO>> getStats() {
        DashboardStatsDTO stats = dashboardService.getStats();
        return ResponseEntity.ok(ApiResponse.ok("Dashboard statistics retrieved successfully", stats));
    }

    @GetMapping("/recent-patients")
    public ResponseEntity<ApiResponse<List<Patient>>> getRecentPatients() {
        List<Patient> recent = dashboardService.getRecentPatients();
        return ResponseEntity.ok(ApiResponse.ok("Recent patients retrieved successfully", recent));
    }
}
