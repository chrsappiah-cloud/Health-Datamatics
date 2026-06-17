//
//  HealthcareAnalyticsEngines.swift
//  Health-Datamatics
//
//  Created by Codex on 17/6/2026.
//

import Foundation

enum AnalyticsMetricKind: String, CaseIterable, Equatable {
    case descriptive
    case diagnostic
    case predictive
    case prescriptive
}

struct RuleTrace: Equatable {
    let ruleID: String
    let description: String
    let evidence: [String]
}

struct OperationDataPoint: Identifiable, Equatable {
    let id: String
    let date: Date
    let value: Double
    let label: String
}

struct ReadmissionEvent: Identifiable, Equatable {
    let id: String
    let dischargeDate: Date
    let readmittedDate: Date?
}

struct TrendMetric: Identifiable, Equatable {
    let id: String
    let kind: AnalyticsMetricKind
    let title: String
    let value: Double
    let interpretation: String
    let ruleTraces: [RuleTrace]
}

struct InterventionSuggestion: Identifiable, Equatable {
    let id: String
    let title: String
    let priority: ClinicalSeverity
    let rationale: String
    let ruleTraces: [RuleTrace]
}

struct TrendAnalyticsResult: Equatable {
    let movingAverage: [OperationDataPoint]
    let readmissionRate: TrendMetric
    let abnormalLabTrends: [TrendMetric]
    let operationalMetrics: [TrendMetric]
    let interventions: [InterventionSuggestion]
}

protocol TrendAnalyzing {
    func analyze(
        observations: [HealthcareObservation],
        readmissions: [ReadmissionEvent],
        utilization: [OperationDataPoint]
    ) -> TrendAnalyticsResult
}

struct HealthcareTrendEngine: TrendAnalyzing {
    var movingAverageWindow = 3
    var readmissionWindowDays = 30

    func analyze(
        observations: [HealthcareObservation],
        readmissions: [ReadmissionEvent],
        utilization: [OperationDataPoint]
    ) -> TrendAnalyticsResult {
        let movingAverage = movingAverage(for: utilization, window: movingAverageWindow)
        let readmissionRate = rollingReadmissionRate(readmissions)
        let abnormalLabTrends = detectAbnormalLabTrends(observations)
        let descriptive = TrendMetric(
            id: "utilization-descriptive",
            kind: .descriptive,
            title: "Average operational load",
            value: utilization.map(\.value).average,
            interpretation: "Average load across \(utilization.count) operational points.",
            ruleTraces: [.init(ruleID: "DES-AVG-001", description: "Mean utilization is computed across supplied points.", evidence: ["points=\(utilization.count)"])]
        )
        let diagnostic = TrendMetric(
            id: "utilization-diagnostic",
            kind: .diagnostic,
            title: "Latest load variance",
            value: latestVariance(points: utilization, movingAverage: movingAverage),
            interpretation: "Positive values indicate the latest point is above the local moving average.",
            ruleTraces: [.init(ruleID: "DIA-VAR-001", description: "Compares latest utilization with latest moving average.", evidence: ["window=\(movingAverageWindow)"])]
        )
        let predictive = TrendMetric(
            id: "utilization-predictive",
            kind: .predictive,
            title: "Next-period projected load",
            value: projectedNextValue(utilization),
            interpretation: "Projection uses the latest linear slope from recent operational values.",
            ruleTraces: [.init(ruleID: "PRE-SLOPE-001", description: "Adds recent average slope to the latest value.", evidence: utilization.suffix(3).map { "\($0.label)=\($0.value)" })]
        )
        let interventions = suggestions(readmissionRate: readmissionRate, abnormalLabTrends: abnormalLabTrends)

        return TrendAnalyticsResult(
            movingAverage: movingAverage,
            readmissionRate: readmissionRate,
            abnormalLabTrends: abnormalLabTrends,
            operationalMetrics: [descriptive, diagnostic, predictive],
            interventions: interventions
        )
    }

    func movingAverage(for points: [OperationDataPoint], window: Int) -> [OperationDataPoint] {
        guard window > 0 else { return points }
        let sorted = points.sorted { $0.date < $1.date }
        return sorted.enumerated().map { index, point in
            let lowerBound = max(0, index - window + 1)
            let values = sorted[lowerBound...index].map(\.value)
            return OperationDataPoint(id: "\(point.id)-ma", date: point.date, value: values.average, label: "\(point.label) moving average")
        }
    }

