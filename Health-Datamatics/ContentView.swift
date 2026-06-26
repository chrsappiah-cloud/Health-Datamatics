//
//  ContentView.swift
//  Health-Datamatics
//
//  Created by Christopher Appiah-Thompson  on 17/6/2026.
//

import Charts
import SwiftUI

struct ContentView: View {
    private let workbench = AnalyticsWorkbench.preview

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView(workbench: workbench)
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.xyaxis.line")
            }

            NavigationStack {
                PatientsView(workbench: workbench)
            }
            .tabItem {
                Label("Patients", systemImage: "person.3.fill")
            }

            NavigationStack {
                DataQualityView(workbench: workbench)
            }
            .tabItem {
                Label("Quality", systemImage: "checklist.checked")
            }

            NavigationStack {
                InsightsView(workbench: workbench)
            }
            .tabItem {
                Label("Insights", systemImage: "lightbulb.max.fill")
            }

            NavigationStack {
                ToolsView()
            }
            .tabItem {
                Label("Tools", systemImage: "slider.horizontal.3")
            }

            NavigationStack {
                ReportsView(workbench: workbench)
            }
            .tabItem {
                Label("Reports", systemImage: "doc.richtext")
            }

            NavigationStack {
                IntegrationsView(workbench: workbench)
            }
            .tabItem {
                Label("Integrations", systemImage: "point.3.connected.trianglepath.dotted")
            }

            NavigationStack {
                AboutAccessView(workbench: workbench)
            }
            .tabItem {
                Label("Access", systemImage: "person.crop.circle.badge.checkmark")
            }
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }
}

private struct DashboardView: View {
    let workbench: AnalyticsWorkbench

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroCard(title: workbench.title, subtitle: workbench.subtitle, tag: "Healthcare analytics workbench")
                    .accessibilityIdentifier("dashboard-hero")

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(workbench.kpis) { metric in
                        MetricCard(metric: metric)
                    }
                }

                SectionCard(title: "Trend mapping", subtitle: "Risk-adjusted quality index") {
                    Chart(workbench.trendSeries) { point in
                        AreaMark(
                            x: .value("Week", point.period),
                            y: .value("Score", point.value)
                        )
                        .foregroundStyle(.teal.opacity(0.18))

                        LineMark(
                            x: .value("Week", point.period),
                            y: .value("Score", point.value)
                        )
                        .foregroundStyle(.teal)
                        .lineStyle(.init(lineWidth: 3))

                        PointMark(
                            x: .value("Week", point.period),
                            y: .value("Score", point.value)
                        )
                        .foregroundStyle(.teal)
                    }
                    .frame(height: 220)
                }

                SectionHeader(title: "Active alerts", subtitle: "Quality, interoperability, and care delivery watchpoints")

                VStack(spacing: 12) {
                    ForEach(workbench.alerts) { alert in
                        AlertRow(alert: alert)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("dashboard-screen")
        .workbenchBackground()
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct PatientsView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Longitudinal patient summaries", subtitle: "Cohorts, care gaps, and risk flags")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(workbench.cohorts) { cohort in
                            CohortCard(cohort: cohort)
                        }
                    }
                    .padding(.vertical, 2)
                }

                VStack(spacing: 12) {
                    ForEach(workbench.patients) { patient in
                        PatientCard(patient: patient)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("patients-screen")
        .workbenchBackground()
        .navigationTitle("Patients")
    }
}

private struct DataQualityView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard(title: "Data quality posture", subtitle: "Warehouse, HL7, and FHIR readiness") {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Overall score")
                                    .font(.headline)
                                Spacer()
                                Text("\(workbench.qualitySnapshot.overallScore)%")
                                    .font(.title3.bold())
                                    .foregroundStyle(.teal)
                            }

                            ProgressView(value: Double(workbench.qualitySnapshot.overallScore), total: 100)
                                .tint(.cyan)
        .preferredColorScheme(.dark)
                        }

                        StatLine(label: "Warehouse lineage", value: workbench.qualitySnapshot.warehouseCoverage)
                        StatLine(label: "FHIR synchronization", value: workbench.qualitySnapshot.fhirSync)
                        StatLine(label: "HL7 latency", value: workbench.qualitySnapshot.hl7Latency)
                    }
                }

                SectionHeader(title: "Rule-based checks", subtitle: "Missingness, duplicates, coding gaps, and anomalies")

                VStack(spacing: 12) {
                    ForEach(workbench.qualityChecks) { check in
                        QualityCheckCard(check: check)
                    }
                }

                SectionHeader(title: "Governance controls", subtitle: "Lineage, terminology, privacy, and release readiness")

                VStack(spacing: 12) {
                    ForEach(workbench.governanceControls) { control in
                        GovernanceControlCard(control: control)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("quality-screen")
        .workbenchBackground()
        .navigationTitle("Data Quality")
    }
}

