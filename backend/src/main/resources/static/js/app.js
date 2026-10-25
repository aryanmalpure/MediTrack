const API_BASE = '/api';

let editingPatientId = null;

document.addEventListener('DOMContentLoaded', () => {
    setupNavigation();
    setupPatientForm();
    setupClinicianForm();
    setupEncounterForm();
    setupSearch();

    resetEncounterDate();

    loadDashboard();
    loadCliniciansDropdown();
    loadPatientsDropdown();
});

function setupNavigation() {
    const navLinks = document.querySelectorAll('nav ul li a');
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const targetTab = link.getAttribute('data-tab');
            switchTab(targetTab);
        });
    });
}

function switchTab(tabId) {
    document.querySelectorAll('nav ul li a').forEach(a => {
        if (a.getAttribute('data-tab') === tabId) {
            a.classList.add('active');
        } else {
            a.classList.remove('active');
        }
    });

    document.querySelectorAll('.tab-section').forEach(sec => {
        if (sec.id === tabId) {
            sec.classList.add('active');
        } else {
            sec.classList.remove('active');
        }
    });

    if (tabId === 'dashboard') {
        loadDashboard();
    } else if (tabId === 'patients') {
        loadPatients();
    } else if (tabId === 'clinicians') {
        loadClinicians();
    } else if (tabId === 'encounters') {
        loadCliniciansDropdown();
        loadPatientsDropdown();
        loadAllEncounters();
    }
}

function showAlert(message, type = 'success') {
    const alertBox = document.getElementById('global-alert');
    alertBox.textContent = message;
    alertBox.className = 'alert-box alert-' + type;
    alertBox.style.display = 'block';

    setTimeout(() => {
        alertBox.style.display = 'none';
    }, 6000);
}

async function loadDashboard() {
    try {
        const statsRes = await fetch(`${API_BASE}/dashboard/stats`);
        const statsJson = await statsRes.json();
        if (statsJson.success) {
            document.getElementById('stat-total-patients').textContent = statsJson.data.totalPatients;
            document.getElementById('stat-total-encounters').textContent = statsJson.data.totalEncounters;
        }

        const recentRes = await fetch(`${API_BASE}/dashboard/recent-patients`);
        const recentJson = await recentRes.json();
        const tbody = document.getElementById('recent-patients-tbody');
        tbody.innerHTML = '';

        if (recentJson.success && recentJson.data.length > 0) {
            recentJson.data.forEach(p => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>#${p.patientId}</strong></td>
                    <td>${escapeHtml(p.name)}</td>
                    <td>${p.dateOfBirth}</td>
                    <td>${escapeHtml(p.gender)}</td>
                    <td>${escapeHtml(p.bloodGroup || 'N/A')}</td>
                    <td>
                        <button class="btn btn-secondary btn-sm" onclick="viewPatientDetails(${p.patientId})">View Details</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        } else {
            tbody.innerHTML = `<tr><td colspan="6" class="no-data">No registered patients found.</td></tr>`;
        }
    } catch (err) {
        console.error('Error loading dashboard:', err);
    }
}

async function loadPatients(searchQuery = '') {
    try {
        let url = `${API_BASE}/patients`;
        if (searchQuery && searchQuery.trim() !== '') {
            url += `?search=${encodeURIComponent(searchQuery.trim())}`;
        }

        const res = await fetch(url);
        const json = await res.json();
        const tbody = document.getElementById('patients-tbody');
        tbody.innerHTML = '';

        if (json.success && json.data.length > 0) {
            json.data.forEach(p => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>#${p.patientId}</strong></td>
                    <td>${escapeHtml(p.name)}</td>
                    <td>${p.dateOfBirth}</td>
                    <td>${escapeHtml(p.gender)}</td>
                    <td>${escapeHtml(p.phone || 'N/A')}</td>
                    <td>${escapeHtml(p.bloodGroup || 'N/A')}</td>
                    <td>
                        <div class="btn-group">
                            <button class="btn btn-primary btn-sm" onclick="viewPatientDetails(${p.patientId})">Details</button>
                            <button class="btn btn-secondary btn-sm" onclick="startEditPatient(${p.patientId})">Edit</button>
                            <button class="btn btn-danger btn-sm" onclick="deletePatient(${p.patientId}, '${escapeHtml(p.name)}')">Delete</button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        } else {
            tbody.innerHTML = `<tr><td colspan="7" class="no-data">No patients found.</td></tr>`;
        }
    } catch (err) {
        showAlert('Failed to fetch patients from server: ' + err.message, 'error');
    }
}

function setupSearch() {
    const searchInput = document.getElementById('patient-search-input');
    const searchBtn = document.getElementById('patient-search-btn');
    const resetBtn = document.getElementById('patient-reset-btn');

    searchBtn.addEventListener('click', () => {
        loadPatients(searchInput.value);
    });

    searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            loadPatients(searchInput.value);
        }
    });

    resetBtn.addEventListener('click', () => {
        searchInput.value = '';
        loadPatients();
    });
}