    func rollingReadmissionRate(_ events: [ReadmissionEvent]) -> TrendMetric {
        guard !events.isEmpty else {
            return TrendMetric(id: "readmission-rate", kind: .descriptive, title: "30-day readmission rate", value: 0, interpretation: "No discharge events supplied.", ruleTraces: [])
        }

        let readmitted = events.filter { event in
            guard let readmittedDate = event.readmittedDate else { return false }
            return Calendar.current.dateComponents([.day], from: event.dischargeDate, to: readmittedDate).day ?? Int.max <= readmissionWindowDays
        }
        let rate = Double(readmitted.count) / Double(events.count)
        return TrendMetric(
            id: "readmission-rate",
            kind: .descriptive,
            title: "\(readmissionWindowDays)-day readmission rate",
            value: rate,
            interpretation: "\(readmitted.count) of \(events.count) discharges returned within \(readmissionWindowDays) days.",
            ruleTraces: [.init(ruleID: "DES-READMIT-030", description: "Counts admissions within the configured post-discharge window.", evidence: ["readmitted=\(readmitted.count)", "discharges=\(events.count)"])]
        )
    }

    func detectAbnormalLabTrends(_ observations: [HealthcareObservation]) -> [TrendMetric] {
        let grouped = Dictionary(grouping: observations.filter { $0.value != nil }, by: { $0.code ?? $0.display })
        return grouped.compactMap { code, values in
            let sorted = values.sorted { ($0.effectiveAt ?? .distantPast) < ($1.effectiveAt ?? .distantPast) }
            guard sorted.count >= 3, let first = sorted.first?.value, let last = sorted.last?.value else { return nil }
            let delta = last - first
            let abnormalCount = sorted.filter { ($0.interpretation ?? "").localizedCaseInsensitiveContains("high") || ($0.interpretation ?? "").localizedCaseInsensitiveContains("abnormal") }.count
            guard abs(delta) >= max(abs(first) * 0.2, 1) || abnormalCount >= 2 else { return nil }

            return TrendMetric(
                id: "lab-trend-\(code)",
                kind: .diagnostic,
                title: "Abnormal trend: \(sorted.first?.display ?? code)",
                value: delta,
                interpretation: "Latest value changed by \(delta.rounded(toPlaces: 2)) with \(abnormalCount) abnormal interpretations.",
                ruleTraces: [.init(ruleID: "DIA-LAB-TREND-001", description: "Flags labs with at least 20% movement or repeated abnormal interpretation.", evidence: ["first=\(first)", "last=\(last)", "abnormalCount=\(abnormalCount)"])]
            )
        }
    }

    private func latestVariance(points: [OperationDataPoint], movingAverage: [OperationDataPoint]) -> Double {
        guard let latest = points.sorted(by: { $0.date < $1.date }).last,
              let average = movingAverage.last else { return 0 }
        return latest.value - average.value
    }

    private func projectedNextValue(_ points: [OperationDataPoint]) -> Double {
        let sorted = points.sorted { $0.date < $1.date }
        guard let last = sorted.last else { return 0 }
        let deltas = zip(sorted, sorted.dropFirst()).map { $1.value - $0.value }
        return last.value + deltas.suffix(3).average
    }

    private func suggestions(readmissionRate: TrendMetric, abnormalLabTrends: [TrendMetric]) -> [InterventionSuggestion] {
        var output: [InterventionSuggestion] = []
        if readmissionRate.value >= 0.12 {
            output.append(
                InterventionSuggestion(
                    id: "readmission-navigator",
                    title: "Expand post-discharge navigator follow-up",
                    priority: .high,
                    rationale: "Readmission rate is above the 12% operational threshold.",
                    ruleTraces: readmissionRate.ruleTraces + [.init(ruleID: "PRE-INT-READMIT-001", description: "Suggests navigator workflow when readmission risk exceeds threshold.", evidence: ["rate=\(readmissionRate.value)"])]
                )
            )
        }
        if !abnormalLabTrends.isEmpty {
            output.append(
                InterventionSuggestion(
                    id: "lab-review-huddle",
                    title: "Create abnormal-lab review huddle",
                    priority: .moderate,
                    rationale: "Repeated lab movement suggests care-team review may reduce avoidable deterioration.",
                    ruleTraces: abnormalLabTrends.flatMap(\.ruleTraces)
                )
            )
        }
        return output
    }
}

