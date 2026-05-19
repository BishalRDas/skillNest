# Entity-Relationship (ER) Diagram
## Project: SkillNest

This document contains the Entity-Relationship Diagram for SkillNest, illustrating the Firestore collection models, their schema definitions, and relationship cardinalities.

### Mermaid Diagram

```mermaid
erDiagram
    users {
        string uid PK "FirebaseAuth UID"
        string name
        string email
        string phone
        string role "User or Worker"
        boolean isPhoneVerified
        string location "City name"
        double lat
        double lng
        string profileImage "Base64 encoded string"
        timestamp createdAt
    }

    workers {
        string uid PK "FirebaseAuth UID (FK users)"
        string name
        string email
        string phone
        string skill "e.g. Plumber, Electrician"
        string experience "Years of experience"
        int charges "Hourly rate"
        string location "City name"
        double lat
        double lng
        string profileImage "Base64 encoded string"
        boolean isPhoneVerified
        boolean isAvailable
        boolean isApproved "Set by Admin"
        boolean isWorking "Status lock during job"
        double averageRating
        int totalReviews
        timestamp createdAt
    }

    jobs {
        string jobId PK "Firestore Auto-generated ID"
        string userId FK "users.uid"
        string workerId FK "workers.uid"
        string userEmail
        string workerName
        string skill
        string status "pending | accepted | rejected | completed"
        int hours
        double charge "Hourly fee"
        double totalPrice "hours * charge"
        string paymentStatus "pending | paid"
        string bookingDate
        string bookingSlot
        string address "Customer delivery address"
        string jobOtp "6-digit OTP code"
        boolean otpVerified
        boolean isReviewed
        timestamp createdAt
        timestamp updatedAt
    }

    reviews {
        string reviewId PK "Firestore Auto-generated ID"
        string jobId FK "jobs.jobId"
        string workerId FK "workers.uid"
        string userId FK "users.uid"
        int rating "1 to 5 scale"
        string reviewText
        timestamp createdAt
    }

    %% Relationships Mapping
    users ||--o| workers : "extends if role is Worker"
    users ||--o{ jobs : "initiates"
    workers ||--o{ jobs : "performs"
    jobs ||--o| reviews : "receives"
    users ||--o{ reviews : "submits"
    workers ||--o{ reviews : "accumulates"
```

### Logical Relationships Description

1. **Users and Workers (`1:0..1` relationship)**:
   - Every registered account has a corresponding document in the `users` collection.
   - If the account role is selected as `"Worker"`, a corresponding document is also created in the `workers` collection sharing the identical `uid` to store skill directories, charges, and status flags.

2. **Users and Jobs (`1:N` relationship)**:
   - A Customer (`user`) can book multiple jobs (`N`) over time.
   - Each job document stores the Customer's identifier (`userId`) to link back to the specific user profile.

3. **Workers and Jobs (`1:N` relationship)**:
   - A `worker` can be requested for and execute multiple jobs (`N`).
   - The job document contains the worker's identifier (`workerId`) to track assignments.

4. **Jobs and Reviews (`1:0..1` relationship)**:
   - Each individual job can have at most one associated review, completed post-delivery to prevent duplicate feedback loops (`isReviewed` status flag on `jobs` toggles from `false` to `true`).

5. **Users/Workers and Reviews (`1:N` relationship)**:
   - A Customer (`user`) submits reviews across various bookings.
   - A `worker` accumulates multiple review objects which dynamically update their `averageRating` and `totalReviews` aggregates via database transactions.
