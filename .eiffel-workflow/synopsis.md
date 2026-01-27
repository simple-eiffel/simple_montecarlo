# Phase 2: Adversarial Review Synopsis

**Project:** simple_montecarlo (Monte Carlo simulation framework)
**Date:** 2026-01-27
**Status:** REVIEW COMPLETE - READY FOR APPROVAL
**Reviewers:** Ollama (deepseek-coder-v2:16b)

---

## Executive Summary

**Verdict:** ✓ **CONTRACTS APPROVED FOR PHASE 3**

Ollama's adversarial review identified **5 issues** across the 5 core contract classes. Critical assessment:
- **Contract Design:** SOUND (no architectural flaws)
- **Void Safety:** SOLID (all void-safety concerns properly handled)
- **Precondition Strength:** GOOD (preconditions prevent invalid states)
- **Main Finding:** Issues are **implementation concerns**, not contract design problems

**Recommendation:** Proceed to Phase 3 (task breakdown) with these findings as implementation guidance during Phase 4.

---

## Issues Identified

### High Severity (2 issues)

#### Issue #1: `MONTE_CARLO_EXPERIMENT.compute_statistics` - Placeholder Implementation

**Location:** src/monte_carlo_experiment.e:197-209
**Class:** MONTE_CARLO_EXPERIMENT
**Feature:** compute_statistics (a_measurements: ARRAYED_LIST [REAL_64]): SIMULATION_STATISTICS

**Finding:**
Method is currently a skeleton that returns dummy statistics:
```eiffel
create Result.make (0, 0, 0, 0, 0, 0, 0, 0, trial_count)
```

**Impact:** Phase 4 implementation must compute actual mean, std_dev, min, max, and confidence intervals from measurements. This is expected for Phase 1 contracts.

**Phase 4 Task:**
- Accept ARRAYED_LIST [REAL_64] parameter (measurements)
- Compute: mean = sum / count
- Compute: std_dev = sqrt(variance)
- Compute: min, max via sorted/iteration
- Compute: CI_95, CI_99 via statistical formulas (integrate simple_math)
- Create Result with all 9 parameters filled

**Contract Validity:** ✓ Preconditions are correct (measurements_attached, measurements_not_empty). Postconditions are achievable (result_attached, result_sample_size).

---

#### Issue #5: `MONTE_CARLO_EXPERIMENT.run_simulation` - Agent Validation

**Location:** src/monte_carlo_experiment.e:55-87
**Class:** MONTE_CARLO_EXPERIMENT
**Feature:** run_simulation

**Finding:**
Ollama noted that precondition `logic_defined: trial_logic_agent /= Void` already exists (line 58) and is correctly enforced before invocation (line 72: `if attached trial_logic_agent as l_agent`).

**Assessment:** ✓ **Already correctly implemented.** Ollama's concern is moot - the contract is solid.

**Why Marked High:** Ollama marked this as high severity because the pattern wasn't obvious. The attached check pattern is correct void-safety handling.

---

### Medium Severity (1 issue)

#### Issue #2: `MONTE_CARLO_EXPERIMENT.extract_all_measurements` - Incomplete Implementation

**Location:** src/monte_carlo_experiment.e:186-195
**Class:** MONTE_CARLO_EXPERIMENT
**Feature:** extract_all_measurements: ARRAYED_LIST [REAL_64]

**Finding:**
Method creates an empty list but doesn't populate it:
```eiffel
create Result.make (trial_count)
-- Implementation in Phase 4
```

**Impact:** Phase 4 must iterate outcomes and collect measurements.

**Phase 4 Task:**
- Iterate: `across outcomes as oc loop ... end`
- For each outcome, extract measurement (TRIAL_OUTCOME has measurements)
- Append each to Result list
- Handle potential void/attached states via `if attached` guards

**Contract Validity:** ✓ Precondition (has_run) ensures outcomes are populated. Postcondition (result_attached) is achievable.

---

### Low Severity (2 issues)

#### Issue #3: `MONTE_CARLO_EXPERIMENT.make` - Redundant Validation Suggestion

**Location:** src/monte_carlo_experiment.e:13-27
**Class:** MONTE_CARLO_EXPERIMENT
**Feature:** make (a_trial_count: INTEGER)

**Finding:**
Ollama suggested adding validation in constructor:
```eiffel
if trial_count <= 0 then
    raise ("Invalid trial count")
end
```

**Assessment:** ✗ **DO NOT ADD.** This is redundant:
1. Precondition `positive_trial_count: a_trial_count > 0` already prevents invalid values at call site
2. Eiffel DbC philosophy: validate at boundaries (callers), not in constructors
3. Adding exception throwing inside a constructor violates Eiffel conventions
4. Postcondition `trial_count_set: trial_count = a_trial_count` is sufficient

**Phase 4 Decision:** Keep constructor as-is. Trust the precondition.

---

#### Issue #4: `MONTE_CARLO_EXPERIMENT.outcome_at` - Indexing Clarity

**Location:** src/monte_carlo_experiment.e:126-135
**Class:** MONTE_CARLO_EXPERIMENT
**Feature:** outcome_at (a_index: INTEGER): TRIAL_OUTCOME