enum ClinicalSeverity: String, Comparable, Equatable {
    case low
    case moderate
    case high
    case critical

    static func < (lhs: ClinicalSeverity, rhs: ClinicalSeverity) -> Bool {
        order(lhs) < order(rhs)
    }

    private static func order(_ severity: ClinicalSeverity) -> Int {
        switch severity {
        case .low: 0
        case .moderate: 1
        case .high: 2
        case .critical: 3
        }
    }
}

struct DataQualityIssue: Identifiable, Equatable {
    let id: String
    let severity: ClinicalSeverity
    let dimension: String
    let evidence: [String]
    let recommendedRemediation: String
}

protocol DataQualityAnalyzing {
    func analyze(record: HealthcareClinicalRecord) -> [DataQualityIssue]
}

struct HealthcareDataQualityAnalyzer: DataQualityAnalyzing {
    let knownObservationCodes: Set<String>

    init(knownObservationCodes: Set<String> = ["8480-6", "8462-4", "718-7", "4548-4", "2951-2", "33747-0"]) {
        self.knownObservationCodes = knownObservationCodes
    }

    func analyze(record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        var issues: [DataQualityIssue] = []
        issues.append(contentsOf: missingness(record))
        issues.append(contentsOf: codeMismatches(record))
        issues.append(contentsOf: duplicatePatients(record))
        issues.append(contentsOf: brokenReferences(record))
        issues.append(contentsOf: outliers(record))
        issues.append(contentsOf: timestampIssues(record))
        issues.append(contentsOf: incompleteObservations(record))
        return issues.sorted { $0.severity > $1.severity }
    }

    private func missingness(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        var evidence: [String] = []
        if record.patient.displayName.nullLike { evidence.append("patient.displayName") }
        evidence += record.observations.filter { $0.display.nullLike }.map { "observation:\($0.id).display" }
        guard !evidence.isEmpty else { return [] }
        return [.init(id: "missingness", severity: .high, dimension: "Null-like missingness", evidence: evidence, recommendedRemediation: "Backfill source values and reject null-like sentinel strings before analytics release.")]
    }

    private func codeMismatches(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        let mismatches = record.observations.filter { observation in
            guard let code = observation.code else { return false }
            return !knownObservationCodes.contains(code)
        }
        guard !mismatches.isEmpty else { return [] }
        return [.init(id: "code-mismatch", severity: .moderate, dimension: "Code mismatches", evidence: mismatches.map { "\($0.id): \($0.code ?? "nil")" }, recommendedRemediation: "Review LOINC mappings and maintain a terminology exception table.")]
    }

    private func duplicatePatients(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        guard let mrn = record.patient.mrn, !mrn.nullLike else { return [] }
        let encounterPatientIDs = Set(record.encounters.compactMap(\.patientID))
        guard encounterPatientIDs.count > 1 else { return [] }
        return [.init(id: "duplicate-patient", severity: .critical, dimension: "Duplicate patients", evidence: ["MRN \(mrn) appears with patient IDs \(encounterPatientIDs.sorted().joined(separator: ", "))"], recommendedRemediation: "Run enterprise master patient index reconciliation before cohort refresh.")]
    }

    private func brokenReferences(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        let encounterIDs = Set(record.encounters.map(\.id))
        let broken = record.observations.filter { observation in
            guard let encounterID = observation.encounterID else { return false }
            return !encounterIDs.contains(encounterID)
        }
        guard !broken.isEmpty else { return [] }
        return [.init(id: "broken-reference", severity: .high, dimension: "Broken references", evidence: broken.map { "\($0.id) -> Encounter/\($0.encounterID ?? "nil")" }, recommendedRemediation: "Refresh encounter dimension before loading observation facts.")]
    }

    private func outliers(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        let outlierEvidence = record.observations.compactMap { observation -> String? in
            guard let value = observation.value else { return nil }
            if observation.display.localizedCaseInsensitiveContains("blood pressure"), value > 260 { return "\(observation.id)=\(value)" }
            if observation.display.localizedCaseInsensitiveContains("hemoglobin"), value > 25 { return "\(observation.id)=\(value)" }
            return nil
        }
        guard !outlierEvidence.isEmpty else { return [] }
        return [.init(id: "outliers", severity: .moderate, dimension: "Outliers", evidence: outlierEvidence, recommendedRemediation: "Confirm units, device mappings, and decimal placement with source-system owners.")]
    }

