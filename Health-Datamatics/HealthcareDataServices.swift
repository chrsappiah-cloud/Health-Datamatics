//
//  HealthcareDataServices.swift
//  Health-Datamatics
//
//  Created by Codex on 17/6/2026.
//

import Foundation

enum HealthcareServiceError: Error, Equatable {
    case missingSMARTToken
    case invalidURL(String)
    case httpStatus(Int)
    case emptyBundle(String)
    case decodingFailed(String)
    case unsupportedResource(String)
}

protocol HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await data(for: request, delegate: nil)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HealthcareServiceError.httpStatus(-1)
        }
        return (data, httpResponse)
    }
}

protocol TokenStore {
    func accessToken() async throws -> String?
    func save(accessToken: String, expiry: Date?) async
}

actor InMemoryTokenStore: TokenStore {
    private var token: String?
    private var expiry: Date?

    func accessToken() async throws -> String? {
        if let expiry, expiry < Date() {
            token = nil
            self.expiry = nil
            return nil
        }
        return token
    }

    func save(accessToken: String, expiry: Date?) async {
        token = accessToken
        self.expiry = expiry
    }
}

struct SMARTConfiguration: Equatable {
    let issuerURL: URL
    let tokenURL: URL
    let clientID: String
    let scopes: [String]
    let redirectURI: URL?
}

protocol SMARTAuthenticating {
    func validAccessToken() async throws -> String
}

struct SMARTAuthenticator: SMARTAuthenticating {
    let configuration: SMARTConfiguration
    let tokenStore: TokenStore

    func validAccessToken() async throws -> String {
        guard let token = try await tokenStore.accessToken(), !token.isEmpty else {
            throw HealthcareServiceError.missingSMARTToken
        }
        return token
    }
}

actor ResponseCache {
    private var storage: [String: Data] = [:]

    func data(for key: String) -> Data? {
        storage[key]
    }

    func save(_ data: Data, for key: String) {
        storage[key] = data
    }

    func removeAll() {
        storage.removeAll()
    }
}

protocol FHIRResource: Decodable {
    static var resourceType: String { get }
    var id: String? { get }
}

struct FHIRBundle<Resource: FHIRResource>: Decodable {
    struct Entry: Decodable {
        let resource: Resource?
    }

    struct Link: Decodable {
        let relation: String
        let url: String
    }

    let entry: [Entry]?
    let link: [Link]?
}

struct FHIRPatient: FHIRResource {
    static let resourceType = "Patient"

    struct Name: Decodable {
        let family: String?
        let given: [String]?
    }

    let id: String?
    let identifier: [FHIRIdentifier]?
    let name: [Name]?
    let gender: String?
    let birthDate: String?
}

struct FHIREncounter: FHIRResource {
    static let resourceType = "Encounter"

    let id: String?
    let status: String?
    let `class`: FHIRCoding?
    let subject: FHIRReference?
    let period: FHIRPeriod?
    let reasonCode: [FHIRCodeableConcept]?
}

struct FHIRObservation: FHIRResource {
    static let resourceType = "Observation"

    let id: String?
    let status: String?
    let code: FHIRCodeableConcept?
    let subject: FHIRReference?
    let encounter: FHIRReference?
    let effectiveDateTime: String?
    let valueQuantity: FHIRQuantity?
    let valueString: String?
    let interpretation: [FHIRCodeableConcept]?
}

struct FHIRCondition: FHIRResource {
    static let resourceType = "Condition"

    let id: String?
    let clinicalStatus: FHIRCodeableConcept?
    let code: FHIRCodeableConcept?
    let subject: FHIRReference?
    let onsetDateTime: String?
}

struct FHIRMedicationRequest: FHIRResource {
    static let resourceType = "MedicationRequest"

    let id: String?
    let status: String?
    let intent: String?
    let medicationCodeableConcept: FHIRCodeableConcept?
    let subject: FHIRReference?
    let authoredOn: String?
}

struct FHIRDiagnosticReport: FHIRResource {
    static let resourceType = "DiagnosticReport"

    let id: String?
    let status: String?
    let code: FHIRCodeableConcept?
    let subject: FHIRReference?
    let effectiveDateTime: String?
    let conclusion: String?
    let result: [FHIRReference]?
}

struct FHIRIdentifier: Decodable, Equatable {
    let system: String?
    let value: String?
}

struct FHIRReference: Decodable, Equatable {
    let reference: String?
    let display: String?