private struct InsightsView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Explainable insights", subtitle: "Descriptive, diagnostic, predictive, and prescriptive workflows")

                VStack(spacing: 12) {
                    ForEach(workbench.insights) { insight in
                        InsightCard(insight: insight)
                    }
                }

                SectionHeader(title: "Analytics workflow", subtitle: "Descriptive, diagnostic, predictive, and prescriptive paths")

                VStack(spacing: 12) {
                    ForEach(workbench.workflowStages) { stage in
                        WorkflowStageCard(stage: stage)
                    }
                }

                SectionHeader(title: "Trend and literature signals", subtitle: "Sentiment and bibliometric mapping cues")

                VStack(spacing: 12) {
                    ForEach(workbench.trendSignals) { signal in
                        TrendSignalRow(signal: signal)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("insights-screen")
        .workbenchBackground()
        .navigationTitle("Insights")
    }
}

private struct ToolsView: View {
    @State private var followUpComplete = true
    @State private var medicationReconciled = false
    @State private var priorAdmissions = 2.0
    @State private var abnormalLabs = 3.0
    @State private var missingFields = 7.0
    @State private var duplicateRows = 3.0
    @State private var codedRows = 84.0
    @State private var selectedCode = "8480-6"
    @State private var reportAudience = "Clinical directors"
    @State private var includeQualityAppendix = true

    private let codeMap: [String: (name: String, system: String, use: String)] = [
        "8480-6": ("Systolic blood pressure", "LOINC", "Vitals trend monitoring"),
        "4548-4": ("Hemoglobin A1c", "LOINC", "Diabetes cohort control"),
        "I50.9": ("Heart failure, unspecified", "ICD-10-CM", "Readmission cohort inclusion"),
        "38341003": ("Hypertensive disorder", "SNOMED CT", "Problem-list normalization")
    ]

    private var riskScore: Int {
        var score = Int(priorAdmissions * 12 + abnormalLabs * 7)
        score += followUpComplete ? -14 : 16
        score += medicationReconciled ? -10 : 12
        return min(max(score, 5), 96)
    }

    private var qualityScore: Int {
        let penalty = Int(missingFields * 2 + duplicateRows * 4 + max(0, 95 - codedRows))
        return min(max(100 - penalty, 0), 100)
    }