    private func timestampIssues(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        let evidence = record.encounters.compactMap { encounter -> String? in
            guard let start = encounter.startedAt, let end = encounter.endedAt, end < start else { return nil }
            return "\(encounter.id): end before start"
        }
        guard !evidence.isEmpty else { return [] }
        return [.init(id: "timestamps", severity: .high, dimension: "Inconsistent timestamps", evidence: evidence, recommendedRemediation: "Apply timezone normalization and reject negative encounter durations.")]
    }

    private func incompleteObservations(_ record: HealthcareClinicalRecord) -> [DataQualityIssue] {
        let incomplete = record.observations.filter { $0.value == nil && $0.interpretation == nil }
        guard !incomplete.isEmpty else { return [] }
        return [.init(id: "incomplete-observations", severity: .moderate, dimension: "Incomplete observations", evidence: incomplete.map(\.id), recommendedRemediation: "Require value, unit, or interpretation before observation facts enter dashboards.")]
    }
}

struct ReportChartSpec: Equatable {
    let title: String
    let points: [OperationDataPoint]
}

struct PDFReportSection: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let interpretation: String
    let chart: ReportChartSpec?
    let disclaimer: String?
}

protocol ReportSectionGenerating {
    func sections(
        workbench: AnalyticsWorkbench,
        clinicalRecord: HealthcareClinicalRecord?,
        trendResult: TrendAnalyticsResult?,
        qualityIssues: [DataQualityIssue],
        insights: [ClinicalRecommendation]
    ) -> [PDFReportSection]
}

struct HealthcareReportSectionGenerator: ReportSectionGenerating {
    func sections(
        workbench: AnalyticsWorkbench,
        clinicalRecord: HealthcareClinicalRecord?,
        trendResult: TrendAnalyticsResult?,
        qualityIssues: [DataQualityIssue],
        insights: [ClinicalRecommendation]
    ) -> [PDFReportSection] {
        [
            executiveSummary(workbench, trendResult),
            cohortOverview(workbench),
            trends(trendResult),
            risks(insights),
            quality(qualityIssues),
            opportunities(trendResult?.interventions ?? []),
            patientImpact(clinicalRecord),
            disclaimer()
        ]
    }

    private func executiveSummary(_ workbench: AnalyticsWorkbench, _ trendResult: TrendAnalyticsResult?) -> PDFReportSection {
        PDFReportSection(
            id: "executive-summary",
            title: "Executive summary",
            body: "\(workbench.title) is tracking \(workbench.kpis.count) core KPIs with \(workbench.alerts.count) active alerts.",
            interpretation: trendResult.map { "Readmission rate is \($0.readmissionRate.value.asPercent)." } ?? "Trend analytics are pending refresh.",
            chart: nil,
            disclaimer: nil
        )
    }

    private func cohortOverview(_ workbench: AnalyticsWorkbench) -> PDFReportSection {
        let total = workbench.cohorts.map(\.count).reduce(0, +)
        return PDFReportSection(id: "cohort-overview", title: "Cohort overview", body: "\(total) patients are represented across \(workbench.cohorts.count) starter cohorts.", interpretation: "Cohort counts should be reconciled against warehouse eligibility logic before operational use.", chart: nil, disclaimer: nil)
    }

    private func trends(_ trendResult: TrendAnalyticsResult?) -> PDFReportSection {
        PDFReportSection(
            id: "trends",
            title: "Trends",
            body: trendResult?.operationalMetrics.map { "\($0.title): \($0.value.rounded(toPlaces: 2))" }.joined(separator: "\n") ?? "No trend metrics available.",
            interpretation: "Moving averages smooth short-term noise while rule traces preserve the underlying calculation path.",
            chart: trendResult.map { ReportChartSpec(title: "Operational moving average", points: $0.movingAverage) },
            disclaimer: nil
        )
    }

    private func risks(_ insights: [ClinicalRecommendation]) -> PDFReportSection {
        PDFReportSection(id: "risks", title: "Risks", body: insights.map(\.title).joined(separator: "\n"), interpretation: "Recommendations are decision-support prompts and require clinician review.", chart: nil, disclaimer: nil)
    }

