//
//  Health_DatamaticsTests.swift
//  Health-DatamaticsTests
//
//  Created by Christopher Appiah-Thompson  on 17/6/2026.
//

import Testing
@testable import Health_Datamatics

struct Health_DatamaticsTests {

    @Test func previewWorkbenchIncludesCoreModules() async throws {
        let workbench = AnalyticsWorkbench.preview

        #expect(workbench.title == "HealthInformaticsIQ")
        #expect(workbench.kpis.count == 4)
        #expect(workbench.cohorts.count == 3)
        #expect(workbench.patients.count == 3)
        #expect(workbench.qualitySnapshot.overallScore > 80)
        #expect(workbench.governanceControls.count == 3)
    }

    @Test func previewWorkbenchIncludesExplainableInsightsAndIntegrations() async throws {
        let workbench = AnalyticsWorkbench.preview

        #expect(workbench.insights.allSatisfy { !$0.explanation.isEmpty })
        #expect(workbench.workflowStages.map(\.name) == ["Descriptive", "Diagnostic", "Predictive", "Prescriptive"])
        #expect(workbench.reports.contains { $0.exportFormats.contains("PDF") })
        #expect(workbench.integrations.contains { $0.modality.contains("FHIR") })
    }

    @Test func reportTemplatesExposeExportPipelineState() async throws {
        let workbench = AnalyticsWorkbench.preview

        #expect(workbench.reports.contains { $0.pipelineState.title == "Scheduled" })
        #expect(workbench.reports.allSatisfy { !$0.exportFormats.isEmpty })
    }

    @Test func previewWorkbenchIncludesBookToAppArchitectureMap() async throws {
        let workbench = AnalyticsWorkbench.preview
        let themes = workbench.architectureMappings.map(\.sourceTheme)

        #expect(workbench.architectureMappings.count == 12)
        #expect(themes.contains("Healthcare IT landscape"))
        #expect(themes.contains("HL7, FHIR, CDA, DICOM"))
        #expect(themes.contains("Ontologies and codesets"))
        #expect(themes.contains("Sentiment, social analytics, bibliometrics"))
        #expect(workbench.architectureMappings.allSatisfy { !$0.appSurface.isEmpty && !$0.serviceContract.isEmpty && !$0.traceability.isEmpty })
    }

}