function setupPatientForm() {
    const form = document.getElementById('patient-form');
    const toggleBtn = document.getElementById('toggle-patient-form-btn');
    const cancelBtn = document.getElementById('cancel-patient-form-btn');
    const formPanel = document.getElementById('patient-form-panel');

    toggleBtn.addEventListener('click', () => {
        resetPatientForm();
        formPanel.style.display = formPanel.style.display === 'none' ? 'block' : 'none';
    });

    cancelBtn.addEventListener('click', () => {
        resetPatientForm();
        formPanel.style.display = 'none';
    });

    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const patientData = {
            name: document.getElementById('patient-name').value.trim(),
            dateOfBirth: document.getElementById('patient-dob').value,
            gender: document.getElementById('patient-gender').value,
            phone: document.getElementById('patient-phone').value.trim(),
            address: document.getElementById('patient-address').value.trim(),
            bloodGroup: document.getElementById('patient-blood-group').value
        };

        if (!patientData.name || !patientData.dateOfBirth || !patientData.gender) {
            showAlert('Please fill in all mandatory fields (Name, Date of Birth, Gender).', 'error');
            return;
        }

        try {
            let res;
            if (editingPatientId) {
                res = await fetch(`${API_BASE}/patients/${editingPatientId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(patientData)
                });
            } else {
                res = await fetch(`${API_BASE}/patients`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(patientData)
                });
            }

            const json = await res.json();
            if (res.ok && json.success) {
                showAlert(editingPatientId ? 'Patient information updated successfully.' : 'New patient registered successfully.', 'success');
                resetPatientForm();
                formPanel.style.display = 'none';
                loadPatients();
                loadPatientsDropdown();
                loadDashboard();
            } else {
                showAlert(json.message || 'Operation failed.', 'error');
            }
        } catch (err) {
            showAlert('Error submitting patient form: ' + err.message, 'error');
        }
    });
}

async function startEditPatient(id) {
    try {
        const res = await fetch(`${API_BASE}/patients/${id}`);
        const json = await res.json();
        if (json.success) {
            const p = json.data;
            editingPatientId = p.patientId;
            document.getElementById('patient-form-title').textContent = `Edit Patient Details (ID #${p.patientId})`;
            document.getElementById('patient-name').value = p.name;
            document.getElementById('patient-dob').value = p.dateOfBirth;
            document.getElementById('patient-gender').value = p.gender;
            document.getElementById('patient-phone').value = p.phone || '';
            document.getElementById('patient-address').value = p.address || '';
            document.getElementById('patient-blood-group').value = p.bloodGroup || '';
            document.getElementById('save-patient-btn').textContent = 'Update Patient';

            const formPanel = document.getElementById('patient-form-panel');
            formPanel.style.display = 'block';
            formPanel.scrollIntoView({ behavior: 'smooth' });
        }
    } catch (err) {
        showAlert('Could not load patient details for editing.', 'error');
    }
}

function resetPatientForm() {
    editingPatientId = null;
    document.getElementById('patient-form').reset();
    document.getElementById('patient-form-title').textContent = 'Register New Patient';
    document.getElementById('save-patient-btn').textContent = 'Save Patient';
}

async function deletePatient(id, name) {
    if (!confirm(`Are you sure you want to delete patient #${id} (${name})?\n\nNote: If this patient has clinical records or encounters, the deletion will be rejected to maintain database referential integrity.`)) {
        return;
    }

    try {
        const res = await fetch(`${API_BASE}/patients/${id}`, {
            method: 'DELETE'
        });
        const json = await res.json();

        if (res.ok && json.success) {
            showAlert(`Patient #${id} (${name}) was successfully deleted.`, 'success');
            loadPatients();
            loadPatientsDropdown();
            loadDashboard();
        } else {
            showAlert(json.message || 'Failed to delete patient.', 'error');
        }
    } catch (err) {
        showAlert('Network or server error while deleting patient: ' + err.message, 'error');
    }
}

async function loadClinicians() {
    try {
        const res = await fetch(`${API_BASE}/clinicians`);
        const json = await res.json();
        const tbody = document.getElementById('clinicians-tbody');
        tbody.innerHTML = '';

        if (json.success && json.data.length > 0) {
            json.data.forEach(c => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>#${c.clinicianId}</strong></td>
                    <td>${escapeHtml(c.name)}</td>
                    <td>${escapeHtml(c.specialty)}</td>
                `;
                tbody.appendChild(tr);
            });
        } else {
            tbody.innerHTML = `<tr><td colspan="3" class="no-data">No clinicians found.</td></tr>`;
        }
    } catch (err) {
        showAlert('Failed to load clinicians: ' + err.message, 'error');
    }
}

function setupClinicianForm() {
    const form = document.getElementById('clinician-form');
    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const name = document.getElementById('clinician-name').value.trim();
        const specialty = document.getElementById('clinician-specialty').value.trim();

        if (!name || !specialty) {
            showAlert('Please enter both clinician name and specialty.', 'error');
            return;
        }

        try {
            const res = await fetch(`${API_BASE}/clinicians`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, specialty })
            });
            const json = await res.json();

            if (res.ok && json.success) {
                showAlert('Clinician added successfully.', 'success');
                form.reset();
                loadClinicians();
                loadCliniciansDropdown();
            } else {
                showAlert(json.message || 'Failed to add clinician.', 'error');
            }
        } catch (err) {
            showAlert('Error submitting clinician form: ' + err.message, 'error');
        }
    });
}

async function loadCliniciansDropdown() {
    try {
        const res = await fetch(`${API_BASE}/clinicians`);
        const json = await res.json();
        const select = document.getElementById('encounter-clinician-select');
        select.innerHTML = '<option value="">-- Select Clinician --</option>';

        if (json.success && json.data.length > 0) {
            json.data.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.clinicianId;
                opt.textContent = `${c.name} (${c.specialty})`;
                select.appendChild(opt);
            });
        }
    } catch (err) {
        console.error('Error populating clinicians dropdown:', err);
    }
}

async function loadPatientsDropdown() {
    try {
        const res = await fetch(`${API_BASE}/patients`);
        const json = await res.json();
        const select = document.getElementById('encounter-patient-select');
        select.innerHTML = '<option value="">-- Select Patient --</option>';

        if (json.success && json.data.length > 0) {
            json.data.forEach(p => {
                const opt = document.createElement('option');
                opt.value = p.patientId;
                opt.textContent = `#${p.patientId} - ${p.name} (DOB: ${p.dateOfBirth})`;
                select.appendChild(opt);
            });
        }
    } catch (err) {
        console.error('Error populating patients dropdown:', err);
    }
}

function resetEncounterDate() {
    const dateInput = document.getElementById('encounter-date');
    if (dateInput) {
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        dateInput.value = now.toISOString().slice(0, 16);
    }
}

function setupEncounterForm() {
    const form = document.getElementById('encounter-form');
    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const patientId = document.getElementById('encounter-patient-select').value;
        const clinicianId = document.getElementById('encounter-clinician-select').value;
        const encounterDateVal = document.getElementById('encounter-date').value;
        const symptoms = document.getElementById('encounter-symptoms').value.trim();
        const diagnosis = document.getElementById('encounter-diagnosis').value.trim();
        const treatmentNotes = document.getElementById('encounter-notes').value.trim();

        if (!patientId || !clinicianId || !encounterDateVal || !diagnosis) {
            showAlert('Please select a patient, clinician, date, and provide a diagnosis.', 'error');
            return;
        }

        const encounterData = {
            patientId: parseInt(patientId),
            clinicianId: parseInt(clinicianId),
            encounterDate: encounterDateVal,
            symptoms: symptoms,
            diagnosis: diagnosis,
            treatmentNotes: treatmentNotes
        };

        try {
            const res = await fetch(`${API_BASE}/encounters`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(encounterData)
            });
            const json = await res.json();

            if (res.ok && json.success) {
                showAlert('Clinical encounter recorded successfully.', 'success');
                form.reset();
                resetEncounterDate();
                loadDashboard();
                loadAllEncounters();
            } else {
                showAlert(json.message || 'Failed to record encounter.', 'error');
            }
        } catch (err) {
            showAlert('Error recording encounter: ' + err.message, 'error');
        }
    });
}

