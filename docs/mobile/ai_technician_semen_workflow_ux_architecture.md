# AI Technician Semen-Service Workflow UX Architecture

Goal: create a guided, field-ready, low-cognitive-load mobile experience that feels like a "guided veterinary field mission" and supports one-handed, outdoor, offline-first execution.

## Global IA Principles
- **Primary mission:** move technician from readiness to verified completion with minimal decisions per step.
- **One-handed use:** primary actions pinned at bottom; thumb-zone controls; avoid top-right actions.
- **Low literacy, fast scan:** short labels, icons + color cues, numbered steps, progressive disclosure.
- **Outdoor visibility:** high-contrast text, large tap targets, minimal fine-print, avoid light gray.
- **Emergency-safe:** warnings surfaced before risk steps; always-visible exit/assist; persistent status.
- **Offline-first:** cache templates/media; clearly label offline availability; support queued sync.
- **Cognitive load control:** single objective per screen; reduce card fragmentation; clear hierarchy.
- **AI assistance:** inline recommendations and context-aware hints; no separate AI screens.
- **Fail-safe:** visible “pause mission” and “report issue” in all execution screens.

## Navigation Model (Top-Level)
1. **Template Overview**
2. **AI Preparation Center**
3. **Readiness Verification**
4. **Step-by-step Insemination Protocol**
5. **Media Learning Center**
6. **Risk and Warning Center**
7. **Smart Service Creation**
8. **In-progress Execution**
9. **Completion and Verification**

Persistent elements for execution screens (4, 8, 9):
- **Mission header:** status chip, animal ID, offline badge
- **Step rail:** vertical progress or numbered step indicator
- **Sticky bottom action bar:** primary CTA + secondary action (pause/help)

---

## 1) Template Overview
**Purpose:** orient the technician, clarify mission outcome, and surface the primary CTA immediately.  
**Priority level:** Critical entry point.

**Visible sections (always):**
- **Mission banner (top):** template name, animal type, service outcome, offline badge
- **Primary CTA block:** “Start Mission” + “Preview Steps” micro-CTA
- **Mission summary:** duration, tools, required materials (icons)
- **Key risks snapshot:** 1–3 highest risks, severity color
- **AI quick guidance:** “AI recommends…” 1–2 lines

**Collapsible sections:**
- Detailed description / context
- Full tools & materials list
- Protocol steps list (full outline)

**Sticky actions:**
- Bottom bar: **Start Mission** (primary), **Save Offline** (secondary)

**CTA behavior:**
- Tapping **Start Mission** routes to AI Preparation Center.
- **Preview Steps** opens a quick bottom sheet with step count and time.

**Visual hierarchy:**
1. Mission banner + status
2. Start Mission CTA
3. Mission summary chips
4. Key risks snapshot
5. AI guidance

**Technician attention order:**
Mission → Start → Time/Tools → Risks → AI hint → Optional detail.

**Field usability rules:**
- CTA always visible above fold.
- Summary chips use icons + short labels.
- Avoid more than 2 cards; use stacked sections with separators.

---

## 2) AI Preparation Center
**Purpose:** convert preparation into actionable tasks with AI coaching.  
**Priority level:** High (pre-execution safety).

**Visible sections (always):**
- **Preparation progress bar:** % complete
- **Task checklist (top 5):** single-line tasks with checkboxes
- **AI tool check:** “AI confirms equipment readiness” with status
- **Offline media status:** “X assets cached”

**Collapsible sections:**
- Full preparation checklist
- “Why this matters” explanations
- Substitution guidance (if tool missing)

**Sticky actions:**
- Bottom bar: **Continue to Readiness** (primary), **Pause Mission** (secondary)

**CTA behavior:**
- Primary CTA locked until critical tasks checked.
- AI suggests missing steps with inline highlights.

**Visual hierarchy:**
1. Progress bar + remaining count
2. Critical tasks list
3. AI tool check
4. Offline status

**Technician attention order:**
Progress → Critical tasks → AI status → Offline status → Optional details.

**Field usability rules:**
- Single tap to check task.
- “Critical” tasks use red dot + top position.
- Avoid long paragraphs; use micro-explainers only on demand.

---

## 3) Readiness Verification
**Purpose:** confirm technician, animal, and environment readiness before protocol.  
**Priority level:** Critical gate.

**Visible sections (always):**
- **Readiness gate header:** “Ready to Begin?” with checklist count
- **Identity checks:** animal ID, service ID (scan or manual)
- **Environment checks:** temperature, hygiene, privacy (toggle)
- **Consent / authority:** confirm if required

**Collapsible sections:**
- Detailed verification notes
- Risk acknowledgements

**Sticky actions:**
- Bottom bar: **Start Protocol** (primary), **Review Risks** (secondary)

**CTA behavior:**
- Primary CTA disabled until critical checks done.
- **Review Risks** opens risk center (screen 6).

**Visual hierarchy:**
1. Readiness header + count
2. Identity checks
3. Environment checks
4. Consent/authority

**Technician attention order:**
Ready status → Identity → Environment → Consent → Proceed.

**Field usability rules:**
- Use toggle or “Yes/No” buttons instead of text inputs.
- Scan-first with fallback manual entry.

---

## 4) Step-by-step Insemination Protocol
**Purpose:** deliver the protocol as a guided mission with AI assistance.  
**Priority level:** Highest.

**Visible sections (always):**
- **Step header:** “Step X of Y” with time estimate
- **Primary instruction block:** single sentence + icon
- **AI guidance:** “Watch for…” micro-tip
- **Safety alert (if relevant):** inline warning banner
- **Step action controls:** “Done” + “Repeat” + “Need Help”

**Collapsible sections:**
- “Why this step matters”
- Expanded technique guidance
- Reference media

