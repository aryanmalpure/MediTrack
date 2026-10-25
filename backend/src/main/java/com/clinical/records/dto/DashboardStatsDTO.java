package com.clinical.records.dto;

public class DashboardStatsDTO {
    private long totalPatients;
    private long totalEncounters;

    public DashboardStatsDTO() {
    }

    public DashboardStatsDTO(long totalPatients, long totalEncounters) {
        this.totalPatients = totalPatients;
        this.totalEncounters = totalEncounters;
    }

    public long getTotalPatients() {
        return totalPatients;
    }

    public void setTotalPatients(long totalPatients) {
        this.totalPatients = totalPatients;
    }

    public long getTotalEncounters() {
        return totalEncounters;
    }

    public void setTotalEncounters(long totalEncounters) {
        this.totalEncounters = totalEncounters;
    }
}