async function loadAllEncounters() {
    try {
        const res = await fetch(`${API_BASE}/encounters`);
        const json = await res.json();
        const tbody = document.getElementById('all-encounters-tbody');
        tbody.innerHTML = '';

        if (json.success && json.data.length > 0) {
            json.data.sort((a, b) => new Date(b.encounterDate) - new Date(a.encounterDate));
            json.data.forEach(e => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>#${e.encounterId}</strong></td>
                    <td>${formatDateTime(e.encounterDate)}</td>
                    <td><a href="#" onclick="viewPatientDetails(${e.patient.patientId}); return false;">${escapeHtml(e.patient.name)} (#${e.patient.patientId})</a></td>
                    <td>${escapeHtml(e.clinician.name)} (${escapeHtml(e.clinician.specialty)})</td>
                    <td><strong>${escapeHtml(e.diagnosis)}</strong></td>
                    <td>${escapeHtml(e.symptoms || '-')}</td>
                    <td>${escapeHtml(e.treatmentNotes || '-')}</td>
                `;
                tbody.appendChild(tr);
            });
        } else {
            tbody.innerHTML = `<tr><td colspan="7" class="no-data">No encounters recorded yet.</td></tr>`;
        }
    } catch (err) {
        console.error('Error loading encounters:', err);
    }
}

async function viewPatientDetails(patientId) {
    try {
        const res = await fetch(`${API_BASE}/patients/${patientId}/details`);
        const json = await res.json();

        if (!res.ok || !json.success) {
            showAlert(json.message || 'Could not fetch patient details.', 'error');
            return;
        }

        const data = json.data;
        const p = data.patient;

        switchTab('patient-details');

        const masterContainer = document.getElementById('patient-master-info');
        masterContainer.innerHTML = `
            <div class="detail-item"><strong>Patient ID</strong> #${p.patientId}</div>
            <div class="detail-item"><strong>Full Name</strong> ${escapeHtml(p.name)}</div>
            <div class="detail-item"><strong>Date of Birth</strong> ${p.dateOfBirth} (Age: ${calculateAge(p.dateOfBirth)})</div>
            <div class="detail-item"><strong>Gender</strong> ${escapeHtml(p.gender)}</div>
            <div class="detail-item"><strong>Blood Group</strong> ${escapeHtml(p.bloodGroup || 'N/A')}</div>
            <div class="detail-item"><strong>Phone</strong> ${escapeHtml(p.phone || 'N/A')}</div>
            <div class="detail-item"><strong>Address</strong> ${escapeHtml(p.address || 'N/A')}</div>
            <div class="detail-item"><strong>Registration Date</strong> ${formatDateTime(p.createdAt)}</div>
        `;

        document.getElementById('quick-add-encounter-btn').onclick = () => {
            switchTab('encounters');
            document.getElementById('encounter-patient-select').value = p.patientId;
        };

        const allergiesTbody = document.getElementById('details-allergies-tbody');
        allergiesTbody.innerHTML = '';
        if (data.allergies && data.allergies.length > 0) {
            data.allergies.forEach(a => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>${escapeHtml(a.allergen)}</strong></td>
                    <td>${escapeHtml(a.reaction || 'N/A')}</td>
                    <td><span style="font-weight:bold; color: ${a.severity === 'Severe' ? '#b02a37' : '#0d3b66'}">${escapeHtml(a.severity)}</span></td>
                `;
                allergiesTbody.appendChild(tr);
            });
        } else {
            allergiesTbody.innerHTML = `<tr><td colspan="3" class="no-data">No known allergies recorded for this patient.</td></tr>`;
        }

        const historyTbody = document.getElementById('details-history-tbody');
        historyTbody.innerHTML = '';
        if (data.medicalHistory && data.medicalHistory.length > 0) {
            data.medicalHistory.forEach(h => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>${escapeHtml(h.conditionName)}</strong></td>
                    <td>${h.diagnosisDate || 'N/A'}</td>
                    <td>${escapeHtml(h.status)}</td>
                `;
                historyTbody.appendChild(tr);
            });
        } else {
            historyTbody.innerHTML = `<tr><td colspan="3" class="no-data">No past medical history recorded.</td></tr>`;
        }

        const encountersTbody = document.getElementById('details-encounters-tbody');
        encountersTbody.innerHTML = '';
        if (data.encounters && data.encounters.length > 0) {
            data.encounters.forEach(e => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><strong>#${e.encounterId}</strong></td>
                    <td>${formatDateTime(e.encounterDate)}</td>
                    <td>${escapeHtml(e.clinician.name)} <br><small style="color:#666">(${escapeHtml(e.clinician.specialty)})</small></td>
                    <td>${escapeHtml(e.symptoms || '-')}</td>
                    <td><strong>${escapeHtml(e.diagnosis)}</strong></td>
                    <td>${escapeHtml(e.treatmentNotes || '-')}</td>
                `;
                encountersTbody.appendChild(tr);
            });
        } else {
            encountersTbody.innerHTML = `<tr><td colspan="6" class="no-data">No previous clinical encounters on record for this patient.</td></tr>`;
        }

        window.scrollTo({ top: 0, behavior: 'smooth' });

    } catch (err) {
        showAlert('Error loading patient details: ' + err.message, 'error');
    }
}

function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function formatDateTime(isoString) {
    if (!isoString) return 'N/A';
    try {
        const d = new Date(isoString);
        return d.toLocaleDateString() + ' ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } catch (e) {
        return isoString;
    }
}

function calculateAge(dobString) {
    if (!dobString) return 'N/A';
    const dob = new Date(dobString);
    const diffMs = Date.now() - dob.getTime();
    const ageDt = new Date(diffMs);
    return Math.abs(ageDt.getUTCFullYear() - 1970);
}