    private func quality(_ issues: [DataQualityIssue]) -> PDFReportSection {
        PDFReportSection(id: "quality-issues", title: "Quality issues", body: issues.map { "\($0.dimension): \($0.evidence.joined(separator: ", "))" }.joined(separator: "\n"), interpretation: "\(issues.count) data quality issues require stewardship review.", chart: nil, disclaimer: nil)
    }

    private func opportunities(_ suggestions: [InterventionSuggestion]) -> PDFReportSection {
        PDFReportSection(id: "intervention-opportunities", title: "Intervention opportunities", body: suggestions.map(\.title).joined(separator: "\n"), interpretation: "Prioritize high-severity suggestions with transparent rule support.", chart: nil, disclaimer: nil)
    }

    private func patientImpact(_ record: HealthcareClinicalRecord?) -> PDFReportSection {
        PDFReportSection(id: "patient-impact", title: "Patient impact narrative", body: record.map { "\($0.patient.displayName) has \($0.conditions.count) active condition signals, \($0.observations.count) observations, and \($0.medicationRequests.count) medication requests." } ?? "Patient-level record not selected.", interpretation: "Narratives are generated from normalized FHIR-style facts.", chart: nil, disclaimer: nil)
    }

    private func disclaimer() -> PDFReportSection {
        PDFReportSection(id: "disclaimer", title: "Disclaimer", body: "This report is generated from analytics data and is not a substitute for clinical judgment.", interpretation: "Validate source completeness, consent, and local governance requirements before distribution.", chart: nil, disclaimer: "PDF-ready content should be reviewed by clinical, privacy, and data stewardship owners.")
    }
}

struct ClinicalRecommendation: Identifiable, Equatable {
    let id: String
    let title: String
    let rationale: String
    let confidence: Double
    let affectedMeasures: [String]
    let ruleTraces: [RuleTrace]
}

protocol ClinicalInsightGenerating {
    func recommendations(record: HealthcareClinicalRecord, utilization: [OperationDataPoint]) -> [ClinicalRecommendation]
}

struct ClinicianInsightEngine: ClinicalInsightGenerating {
    func recommendations(record: HealthcareClinicalRecord, utilization: [OperationDataPoint]) -> [ClinicalRecommendation] {
        var output: [ClinicalRecommendation] = []
        let abnormalLabs = record.observations.filter { ($0.interpretation ?? "").localizedCaseInsensitiveContains("high") || ($0.interpretation ?? "").localizedCaseInsensitiveContains("abnormal") }
        if !abnormalLabs.isEmpty {
            output.append(
                ClinicalRecommendation(
                    id: "review-abnormal-labs",
                    title: "Review abnormal laboratory trajectory",
                    rationale: "\(abnormalLabs.count) observations include abnormal interpretation flags.",
                    confidence: min(0.95, 0.6 + Double(abnormalLabs.count) * 0.08),
                    affectedMeasures: ["Deterioration risk", "Diagnostic turnaround", "Escalation timeliness"],
                    ruleTraces: [.init(ruleID: "CDS-LAB-001", description: "Flags records with abnormal or high observation interpretations.", evidence: abnormalLabs.map { "\($0.display): \($0.interpretation ?? "")" })]
                )
            )
        }

        let activeConditions = record.conditions.filter { ($0.clinicalStatus ?? "").localizedCaseInsensitiveContains("active") }
        let medicationCount = record.medicationRequests.filter { ($0.status ?? "").localizedCaseInsensitiveContains("active") }.count
        if activeConditions.count >= 2 && medicationCount == 0 {
            output.append(
                ClinicalRecommendation(
                    id: "medication-reconciliation",
                    title: "Confirm medication reconciliation",
                    rationale: "Multiple active diagnoses are present without active medication requests in the normalized record.",
                    confidence: 0.72,
                    affectedMeasures: ["Medication safety", "Care gap closure"],
                    ruleTraces: [.init(ruleID: "CDS-MED-REC-001", description: "Compares active condition count with active medication requests.", evidence: ["activeConditions=\(activeConditions.count)", "activeMedicationRequests=\(medicationCount)"])]
                )
            )
        }

        if utilization.map(\.value).average > 80 {
            output.append(
                ClinicalRecommendation(
                    id: "utilization-follow-up",
                    title: "Schedule high-utilization follow-up",
                    rationale: "Recent utilization signal is above the high-touch care threshold.",
                    confidence: 0.68,
                    affectedMeasures: ["Readmission risk", "Avoidable utilization"],
                    ruleTraces: [.init(ruleID: "CDS-UTIL-001", description: "Flags average utilization above 80.", evidence: ["average=\(utilization.map(\.value).average)"])]
                )
            )
        }

        return output
    }
}

