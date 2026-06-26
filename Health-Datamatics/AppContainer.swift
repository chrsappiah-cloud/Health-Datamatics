//
//  AppContainer.swift
//  Health-Datamatics
//
//  Created by Codex on 17/6/2026.
//

import Foundation

struct AppContainer {
    let trendAnalyzer: TrendAnalyzing
    let dataQualityAnalyzer: DataQualityAnalyzing
    let reportGenerator: ReportSectionGenerating
    let insightGenerator: ClinicalInsightGenerating
    let notePipeline: NoteAnalysisPipelining
    let warehouseContract: WarehouseContract

    static let preview = AppContainer(
        trendAnalyzer: HealthcareTrendEngine(),
        dataQualityAnalyzer: HealthcareDataQualityAnalyzer(),
        reportGenerator: HealthcareReportSectionGenerator(),
        insightGenerator: ClinicianInsightEngine(),
        notePipeline: NoteAnalysisPipeline(analyzer: RuleBasedClinicalNoteAnalyzer()),
        warehouseContract: .healthcareAnalytics
    )
}