    private var riskBand: (title: String, color: Color, action: String) {
        switch riskScore {
        case 70...:
            return ("High", .red, "Schedule nurse navigator outreach within 24 hours and verify discharge medications.")
        case 40..<70:
            return ("Moderate", .orange, "Confirm follow-up appointment and review abnormal-result queue.")
        default:
            return ("Low", .teal, "Continue standard pathway and monitor the next scheduled encounter.")
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Public analytics tools", subtitle: "Use built-in calculators and templates without an account, invitation, or paid subscription")

                SectionCard(title: "Readmission risk estimator", subtitle: "Adjust care-transition signals and see an explainable recommendation") {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Follow-up booked", isOn: $followUpComplete)
                        Toggle("Medication reconciliation complete", isOn: $medicationReconciled)
                        SliderControl(title: "Prior admissions", value: $priorAdmissions, range: 0...6, format: "%.0f")
                        SliderControl(title: "Abnormal lab flags", value: $abnormalLabs, range: 0...8, format: "%.0f")

                        ResultBand(title: "\(riskScore)% \(riskBand.title) risk", detail: riskBand.action, color: riskBand.color)
                    }
                }

                SectionCard(title: "Dataset quality scorer", subtitle: "Model missingness, duplicates, and coding coverage before releasing a dashboard") {
                    VStack(alignment: .leading, spacing: 16) {
                        SliderControl(title: "Missing required fields", value: $missingFields, range: 0...20, format: "%.0f")
                        SliderControl(title: "Potential duplicate rows", value: $duplicateRows, range: 0...12, format: "%.0f")
                        SliderControl(title: "Terminology coverage", value: $codedRows, range: 60...100, format: "%.0f%%")

                        ProgressView(value: Double(qualityScore), total: 100)
                            .tint(qualityScore >= 85 ? .teal : qualityScore >= 70 ? .orange : .red)

                        ResultBand(
                            title: "\(qualityScore)% release readiness",
                            detail: qualityScore >= 85 ? "Ready for stakeholder review with routine steward sign-off." : "Hold release and remediate the highest-impact quality findings.",
                            color: qualityScore >= 85 ? .teal : .orange
                        )
                    }
                }

                SectionCard(title: "Terminology mapper", subtitle: "Look up common healthcare codes used by the sample analytics workflows") {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Code", selection: $selectedCode) {
                            ForEach(codeMap.keys.sorted(), id: \.self) { code in
                                Text(code).tag(code)
                            }
                        }
                        .pickerStyle(.segmented)

                        if let item = codeMap[selectedCode] {
                            StatLine(label: "Display", value: item.name)
                            StatLine(label: "Code system", value: item.system)
                            StatLine(label: "Analytics use", value: item.use)
                        }
                    }
                }

                SectionCard(title: "Report assembler", subtitle: "Preview the sections a user can generate from app content") {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Audience", selection: $reportAudience) {
                            Text("Clinical directors").tag("Clinical directors")
                            Text("Executives").tag("Executives")
                            Text("Data stewards").tag("Data stewards")
                        }
                        .pickerStyle(.menu)

                        Toggle("Include quality appendix", isOn: $includeQualityAppendix)

                        VStack(alignment: .leading, spacing: 8) {
                            ReportLine(number: 1, title: "\(reportAudience) summary")
                            ReportLine(number: 2, title: "Risk trends and cohort movement")
                            ReportLine(number: 3, title: "Recommended actions with rationale")
                            if includeQualityAppendix {
                                ReportLine(number: 4, title: "Data quality appendix and steward notes")
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("tools-screen")
        .workbenchBackground()
        .navigationTitle("Tools")
    }
}

private struct ReportsView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Report generation", subtitle: "Executive, clinical, and stewardship-ready exports")
                    .accessibilityIdentifier("reports-generation")

                VStack(spacing: 12) {
                    ForEach(workbench.reports) { report in
                        ReportCard(report: report)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("reports-screen")
        .workbenchBackground()
        .navigationTitle("Reports")
    }
}

private struct IntegrationsView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Integration readiness", subtitle: "FHIR, HL7, vendor APIs, and warehouse-backed queries")
                    .accessibilityIdentifier("integrations-readiness")

                VStack(spacing: 12) {
                    ForEach(workbench.integrations) { integration in
                        IntegrationCard(integration: integration)
                    }
                }

                SectionCard(title: "Reference architecture", subtitle: "Operational feeds become governed analytics products") {
                    VStack(alignment: .leading, spacing: 14) {
                        ArchitectureStep(icon: "server.rack", title: "Ingest", detail: "FHIR resources, HL7 ADT messages, vendor APIs, and SQL extracts land in controlled staging.")
                        ArchitectureStep(icon: "square.stack.3d.up", title: "Model", detail: "Warehouse marts standardize patients, encounters, observations, cohorts, and ML features.")
                        ArchitectureStep(icon: "doc.text.magnifyingglass", title: "Explain", detail: "Dashboards, insight cards, and PDF reports expose rationale, quality caveats, and ownership.")
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("integrations-screen")
        .workbenchBackground()
        .navigationTitle("Integrations")
    }
}

