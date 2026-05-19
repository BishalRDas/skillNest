const pptxgen = require("pptxgenjs");
const path = require("path");
const fs = require("fs");

function buildPresentation() {
  const pptx = new pptxgen();
  pptx.layout = "LAYOUT_16x9";

  // Palette colors (Hex strings, without hash prefix)
  const COLOR_PRIMARY = "0F172A";     // Slate 900
  const COLOR_ACCENT = "3B82F6";      // Blue 500
  const COLOR_WHITE = "FFFFFF";
  const COLOR_BG_LIGHT = "F8FAFC";   // Slate 50
  const COLOR_TEXT_DARK = "1E293B";  // Slate 800
  const COLOR_TEXT_MUTED = "64748B"; // Slate 500

  // Helper to add title
  function addTitle(slide, text, isDark = false) {
    slide.addText(text, {
      x: 0.5,
      y: 0.4,
      w: 12.3,
      h: 0.8,
      fontSize: 36,
      bold: true,
      color: isDark ? COLOR_WHITE : COLOR_PRIMARY,
      fontFace: "Arial"
    });
  }

  // Helper to create content slide with bullets
  function createBulletSlide(title, points) {
    const slide = pptx.addSlide();
    slide.background = { fill: COLOR_BG_LIGHT };
    addTitle(slide, title);
    
    const bulletText = points.map(p => ({
      text: "• " + p,
      options: { fontSize: 22, color: COLOR_TEXT_DARK, fontFace: "Arial", spaceAfter: 20 }
    }));
    
    slide.addText(bulletText, {
      x: 0.7,
      y: 1.5,
      w: 11.9,
      h: 5.2,
      valign: "top"
    });
    return slide;
  }

  // Helper to create diagram slide
  function createDiagramSlide(title, bullets, imageName) {
    const slide = pptx.addSlide();
    slide.background = { fill: COLOR_BG_LIGHT };
    addTitle(slide, title);
    
    const bulletText = bullets.map(p => ({
      text: "• " + p,
      options: { fontSize: 18, color: COLOR_TEXT_DARK, fontFace: "Arial", spaceAfter: 14 }
    }));
    
    slide.addText(bulletText, {
      x: 0.5,
      y: 1.5,
      w: 4.5,
      h: 5.2,
      valign: "top"
    });
    
    const imgPath = path.join(__dirname, imageName);
    if (fs.existsSync(imgPath)) {
      slide.addImage({
        path: imgPath,
        x: 5.3,
        y: 1.4,
        w: 7.5,
        h: 5.3
      });
    } else {
      slide.addText(`[Image ${imageName} not found]`, {
        x: 5.3,
        y: 1.4,
        w: 7.5,
        h: 5.3,
        color: "EF4444",
        fontSize: 24,
        align: "center",
        valign: "middle"
      });
    }
    return slide;
  }

  // ==========================================
  // SLIDE 1: Title Slide (Dark Background)
  // ==========================================
  const slideTitle = pptx.addSlide();
  slideTitle.background = { fill: COLOR_PRIMARY };

  // Add big title
  slideTitle.addText("SkillNest", {
    x: 1.0,
    y: 2.0,
    w: 11.3,
    h: 1.2,
    fontSize: 64,
    bold: true,
    color: COLOR_WHITE,
    fontFace: "Arial",
    align: "center"
  });

  // Add subtitle
  slideTitle.addText("On-Demand Local Service Finder & Booking Platform", {
    x: 1.0,
    y: 3.3,
    w: 11.3,
    h: 0.8,
    fontSize: 28,
    color: COLOR_ACCENT,
    fontFace: "Arial",
    align: "center"
  });

  // Add meta info
  slideTitle.addText("Software Requirements Specification & System Architecture Design\nCreated: May 2026", {
    x: 1.0,
    y: 5.2,
    w: 11.3,
    h: 1.0,
    fontSize: 16,
    color: COLOR_TEXT_MUTED,
    fontFace: "Arial",
    align: "center"
  });

  // ==========================================
  // SLIDE 2: Project Overview & Scope
  // ==========================================
  createBulletSlide("Project Overview & Scope", [
    "SkillNest is an on-demand directory connecting customers with local freelance service providers (electricians, plumbers, painters, etc.).",
    "Target Platforms: Cross-platform mobile applications implemented using Flutter framework.",
    "Backend Core: Runs on Firebase Authentication (secure logins) and Google Cloud Firestore (real-time NoSQL storage).",
    "Key Differentiator: Interactive location-based searching combined with a secure OTP handshake verification flow to safeguard physical job transactions."
  ]);

  // ==========================================
  // SLIDE 3: System Features & Role Separation
  // ==========================================
  createBulletSlide("System Features & Role Separation", [
    "Customer Panel: Custom searches, maps integration for city tagging, job booking, OTP tracking, payments, and ratings submission.",
    "Worker Directory: Custom profile details, base64 photo processing, charges management, availability toggle (Online/Offline), requests acceptance, and verification.",
    "OTP Handshake Protection: Secures the connection. Jobs are only validated when workers verify the customer's unique code on-site.",
    "Feedback Engine: Dynamic transactional review execution updating workers' total counts and average ratings atomically."
  ]);

  // ==========================================
  // SLIDE 4: Use Case Diagram
  // ==========================================
  createDiagramSlide(
    "Use Case Diagram",
    [
      "Customer Actor: Initiates profiles, registers location coordinates, searches, requests bookings, and submits ratings.",
      "Worker Actor: Manages availability status, updates hourly pricing charges, accepts jobs, and executes verification code entries.",
      "Admin Actor: Pulls global database lists for monitoring users, workers, and active transactions."
    ],
    "UseCaseDiagram.png"
  );

  // ==========================================
  // SLIDE 5: Entity-Relationship Diagram (ERD)
  // ==========================================
  createDiagramSlide(
    "Entity-Relationship Diagram",
    [
      "users collection: Core registry containing authentication credentials, location fields, and user roles.",
      "workers collection: Sub-document extension for workers storing skill categories, charges, and ratings.",
      "jobs collection: Pivot registry mapping transactions (payment status, OTP code, completion details).",
      "reviews collection: Connects jobs to ratings feedback records."
    ],
    "ERDiagram.png"
  );

  // ==========================================
  // SLIDE 6: Data Flow Diagram (DFD Level 0)
  // ==========================================
  createDiagramSlide(
    "Data Flow Diagram (Level 0 - Context)",
    [
      "High-level depiction of input/output boundaries.",
      "Customer sends credentials, maps data, booking parameters, and completions.",
      "Worker sends certifications, status toggles, and OTP entries.",
      "System feeds matching provider lists, OTP warnings, and admin statistics."
    ],
    "DFD0.png"
  );

  // ==========================================
  // SLIDE 7: Data Flow Diagram (DFD Level 1)
  // ==========================================
  createDiagramSlide(
    "Data Flow Diagram (Level 1 - Detail)",
    [
      "Authentication & Redirection (1.0): Validates logins.",
      "Profile & Coordinates Management (2.0): Compresses images & updates Firestore.",
      "Search & Booking Engine (3.0, 4.0): Evaluates matching locations.",
      "OTP verification & Completion (5.0): Regulates job states.",
      "Ratings Execution (6.0): Runs atomic calculation transactions."
    ],
    "DFD1.png"
  );

  // ==========================================
  // SLIDE 8: Sequence Diagram (Job Booking Loop)
  // ==========================================
  createDiagramSlide(
    "Transaction Sequence Diagram",
    [
      "1. Request Phase: Customer submits a booking. System stores status as pending.",
      "2. Acceptance: Worker accepts; system auto-rejects other requests, locks worker, and generates OTP.",
      "3. Verification: Worker inputs customer's verbal OTP, unlocking 'In Progress' state.",
      "4. Completion: Customer clicks complete, finalizing payment and resetting worker locks."
    ],
    "SequenceDiagram.png"
  );

  // ==========================================
  // SLIDE 9: Project Gantt Chart
  // ==========================================
  createDiagramSlide(
    "Development Gantt Chart",
    [
      "Phase 1 (Requirements): Requirements elicitation, SRS draft, and architectural diagram modeling.",
      "Phase 2 (UI/UX Design): Style system configuration, location pickers, and screen views mockups.",
      "Phase 3 (Core Services): Firebase authentication, jobs transaction engines, and OTP verifier integrations.",
      "Phase 4 (Testing & Deployment): Regression tests, widget mocks, and building production bundles."
    ],
    "GanttChart.png"
  );

  // ==========================================
  // SLIDE 10: Verification & Test Cases
  // ==========================================
  const slideTc = pptx.addSlide();
  slideTc.background = { fill: COLOR_BG_LIGHT };
  addTitle(slideTc, "Verification & Test Cases Summary");

  // Create table rows
  const cellHeaderStyle = { fill: COLOR_PRIMARY, color: COLOR_WHITE, bold: true, fontSize: 14, fontFace: "Arial" };
  const cellBodyStyle = { fontSize: 11, color: COLOR_TEXT_DARK, fontFace: "Arial" };

  const rows = [
    [
      { text: "Test ID", options: cellHeaderStyle },
      { text: "Feature Area", options: cellHeaderStyle },
      { text: "Execution Steps Summary", options: cellHeaderStyle },
      { text: "Expected Result", options: cellHeaderStyle }
    ],
    [
      { text: "TC-AUTH-02", options: cellBodyStyle },
      { text: "Worker Sign Up", options: cellBodyStyle },
      { text: "Fill skills & experience registry, click Register.", options: cellBodyStyle },
      { text: "Worker doc created with isApproved=false, routes to WorkerHome.", options: cellBodyStyle }
    ],
    [
      { text: "TC-PROF-02", options: cellBodyStyle },
      { text: "OSM Location Pick", options: cellBodyStyle },
      { text: "Select location point on map, trigger Geocode Save.", options: cellBodyStyle },
      { text: "Coordinates translated to city string, updates in users profile doc.", options: cellBodyStyle }
    ],
    [
      { text: "TC-SCH-01", options: cellBodyStyle },
      { text: "City Search Filter", options: cellBodyStyle },
      { text: "Open customer lookup page in city 'Guwahati'.", options: cellBodyStyle },
      { text: "Displays approved, verified workers in same city. Busy workers filtered out.", options: cellBodyStyle }
    ],
    [
      { text: "TC-JOB-02", options: cellBodyStyle },
      { text: "Acceptance Locking", options: cellBodyStyle },
      { text: "Worker accepts booking ID.", options: cellBodyStyle },
      { text: "Status shifts to accepted, generates OTP code, locks worker availability isWorking=true.", options: cellBodyStyle }
    ],
    [
      { text: "TC-JOB-03", options: cellBodyStyle },
      { text: "OTP Handshake", options: cellBodyStyle },
      { text: "Worker enters matching 6-digit Customer OTP.", options: cellBodyStyle },
      { text: "otpVerified field set to true in Firestore. Work starts in progress.", options: cellBodyStyle }
    ],
    [
      { text: "TC-REV-01", options: cellBodyStyle },
      { text: "Atomic Review Loop", options: cellBodyStyle },
      { text: "Customer submits 4-star review comments.", options: cellBodyStyle },
      { text: "Calculates worker rating average atomically via transactions, increments counts.", options: cellBodyStyle }
    ]
  ];

  slideTc.addTable(rows, {
    x: 0.5,
    y: 1.5,
    w: 12.3,
    h: 5.2,
    colW: [1.3, 1.8, 5.2, 4.0]
  });

  // ==========================================
  // SLIDE 11: Technology Stack & Conclusion
  // ==========================================
  createBulletSlide("Technology Stack & Architecture Summary", [
    "Core Frontend Framework: Flutter (Dart SDK) using clean state toggles and streams architecture.",
    "Mapping Integrations: flutter_map using OpenStreetMap tile provider API, and geocoding package for geographic reverse-lookup.",
    "Database Architecture: Google Cloud Firestore (NoSQL, collection-based triggers and document references).",
    "Authentication Engine: Firebase Auth, augmented with a custom OTP verifier flow for transaction safety.",
    "Verification Standard: Full coverage via structured unit services tests and role-based interface scenario test guides."
  ]);

  // Save the presentation file
  const outputPath = path.join(__dirname, "SkillNest_Presentation.pptx");
  pptx.writeFile({ fileName: outputPath }).then(() => {
    console.log(`Presentation successfully created at ${outputPath}`);
  }).catch(err => {
    console.error(`Error saving presentation: ${err.message}`);
  });
}

buildPresentation();
