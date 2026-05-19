# Sequence Diagram
## Project: SkillNest

This Sequence Diagram represents the transactional workflow of **Job Booking, OTP Security Handshake, Work Verification, Job Completion, and Reviews**.

### Mermaid Diagram

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Customer (UserHome)
    participant DB as DatabaseService / Firestore
    actor Worker as Worker (WorkerHome)

    %% Step 1: Booking Request
    Note over Customer, DB: 1. Job Booking Request Phase
    Customer->>DB: sendJobRequest(workerId, Skill, slot, pricing, address)
    activate DB
    DB->>DB: Add Job Document (status="pending", paymentStatus="pending", otpVerified=false)
    DB-->>Customer: Sync request status (pending)
    deactivate DB
    DB-->>Worker: Stream pending job request (Firestore snapshots)
    
    %% Step 2: Acceptance & OTP Generation
    Note over Worker, DB: 2. Job Acceptance & OTP Phase
    Worker->>DB: acceptJob(jobId)
    activate DB
    DB->>DB: Reject other pending jobs for this Customer
    DB->>DB: Generate 6-digit OTP code (jobOtp)
    DB->>DB: Update Job Doc (status="accepted", jobOtp=otp)
    DB->>DB: Lock Worker (workers.doc.isWorking = true)
    DB-->>Worker: Sync accepted state & display Verification UI
    deactivate DB
    DB-->>Customer: Sync accepted state & display jobOtp on screen
    
    %% Step 3: On-Site Handshake & OTP Verification
    Note over Customer, Worker: 3. Physical Handshake & Verification Phase
    Customer-->>Worker: Provide OTP verbally (On-Site)
    Worker->>DB: verifyJobOtp(jobId, enteredOtp)
    activate DB
    alt OTP Matches
        DB->>DB: Update Job Doc (otpVerified=true)
        DB-->>Worker: Return verification success (true)
        DB-->>Customer: Sync otpVerified = true (Display "In Progress")
    else OTP Mismatch
        DB-->>Worker: Return verification failure (false)
    end
    deactivate DB
    
    %% Step 4: Completion & Payment
    Note over Customer, DB: 4. Job Completion & Payment Phase
    Worker-->>Customer: Perform physical service
    Customer->>DB: completeJob(jobId)
    activate DB
    DB->>DB: Verify otpVerified == true
    DB->>DB: Update Job Doc (status="completed", paymentStatus="paid")
    DB->>DB: Unlock Worker (workers.doc.isWorking = false)
    DB-->>Customer: Sync completed status & display Review Prompt
    DB-->>Worker: Sync completed status (Ready for new requests)
    deactivate DB
    
    %% Step 5: Review & Stats Transaction
    Note over Customer, DB: 5. Rating & Review Feedback Loop
    Customer->>DB: submitReview(jobId, workerId, rating, reviewText)
    activate DB
    Note over DB: Run DB Transaction
    DB->>DB: Write Review Document to 'reviews' collection
    DB->>DB: Update Job Doc (isReviewed = true)
    DB->>DB: Recalculate Worker metrics (averageRating & totalReviews)
    DB-->>Customer: Review saved successfully
    DB-->>Worker: Sync updated rating statistics
    deactivate DB
```

### Workflow Execution Details

1. **Job Request (Steps 1–3)**:
   - The Customer selects a worker from the search tab and submits slot dates and rates. A document is created in the `jobs` collection with standard fields in a `"pending"` state.

2. **Job Acceptance (Steps 4–8)**:
   - The Worker receives real-time updates through Firestore snapshot listeners.
   - When the Worker accepts, any other pending job requests the Customer initiated are automatically marked as `"rejected"`.
   - A 6-digit random code is generated, and the Worker's `isWorking` status is set to `true`, taking them off the availability pool. The Customer's screen updates to display this OTP.

3. **OTP Security Verification (Steps 9–15)**:
   - The Worker meets the Customer at the booking location and requests the code.
   - Verification occurs inside a Firestore document update, ensuring that the worker cannot initiate/claim work without customer confirmation.

4. **Job Completion (Steps 16–21)**:
   - Once work concludes, the Customer flags the job as completed. This unlocks the Worker's status (`isWorking = false`), making them available in searches again.

5. **Reviews & Rating updates (Steps 22–25)**:
   - The customer submits feedback. A transaction reads the worker's current rating profile, averages it with the new rating, and writes the updated document fields atomically to prevent concurrency issues.