    var referencedID: String? {
        reference?.split(separator: "/").last.map(String.init)
    }
}

struct FHIRCoding: Decodable, Equatable {
    let system: String?
    let code: String?
    let display: String?
}

struct FHIRCodeableConcept: Decodable, Equatable {
    let coding: [FHIRCoding]?
    let text: String?

    var primaryCode: String? {
        coding?.first?.code
    }

    var displayText: String {
        text ?? coding?.first?.display ?? primaryCode ?? "Uncoded"
    }
}

struct FHIRQuantity: Decodable, Equatable {
    let value: Double?
    let unit: String?
    let system: String?
    let code: String?
}

struct FHIRPeriod: Decodable, Equatable {
    let start: String?
    let end: String?
}

struct HealthcareClinicalRecord: Equatable {
    let patient: HealthcarePatient
    let encounters: [HealthcareEncounter]
    let observations: [HealthcareObservation]
    let conditions: [HealthcareCondition]
    let medicationRequests: [HealthcareMedicationRequest]
    let diagnosticReports: [HealthcareDiagnosticReport]
}

struct HealthcarePatient: Identifiable, Equatable {
    let id: String
    let mrn: String?
    let displayName: String
    let gender: String?
    let birthDate: String?
}

struct HealthcareEncounter: Identifiable, Equatable {
    let id: String
    let patientID: String?
    let status: String?
    let classCode: String?
    let startedAt: Date?
    let endedAt: Date?
}

struct HealthcareObservation: Identifiable, Equatable {
    let id: String
    let patientID: String?
    let encounterID: String?
    let code: String?
    let display: String
    let value: Double?
    let unit: String?
    let effectiveAt: Date?
    let interpretation: String?
}

struct HealthcareCondition: Identifiable, Equatable {
    let id: String
    let patientID: String?
    let code: String?
    let display: String
    let onsetAt: Date?
    let clinicalStatus: String?
}

struct HealthcareMedicationRequest: Identifiable, Equatable {
    let id: String
    let patientID: String?
    let medication: String
    let status: String?
    let authoredAt: Date?
}

struct HealthcareDiagnosticReport: Identifiable, Equatable {
    let id: String
    let patientID: String?
    let code: String?
    let display: String
    let effectiveAt: Date?
    let conclusion: String?
    let linkedObservationIDs: [String]
}

enum FHIRNormalizer {
    private static let dateFormatter = ISO8601DateFormatter()

    static func patient(from resource: FHIRPatient) -> HealthcarePatient {
        let name = resource.name?.first
        let given = name?.given?.joined(separator: " ")
        let displayName = [given, name?.family]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return HealthcarePatient(
            id: resource.id ?? UUID().uuidString,
            mrn: resource.identifier?.first?.value,
            displayName: displayName.isEmpty ? "Unnamed patient" : displayName,
            gender: resource.gender,
            birthDate: resource.birthDate
        )
    }

    static func encounter(from resource: FHIREncounter) -> HealthcareEncounter {
        HealthcareEncounter(
            id: resource.id ?? UUID().uuidString,
            patientID: resource.subject?.referencedID,
            status: resource.status,
            classCode: resource.class?.code,
            startedAt: parse(resource.period?.start),
            endedAt: parse(resource.period?.end)
        )
    }

    static func observation(from resource: FHIRObservation) -> HealthcareObservation {
        HealthcareObservation(
            id: resource.id ?? UUID().uuidString,
            patientID: resource.subject?.referencedID,
            encounterID: resource.encounter?.referencedID,
            code: resource.code?.primaryCode,
            display: resource.code?.displayText ?? "Observation",
            value: resource.valueQuantity?.value,
            unit: resource.valueQuantity?.unit ?? resource.valueQuantity?.code,
            effectiveAt: parse(resource.effectiveDateTime),
            interpretation: resource.interpretation?.first?.displayText
        )
    }

    static func condition(from resource: FHIRCondition) -> HealthcareCondition {
        HealthcareCondition(
            id: resource.id ?? UUID().uuidString,
            patientID: resource.subject?.referencedID,
            code: resource.code?.primaryCode,
            display: resource.code?.displayText ?? "Condition",
            onsetAt: parse(resource.onsetDateTime),
            clinicalStatus: resource.clinicalStatus?.displayText
        )
    }

