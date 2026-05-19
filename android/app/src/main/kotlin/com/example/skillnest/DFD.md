# Data Flow Diagrams (DFD)
## Project: SkillNest

This document contains Data Flow Diagrams illustrating how data enters, flows through, is stored in, and leaves the SkillNest platform.

---

## 1. DFD Level 0 (Context Diagram)

The Context Diagram defines the system boundary, showing the high-level input and output data flows between the **SkillNest System** and external entities (**Customer**, **Worker**, and **Admin**).

### Mermaid Diagram

```mermaid
graph LR
  %% Entity Styling
  Customer[Customer / User]
  Worker[Worker / Provider]
  Admin[System Admin]
  
  %% System Boundary
  subgraph SkillNest System Boundary
    System((SkillNest Application))
  end

  %% Customer Data Flows
  Customer -->|Credentials / Register Info| System
  Customer -->|Geographic Map Selection| System
  Customer -->|Booking details, Slot & Address| System
  Customer -->|Rating & Textual Review| System
  Customer -->|Job Completion Confirmation| System
  
  System -->|Worker matching lists & profile details| Customer
  System -->|Secure 6-digit Job OTP code| Customer
  System -->|Transactions & Booking History| Customer
  System -->|Authentication Status| Customer

  %% Worker Data Flows
  Worker -->|Credentials & Skill Registry| System
  Worker -->|Availability Toggles & Base64 Photos| System
  Worker -->|Job Acceptance / Rejection| System
  Worker -->|Customer OTP for verification| System
  
  System -->|Incoming Job request Alerts| Worker
  System -->|Customer address & slot specs| Worker
  System -->|Authentication & Verification Status| Worker
  System -->|Reviews & Performance Statistics| Worker

  %% Admin Data Flows
  Admin -->|Monitoring requests| System
  System -->|Global Lists of Users & Workers| System
  System -->|Global Job Transactions logs| Admin
```

---

## 2. DFD Level 1 (Process Decomposition)

The Level 1 DFD decomposes the system into specific sub-processes and explicitly maps their reads and writes to the data stores (Firestore Collections: `users`, `workers`, `jobs`, `reviews`).

### Mermaid Diagram

```mermaid
graph TD
  %% External Entities
  Customer[Customer]
  Worker[Worker]
  Admin[Admin]

  %% Data Stores (Double Bar Representation)
  subgraph Firestore Database
    DS_Users[(users collection)]
    DS_Workers[(workers collection)]
    DS_Jobs[(jobs collection)]
    DS_Reviews[(reviews collection)]
  end

  %% Processes
  P1((1.0 Auth & Routing))
  P2((2.0 Profile & Location))
  P3((3.0 Search & Filter))
  P4((4.0 Booking Request))
  P5((5.0 Job Cycle & OTP))
  P6((6.0 Review Loop))
  P7((7.0 Admin Controls))

  %% Process 1.0 Flows
  Customer -->|Credentials| P1
  Worker -->|Credentials| P1
  P1 -->|Register / Write user data| DS_Users
  P1 -->|Register / Write worker data| DS_Workers
  DS_Users -->|Verify role / account| P1
  P1 -->|Auth status & role redirection| Customer
  P1 -->|Auth status & role redirection| Worker

  %% Process 2.0 Flows
  Customer -->|Map Selection & Base64 Photos| P2
  Worker -->|Availability & Skills updates| P2
  P2 -->|Update profile & location| DS_Users
  P2 -->|Update stats & availability| DS_Workers

  %% Process 3.0 Flows
  Customer -->|Location Query| P3
  DS_Workers -->|Retrieve available workers in city| P3
  P3 -->|Matching Workers directory| Customer

  %% Process 4.0 Flows
  Customer -->|Select Slot, Hours, Date, Address| P4
  DS_Workers -->|Read worker rates| P4
  P4 -->|Create job record in pending state| DS_Jobs
  P4 -->|Request Notification| Worker

  %% Process 5.0 Flows
  Worker -->|Accept / Reject Job| P5
  Worker -->|Provide Customer OTP code| P5
  Customer -->|Confirm Work Done & Pay| P5
  
  P5 -->|Update worker availability flag isWorking| DS_Workers
  P5 -->|Read OTP & status data| DS_Jobs
  P5 -->|Write OTP, verify otpVerified, update status accept/complete| DS_Jobs
  
  P5 -->|Display OTP & Job details| Customer
  P5 -->|Display Customer location & verification status| Worker

  %% Process 6.0 Flows
  Customer -->|Review text & rating| P6
  P6 -->|Write review document| DS_Reviews
  P6 -->|Increment totalReviews & recalculate averageRating| DS_Workers
  P6 -->|Set isReviewed to true| DS_Jobs

  %% Process 7.0 Flows
  Admin -->|Read dashboard requests| P7
  DS_Users -->|Read user list| P7
  DS_Workers -->|Read worker list| P7
  DS_Jobs -->|Read jobs list| P7
  P7 -->|Display reports| Admin
```

---

## 3. Data Dictionary Summary

| Data Flow / Element | Origin | Destination | Description |
| :--- | :--- | :--- | :--- |
| **Credentials** | Customer / Worker | Process 1.0 | Email, password, and registration attributes (name, role). |
| **Profile Data** | Customer / Worker | Process 2.0 | Base64 profile picture strings, phone updates, and name updates. |
| **Geographic coordinates** | Map Picker UI | Process 2.0 | Lat/Long coordinates translated into city names via geocoding. |
| **Job Request Specs** | Customer | Process 4.0 | Date, hourly charges, slot times, client address, and total price. |
| **Verification OTP** | Process 5.0 / jobs collection | Customer | 6-digit random code shown on Customer screen. |
| **OTP Entry** | Worker | Process 5.0 | Code submitted by worker to verify physical presence on-site. |
| **Review Payload** | Customer | Process 6.0 | Rating integer (1-5), feedback comments, and job id. |
