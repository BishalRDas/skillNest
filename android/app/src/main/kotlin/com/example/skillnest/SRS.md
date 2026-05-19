# Software Requirements Specification (SRS)
## Project: SkillNest

---

## 1. Introduction

### 1.1 Purpose
The purpose of this document is to specify the software requirements for the **SkillNest** mobile application. This specification defines both functional and non-functional requirements to guide development, testing, deployment, and future expansion.

### 1.2 Document Conventions
- This document follows standard IEEE template recommendations for Software Requirements Specifications.
- Priority levels for requirements are labeled as: **M** (Must have/Critical), **S** (Should have/High), **C** (Could have/Nice to have).

### 1.3 Intended Audience and Reading Suggestions
This document is intended for:
- **Developers**: To guide the database and Flutter frontend implementations.
- **Testers**: To formulate verification procedures and test cases.
- **Project Evaluators / Academics**: To assess structural adherence to software engineering standards.

### 1.4 Product Scope
SkillNest is an on-demand, location-based service provider directory and booking mobile application. It aims to bridge the gap between freelance manual service workers (electricians, plumbers, carpenters, etc.) and customers looking for immediate assistance.

**Key Scope Items:**
- **Cross-Platform Mobile Client**: Created via Flutter.
- **Role-Based Workflows**: Customer, Worker, and Admin interfaces.
- **Verification & Security**: OTP-based handshake to initiate and complete jobs.
- **Location-Based Matching**: Matches providers with customers in the same city.
- **Feedback Loop**: Customers write reviews that calculate worker star ratings.

---

## 2. Overall Description

### 2.1 Product Perspective
SkillNest operates as a decentralized mobile portal. It integrates with Firebase Authentication for account creation, Cloud Firestore for real-time transactional data storage, and OpenStreetMap (via flutter_map) for geospatial location tracking.

```
+-----------------------------------------------------------+
|                      SkillNest App                        |
|   +---------------+     +---------------+     +-------+   |
|   | Customer UI   |     |   Worker UI   |     | Admin |   |
|   +-------+-------+     +-------+-------+     +---+---+   |
+-----------|---------------------|-----------------|-------+
            |                     |                 |
            +----------+----------+-----------------+
                       |
                       v
            +---------------------+
            |  Firebase Backend   |
            |  - Auth             |
            |  - Firestore Db     |
            |  - Storage (Base64) |
            +---------------------+
```

### 2.2 Product Functions
The high-level capabilities of SkillNest include:
1. **User Sign Up and Authentication**: Registering as either Customer or Worker, using email/password and logging in.
2. **Profile Personalization**: Uploading compressed profile pictures (saved as base64 strings), changing account details, and changing passwords.
3. **Map-Based Location Selector**: Selecting coordinates on an interactive map to derive the user's city name.
4. **Service Directory Search**: Filtering workers by city, availability status, and administrative approval.
5. **Work Booking Engine**: Specifying dates, time slots, locations, hourly charges, and booking hours.
6. **OTP-Based Security Flow**: Creating a unique OTP code visible to the Customer, which the Worker must obtain and verify on-site to transition the job status.
7. **Interactive Feedback Loop**: Giving ratings and textual comments upon job completion.
8. **Admin Panel**: Listing users, viewing worker skills/experience, and monitoring transactional jobs.

### 2.3 User Classes and Characteristics
SkillNest defines three primary user classes:
- **Customer (User)**: Non-technical users seeking service providers. They require an intuitive search, transparent pricing, and simple booking controls.
- **Worker (Service Provider)**: Freelance technicians who manage their availability, profile, rates, and verify booking codes on the job.
- **Admin (System Administrator)**: Oversees system operations, monitors registrations, inspects jobs, and manages approvals.

### 2.4 Operating Environment
- **Client Application**: Android (SDK 21+) and iOS (iOS 12.0+).
- **Backend Database**: Firebase Firestore (NoSQL cloud database).
- **Third-Party Services**: OpenStreetMap Tile Servers, Nominatim Geocoding API.

### 2.5 Design and Implementation Constraints
- **Database Limits**: Images are compressed and stored as Base64 strings directly in Firestore documents. Individual documents must not exceed the Firestore 1MB size limit.
- **Internet Dependency**: The application requires active internet connectivity for Firestore sync and map loading.

### 2.6 Assumptions and Dependencies
- It is assumed that users have functional GPS-enabled devices to fetch location coordinates.
- System notifications are currently dependent on local device state updates synced via Firestore streams.

---

## 3. System Features

