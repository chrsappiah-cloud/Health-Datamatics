# Implementation Prompts

## 1. FHIR Integration Prompt

Build a Swift service layer that authenticates against a SMART-on-FHIR compatible endpoint, fetches Patient, Encounter, Observation, Condition, MedicationRequest, and DiagnosticReport resources, normalizes them into local Swift models, and caches them with async/await. Include error handling, pagination, and unit-testable protocols.

## 2. Trend Analytics Prompt

Implement a trend engine that computes descriptive, diagnostic, predictive, and prescriptive metrics for healthcare operations. Include moving averages, rolling readmission rates, abnormal lab trend detection, and intervention suggestions with transparent rule traces.

## 3. Data Quality Prompt

Create a healthcare data quality analyzer in Swift that detects null-like missingness, code mismatches, duplicate patients, broken foreign-key style references, outliers, inconsistent timestamps, and incomplete observations. Return severity, evidence, and recommended remediation steps.

## 4. Report Generation Prompt

Generate PDF-ready report sections from app state: executive summary, cohort overview, trends, risks, quality issues, intervention opportunities, and patient impact narrative. Include charts, plain-language interpretation, and disclaimer blocks.

## 5. CDS-Inspired Insights Prompt

Build a clinician-facing insight layer that transforms observations, diagnoses, medications, and utilization signals into explainable recommendations. Every recommendation must include rationale, confidence, affected measures, and the exact rules or models that produced it.

## 6. NLP Prompt

Add a note-analysis pipeline that extracts structured concerns from clinical notes using an LLM-compatible abstraction. Support sentiment and tonality cues for patient feedback, topic clustering, and safety-flag detection while keeping PHI-safe boundaries.

## 7. Warehouse Integration Prompt

Design a backend contract for a healthcare data warehouse with endpoints for cohorts, encounters, utilization, DRG/ICD summaries, LOINC observations, and report aggregates. Map the JSON payloads to the Swift models already included in the starter.

## Book-to-App Condensation

| Source theme | App condensation |
| --- | --- |
| Healthcare IT landscape | Integration layer, governance screens, workflow context. |
| Relational databases and SQL | Repository contracts, cohort queries, aggregate endpoints. |
| HL7/FHIR/CDA/DICOM | Interoperability adapters and normalization layer. |
| Ontologies and codesets | ICD, SNOMED CT, LOINC, and HCPCS mapping services. |
| pandas/NumPy/data quality | Quality analyzer, missingness views, transformation pipeline. |
| Machine learning and explainability | Risk models, trend interpretation, confidence and rationale UI. |
| Hadoop/Spark/cloud/MLOps | Backend assumptions for scalable warehouse and model deployment. |
| Descriptive/diagnostic/predictive/prescriptive analytics | Analytics tabs and report sections. |
| BI dashboards and visualization | KPI cards, charts, dashboard summaries. |
| Sentiment/social analytics/bibliometrics | Patient feedback analytics, public-health trend watch, research trend mapping. |
| Platform/vendor mindset | Modular adapters for BI summaries, semantic layers, cloud analytics services, and edge AI. |
| SwiftUI + Charts | Local-first analytics UI with async/await service boundaries. |
