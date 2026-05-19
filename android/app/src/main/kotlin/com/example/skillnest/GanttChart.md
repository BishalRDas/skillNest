# Project Gantt Chart
## Project: SkillNest

This document contains a Gantt Chart representing the development phases, tasks, dependencies, and timeline of the SkillNest project.

### Mermaid Diagram

```mermaid
gantt
    title SkillNest Project Schedule (2026)
    dateFormat  YYYY-MM-DD
    axisFormat  %b %d

    section Requirements & Architecture
    Requirements Elicitation & Analysis  :active, req1, 2026-05-01, 5d
    SRS Development                      :req2, after req1, 3d
    System Design & Diagrams Modeling    :req3, after req2, 4d

    section UI/UX Design (Flutter)
    Theme System Setup (Dark/Light Mode)  :ui1, 2026-05-05, 3d
    Auth & Profile Interface Mockups     :ui2, after ui1, 4d
    Booking & Directory UI Views         :ui3, after ui2, 6d
    Geocoding Map Interface Development   :ui4, after ui3, 4d

    section Database & Core Services
    Firestore Collections Architecture   :db1, 2026-05-08, 4d
    FirebaseAuth Service Integration     :db2, after db1, 4d
    Job Transactional Functions (Db)     :db3, after db2, 6d
    OTP SMS Handler Verification Service  :db4, after db3, 4d
    Atomic Reviews Transaction Handling   :db5, after db4, 3d

    section Verification & Quality Assurance
    Manual Test Cases Formulation       :tst1, 2026-05-18, 3d
    Unit & Widget Testing (Flutter test) :tst2, 2026-05-20, 5d
    E2E Integration Testing (Firebase)   :tst3, after tst2, 6d
    Bug Fixing & Performance Optimization :tst4, after tst3, 4d

    section Deployment & Review
    Staging Build & Testing              :dep1, 2026-06-03, 3d
    Production Bundle Compiling (APK/AAB):dep2, after dep1, 2d
    Final Review & App Store Submit      :dep3, after dep2, 4d
```

### Schedule Phase Breakdown

1. **Requirements & Architecture (May 1 – May 12)**:
   - Defining core customer-worker search scopes, role structures, and document schemas.
   - Drawing blueprints: Use Cases, Entity-Relationships, Data Flow Diagrams (Context & Level 1), and Sequence flows.

2. **UI/UX Design (May 5 – May 22)**:
   - Establishing design systems supporting Light/Dark themes.
   - Crafting responsive customer lookup grids, worker job management tabs, and embedding interactive maps (OpenStreetMap).

3. **Database & Core Services (May 8 – May 29)**:
   - Building Firestore integrations, writing transactional operations for atomic ratings increments, implementing OTP authentication sequences, and configuring lock structures (`isWorking` flag).

4. **Verification & Quality Assurance (May 18 – Jun 3)**:
   - Writing test case tables.
   - Conducting unit tests on services and manual regression testing on user workflows (Signups, locations, and OTP triggers).

5. **Deployment & Review (Jun 3 – Jun 12)**:
   - Bundling Android installation packages, resolving environment overrides, and preparing submission materials.