### 3.1 User Authentication & Role Routing
- **Description**: Users register via Email/Password and pick a role: Customer (`User`) or `Worker`. Upon login, the app routes the client to `UserHome`, `WorkerHome`, or `AdminHome`.
- **Requirements**:
  - **FR-1.1**: System shall register users with email, password, name, and role choice. (Priority: M)
  - **FR-1.2**: System shall store worker-specific attributes (skill, experience, charges) if the selected role is "Worker". (Priority: M)
  - **FR-1.3**: System shall block unverified accounts from appearing in searches. (Priority: M)

### 3.2 Location and Profile Management
- **Description**: Users customize profiles, change passwords, and set their location using a map-based coordinates system.
- **Requirements**:
  - **FR-2.1**: System shall provide an interactive map for location picking. (Priority: M)
  - **FR-2.2**: System shall resolve lat/long coordinates into a city name via geocoding. (Priority: M)
  - **FR-2.3**: System shall compress profile photos to base64 format under 900KB. (Priority: M)
  - **FR-2.4**: Workers shall toggle their availability status (online/offline) from their profile tab. (Priority: M)

### 3.3 Search & Service Booking
- **Description**: Customers look up workers matching their city location and schedule a service slot.
- **Requirements**:
  - **FR-3.1**: Search tab shall only list workers whose `isApproved` is true, `isAvailable` is true, `isPhoneVerified` is true, and `isWorking` is false. (Priority: M)
  - **FR-3.2**: Search results shall filter workers based on matching city name strings. (Priority: M)
  - **FR-3.3**: Customers shall request jobs by entering booking date, slot, address, and calculated price. (Priority: M)

### 3.4 OTP Handshake & Job Lifecycle
- **Description**: Manages request acceptance, secure startup via verification code, and transaction finalization.
- **Requirements**:
  - **FR-4.1**: Worker shall accept or reject pending job requests. (Priority: M)
  - **FR-4.2**: Accepting a job request shall auto-reject all other pending requests for that customer. (Priority: M)
  - **FR-4.3**: Accepting a job shall set worker status `isWorking` to true and generate a 6-digit verification code (`jobOtp`). (Priority: M)
  - **FR-4.4**: Worker must enter the correct customer OTP to verify service delivery (`otpVerified = true`). (Priority: M)
  - **FR-4.5**: Customers shall mark verified jobs as complete, transitioning the job status to `completed` and worker availability `isWorking` back to false. (Priority: M)

### 3.5 Rating and Review System
- **Description**: Customers rate completed jobs to feed worker performance metrics.
- **Requirements**:
  - **FR-5.1**: Customer shall submit reviews (1-5 star scale and feedback text) only for completed, unreviewed jobs. (Priority: M)
  - **FR-5.2**: System shall run a transaction updating the worker's average rating and total review counts upon submission. (Priority: M)

### 3.6 Admin Panel
- **Description**: Monitoring tool for the platform operator.
- **Requirements**:
  - **FR-6.1**: Admin shall view a listing of registered Users and registered Workers. (Priority: M)
  - **FR-6.2**: Admin shall view a real-time list of all Jobs and their transactional statuses. (Priority: M)

---

## 4. External Interface Requirements

### 4.1 User Interfaces
- Mobile client views use dynamic styling systems supporting Dark Mode and Light Mode theme switches.
- Custom navigation bars, status indicators, and modal alert boxes control transaction prompts.

### 4.2 Software Interfaces
- **OS**: Android Framework and iOS SDK.
- **Database Client**: cloud_firestore package.
- **Map Renderer**: flutter_map library linking OpenStreetMap endpoint API.
- **Geocoder**: geocoding package.

---

## 5. Non-Functional Requirements

### 5.1 Performance
- Firestore listeners must sync data updates to client widgets in under 1.5 seconds under typical network conditions.
- Base64 compression must execute in under 3 seconds on standard mid-range mobile processors.

### 5.2 Safety
- To prevent document bloat and Firestore exceptions, profile image uploads exceeding 900KB in size must be rejected with user-facing alerts.

### 5.3 Security
- Users must authenticate using secure tokens managed by Firebase Auth.
- Write access to sensitive Firestore structures (like jobs status updates) should be governed by Firestore Security Rules validating that the authenticated `auth.uid` matches the document's references.

### 5.4 Software Quality Attributes
- **Usability**: Easy-to-use workflows allowing booking in under 3 taps from the search screen.
- **Availability**: Offline state handling gracefully alerts users of disconnected sync status.
