# SkillNest Presentation Slides Outline
## On-Demand Local Service Booking System

Use this outline to build or review your slide deck. All diagrams are saved as PNG files in this directory and can be directly inserted into your PowerPoint slides.

---

### Slide 1: Title Slide (Dark Background)
* **Title**: SkillNest
* **Subtitle**: On-Demand Local Service Finder & Booking Platform
* **Footer**: Software Requirements Specification & Design Diagrams Presentation
* **Visual Theme**: Deep Blue / Slate theme.

---

### Slide 2: Project Overview & Scope
* **Title**: Project Scope & Target Goals
* **Key Bullet Points**:
  * **Objective**: A location-aware mobile portal bridging the gap between freelance manual service workers (electricians, plumbers, carpenters, etc.) and customers.
  * **Framework**: Cross-platform application built using the Flutter framework.
  * **Backend**: Powered by Google Cloud Firestore (real-time NoSQL database) and Firebase Authentication (secure logins).
  * **Core Innovation**: Geocoding location searches matching workers and customers in the same city, backed by a secure 6-digit OTP verification handshake for physical job transactions.

---

### Slide 3: System Features & Role separation
* **Title**: Platform Features
* **Key Bullet Points**:
  * **Customer Workflow**: Location picker on an interactive map, dynamic provider listing, booking engine, secure verification OTP display, and review submission.
  * **Worker Workflow**: Profile management, base64 compressed profile photo uploads, hourly rate settings, online/offline availability switch, request alerts, and OTP inputs.
  * **Verification Handshake**: Restricts service completion until the worker enters the client's verbal OTP code.
  * **Reviews & Ratings**: Atomic database transactions that recalculate ratings and review counts immediately upon customer submission.

---

### Slide 4: Use Case Diagram
* **Title**: Use Case Diagram
* **Content (Left Column)**:
  * Outlines system boundaries and how system actors interact with functionalities.
  * **Actors**: Customer (User), Worker, and Admin.
  * **Key Use Cases**: Authentication, profile management, map-based coordinate location settings, provider search, booking requests, OTP generation & verification, rating/review updates, and admin monitoring dashboard.
* **Diagram (Right Column)**: Insert `UseCaseDiagram.png` here.

---

### Slide 5: Entity-Relationship Diagram (ERD)
* **Title**: Database Schema & ER Model
* **Content (Left Column)**:
  * Maps Firestore collections, attributes, and cardinality.
  * **users**: Stores authentication info, profiles, locations, and roles.
  * **workers**: Extends user registry, adding skills, charges, average ratings, and status.
  * **jobs**: Logs booking dates, time slots, pricing, OTP, and status.
  * **reviews**: Stores ratings (1-5) and feedback texts.
* **Diagram (Right Column)**: Insert `ERDiagram.png` here.

---

### Slide 6: Data Flow Diagram (DFD Level 0)
* **Title**: DFD Level 0 (Context Diagram)
* **Content (Left Column)**:
  * Outlines system inputs, outputs, and external boundary data flows.
  * **Customer Flows**: Logs inputs (credentials, bookings, ratings) and outputs (matches list, OTP, transaction logs).
  * **Worker Flows**: Logs inputs (skills, availability, verify codes) and outputs (booking alerts, reviews statistics).
  * **Admin Flows**: Pulls global lists of users and transaction logs.
* **Diagram (Right Column)**: Insert `DFD0.png` here.

---

### Slide 7: Data Flow Diagram (DFD Level 1)
* **Title**: DFD Level 1 (Process Breakdown)
* **Content (Left Column)**:
  * Decomposes the application into specific subprocesses and maps database collection reads/writes.
  * **Subprocesses**:
    * 1.0 Authentication & Routing
    * 2.0 Profile & Location Config
    * 3.0 Search & Match Filtering
    * 4.0 Booking requests
    * 5.0 Job Verification & OTP
    * 6.0 Reviews & Ratings Transaction
    * 7.0 Admin Controls
* **Diagram (Right Column)**: Insert `DFD1.png` here.

---

### Slide 8: Sequence Diagram (Transaction Flow)
* **Title**: Transaction Sequence Flow
* **Content (Left Column)**:
  * Illustrates the sequence of message exchanges for a booking:
    * 1. Customer initiates request (sets status to pending).
    * 2. Worker accepts (auto-rejects other pending requests for that user, locks worker, and generates OTP).
    * 3. Handshake verification (Worker inputs customer's verbal OTP code to activate job).
    * 4. Completion (Customer completes job, processing payment simulation and releasing worker's busy locks).
* **Diagram (Right Column)**: Insert `SequenceDiagram.png` here.

---

### Slide 9: Gantt Chart (Project Schedule)
* **Title**: Project Schedule & Timeline
* **Content (Left Column)**:
  * Visualizes the timeline for the development cycle:
    * **Requirements & Diagrams**: Modeling blueprints and compiling specifications (May 1 - May 12).
    * **UI/UX Design**: Configuration of widgets, theme systems, and OSM map picker interfaces (May 5 - May 22).
    * **Core Services & DB**: Developing Firestore collections and transactional code (May 8 - May 29).
    * **Testing & Release**: Formulating test cases, widget unit tests, staging builds, and production compilation (May 18 - Jun 12).
* **Diagram (Right Column)**: Insert `GanttChart.png` here.

---

### Slide 10: Test Cases Table
* **Title**: Quality Verification & Test Cases
* **Content**: Insert a table or slide content summarizing core test scenarios:
  * **TC-AUTH-02 (Worker Sign Up)**: Checks skill registry and redirection to `WorkerHome`.
  * **TC-PROF-02 (OSM Map Selector)**: Checks coordinate location picker and geocoding city resolver.
  * **TC-SCH-01 (City Match Filter)**: Checks search query constraints (matches city names, filters busy workers).
  * **TC-JOB-03 (OTP Verification)**: Checks success path when worker enters matching customer code on-site.
  * **TC-REV-01 (Atomic Rating)**: Checks ratings average calculation and total reviews increment.

---

### Slide 11: Technology Stack Summary (Light Background)
* **Title**: Technical Architecture
* **Key Bullet Points**:
  * **Frontend**: Flutter SDK (Dart) for reactive mobile client layout.
  * **Geospatial**: `flutter_map` library linking OpenStreetMap and `geocoding` geocoder library.
  * **Auth**: Firebase Auth token management.
  * **NoSQL Database**: Cloud Firestore (relational documents model).
  * **Documentation**: Full requirements coverage documented in `SRS.md`, diagrams in `UseCaseDiagram.md`, `ERDiagram.md`, `DFD.md`, `SequenceDiagram.md`, and test scripts in `TestCases.md`.
