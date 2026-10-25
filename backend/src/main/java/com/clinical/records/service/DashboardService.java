package com.clinical.records.service;

import com.clinical.records.dto.DashboardStatsDTO;
import com.clinical.records.entity.Patient;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DashboardService {

    private final PatientService patientService;
    private final EncounterService encounterService;

    public DashboardService(PatientService patientService, EncounterService encounterService) {
        this.patientService = patientService;
        this.encounterService = encounterService;
    }

    public DashboardStatsDTO getStats() {
        long totalPatients = patientService.getTotalPatientsCount();
        long totalEncounters = encounterService.getTotalEncountersCount();
        return new DashboardStatsDTO(totalPatients, totalEncounters);
    }

    public List<Patient> getRecentPatients() {
        return patientService.getRecentPatients();
    }
}