**Finding:**
Current code: `Result := outcomes [a_index]`

Ollama noted that `outcome_at` uses 1-based indexing (precondition: `1 <= a_index <= trial_count`), but internally outcomes is an ARRAYED_LIST (0-based). This creates a potential off-by-one error.

**Phase 4 Task:**
Option A (Recommended): Adjust indexing for user-friendliness:
```eiffel
Result := outcomes [a_index - 1]  -- Convert 1-based to 0-based
```

Option B: Keep as-is and document in postcondition comment:
```eiffel
-- Outcome from trial number `a_index` (1-indexed to user, 1-indexed internally)
```

**Contract Validity:** ⚠ Both options are valid; Phase 4 must choose consistently. The precondition and postcondition don't reveal the internal indexing scheme - this is a usability issue.

**Recommendation for Phase 4:** Use Option A (adjust to outcomes[a_index - 1]) because:
- Users think in 1-based trials ("trial 1, trial 2, ...")
- Internal ARRAYED_LIST is 0-based
- Conversion at boundary is standard pattern

---

## Issue Classification by Component

| Class | Issue | Severity | Phase 4 Impact | Status |
|-------|-------|----------|----------------|--------|
| MONTE_CARLO_EXPERIMENT | compute_statistics placeholder | High | Implement statistics calculations | Expected |
| MONTE_CARLO_EXPERIMENT | run_simulation agent validation | High | ✓ Already correct | Verified |
| MONTE_CARLO_EXPERIMENT | extract_all_measurements placeholder | Medium | Implement iteration + extraction | Expected |
| MONTE_CARLO_EXPERIMENT | make validation redundancy | Low | Reject suggestion; trust precondition | Design Decision |
| MONTE_CARLO_EXPERIMENT | outcome_at indexing | Low | Clarify and fix off-by-one | Phase 4 Choice |

---

## Contract Design Assessment

### Strengths

✓ **Void Safety:** All classes compile with void_safety="all"
✓ **Preconditions:** Well-structured, enforce valid states at entry
✓ **Postconditions:** Specify achievable outcomes without over-constraining
✓ **Invariants:** Correctly track class consistency (e.g., trial_count > 0, outcomes bounded)
✓ **SCOOP Compatibility:** Explicit attached checks for detachable fields
✓ **Semantic API:** Business-friendly names (Experiment, Trial, Outcome, Measurement)

### Areas Flagged for Implementation

⚠ **Model Queries:** outcomes_count, outcomes_valid are helpers; full MML_SEQUENCE integration deferred to Phase 4 ✓ (intentional)
⚠ **Placeholder Methods:** compute_statistics and extract_all_measurements need bodies in Phase 4 ✓ (expected)
⚠ **Indexing Edge Case:** outcome_at needs clarification on 1-based vs 0-based ✓ (identified)

### No Critical Flaws

✗ No missing invariants identified
✗ No weak preconditions (all preconditions constrain to valid states)
✗ No frame condition violations (all postconditions track state changes)
✗ No void-safety issues beyond current attached check pattern
✗ No SCOOP incompatibilities

---

## Ollama's Overall Assessment

> "The contracts are generally well-structured with good preconditions and postconditions. The main issues are:
> 1. **Placeholder implementations** that need real logic (compute_statistics, extract_all_measurements)
> 2. **Clarity on indexing schemes** (1-based vs 0-based)
> 3. **Validation of agent state** before invocation
>
> All issues are addressable and the fundamental contract design is sound. The void-safe and SCOOP-compatible structure is properly maintained."

---

## Recommendations for Phase 3 (Task Breakdown)

When generating Phase 3 tasks via `/eiffel.tasks`, ensure:

1. **Issue #1 Task (High Priority):**
   - Implement compute_statistics with mean, std_dev, min, max, CI calculations
   - Integrate simple_math for sqrt, percentile functions
   - Tag: STATISTICS_CALCULATION

2. **Issue #2 Task (High Priority):**
   - Implement extract_all_measurements to iterate outcomes and collect measurements
   - Handle void/attached states with proper guards
   - Tag: DATA_EXTRACTION

3. **Issue #4 Task (Medium Priority):**
   - Decide: outcome_at indexing (1-based to user, 0-based internally)
   - Recommend: `Result := outcomes [a_index - 1]`
   - Tag: INDEXING_CLARITY

4. **Issue #5 Verification (Low Priority):**
   - Confirm run_simulation precondition and attached check are correct
   - No changes needed
   - Tag: VERIFICATION_ONLY

---

## Decision: Proceed to Phase 3?

**Current Status:** ✓ **YES - APPROVED**

**Rationale:**
- Contract design is architecturally sound
- All identified issues are implementation-level (appropriate for Phase 4)
- No design flaws that would require contract rework
- Void safety and SCOOP compatibility verified
- Issues are actionable and well-scoped for Phase 3 task breakdown

**Next Action:**
Run `/eiffel.tasks d:\prod\simple_montecarlo` to break contracts into implementation tasks for Phase 4.

---

**Evidence File:** `.eiffel-workflow/evidence/phase2-chain.txt`
**Generated by:** Claude Code Eiffel-Review Skill
**Date:** 2026-01-27

