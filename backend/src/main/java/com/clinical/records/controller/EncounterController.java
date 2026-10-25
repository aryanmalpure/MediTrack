package com.clinical.records.controller;

import com.clinical.records.dto.ApiResponse;
import com.clinical.records.dto.EncounterRequest;
import com.clinical.records.entity.Encounter;
import com.clinical.records.service.EncounterService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/encounters")
@CrossOrigin(origins = "*")
public class EncounterController {

    private final EncounterService encounterService;

    public EncounterController(EncounterService encounterService) {
        this.encounterService = encounterService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Encounter>> recordEncounter(@Valid @RequestBody EncounterRequest request) {
        Encounter saved = encounterService.recordEncounter(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Clinical encounter recorded successfully", saved));
    }

    @GetMapping("/patient/{patientId}")
    public ResponseEntity<ApiResponse<List<Encounter>>> getPatientEncounters(@PathVariable Long patientId) {
        List<Encounter> encounters = encounterService.getPatientEncounters(patientId);
        return ResponseEntity.ok(ApiResponse.ok("Patient encounters retrieved successfully", encounters));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Encounter>>> getAllEncounters() {
        List<Encounter> encounters = encounterService.getAllEncounters();
        return ResponseEntity.ok(ApiResponse.ok("All encounters retrieved successfully", encounters));
    }
}