private struct AboutAccessView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroCard(
                    title: "Health-Datamatics",
                    subtitle: "A public healthcare analytics reference app with sample dashboards, calculators, quality checks, interoperability examples, and report-building workflows.",
                    tag: "Public app access"
                )

                SectionCard(title: "Who can use this app?", subtitle: "Designed for the general public and healthcare analytics learners") {
                    VStack(alignment: .leading, spacing: 12) {
                        AccessFact(icon: "globe", title: "Public audience", detail: "Anyone who downloads the app can open the dashboards, tools, reports, integration examples, and architecture references.")
                        AccessFact(icon: "person.crop.circle.badge.xmark", title: "No organization restriction", detail: "The app is not limited to one company, client, hospital, partner, employee group, or contractor group.")
                        AccessFact(icon: "lock.open", title: "No account required", detail: "Users do not need an invitation, approval, pre-registration, or enterprise login to use the included functionality.")
                    }
                }

                SectionCard(title: "Business model", subtitle: "No paid digital content is unlocked in the app") {
                    VStack(alignment: .leading, spacing: 12) {
                        AccessFact(icon: "creditcard", title: "No in-app purchases", detail: "There are no subscriptions, paid accounts, paid feature tiers, or externally purchased digital content in this build.")
                        AccessFact(icon: "doc.text.magnifyingglass", title: "Educational sample data", detail: "All visible dashboards use sample, non-production healthcare analytics scenarios for demonstration and learning.")
                        AccessFact(icon: "shippingbox", title: "No enterprise service sale", detail: "The app does not sell enterprise services to single users, consumers, families, or organizations inside the app.")
                    }
                }

                SectionCard(title: "Included functionality", subtitle: "What a reviewer can try immediately") {
                    VStack(alignment: .leading, spacing: 12) {
                        AccessFact(icon: "chart.xyaxis.line", title: "Dashboards and charts", detail: "Explore KPIs, trend lines, active alerts, cohorts, patient summaries, and governance controls.")
                        AccessFact(icon: "slider.horizontal.3", title: "Interactive tools", detail: "Estimate readmission risk, score dataset quality, map healthcare codes, and assemble report sections.")
                        AccessFact(icon: "point.3.connected.trianglepath.dotted", title: "Interoperability reference", detail: "Review FHIR, HL7, warehouse, terminology, and architecture mappings used by modern health analytics teams.")
                    }
                }

                SectionHeader(title: "Architecture reference", subtitle: "Domain-to-app mapping remains available for technical reviewers")

                VStack(spacing: 12) {
                    ForEach(workbench.architectureMappings.prefix(6)) { mapping in
                        ArchitectureMappingCard(mapping: mapping)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("access-screen")
        .workbenchBackground()
        .navigationTitle("Access")
    }
}

private struct ArchitectureMapView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Architecture map", subtitle: "Book-to-app condensation across UI, services, data, and backend assumptions")
                    .accessibilityIdentifier("architecture-map")

                SectionCard(title: "Capability stack", subtitle: "From clinical systems to explainable action") {
                    VStack(alignment: .leading, spacing: 14) {
                        ArchitectureStep(icon: "network", title: "Connect", detail: "SMART-on-FHIR, HL7, warehouse, and vendor adapters hydrate normalized Swift models.")
                        ArchitectureStep(icon: "checkmark.seal", title: "Govern", detail: "Terminology, lineage, privacy, missingness, and data stewardship checks preserve trust.")
                        ArchitectureStep(icon: "chart.line.uptrend.xyaxis", title: "Analyze", detail: "Descriptive, diagnostic, predictive, and prescriptive engines compute transparent measures.")
                        ArchitectureStep(icon: "doc.richtext", title: "Explain", detail: "Insight cards and PDF-ready sections preserve rationale, confidence, caveats, and rule traces.")
                    }
                }

                SectionHeader(title: "Source themes", subtitle: "How each domain theme becomes app behavior")

                VStack(spacing: 12) {
                    ForEach(workbench.architectureMappings) { mapping in
                        ArchitectureMappingCard(mapping: mapping)
                    }
                }
            }
            .padding(20)
        }
        .accessibilityIdentifier("architecture-screen")
        .workbenchBackground()
        .navigationTitle("Architecture")
    }
}

private struct HeroCard: View {
    let title: String
    let subtitle: String
    let tag: String

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Color.cyan.opacity(0.30), Color.indigo.opacity(0.22), Color.black.opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 82, height: 82)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.24), lineWidth: 1)
                        )

                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.white, .cyan)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(tag.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.cyan)

                    Text(title)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 96, weight: .light))
                .foregroundStyle(.white.opacity(0.10))
                .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .cyan.opacity(0.18), radius: 24, y: 12)
    }
}

private struct ArchitectureMappingCard: View {
    let mapping: DomainArchitectureMapping

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(mapping.sourceTheme)
                .font(.headline)

            StatLine(label: "App surface", value: mapping.appSurface)
            StatLine(label: "Service contract", value: mapping.serviceContract)
            StatLine(label: "Backend assumption", value: mapping.backendAssumption)

            Text(mapping.traceability)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct MetricCard: View {
    let metric: KPI

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(metric.title)
                    .font(.headline)
                Spacer()
                Image(systemName: metric.direction.symbol)
                    .foregroundStyle(metric.direction.color)
            }

            Text(metric.value)
                .font(.system(.title2, design: .rounded, weight: .bold))

            Text(metric.delta)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(metric.direction.color)

            Text(metric.footnote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumCard(cornerRadius: 20)
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: title, subtitle: subtitle)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 22)
    }
}

