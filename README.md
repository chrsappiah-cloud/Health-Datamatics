# HealthInformaticsIQ

HealthInformaticsIQ is an iOS-first healthcare analytics cockpit for clinicians, administrators, and informatics teams. It condenses healthcare IT architecture, SQL/data warehousing, HL7/FHIR interoperability, ontologies, data quality, machine learning, dashboards, and reporting workflows into a local-first SwiftUI starter.

The app is not intended to be just a chart viewer. It is an informatics workbench that can ingest normalized healthcare data, detect trends, surface data-quality issues, generate transparent interpretations, and assemble report-ready narratives that connect operational changes to patient outcomes.

## Core Surfaces

| Surface | Purpose |
| --- | --- |
| Dashboard | KPI cards, quality and outcome trends, alerts, and executive summaries. |
| Patients | Longitudinal patient summaries, cohorts, care gaps, and risk flags. |
| Data Quality | Missingness, duplicates, coding gaps, broken references, outliers, and governance controls. |
| Insights | Descriptive, diagnostic, predictive, and prescriptive analytics with rationale and confidence. |
| Reports | PDF-ready executive, clinical, and stewardship report sections. |
| Integrations | FHIR, HL7, vendor API, and warehouse-backed readiness context. |
| Architecture | Book-to-app condensation that maps domain themes to app surfaces, service contracts, and backend assumptions. |

## Architecture

The starter separates ingestion, normalization, analytics, quality checks, insights, reports, and presentation:

- `AppContainer.swift` defines dependency injection boundaries for analytics, quality, reporting, insight, NLP, and warehouse contracts.
- `HealthcareDataServices.swift` contains SMART-on-FHIR authentication abstractions, async caching, paginated FHIR fetching, and normalization into local Swift models.
- `HealthcareAnalyticsEngines.swift` contains the trend engine, data quality analyzer, report section generator, CDS-style insight engine, note-analysis pipeline, and warehouse API contract.
- `AnalyticsWorkbench.swift` provides preview data and the architecture map that drives the SwiftUI starter.
- `ContentView.swift` implements the SwiftUI + Charts local-first workbench surfaces.

## Feature Flow

1. Fetch FHIR resources or warehouse aggregates.
2. Normalize codes, timestamps, references, and units into local Swift models.
3. Compute KPIs, moving averages, readmission rates, lab trends, and intervention opportunities.
4. Detect missingness, duplicate anomalies, terminology gaps, broken references, outliers, and timestamp inconsistencies.
5. Generate explainable insights with rationale, confidence, affected measures, and exact rule traces.
6. Assemble executive or clinical report sections with charts, interpretation, caveats, and disclaimer blocks.

## Backend Assumptions

The app is designed to work with SMART-on-FHIR, warehouse APIs, cloud analytics services, or edge-AI backends through protocol-oriented boundaries. The iOS app can run from cached local data and progressively hydrate from production services as those adapters are implemented.