struct NoteAnalysisRequest: Equatable {
    let noteID: String
    let redactedText: String
    let metadata: [String: String]
}

struct NoteAnalysisResult: Equatable {
    let noteID: String
    let structuredConcerns: [String]
    let sentiment: String
    let tonalityCues: [String]
    let topicClusters: [String]
    let safetyFlags: [String]
    let phiBoundary: String
}

protocol ClinicalNoteLLMAnalyzing {
    func analyze(request: NoteAnalysisRequest) async throws -> NoteAnalysisResult
}

struct RuleBasedClinicalNoteAnalyzer: ClinicalNoteLLMAnalyzing {
    func analyze(request: NoteAnalysisRequest) async throws -> NoteAnalysisResult {
        let text = request.redactedText.lowercased()
        let concerns = ["pain", "breath", "fall", "medication", "confusion"].filter { text.contains($0) }
        let safetyFlags = ["suicidal", "self harm", "abuse", "overdose"].filter { text.contains($0) }
        let sentiment = text.contains("frustrated") || text.contains("angry") ? "negative" : "neutral"
        let topics = concerns.isEmpty ? ["general clinical note"] : concerns.map { "\($0) concern" }

        return NoteAnalysisResult(
            noteID: request.noteID,
            structuredConcerns: concerns,
            sentiment: sentiment,
            tonalityCues: sentiment == "negative" ? ["frustration cue"] : [],
            topicClusters: topics,
            safetyFlags: safetyFlags,
            phiBoundary: "Only redactedText is sent to the analyzer; patient identifiers remain outside the LLM boundary."
        )
    }
}

protocol NoteAnalysisPipelining {
    func analyze(notes: [NoteAnalysisRequest]) async throws -> [NoteAnalysisResult]
}

struct NoteAnalysisPipeline: NoteAnalysisPipelining {
    let analyzer: ClinicalNoteLLMAnalyzing

    func analyze(notes: [NoteAnalysisRequest]) async throws -> [NoteAnalysisResult] {
        var output: [NoteAnalysisResult] = []
        for note in notes {
            output.append(try await analyzer.analyze(request: note))
        }
        return output
    }
}

struct WarehouseEndpoint: Equatable {
    let path: String
    let description: String
    let mapsTo: String
}

struct WarehouseContract: Equatable {
    let basePath: String
    let endpoints: [WarehouseEndpoint]

    static let healthcareAnalytics = WarehouseContract(
        basePath: "/api/v1/warehouse",
        endpoints: [
            .init(path: "/cohorts", description: "Cohort membership, eligibility, and attribution windows.", mapsTo: "Cohort"),
            .init(path: "/encounters", description: "Encounter facts with admission, discharge, location, and service-line fields.", mapsTo: "HealthcareEncounter"),
            .init(path: "/utilization", description: "Utilization measures including ED visits, admissions, bed-days, and no-shows.", mapsTo: "OperationDataPoint"),
            .init(path: "/summaries/drg-icd", description: "DRG, ICD, and case-mix rollups by service line.", mapsTo: "TrendMetric"),
            .init(path: "/observations/loinc", description: "LOINC-coded observation facts and abnormality flags.", mapsTo: "HealthcareObservation"),
            .init(path: "/reports/aggregates", description: "Pre-aggregated report sections for executive and clinical packs.", mapsTo: "PDFReportSection")
        ]
    )
}

protocol WarehouseAPIClientProtocol {
    func cohorts() async throws -> [Cohort]
    func encounters(cohortID: String) async throws -> [HealthcareEncounter]
    func utilization(cohortID: String) async throws -> [OperationDataPoint]
    func drgICDSummaries(cohortID: String) async throws -> [TrendMetric]
    func loincObservations(cohortID: String) async throws -> [HealthcareObservation]
    func reportAggregates(cohortID: String) async throws -> [PDFReportSection]
}

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

private extension Array where Element == OperationDataPoint {
    var average: Double {
        map(\.value).average
    }
}

private extension String {
    var nullLike: Bool {
        let normalized = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized.isEmpty || ["null", "nil", "n/a", "na", "unknown", "none", "-"].contains(normalized)
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    var asPercent: String {
        "\(rounded(toPlaces: 3) * 100)%"
    }
}