**Sticky actions:**
- Bottom bar: **Mark Step Done** (primary), **Pause/Help** (secondary)

**CTA behavior:**
- Primary CTA advances to next step.
- If step is critical, requires acknowledgment checkbox.

**Visual hierarchy:**
1. Step header + progress
2. Primary instruction
3. Safety alert
4. AI guidance
5. Secondary actions

**Technician attention order:**
Step number → Instruction → Warning → AI hint → Action.

**Field usability rules:**
- One step per screen; no scrolling needed for primary action.
- Use large tap targets; haptic feedback on step complete.

---

## 5) Media Learning Center
**Purpose:** active learning support without breaking mission flow.  
**Priority level:** Medium.

**Visible sections (always):**
- **Quick media rail:** 3–5 short clips or images
- **“Watch before step X” prompts**
- **Download/offline status**

**Collapsible sections:**
- Full media library
- Detailed labels and captions

**Sticky actions:**
- Bottom bar: **Back to Step** (primary), **Download All** (secondary)

**CTA behavior:**
- Auto-suggest media based on current step.
- Short playback with “I Understand” acknowledgment.

**Visual hierarchy:**
1. Step-specific media prompt
2. Media rail
3. Offline status

**Technician attention order:**
Step prompt → Media → Offline availability.

**Field usability rules:**
- Auto-play muted previews; full-screen on tap.
- Download indicator must be visible outdoors (high contrast).

---

## 6) Risk and Warning Center
**Purpose:** consolidate critical safety instructions and emergency handling.  
**Priority level:** High (safety).

**Visible sections (always):**
- **Top critical warnings (max 3)**
- **Emergency actions:** call, report, stop
- **Risk status checks:** confirm if risk conditions exist

**Collapsible sections:**
- Full risk list
- Detailed emergency protocol

**Sticky actions:**
- Bottom bar: **Acknowledge & Return** (primary), **Report Issue** (secondary)

**CTA behavior:**
- Must acknowledge critical warnings before protocol entry.

**Visual hierarchy:**
1. Critical warnings
2. Emergency actions
3. Risk checks

**Technician attention order:**
Warnings → Emergency actions → Risk checks → Return.

**Field usability rules:**
- Use high-contrast red/amber warnings.
- Avoid paragraphs; use bullet micro-steps.

---

## 7) Smart Service Creation
**Purpose:** turn protocol into a structured service session with AI auto-fill.  
**Priority level:** High.

**Visible sections (always):**
- **AI auto-filled summary:** animal, date, location, template
- **Minimal required inputs:** 3–5 fields max
- **Quick confidence rating:** slider or 3-button scale

**Collapsible sections:**
- Full administrative details
- Optional notes

**Sticky actions:**
- Bottom bar: **Create Service** (primary), **Edit Details** (secondary)

**CTA behavior:**
- AI fills values; user confirms.
- Validation inline with single error summary at top.

**Visual hierarchy:**
1. AI summary
2. Required fields
3. Confidence rating

**Technician attention order:**
Summary → Required → Confidence → Create.

**Field usability rules:**
- Use large toggles/selectors; avoid long text entry.
- Show offline queue if no connectivity.

---

## 8) In-progress Execution
**Purpose:** manage active mission state, capture key events quickly.  
**Priority level:** Highest.

**Visible sections (always):**
- **Current step + timer**
- **Event capture buttons:** complication, pause, resume
- **AI quick check:** “AI recommends next action”
- **Progress timeline:** completed steps

**Collapsible sections:**
- Past step notes
- Detailed AI explanations

**Sticky actions:**
- Bottom bar: **Next Step** (primary), **Pause/Help** (secondary)

**CTA behavior:**
- Primary CTA moves to next step or finalize.
- If complication flagged, routes to Risk Center.

**Visual hierarchy:**
1. Current step + timer
2. Next action
3. AI quick check
4. Timeline

**Technician attention order:**
Current step → Next action → AI check → Timeline.

**Field usability rules:**
- Use single-tap event capture.
- Maintain persistent status indicators.

---

## 9) Completion and Verification
**Purpose:** verify outcome, capture evidence, and finalize safely.  
**Priority level:** High (closure).

**Visible sections (always):**
- **Outcome confirmation:** success/failure buttons
- **Verification checklist:** 3–5 items
- **Evidence capture:** photo/notes (optional)
- **Sync status:** offline queue indicator

**Collapsible sections:**
- Full report details
- Additional notes

**Sticky actions:**
- Bottom bar: **Complete Mission** (primary), **Save Draft** (secondary)

**CTA behavior:**
- Completion requires verification checklist.
- If offline, queues submission with confirmation.

**Visual hierarchy:**
1. Outcome confirmation
2. Verification checklist
3. Evidence capture
4. Sync status

**Technician attention order:**
Outcome → Verify → Evidence → Submit.

**Field usability rules:**
- No more than 2 text fields.
- Provide clear offline submission messaging.

---

## Cross-Screen Attention Flow (Mission Loop)
1. **Orientation:** overview → immediate CTA
2. **Preparation:** tasks → readiness gate
3. **Execution:** step + AI guidance → confirm
4. **Verification:** outcome + evidence → completion

## Emergency-Safe Flow
- Always-visible **Pause Mission** and **Report Issue** in execution screens.
- Risk center reachable within 1 tap from any execution screen.
- If critical warning triggered, block progression until acknowledged.

## Offline-First Behavior
- Clear offline badge on all screens.
- Cache templates/media at entry; prompt if not cached.
- Queue service creation and completion if offline.

## Field Usability Heuristics
- Minimum 48px tap targets.
- No more than 2 primary actions per screen.
- Keep primary CTA in thumb zone.
- Short, directive labels: “Start”, “Next”, “Done”.

