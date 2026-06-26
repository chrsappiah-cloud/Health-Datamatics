//
//  HealthcareArchitectureTests.swift
//  Health-DatamaticsTests
//
//  Created by Codex on 17/6/2026.
//

import Foundation
import Testing
@testable import Health_Datamatics

struct HealthcareArchitectureTests {

    @Test func smartFHIRClientHandlesPaginationAndCaching() async throws {
        let baseURL = try #require(URL(string: "https://fhir.example.test"))
        let page1 = """
        {
          "resourceType": "Bundle",
          "entry": [
            { "resource": { "resourceType": "Patient", "id": "p1", "name": [{ "family": "Rivera", "given": ["Maya"] }] } }
          ],
          "link": [{ "relation": "next", "url": "https://fhir.example.test/Patient?page=2" }]
        }
        """.data(using: .utf8)!
        let page2 = """
        {
          "resourceType": "Bundle",
          "entry": [
            { "resource": { "resourceType": "Patient", "id": "p2", "name": [{ "family": "Singh", "given": ["Arun"] }] } }
          ]
        }
        """.data(using: .utf8)!
        let transport = FakeHTTPTransport(responses: [
            "https://fhir.example.test/Patient": page1,
            "https://fhir.example.test/Patient?page=2": page2
        ])
        let tokenStore = InMemoryTokenStore()
        await tokenStore.save(accessToken: "token", expiry: nil)
        let authenticator = SMARTAuthenticator(
            configuration: SMARTConfiguration(issuerURL: baseURL, tokenURL: baseURL.appendingPathComponent("token"), clientID: "client", scopes: ["patient/*.read"], redirectURI: nil),
            tokenStore: tokenStore
        )
        let client = SMARTFHIRClient(baseURL: baseURL, authenticator: authenticator, transport: transport, cache: ResponseCache())

        let firstFetch = try await client.fetchResource(FHIRPatient.self, path: "Patient", queryItems: [])
        let secondFetch = try await client.fetchResource(FHIRPatient.self, path: "Patient", queryItems: [])

        #expect(firstFetch.map(\.id) == ["p1", "p2"])
        #expect(secondFetch.map(\.id) == ["p1", "p2"])
        #expect(await transport.requestCount == 2)
    }

    @Test func trendEngineComputesMovingAveragesReadmissionsAndInterventions() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let utilization = [
            OperationDataPoint(id: "u1", date: now, value: 70, label: "W1"),
            OperationDataPoint(id: "u2", date: now.addingTimeInterval(86_400), value: 80, label: "W2"),
            OperationDataPoint(id: "u3", date: now.addingTimeInterval(172_800), value: 95, label: "W3")
        ]
        let readmissions = [
            ReadmissionEvent(id: "r1", dischargeDate: now, readmittedDate: now.addingTimeInterval(10 * 86_400)),
            ReadmissionEvent(id: "r2", dischargeDate: now, readmittedDate: nil),
            ReadmissionEvent(id: "r3", dischargeDate: now, readmittedDate: nil)
        ]
        let observations = [
            HealthcareObservation(id: "o1", patientID: "p1", encounterID: "e1", code: "718-7", display: "Hemoglobin", value: 10, unit: "g/dL", effectiveAt: now, interpretation: nil),
            HealthcareObservation(id: "o2", patientID: "p1", encounterID: "e1", code: "718-7", display: "Hemoglobin", value: 12, unit: "g/dL", effectiveAt: now.addingTimeInterval(86_400), interpretation: "High"),
            HealthcareObservation(id: "o3", patientID: "p1", encounterID: "e1", code: "718-7", display: "Hemoglobin", value: 14, unit: "g/dL", effectiveAt: now.addingTimeInterval(172_800), interpretation: "High")
        ]

        let result = HealthcareTrendEngine().analyze(observations: observations, readmissions: readmissions, utilization: utilization)

