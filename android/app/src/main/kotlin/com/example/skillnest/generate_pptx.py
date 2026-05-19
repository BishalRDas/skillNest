import sys
import os
import subprocess

# Ensure python-pptx is installed
try:
    import pptx
except ImportError:
    print("python-pptx not found. Installing now...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "python-pptx"])
    import pptx

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def build_presentation():
    prs = Presentation()
    # 16:9 widescreen dimensions
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # Color Palette (Slate Blue / Dark Teal theme)
    COLOR_PRIMARY = RGBColor(15, 23, 42)     # Slate 900
    COLOR_ACCENT = RGBColor(59, 130, 246)    # Blue 500
    COLOR_WHITE = RGBColor(255, 255, 255)
    COLOR_BG_LIGHT = RGBColor(248, 250, 252) # Slate 50
    COLOR_TEXT_DARK = RGBColor(30, 41, 59)   # Slate 800
    COLOR_TEXT_MUTED = RGBColor(100, 116, 139) # Slate 500

    def set_solid_background(slide, color):
        background = slide.background
        fill = background.fill
        fill.solid()
        fill.fore_color.rgb = color

    def add_title(slide, text, color=COLOR_PRIMARY):
        txBox = slide.shapes.add_textbox(Inches(0.5), Inches(0.4), Inches(12.33), Inches(0.8))
        tf = txBox.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
        p = tf.paragraphs[0]
        p.text = text
        p.font.size = Pt(36)
        p.font.bold = True
        p.font.color.rgb = color
        p.font.name = 'Arial'

    def create_bullet_slide(title, points):
        slide = prs.slides.add_slide(prs.slide_layouts[6]) # Blank
        set_solid_background(slide, COLOR_BG_LIGHT)
        add_title(slide, title)
        
        txBox = slide.shapes.add_textbox(Inches(0.7), Inches(1.5), Inches(11.93), Inches(5.2))
        tf = txBox.text_frame
        tf.word_wrap = True
        
        for idx, pt in enumerate(points):
            p = tf.add_paragraph() if idx > 0 else tf.paragraphs[0]
            p.text = "• " + pt
            p.font.size = Pt(22)
            p.font.color.rgb = COLOR_TEXT_DARK
            p.font.name = 'Arial'
            p.space_after = Pt(20)
            p.line_spacing = 1.15
        return slide

    def create_diagram_slide(title, text_bullets, image_filename):
        slide = prs.slides.add_slide(prs.slide_layouts[6]) # Blank
        set_solid_background(slide, COLOR_BG_LIGHT)
        add_title(slide, title)
        
        # Left Text Panel
        txBox = slide.shapes.add_textbox(Inches(0.5), Inches(1.5), Inches(4.5), Inches(5.2))
        tf = txBox.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_right = 0
        
        for idx, pt in enumerate(text_bullets):
            p = tf.add_paragraph() if idx > 0 else tf.paragraphs[0]
            p.text = "• " + pt
            p.font.size = Pt(18)
            p.font.color.rgb = COLOR_TEXT_DARK
            p.font.name = 'Arial'
            p.space_after = Pt(14)
            p.line_spacing = 1.1

        # Right Image Panel
        img_path = os.path.join(os.path.dirname(__file__), image_filename)
        if os.path.exists(img_path):
            # Scale and center on the right side
            slide.shapes.add_picture(img_path, Inches(5.3), Inches(1.4), width=Inches(7.533), height=Inches(5.3))
        else:
            # Fallback text box if image missing
            box = slide.shapes.add_textbox(Inches(5.3), Inches(1.4), Inches(7.533), Inches(5.3))
            tf_err = box.text_frame
            p_err = tf_err.paragraphs[0]
            p_err.text = f"[Image {image_filename} not found]"
            p_err.font.color.rgb = RGBColor(239, 68, 68)
            p_err.font.size = Pt(24)
            p_err.alignment = PP_ALIGN.CENTER
            
        return slide

    # ==========================================
    # SLIDE 1: Title Slide (Dark Background)
    # ==========================================
    slide_title = prs.slides.add_slide(prs.slide_layouts[6])
    set_solid_background(slide_title, COLOR_PRIMARY)

    txBox = slide_title.shapes.add_textbox(Inches(1.0), Inches(2.0), Inches(11.33), Inches(2.0))
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "SkillNest"
    p.font.size = Pt(64)
    p.font.bold = True
    p.font.color.rgb = COLOR_WHITE
    p.font.name = 'Arial'
    p.alignment = PP_ALIGN.CENTER

    p2 = tf.add_paragraph()
    p2.text = "On-Demand Local Service Finder & Booking Platform"
    p2.font.size = Pt(28)
    p2.font.color.rgb = COLOR_ACCENT
    p2.font.name = 'Arial'
    p2.alignment = PP_ALIGN.CENTER
    p2.space_before = Pt(10)

    txBox_meta = slide_title.shapes.add_textbox(Inches(1.0), Inches(5.2), Inches(11.33), Inches(1.0))
    tf_meta = txBox_meta.text_frame
    p_meta = tf_meta.paragraphs[0]
    p_meta.text = "Software Requirements Specification & System Architecture Design\nCreated: May 2026"
    p_meta.font.size = Pt(16)
    p_meta.font.color.rgb = COLOR_TEXT_MUTED
    p_meta.alignment = PP_ALIGN.CENTER

    # ==========================================
    # SLIDE 2: Project Overview & Scope
    # ==========================================
    create_bullet_slide("Project Overview & Scope", [
        "SkillNest is an on-demand directory connecting customers with local freelance service providers (electricians, plumbers, painters, etc.).",
        "Target Platforms: Cross-platform mobile applications implemented using Flutter framework.",
        "Backend Core: Runs on Firebase Authentication (secure logins) and Google Cloud Firestore (real-time NoSQL storage).",
        "Key Differentiator: Interactive location-based searching combined with a secure OTP handshake verification flow to safeguard physical job transactions."
    ])

    # ==========================================
    # SLIDE 3: System Features & Capabilities
    # ==========================================
    create_bullet_slide("System Features & Role Separation", [
        "Customer Panel: Custom searches, maps integration for city tagging, job booking, OTP tracking, payments, and ratings submission.",
        "Worker Directory: Custom profile details, base64 photo processing, charges management, availability toggle (Online/Offline), requests acceptance, and verification.",
        "OTP Handshake Protection: Secures the connection. Jobs are only validated when workers verify the customer's unique code on-site.",
        "Feedback Engine: Dynamic transactional review execution updating workers' total counts and average ratings atomically."
    ])

    # ==========================================
    # SLIDE 4: Use Case Diagram
    # ==========================================
    create_diagram_slide(
        "Use Case Diagram",
        [
            "Customer Actor: Initiates profiles, registers location coordinates, searches, requests bookings, and submits ratings.",
            "Worker Actor: Manages availability status, updates hourly pricing charges, accepts jobs, and executes verification code entries.",
            "Admin Actor: Pulls global database lists for monitoring users, workers, and active transactions."
        ],
        "UseCaseDiagram.png"
    )

    # ==========================================
    # SLIDE 5: Entity-Relationship Diagram (ERD)
    # ==========================================
    create_diagram_slide(
        "Entity-Relationship Diagram",
        [
            "users collection: Core registry containing authentication credentials, location fields, and user roles.",
            "workers collection: Sub-document extension for workers storing skill categories, charges, and ratings.",
            "jobs collection: Pivot registry mapping transactions (payment status, OTP code, completion details).",
            "reviews collection: Connects jobs to ratings feedback records."
        ],
        "ERDiagram.png"
    )

    # ==========================================
    # SLIDE 6: Data Flow Diagram (DFD Level 0)
    # ==========================================
    create_diagram_slide(
        "Data Flow Diagram (Level 0 - Context)",
        [
            "High-level depiction of input/output boundaries.",
            "Customer sends credentials, maps data, booking parameters, and completions.",
            "Worker sends certifications, status toggles, and OTP entries.",
            "System feeds matching provider lists, OTP warnings, and admin statistics."
        ],
        "DFD0.png"
    )

    # ==========================================
    # SLIDE 7: Data Flow Diagram (DFD Level 1)
    # ==========================================
    create_diagram_slide(
        "Data Flow Diagram (Level 1 - Detail)",
        [
            "Authentication & Redirection (1.0): Validates logins.",
            "Profile & Coordinates Management (2.0): Compresses images & updates Firestore.",
            "Search & Booking Engine (3.0, 4.0): Evaluates matching locations.",
            "OTP verification & Completion (5.0): Regulates job states.",
            "Ratings Execution (6.0): Runs atomic calculation transactions."
        ],
        "DFD1.png"
    )

    # ==========================================
    # SLIDE 8: Sequence Diagram (Job Booking Loop)
    # ==========================================
    create_diagram_slide(
        "Transaction Sequence Diagram",
        [
            "1. Request Phase: Customer submits a booking. System stores status as pending.",
            "2. Acceptance: Worker accepts; system auto-rejects other requests, locks worker, and generates OTP.",
            "3. Verification: Worker inputs customer's verbal OTP, unlocking 'In Progress' state.",
            "4. Completion: Customer clicks complete, finalizing payment and resetting worker locks."
        ],
        "SequenceDiagram.png"
    )

    # ==========================================
    # SLIDE 9: Project Gantt Chart
    # ==========================================
    create_diagram_slide(
        "Development Gantt Chart",
        [
            "Phase 1 (Requirements): Requirements elicitation, SRS draft, and architectural diagram modeling.",
            "Phase 2 (UI/UX Design): Style system configuration, location pickers, and screen views mockups.",
            "Phase 3 (Core Services): Firebase authentication, jobs transaction engines, and OTP verifier integrations.",
            "Phase 4 (Testing & Deployment): Regression tests, widget mocks, and building production bundles."
        ],
        "GanttChart.png"
    )

    # ==========================================
    # SLIDE 10: Verification & Test Cases
    # ==========================================
    slide_tc = prs.slides.add_slide(prs.slide_layouts[6])
    set_solid_background(slide_tc, COLOR_BG_LIGHT)
    add_title(slide_tc, "Verification & Test Cases Summary")

    # Add a table to summarize key test cases
    rows = 7
    cols = 4
    left = Inches(0.5)
    top = Inches(1.5)
    width = Inches(12.33)
    height = Inches(5.2)

    table = slide_tc.shapes.add_table(rows, cols, left, top, width, height).table
    
    # Set Column widths
    table.columns[0].width = Inches(1.5)  # Test ID
    table.columns[1].width = Inches(2.2)  # Feature
    table.columns[2].width = Inches(5.13) # Test Steps
    table.columns[3].width = Inches(3.5)  # Expected Output

    # Define Header cells
    headers = ["Test ID", "Feature Area", "Execution Steps Summary", "Expected Result"]
    for col_idx, text in enumerate(headers):
        cell = table.cell(0, col_idx)
        cell.text = text
        cell.fill.solid()
        cell.fill.fore_color.rgb = COLOR_PRIMARY
        p = cell.text_frame.paragraphs[0]
        p.font.bold = True
        p.font.size = Pt(16)
        p.font.color.rgb = COLOR_WHITE
        p.font.name = 'Arial'

    # Data content
    test_cases_summary = [
        ("TC-AUTH-02", "Worker Sign Up", "Fill skills & experience registry, click Register.", "Worker doc created with isApproved=false, routes to WorkerHome."),
        ("TC-PROF-02", "OSM Location Pick", "Select location point on map, trigger Geocode Save.", "Coordinates translated to city string, updates in users profile doc."),
        ("TC-SCH-01", "City Search Filter", "Open customer lookup page in city 'Guwahati'.", "Displays approved, verified workers in same city. Busy workers filtered out."),
        ("TC-JOB-02", "Acceptance Locking", "Worker accepts booking ID.", "Status shifts to accepted, generates OTP code, locks worker availability isWorking=true."),
        ("TC-JOB-03", "OTP Handshake", "Worker enters matching 6-digit Customer OTP.", "otpVerified field set to true in Firestore. Work starts in progress."),
        ("TC-REV-01", "Atomic Review Loop", "Customer submits 4-star review comments.", "Calculates worker rating average atomically via transactions, increments counts.")
    ]

    for row_idx, row_data in enumerate(test_cases_summary):
        for col_idx, text in enumerate(row_data):
            cell = table.cell(row_idx + 1, col_idx)
            cell.text = text
            p = cell.text_frame.paragraphs[0]
            p.font.size = Pt(13)
            p.font.color.rgb = COLOR_TEXT_DARK
            p.font.name = 'Arial'

    # ==========================================
    # SLIDE 11: Technology Stack & Conclusion
    # ==========================================
    create_bullet_slide("Technology Stack & Architecture Summary", [
        "Core Frontend Framework: Flutter (Dart SDK) using clean state toggles and streams architecture.",
        "Mapping Integrations: flutter_map using OpenStreetMap tile provider API, and geocoding package for geographic reverse-lookup.",
        "Database Architecture: Google Cloud Firestore (NoSQL, collection-based triggers and document references).",
        "Authentication Engine: Firebase Auth, augmented with a custom OTP verifier flow for transaction safety.",
        "Verification Standard: Full coverage via structured unit services tests and role-based interface scenario test guides."
    ])

    # Save presentation
    output_path = os.path.join(os.path.dirname(__file__), "SkillNest_Presentation.pptx")
    prs.save(output_path)
    print(f"Presentation successfully created at {output_path}")

if __name__ == "__main__":
    build_presentation()
