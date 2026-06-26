//
//  AnalyticsWorkbench.swift
//  Health-Datamatics
//
//  Created by Christopher Appiah-Thompson  on 17/6/2026.
//

import SwiftUI

struct AnalyticsWorkbench {
    let title: String
    let subtitle: String
    let kpis: [KPI]
    let trendSeries: [TrendPoint]
    let alerts: [AlertItem]
    let cohorts: [Cohort]
    let patients: [PatientSummary]
    let qualitySnapshot: QualitySnapshot
    let qualityChecks: [QualityCheck]
    let workflowStages: [AnalyticsWorkflowStage]
    let governanceControls: [GovernanceControl]
    let insights: [InsightStory]
    let trendSignals: [TrendSignal]
    let reports: [ReportTemplate]
    let integrations: [IntegrationStatus]
    let architectureMappings: [DomainArchitectureMapping]
}

struct KPI: Identifiable {
    let id: String
    let title: String
    let value: String
    let delta: String
    let footnote: String
    let direction: TrendDirection
}

struct TrendPoint: Identifiable {
    let id: String
    let period: String
    let value: Double
}

struct AlertItem: Identifiable {
    let id: String
    let title: String
    let detail: String
    let severity: SeverityLevel
    let owner: String
}

struct Cohort: Identifiable {
    let id: String
    let name: String
    let count: Int
    let focus: String
}

struct PatientSummary: Identifiable {
    let id: String
    let name: String
    let mrn: String
    let age: Int
    let primaryCondition: String
    let lastEncounter: String
    let riskLevel: RiskLevel
    let careGap: String
}

struct QualitySnapshot {
    let overallScore: Int
    let warehouseCoverage: String
    let fhirSync: String
    let hl7Latency: String
}

struct QualityCheck: Identifiable {
    let id: String
    let title: String
    let finding: String
    let impact: String
    let status: QualityStatus
}

struct AnalyticsWorkflowStage: Identifiable {
    let id: String
    let name: String
    let method: String
    let output: String
    let owner: String
}

struct GovernanceControl: Identifiable {
    let id: String
    let title: String
    let description: String
    let coverage: Int
    let status: QualityStatus
}

struct InsightStory: Identifiable {
    let id: String
    let title: String
    let summary: String
    let explanation: String
    let recommendedAction: String
    let confidence: Int
}

struct TrendSignal: Identifiable {
    let id: String
    let topic: String
    let direction: TrendDirection
    let evidence: String
    let domain: String
}

struct ReportTemplate: Identifiable {
    let id: String
    let title: String
    let audience: String
    let cadence: String
    let exportFormats: [String]
    let pipelineState: ExportPipelineState
    let summary: String
}

struct IntegrationStatus: Identifiable {
    let id: String
    let system: String
    let modality: String
    let state: IntegrationState
    let latency: String
    let note: String
}

struct DomainArchitectureMapping: Identifiable {
    let id: String
    let sourceTheme: String
    let appSurface: String
    let serviceContract: String
    let backendAssumption: String
    let traceability: String
}

enum TrendDirection {
    case up
    case down
    case flat

    var symbol: String {
        switch self {
        case .up: "arrow.up.forward"
        case .down: "arrow.down.forward"
        case .flat: "arrow.left.and.right"
        }
    }

    var color: Color {
        switch self {
        case .up: .teal
        case .down: .red
        case .flat: .orange
        }
    }
}

enum SeverityLevel {
    case critical
    case elevated
    case watch

    var title: String {
        switch self {
        case .critical: "Critical"
        case .elevated: "Elevated"
        case .watch: "Watch"
        }
    }

    var color: Color {
        switch self {
        case .critical: .red
        case .elevated: .orange
        case .watch: .yellow
        }
    }
}

enum RiskLevel {
    case high
    case moderate
    case stable

    var title: String {
        switch self {
        case .high: "High risk"
        case .moderate: "Moderate risk"
        case .stable: "Stable"
        }
    }

    var color: Color {
        switch self {
        case .high: .red
        case .moderate: .orange
        case .stable: .teal
        }
    }
}

enum QualityStatus {
    case good
    case needsAttention
    case failing

    var title: String {
        switch self {
        case .good: "On track"
        case .needsAttention: "Needs attention"
        case .failing: "Escalate"
        }
    }

    var color: Color {
        switch self {
        case .good: .teal
        case .needsAttention: .orange
        case .failing: .red
        }
    }
}

enum IntegrationState {
    case ready
    case pilot
    case blocked

