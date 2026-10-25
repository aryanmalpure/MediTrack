package com.clinical.records.controller;

import com.clinical.records.dto.ApiResponse;
import com.clinical.records.dto.PatientDetailsDTO;
import com.clinical.records.entity.Patient;
import com.clinical.records.service.PatientService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/patients")
@CrossOrigin(origins = "*")
public class PatientController {

    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Patient>>> getAllPatients(@RequestParam(required = false) String search) {
        List<Patient> patients;
        if (search != null && !search.trim().isEmpty()) {
            patients = patientService.searchPatients(search);
        } else {
            patients = patientService.getAllPatients();
        }
        return ResponseEntity.ok(ApiResponse.ok("Patients fetched successfully", patients));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Patient>> getPatientById(@PathVariable Long id) {
        Patient patient = patientService.getPatientById(id);
        return ResponseEntity.ok(ApiResponse.ok("Patient details fetched successfully", patient));
    }

    @GetMapping("/{id}/details")
    public ResponseEntity<ApiResponse<PatientDetailsDTO>> getPatientDetails(@PathVariable Long id) {
        PatientDetailsDTO details = patientService.getPatientDetails(id);
        return ResponseEntity.ok(ApiResponse.ok("Full patient clinical history retrieved successfully", details));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Patient>> createPatient(@Valid @RequestBody Patient patient) {
        Patient created = patientService.createPatient(patient);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Patient registered successfully", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Patient>> updatePatient(@PathVariable Long id, @Valid @RequestBody Patient patient) {
        Patient updated = patientService.updatePatient(id, patient);
        return ResponseEntity.ok(ApiResponse.ok("Patient information updated successfully", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePatient(@PathVariable Long id) {
        patientService.deletePatient(id);
        return ResponseEntity.ok(ApiResponse.ok("Patient record deleted successfully"));
    }
}
