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
                ArchitectureMapView(workbench: workbench)
            }
            .tabItem {
                Label("Architecture", systemImage: "map")
            }
        }
        .tint(.teal)
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
        .background(Color(.systemGroupedBackground))
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
        .background(Color(.systemGroupedBackground))
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
                                .tint(.teal)
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
        .background(Color(.systemGroupedBackground))
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
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Insights")
    }
}

private struct ReportsView: View {
    let workbench: AnalyticsWorkbench

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Report generation", subtitle: "Executive, clinical, and stewardship-ready exports")

                VStack(spacing: 12) {
                    ForEach(workbench.reports) { report in
                        ReportCard(report: report)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
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
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Integrations")
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
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Architecture")
    }
}

private struct HeroCard: View {
    let title: String
    let subtitle: String
    let tag: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(tag.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.teal)

            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.teal.opacity(0.18), Color.blue.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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

#Preview {
    ContentView()
}
