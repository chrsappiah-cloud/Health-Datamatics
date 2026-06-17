# Privacy Responses

Health-Datamatics is designed for healthcare analytics workflows and may be connected to protected health information in production deployments. The current starter build uses local sample data for review and demonstration.

Recommended App Store privacy posture for the current build:

- Data collection: No production user data is collected by this starter build.
- Tracking: The app does not track users across apps or websites.
- Third-party advertising: None.
- Account creation: Not required for the sample review flow.
- Health data: No live HealthKit or external EHR data is collected in the submitted starter build.
- Diagnostics: No custom analytics SDK is included.

Production note: If connected to SMART-on-FHIR, HL7, warehouse, LLM, or vendor APIs, the privacy labels must be updated to reflect actual data collection, retention, linkage, and processing behavior.