    static func medicationRequest(from resource: FHIRMedicationRequest) -> HealthcareMedicationRequest {
        HealthcareMedicationRequest(
            id: resource.id ?? UUID().uuidString,
            patientID: resource.subject?.referencedID,
            medication: resource.medicationCodeableConcept?.displayText ?? "Medication request",
            status: resource.status,
            authoredAt: parse(resource.authoredOn)
        )
    }

    static func diagnosticReport(from resource: FHIRDiagnosticReport) -> HealthcareDiagnosticReport {
        HealthcareDiagnosticReport(
            id: resource.id ?? UUID().uuidString,
            patientID: resource.subject?.referencedID,
            code: resource.code?.primaryCode,
            display: resource.code?.displayText ?? "Diagnostic report",
            effectiveAt: parse(resource.effectiveDateTime),
            conclusion: resource.conclusion,
            linkedObservationIDs: resource.result?.compactMap(\.referencedID) ?? []
        )
    }

    static func parse(_ value: String?) -> Date? {
        guard let value else { return nil }
        return dateFormatter.date(from: value)
    }
}

protocol FHIRClientProtocol {
    func fetchResource<Resource: FHIRResource>(_ type: Resource.Type, path: String, queryItems: [URLQueryItem]) async throws -> [Resource]
}

struct SMARTFHIRClient: FHIRClientProtocol {
    let baseURL: URL
    let authenticator: SMARTAuthenticating
    let transport: HTTPTransport
    let cache: ResponseCache
    var decoder = JSONDecoder()

    func fetchResource<Resource: FHIRResource>(_ type: Resource.Type, path: String, queryItems: [URLQueryItem] = []) async throws -> [Resource] {
        var pageURL: URL? = try makeURL(path: path, queryItems: queryItems)
        var resources: [Resource] = []

        while let url = pageURL {
            let data = try await fetchData(url: url)
            do {
                let bundle = try decoder.decode(FHIRBundle<Resource>.self, from: data)
                resources.append(contentsOf: bundle.entry?.compactMap(\.resource) ?? [])
                pageURL = bundle.link?.first { $0.relation == "next" }.flatMap { URL(string: $0.url) }
            } catch {
                throw HealthcareServiceError.decodingFailed(Resource.resourceType)
            }
        }

        return resources
    }

    private func fetchData(url: URL) async throws -> Data {
        let cacheKey = url.absoluteString
        if let cached = await cache.data(for: cacheKey) {
            return cached
        }

        let token = try await authenticator.validAccessToken()
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/fhir+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await transport.data(for: request)
        guard (200..<300).contains(response.statusCode) else {
            throw HealthcareServiceError.httpStatus(response.statusCode)
        }
        await cache.save(data, for: cacheKey)
        return data
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw HealthcareServiceError.invalidURL(path)
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            throw HealthcareServiceError.invalidURL(path)
        }
        return url
    }
}

protocol ClinicalFHIRServicing {
    func clinicalRecord(patientID: String) async throws -> HealthcareClinicalRecord
}

struct ClinicalFHIRService: ClinicalFHIRServicing {
    let client: FHIRClientProtocol

    func clinicalRecord(patientID: String) async throws -> HealthcareClinicalRecord {
        let patientResources = try await client.fetchResource(FHIRPatient.self, path: "Patient", queryItems: [.init(name: "_id", value: patientID)])
        guard let patient = patientResources.first.map(FHIRNormalizer.patient) else {
            throw HealthcareServiceError.emptyBundle("Patient")
        }

        async let encounters = client.fetchResource(FHIREncounter.self, path: "Encounter", queryItems: [.init(name: "patient", value: patientID)])
        async let observations = client.fetchResource(FHIRObservation.self, path: "Observation", queryItems: [.init(name: "patient", value: patientID)])
        async let conditions = client.fetchResource(FHIRCondition.self, path: "Condition", queryItems: [.init(name: "patient", value: patientID)])
        async let medications = client.fetchResource(FHIRMedicationRequest.self, path: "MedicationRequest", queryItems: [.init(name: "patient", value: patientID)])
        async let reports = client.fetchResource(FHIRDiagnosticReport.self, path: "DiagnosticReport", queryItems: [.init(name: "patient", value: patientID)])

        return try await HealthcareClinicalRecord(
            patient: patient,
            encounters: encounters.map(FHIRNormalizer.encounter),
            observations: observations.map(FHIRNormalizer.observation),
            conditions: conditions.map(FHIRNormalizer.condition),
            medicationRequests: medications.map(FHIRNormalizer.medicationRequest),
            diagnosticReports: reports.map(FHIRNormalizer.diagnosticReport)
        )
    }
}