private struct AlertRow: View {
    let alert: AlertItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(alert.severity.color)
                .frame(width: 12, height: 12)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(alert.title)
                        .font(.headline)
                    Spacer()
                    StatusPill(title: alert.severity.title, color: alert.severity.color)
                }

                Text(alert.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Owner: \(alert.owner)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumCard(cornerRadius: 18)
    }
}

private struct CohortCard: View {
    let cohort: Cohort

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(cohort.name)
                .font(.headline)

            Text("\(cohort.count) patients")
                .font(.title3.bold())
                .foregroundStyle(.teal)

            Text(cohort.focus)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(width: 220, alignment: .leading)
        .padding(16)
        .premiumCard(cornerRadius: 20)
    }
}

private struct PatientCard: View {
    let patient: PatientSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.headline)
                    Text("\(patient.mrn) | Age \(patient.age)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                StatusPill(title: patient.riskLevel.title, color: patient.riskLevel.color)
            }

            StatLine(label: "Condition", value: patient.primaryCondition)
            StatLine(label: "Last encounter", value: patient.lastEncounter)
            StatLine(label: "Care gap", value: patient.careGap)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct QualityCheckCard: View {
    let check: QualityCheck

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(check.title)
                    .font(.headline)
                Spacer()
                StatusPill(title: check.status.title, color: check.status.color)
            }

            Text(check.finding)
                .font(.subheadline)

            Text(check.impact)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct GovernanceControlCard: View {
    let control: GovernanceControl

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(control.title)
                        .font(.headline)
                    Text(control.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusPill(title: control.status.title, color: control.status.color)
            }

            HStack {
                ProgressView(value: Double(control.coverage), total: 100)
                    .tint(control.status.color)
                Text("\(control.coverage)%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(control.status.color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct WorkflowStageCard: View {
    let stage: AnalyticsWorkflowStage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stage.name)
                        .font(.headline)
                    Text(stage.method)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(stage.owner)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            Text(stage.output)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct InsightCard: View {
    let insight: InsightStory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(insight.title)
                    .font(.headline)
                Spacer()
                Text("\(insight.confidence)% confidence")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            Text(insight.summary)
                .font(.subheadline)

            Divider()

            StatLine(label: "Why it matters", value: insight.explanation)
            StatLine(label: "Next best action", value: insight.recommendedAction)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct TrendSignalRow: View {
    let signal: TrendSignal

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: signal.direction.symbol)
                .foregroundStyle(signal.direction.color)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(signal.topic)
                        .font(.headline)
                    Spacer()
                    Text(signal.domain)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text(signal.evidence)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumCard(cornerRadius: 18)
    }
}

private struct ReportCard: View {
    let report: ReportTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.headline)
                    Text(report.audience)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(report.cadence)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            Text(report.summary)
                .font(.subheadline)

            HStack {
                StatusPill(title: report.pipelineState.title, color: report.pipelineState.color)
                Text(report.exportFormats.joined(separator: " | "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct ArchitectureStep: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct IntegrationCard: View {
    let integration: IntegrationStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(integration.system)
                        .font(.headline)
                    Text(integration.modality)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusPill(title: integration.state.title, color: integration.state.color)
            }

            StatLine(label: "Latency", value: integration.latency)
            Text(integration.note)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard(cornerRadius: 20)
    }
}

private struct StatusPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

private struct SliderControl: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: format, value))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            Slider(value: $value, in: range, step: 1)
                .tint(.cyan)
        }
    }
}

private struct ResultBand: View {
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(color)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ReportLine: View {
    let number: Int
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.black)
                .frame(width: 24, height: 24)
                .background(.cyan)
                .clipShape(Circle())

            Text(title)
                .font(.subheadline)
        }
    }
}

private struct AccessFact: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.teal)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct StatLine: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
        }
    }
}


private extension View {
    func workbenchBackground() -> some View {
        background {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.02, green: 0.05, blue: 0.08), Color(red: 0.03, green: 0.11, blue: 0.13), Color(red: 0.06, green: 0.06, blue: 0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 180, weight: .ultraLight))
                    .foregroundStyle(.cyan.opacity(0.035))
                    .offset(x: 120, y: -260)
            }
            .ignoresSafeArea()
        }
    }

    func premiumCard(cornerRadius: CGFloat) -> some View {
        background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 18, y: 10)
    }
}

#Preview {
    ContentView()
}