        #expect(result.movingAverage.map(\.value) == [70, 75, 81.66666666666667])
        #expect(result.readmissionRate.value > 0.3)
        #expect(result.abnormalLabTrends.count == 1)
        #expect(result.interventions.contains { $0.id == "readmission-navigator" })
        #expect(result.operationalMetrics.map(\.kind).contains(.predictive))
    }

    @Test func dataQualityAnalyzerFindsEvidenceAndRemediation() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let record = HealthcareClinicalRecord(
            patient: HealthcarePatient(id: "p1", mrn: "MRN1", displayName: "Unknown", gender: nil, birthDate: nil),
            encounters: [
                HealthcareEncounter(id: "e1", patientID: "p1", status: "finished", classCode: "IMP", startedAt: now, endedAt: now.addingTimeInterval(-60))
            ],
            observations: [
                HealthcareObservation(id: "o1", patientID: "p1", encounterID: "missing", code: "BAD", display: "Systolic blood pressure", value: 300, unit: "mmHg", effectiveAt: now, interpretation: nil),
                HealthcareObservation(id: "o2", patientID: "p1", encounterID: "e1", code: "8480-6", display: "Blood pressure", value: nil, unit: nil, effectiveAt: now, interpretation: nil)
            ],
            conditions: [],
            medicationRequests: [],
            diagnosticReports: []
        )

        let issues = HealthcareDataQualityAnalyzer().analyze(record: record)

        #expect(issues.contains { $0.dimension == "Null-like missingness" })
        #expect(issues.contains { $0.dimension == "Broken references" })
        #expect(issues.contains { $0.dimension == "Outliers" })
        #expect(issues.contains { $0.dimension == "Inconsistent timestamps" })
        #expect(issues.allSatisfy { !$0.recommendedRemediation.isEmpty })
    }

    @Test func insightReportAndNoteLayersRemainExplainable() async throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let record = HealthcareClinicalRecord(
            patient: HealthcarePatient(id: "p1", mrn: "MRN1", displayName: "Maya Rivera", gender: "female", birthDate: "1971-01-01"),
            encounters: [],
            observations: [
                HealthcareObservation(id: "o1", patientID: "p1", encounterID: nil, code: "718-7", display: "Hemoglobin", value: 14, unit: "g/dL", effectiveAt: now, interpretation: "High")
            ],
            conditions: [
                HealthcareCondition(id: "c1", patientID: "p1", code: "I50", display: "Heart failure", onsetAt: now, clinicalStatus: "active"),
                HealthcareCondition(id: "c2", patientID: "p1", code: "E11", display: "Diabetes", onsetAt: now, clinicalStatus: "active")
            ],
            medicationRequests: [],
            diagnosticReports: []
        )
        let insights = ClinicianInsightEngine().recommendations(record: record, utilization: [OperationDataPoint(id: "u1", date: now, value: 90, label: "W1")])
        let reportSections = HealthcareReportSectionGenerator().sections(workbench: .preview, clinicalRecord: record, trendResult: nil, qualityIssues: [], insights: insights)
        let noteResults = try await NoteAnalysisPipeline(analyzer: RuleBasedClinicalNoteAnalyzer()).analyze(notes: [
            NoteAnalysisRequest(noteID: "n1", redactedText: "Patient reports pain and frustrated tone. No identifiers included.", metadata: [:])
        ])

        #expect(insights.allSatisfy { !$0.rationale.isEmpty && !$0.ruleTraces.isEmpty })
        #expect(reportSections.map(\.id).contains("disclaimer"))
        #expect(reportSections.map(\.id).contains("patient-impact"))
        #expect(noteResults.first?.structuredConcerns.contains("pain") == true)
        #expect(noteResults.first?.phiBoundary.contains("redactedText") == true)
    }

    @Test func warehouseContractMapsRequiredBackendEndpoints() {
        let contract = WarehouseContract.healthcareAnalytics
        let paths = Set(contract.endpoints.map(\.path))

        #expect(paths.contains("/cohorts"))
        #expect(paths.contains("/encounters"))
        #expect(paths.contains("/utilization"))
        #expect(paths.contains("/summaries/drg-icd"))
        #expect(paths.contains("/observations/loinc"))
        #expect(paths.contains("/reports/aggregates"))
        #expect(contract.endpoints.allSatisfy { !$0.mapsTo.isEmpty })
    }
}

actor FakeHTTPTransport: HTTPTransport {
    private let responses: [String: Data]
    private(set) var requestCount = 0

    init(responses: [String: Data]) {
        self.responses = responses
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requestCount += 1
        let key = request.url?.absoluteString ?? ""
        let data = responses[key] ?? Data("{}".utf8)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