    var title: String {
        switch self {
        case .ready: "Ready"
        case .pilot: "Pilot"
        case .blocked: "Blocked"
        }
    }

    var color: Color {
        switch self {
        case .ready: .teal
        case .pilot: .orange
        case .blocked: .red
        }
    }
}

enum ExportPipelineState {
    case draft
    case validated
    case scheduled

    var title: String {
        switch self {
        case .draft: "Draft"
        case .validated: "Validated"
        case .scheduled: "Scheduled"
        }
    }

    var color: Color {
        switch self {
        case .draft: .orange
        case .validated: .teal
        case .scheduled: .blue
        }
    }
}

extension AnalyticsWorkbench {
    static let preview = AnalyticsWorkbench(
        title: "HealthInformaticsIQ",
        subtitle: "A clinician and administrator analytics cockpit for healthcare informatics, explainable outcome improvement, and report synthesis.",
        kpis: [
            KPI(id: "readmissions", title: "30-day readmissions", value: "9.4%", delta: "-1.2%", footnote: "vs prior quarter", direction: .up),
            KPI(id: "alos", title: "Average length of stay", value: "4.8 days", delta: "-0.3", footnote: "risk adjusted", direction: .up),
            KPI(id: "sepsis", title: "Sepsis bundle compliance", value: "91%", delta: "+4.6%", footnote: "last 6 weeks", direction: .up),
            KPI(id: "outpatient", title: "Outpatient no-show risk", value: "13.8%", delta: "+1.9%", footnote: "predictive watchlist", direction: .flat)
        ],
        trendSeries: [
            TrendPoint(id: "wk1", period: "W1", value: 78),
            TrendPoint(id: "wk2", period: "W2", value: 80),
            TrendPoint(id: "wk3", period: "W3", value: 82),
            TrendPoint(id: "wk4", period: "W4", value: 81),
            TrendPoint(id: "wk5", period: "W5", value: 86),
            TrendPoint(id: "wk6", period: "W6", value: 88)
        ],
        alerts: [
            AlertItem(id: "coding-gap", title: "Coding completeness dropped in cardiology", detail: "Unmapped SNOMED-to-ICD diagnosis concepts increased to 6.1% after a template change.", severity: .critical, owner: "Terminology services"),
            AlertItem(id: "fhir-latency", title: "FHIR medication sync is delayed", detail: "Two vendor endpoints are delivering discharge medications 45 minutes behind SLA.", severity: .elevated, owner: "Interoperability team"),
            AlertItem(id: "cohort-shift", title: "High-risk COPD cohort expanding", detail: "Predictive scores and nurse call sentiment show a meaningful rise in deterioration risk.", severity: .watch, owner: "Population health")
        ],
        cohorts: [
            Cohort(id: "chf", name: "CHF care management", count: 248, focus: "Readmission prevention and medication adherence"),
            Cohort(id: "copd", name: "COPD exacerbation watch", count: 173, focus: "Remote monitoring and symptom escalation"),
            Cohort(id: "diabetes", name: "Diabetes A1c outreach", count: 412, focus: "Gap closure and overdue review"),
            Cohort(id: "ed-flow", name: "ED boarding watch", count: 96, focus: "Bed assignment delays and late-night throughput"),
            Cohort(id: "maternal", name: "Maternal safety bundle", count: 138, focus: "Hypertension screening and follow-up reliability"),
            Cohort(id: "behavioral", name: "Behavioral health transitions", count: 121, focus: "Warm handoffs and seven-day continuity checks")
        ],
        patients: [
            PatientSummary(id: "pat-001", name: "Aaliyah Johnson", mrn: "MRN-102944", age: 67, primaryCondition: "Congestive heart failure", lastEncounter: "Discharged 2 days ago", riskLevel: .high, careGap: "Post-discharge follow-up not booked"),
            PatientSummary(id: "pat-002", name: "Luca Martin", mrn: "MRN-220184", age: 54, primaryCondition: "Type 2 diabetes", lastEncounter: "Endocrinology review 12 days ago", riskLevel: .moderate, careGap: "HbA1c trend rising above target"),
            PatientSummary(id: "pat-003", name: "Sofia Chen", mrn: "MRN-198305", age: 39, primaryCondition: "Asthma", lastEncounter: "ED visit 18 hours ago", riskLevel: .stable, careGap: "Controller medication reconciliation pending"),
            PatientSummary(id: "pat-004", name: "Marcus Okafor", mrn: "MRN-330512", age: 72, primaryCondition: "COPD", lastEncounter: "Pulmonary clinic 5 days ago", riskLevel: .high, careGap: "Home oxygen assessment overdue"),
            PatientSummary(id: "pat-005", name: "Nora Patel", mrn: "MRN-418820", age: 61, primaryCondition: "Chronic kidney disease", lastEncounter: "Nephrology review yesterday", riskLevel: .moderate, careGap: "eGFR decline needs medication review"),
            PatientSummary(id: "pat-006", name: "Ethan Williams", mrn: "MRN-519410", age: 45, primaryCondition: "Hypertension", lastEncounter: "Primary care visit 9 days ago", riskLevel: .stable, careGap: "Home BP readings not uploaded")
        ],
        qualitySnapshot: QualitySnapshot(overallScore: 87, warehouseCoverage: "94% warehouse lineage mapped", fhirSync: "FHIR resources synced every 15 min", hl7Latency: "HL7 ADT median latency 42 sec"),
        qualityChecks: [
            QualityCheck(id: "missingness", title: "Missing discharge disposition", finding: "2.3% of inpatient discharges are missing final disposition in the warehouse mart.", impact: "Biases LOS and outcomes benchmarking.", status: .needsAttention),
            QualityCheck(id: "duplicates", title: "Potential duplicate encounters", finding: "17 encounter pairs share timestamp, MRN, and attending service fingerprints.", impact: "Inflates admission counts and cohort logic.", status: .failing),
            QualityCheck(id: "coding", title: "Procedure coding gaps", finding: "Orthopaedic theatre extracts now meet the 98% procedure mapping threshold.", impact: "Improves service line revenue and case-mix quality.", status: .good),
            QualityCheck(id: "result-units", title: "Observation unit drift", finding: "Creatinine feeds contain mixed mg/dL and umol/L values from two laboratory interfaces.", impact: "Can distort renal-risk trend interpretation unless units are normalized.", status: .needsAttention),
            QualityCheck(id: "late-arrivals", title: "Late-arriving claims", finding: "Commercial payer claims lag the encounter mart by 11 days at the 90th percentile.", impact: "Monthly utilization packs need a provisional-status label.", status: .needsAttention),
            QualityCheck(id: "identity", title: "Identity match confidence", finding: "Enterprise master patient index confidence exceeds the release threshold for all sampled cohorts.", impact: "Supports safer longitudinal patient summaries.", status: .good)
        ],
        workflowStages: [
            AnalyticsWorkflowStage(id: "descriptive", name: "Descriptive", method: "KPI rollups, dashboards, cohort profiles", output: "What changed across quality, outcomes, and utilization.", owner: "BI analytics"),
            AnalyticsWorkflowStage(id: "diagnostic", name: "Diagnostic", method: "Drilldowns, coding audits, variance attribution", output: "Why the change emerged and where it concentrates.", owner: "Clinical informatics"),
            AnalyticsWorkflowStage(id: "predictive", name: "Predictive", method: "Risk scores, anomaly detection, sentiment signals", output: "Who or which service line is likely to deteriorate next.", owner: "Data science"),
            AnalyticsWorkflowStage(id: "prescriptive", name: "Prescriptive", method: "CDS-inspired recommendations and playbooks", output: "Which intervention should be considered and how to monitor it.", owner: "Care transformation")
        ],
        governanceControls: [
            GovernanceControl(id: "lineage", title: "Lineage and stewardship", description: "Source-to-mart traceability for SQL warehouse tables, FHIR resources, and HL7 feeds.", coverage: 94, status: .good),
            GovernanceControl(id: "terminology", title: "Terminology mapping", description: "SNOMED, LOINC, ICD, and local code mappings reviewed before analytics release.", coverage: 88, status: .needsAttention),
            GovernanceControl(id: "privacy", title: "Privacy and role access", description: "PHI views separated from executive summaries with audit-ready access controls.", coverage: 91, status: .good)
        ],
        insights: [
            InsightStory(id: "ins-001", title: "Readmission pressure easing after discharge navigator rollout", summary: "CHF readmissions are improving while contact-centre follow-up reach has climbed above 85%.", explanation: "The strongest drivers are nurse callback completion, medication reconciliation within 48 hours, and fewer uncoded discharge summaries.", recommendedAction: "Expand the navigator workflow to COPD and monitor 14-day revisit rates.", confidence: 89),
            InsightStory(id: "ins-002", title: "ED boarding risk concentrates overnight", summary: "Diagnostic and sentiment signals both show a bottleneck between 22:00 and 03:00.", explanation: "Lab turnaround, bed assignment delays, and negative handover sentiment cluster in the same interval.", recommendedAction: "Pilot an overnight command-centre huddle with pathology escalation rules.", confidence: 81),
            InsightStory(id: "ins-003", title: "Diabetes outreach list needs recency weighting", summary: "Patients with rising A1c and no appointment in 90 days are being diluted by lower-risk historical gaps.", explanation: "Recent abnormal labs and missed reviews predict near-term escalation better than a simple overdue-list sort.", recommendedAction: "Rank outreach by A1c velocity, last visit, and medication-fill signal.", confidence: 84),
            InsightStory(id: "ins-004", title: "Coding drift follows template migration", summary: "Cardiology procedure completeness dropped after the new documentation template went live.", explanation: "The timing matches the template change and the missing-code pattern is concentrated in one service line.", recommendedAction: "Add terminology validation to the template and review unmapped concepts daily for two weeks.", confidence: 92)
        ],
        trendSignals: [
            TrendSignal(id: "sig-001", topic: "FHIR bulk export adoption", direction: .up, evidence: "Vendor roadmap and standards group updates indicate broader payer-provider exchange support.", domain: "Interoperability"),
            TrendSignal(id: "sig-002", topic: "Clinical note sentiment drift", direction: .flat, evidence: "Nursing free text shows steady concern language despite improved vitals compliance.", domain: "Sentiment mapping"),
            TrendSignal(id: "sig-003", topic: "Explainable CDS pilots", direction: .up, evidence: "Recent implementation papers increasingly pair risk flags with local rationale statements.", domain: "Bibliometric trend mapping"),
            TrendSignal(id: "sig-004", topic: "Data product governance", direction: .up, evidence: "Analytics teams are documenting ownership, freshness, lineage, and quality checks with every released metric.", domain: "Governance"),
            TrendSignal(id: "sig-005", topic: "Ambient documentation analytics", direction: .up, evidence: "Clinical operations groups are testing note summarization with quality and privacy guardrails.", domain: "Workflow intelligence")
        ],
        reports: [
            ReportTemplate(id: "rep-001", title: "Executive quality pack", audience: "Executives and governance boards", cadence: "Monthly", exportFormats: ["PDF", "CSV"], pipelineState: .scheduled, summary: "KPI rollups, service line variance, and governance commentary."),
            ReportTemplate(id: "rep-002", title: "Clinical service summary", audience: "Clinical directors", cadence: "Weekly", exportFormats: ["PDF", "FHIR Bundle"], pipelineState: .validated, summary: "Cohorts, risk flags, quality gaps, and explainable care recommendations."),
            ReportTemplate(id: "rep-003", title: "Data stewardship exception log", audience: "Data warehouse and informatics teams", cadence: "Daily", exportFormats: ["CSV", "JSON"], pipelineState: .draft, summary: "Missingness, duplicates, coding drift, and anomaly tracebacks."),
            ReportTemplate(id: "rep-004", title: "Population health outreach list", audience: "Care coordinators", cadence: "Twice weekly", exportFormats: ["CSV", "PDF"], pipelineState: .validated, summary: "Prioritized care gaps, risk reasons, and suggested contact scripts."),
            ReportTemplate(id: "rep-005", title: "Interoperability readiness brief", audience: "Integration and vendor teams", cadence: "Biweekly", exportFormats: ["PDF", "JSON"], pipelineState: .scheduled, summary: "FHIR latency, HL7 message quality, mapping gaps, and endpoint readiness.")
        ],
        integrations: [
            IntegrationStatus(id: "int-001", system: "Epic FHIR APIs", modality: "FHIR R4", state: .ready, latency: "12 min refresh", note: "Patient, Encounter, Observation, and Medication resources normalized."),
            IntegrationStatus(id: "int-002", system: "ADT message bus", modality: "HL7 v2", state: .ready, latency: "42 sec median", note: "Admissions and transfers flow into the longitudinal patient view."),
            IntegrationStatus(id: "int-003", system: "Enterprise warehouse", modality: "SQL / star schema", state: .pilot, latency: "Hourly loads", note: "Cohort marts power dashboards, report templates, and ML feature snapshots.")
        ],
        architectureMappings: [
            DomainArchitectureMapping(id: "landscape", sourceTheme: "Healthcare IT landscape", appSurface: "Integration layer, governance screens, workflow context", serviceContract: "ClinicalFHIRServicing, WarehouseAPIClientProtocol", backendAssumption: "FHIR gateway plus warehouse marts behind role-aware APIs", traceability: "Shows how source-system context flows into workbench navigation."),
            DomainArchitectureMapping(id: "sql", sourceTheme: "Relational databases and SQL", appSurface: "Cohort query views, aggregate endpoints, report packs", serviceContract: "WarehouseContract.healthcareAnalytics", backendAssumption: "SQL warehouse exposes curated cohort, encounter, utilization, DRG, ICD, and LOINC endpoints", traceability: "Maps operational tables to Swift models used by dashboards and reports."),
            DomainArchitectureMapping(id: "interop", sourceTheme: "HL7, FHIR, CDA, DICOM", appSurface: "Interoperability adapters and normalization layer", serviceContract: "SMARTFHIRClient, FHIRNormalizer", backendAssumption: "SMART-on-FHIR endpoint and vendor adapters normalize clinical payloads", traceability: "Patient, Encounter, Observation, Condition, MedicationRequest, and DiagnosticReport become local models."),
            DomainArchitectureMapping(id: "codesets", sourceTheme: "Ontologies and codesets", appSurface: "Coding quality checks and terminology governance", serviceContract: "HealthcareDataQualityAnalyzer", backendAssumption: "ICD, SNOMED CT, LOINC, and HCPCS reference sets are versioned by terminology services", traceability: "Flags code mismatches and steward-owned mapping gaps."),
            DomainArchitectureMapping(id: "quality", sourceTheme: "pandas, NumPy, data quality", appSurface: "Missingness views, duplicate detection, transformation pipeline", serviceContract: "DataQualityAnalyzing", backendAssumption: "Warehouse jobs produce profiling statistics before release", traceability: "Returns severity, evidence, and remediation for every quality issue."),
            DomainArchitectureMapping(id: "ml", sourceTheme: "Machine learning and explainability", appSurface: "Risk model summaries, trend interpretation, confidence and rationale UI", serviceContract: "ClinicalInsightGenerating, TrendAnalyzing", backendAssumption: "Model registry publishes scores with features, thresholds, and rule traces", traceability: "Every recommendation carries confidence, affected measures, rationale, and rules."),
            DomainArchitectureMapping(id: "mlops", sourceTheme: "Hadoop, Spark, cloud, MLOps", appSurface: "Scalable warehouse and model deployment assumptions", serviceContract: "WarehouseAPIClientProtocol", backendAssumption: "Spark/cloud pipelines refresh marts and model outputs asynchronously", traceability: "Keeps the iOS app local-first while backend scale remains modular."),
            DomainArchitectureMapping(id: "analytics", sourceTheme: "Descriptive, diagnostic, predictive, prescriptive analytics", appSurface: "Analytics tabs, interventions, report sections", serviceContract: "HealthcareTrendEngine", backendAssumption: "Operational facts and model scores arrive as time series and events", traceability: "Moving averages, readmission rates, abnormal labs, and suggestions share rule traces."),
            DomainArchitectureMapping(id: "bi", sourceTheme: "BI dashboards and visualization", appSurface: "KPI cards, charts, dashboard summaries", serviceContract: "PDFReportSection, ReportChartSpec", backendAssumption: "Power BI-like summaries and Looker-style semantic metrics can hydrate the same models", traceability: "Charts and plain-language interpretation are PDF-ready."),
            DomainArchitectureMapping(id: "sentiment", sourceTheme: "Sentiment, social analytics, bibliometrics", appSurface: "Patient feedback analytics, public-health watch, research trend mapping", serviceContract: "NoteAnalysisPipelining, ClinicalNoteLLMAnalyzing", backendAssumption: "PHI-safe redaction boundary precedes any LLM-compatible analysis", traceability: "Structured concerns, tone, topics, safety flags, and research signals remain inspectable."),
            DomainArchitectureMapping(id: "vendor", sourceTheme: "Platform and vendor mindset", appSurface: "Modular adapters for BI, semantics, cloud analytics, and edge AI", serviceContract: "HTTPTransport, SMARTAuthenticating, WarehouseAPIClientProtocol", backendAssumption: "Vendor services are replaceable behind protocols and typed DTOs", traceability: "Supports FHIR, warehouse, cloud analytics, or edge-AI backends with async/await."),
            DomainArchitectureMapping(id: "swiftui", sourceTheme: "SwiftUI and Charts local-first app", appSurface: "Native tabs, cards, charts, and report previews", serviceContract: "AnalyticsWorkbench.preview plus async service boundaries", backendAssumption: "The app can run with cached local data and progressively hydrate from backends", traceability: "Bridges executive, clinical, informatics, and governance workflows.")
        ]
    )
}
