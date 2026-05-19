# Functional Test Cases Suite
## Project: SkillNest

This document contains detailed functional test cases designed to verify the capabilities of the SkillNest application.

---

### 1. User Authentication (TC-AUTH)

| Test ID | Component / Feature | Test Description | Preconditions | Input Data | Test Steps | Expected Output |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-01** | Register (Customer) | Verify successful registration of a Customer. | App opened on Register screen. | Name: "John Customer"<br>Email: "john@customer.com"<br>Password: "Pass123!"<br>Role: "User" | 1. Fill registration form fields.<br>2. Click Register button. | 1. User document created in `users` collection.<br>2. Routed to `UserHome` (Profile page). |
| **TC-AUTH-02** | Register (Worker) | Verify successful registration of a Worker. | App opened on Register screen. | Name: "Bob Worker"<br>Email: "bob@worker.com"<br>Password: "Pass123!"<br>Role: "Worker"<br>Skill: "Electrician"<br>Experience: "3" | 1. Fill registration form fields.<br>2. Enter skill & experience.<br>3. Click Register button. | 1. User doc created in `users` collection.<br>2. Worker doc created in `workers` collection (`isApproved=false`).<br>3. Routed to `WorkerHome`. |
| **TC-AUTH-03** | Login (Validation) | Verify authentication failure with incorrect password. | User already exists. | Email: "john@customer.com"<br>Password: "WrongPass" | 1. Open login screen.<br>2. Enter credentials.<br>3. Tap login. | 1. Error snackbar displayed ("Wrong password").<br>2. Login blocks redirect. |
| **TC-AUTH-04** | Role Redirection | Verify successful redirection based on Firestore role field. | Logged out. Registered user exists with role="Worker". | Email: "bob@worker.com"<br>Password: "Pass123!" | 1. Open login screen.<br>2. Enter credentials.<br>3. Tap login. | 1. App queries Firestore role attribute.<br>2. Redirects user to `WorkerHome`. |

---

### 2. Profile and Location Management (TC-PROF)

| Test ID | Component / Feature | Test Description | Preconditions | Input Data | Test Steps | Expected Output |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-PROF-01** | Image Compression | Verify profile image upload limits and Base64 conversion. | Logged in. Profile tab open. | Large Gallery image (e.g. 5MB) | 1. Click upload profile camera icon.<br>2. Select image.<br>3. Trigger base64 compress. | 1. Image compressed.<br>2. Under 900KB check passes.<br>3. Profile image saved in database. |
| **TC-PROF-02** | Location Picker | Verify OpenStreetMap coordinate selection and City resolution. | Logged in. Set Location dialog open. | Tap coordinates on map (e.g. 26.1445, 91.7362) | 1. Pan map to location.<br>2. Tap point to place pin.<br>3. Click Save Location. | 1. Geocoding translates coordinates to "guwahati".<br>2. `lat`, `lng`, and `location` ("guwahati") updated in document. |
| **TC-PROF-03** | Availability Toggles | Verify Worker toggling active availability state. | Logged in as Worker. | Availability Switch: Checked -> Unchecked | 1. Open Worker profile.<br>2. Toggle availability switch off. | 1. `isAvailable` set to `false` in `workers` document.<br>2. Worker disappears from search results. |

---

### 3. Worker Search and Filtering (TC-SCH)

| Test ID | Component / Feature | Test Description | Preconditions | Input Data | Test Steps | Expected Output |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-SCH-01** | Location Filter | Verify search tab only displays workers inside client's current city. | Customer is in "guwahati". Worker A is in "guwahati", Worker B is in "delhi". | Search tab active | 1. Navigate to search tab. | 1. Search lists Worker A.<br>2. Worker B is hidden from list. |
| **TC-SCH-02** | Approval Guard | Verify unapproved workers do not appear in searches. | Customer & Worker in "guwahati". Worker `isApproved` is false. | Search tab active | 1. Navigate to search tab. | 1. Search lists zero matching workers. |
| **TC-SCH-03** | Status Busy Guard | Verify worker currently on a job is excluded from search listings. | Worker `isWorking` is true in Firestore. | Search tab active | 1. Navigate to search tab. | 1. Busy worker excluded from list. |

