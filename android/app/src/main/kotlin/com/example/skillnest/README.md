# SkillNest Project Documentation

Welcome to the documentation suite for **SkillNest**—an on-demand service provider (worker) booking mobile application.

This directory contains the software engineering design documents, specifications, and diagrams mapping out the application's architecture, processes, data structures, and test suites.

## Document Index

1. **[Software Requirements Specification (SRS)](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/SRS.md)**
   Comprehensive requirements specification including system features, user classes, data descriptions, and functional/non-functional requirements.

2. **[Use Case Diagram](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/UseCaseDiagram.md)**
   Mermaid diagram detailing user interactions (Customer, Worker, Admin) with system functionalities.

3. **[Entity-Relationship (ER) Diagram](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/ERDiagram.md)**
   Mermaid ER model mapping the database schema (Firestore collections: `users`, `workers`, `jobs`, `reviews`) and relationships.

4. **[Data Flow Diagram (DFD)](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/DFD.md)**
   DFD Level 0 (Context Diagram) and DFD Level 1 (Process Breakdown) illustrating the flow of data through the system.

5. **[Sequence Diagram](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/SequenceDiagram.md)**
   A detailed sequence flow representing the key user journey: **Job Booking, OTP Security Handshake, and Completion**.

6. **[Test Cases](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/TestCases.md)**
   A comprehensive tabular suite of functional test cases spanning all roles and features.

7. **[Gantt Chart](file:///c:/Project1/skillNest/android/app/src/main/kotlin/com/example/skillnest/GanttChart.md)**
   Mermaid Gantt timeline illustrating the project's development schedule and lifecycle stages.

---

## SkillNest Overview

SkillNest connects local freelance service providers (Workers: plumbers, carpenters, electricians, etc.) with clients (Customers) based on location-based filtering. The mobile client is built using **Flutter** and uses **Firebase (Firestore, Authentication)** as its backend service.

### Key Workflows
- **Location Mapping**: Customers and Workers pick geographical locations via OpenStreetMap interface which translates coordinates into local cities.
- **OTP Handshake Security**: Upon job acceptance, a unique 6-digit verification code is generated. This code must be exchanged and verified by the worker to initiate and complete the booking securely.
- **Review Loop**: Every completed job allows the Customer to review and rate the Worker, dynamically recalculating the worker's average rating.
