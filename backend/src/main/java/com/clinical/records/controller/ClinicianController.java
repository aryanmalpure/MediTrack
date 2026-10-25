package com.clinical.records.controller;

import com.clinical.records.dto.ApiResponse;
import com.clinical.records.entity.Clinician;
import com.clinical.records.service.ClinicianService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clinicians")
@CrossOrigin(origins = "*")
public class ClinicianController {

    private final ClinicianService clinicianService;

    public ClinicianController(ClinicianService clinicianService) {
        this.clinicianService = clinicianService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Clinician>>> getAllClinicians() {
        List<Clinician> clinicians = clinicianService.getAllClinicians();
        return ResponseEntity.ok(ApiResponse.ok("Clinicians fetched successfully", clinicians));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Clinician>> createClinician(@Valid @RequestBody Clinician clinician) {
        Clinician created = clinicianService.createClinician(clinician);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Clinician added successfully", created));
    }
}