---

### 4. Job Request & Verification Lifecycle (TC-JOB)

| Test ID | Component / Feature | Test Description | Preconditions | Input Data | Test Steps | Expected Output |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-JOB-01** | Booking Request | Verify creating job request in database with correct charges. | Customer views worker profile. Worker rate: ₹500/hr. | Booking date: "2026-05-25"<br>Hours: 3<br>Slot: "10:00 AM - 01:00 PM" | 1. Click Request Job.<br>2. Select slot and hours.<br>3. Click submit. | 1. Job document created.<br>2. Status set to "pending".<br>3. `totalPrice` set to ₹1500 (3 * 500). |
| **TC-JOB-02** | Request Accept & Auto-Reject | Verify acceptance locks worker and auto-rejects other pending requests. | Multiple pending jobs exist for Customer. | Job ID: "JOB_ALPHA" | 1. Worker opens Request tab.<br>2. Clicks Accept on "JOB_ALPHA". | 1. "JOB_ALPHA" status = "accepted".<br>2. Other customer jobs = "rejected".<br>3. Worker `isWorking` = true.<br>4. 6-digit `jobOtp` generated. |
| **TC-JOB-03** | OTP Verification (Success) | Verify worker inputs correct OTP to activate job on-site. | Job accepted. Customer has OTP displayed on screen. | Entered OTP: "123456" (Matching) | 1. Worker enters customer's OTP code in app.<br>2. Clicks Verify OTP. | 1. `otpVerified` updated to `true` in Firestore.<br>2. Returns verification success. |
| **TC-JOB-04** | OTP Verification (Failure) | Verify worker inputs incorrect OTP code. | Job accepted. Customer has OTP. | Entered OTP: "000000" (Mismatching) | 1. Worker enters incorrect OTP code.<br>2. Clicks Verify OTP. | 1. Returns failure dialog.<br>2. `otpVerified` remains `false`. |
| **TC-JOB-05** | Complete Job | Verify completing job restores worker availability. | OTP verified. Job in progress. | Complete Job trigger | 1. Customer clicks Complete Job on UI. | 1. Job status = "completed", paymentStatus = "paid".<br>2. Worker `isWorking` set to `false` (active in search again). |

---

### 5. Ratings and Feedback (TC-REV)

| Test ID | Component / Feature | Test Description | Preconditions | Input Data | Test Steps | Expected Output |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-REV-01** | Review Submission | Verify submitting ratings updates worker aggregates. | Job status = "completed", `isReviewed` = false. Worker has 1 review (5.0 avg). | Rating: 4<br>ReviewText: "Good work" | 1. Customer opens review dialog.<br>2. Selects 4 stars and types comment.<br>3. Clicks Submit. | 1. Review doc written to database.<br>2. Job `isReviewed` set to `true`.<br>3. Worker averageRating updated to 4.5 ((5.0*1 + 4)/2).<br>4. totalReviews set to 2. |
| **TC-REV-02** | Duplicate Review Guard | Verify client cannot submit reviews for already reviewed bookings. | Job `isReviewed` is already `true`. | Review dialog trigger | 1. Navigate to booking card. | 1. "Review" button is disabled/hidden.<br>2. Call fails if bypassed directly. |

---

### 6. Admin Panel Operations (TC-ADM)

| Test ID | Component / Feature | Test Description | Preconditions | Input Data | Test Steps | Expected Output |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-ADM-01** | Monitor Collections | Verify admin pulls dashboard records from Firestore. | Admin logged in. | Admin dashboard active | 1. Click tabs (Users, Workers, Jobs). | 1. Admin reads all collections.<br>2. Displays lists with correct status details. |
