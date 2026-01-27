# Implementation Tasks: simple_montecarlo

**Project:** simple_montecarlo (Monte Carlo simulation framework)
**Phase:** Phase 4 (Implementation)
**Date:** 2026-01-27
**Total Tasks:** 8
**Estimated Effort:** 3-4 weeks

---

## Overview

Break contracts from Phase 1 into implementable features with clear acceptance criteria. All tasks follow the Phase 2 synopsis recommendations.

---

## Task 1: Implement MEASUREMENT Class

**Files:** src/measurement.e (60 lines)
**Features Involved:**
- `make_real (a_value: REAL_64)` - Create real-valued measurement
- `make_integer (a_value: INTEGER)` - Create integer-valued measurement
- `as_real: REAL_64` - Convert to real (promote integer if needed)
- `as_integer: INTEGER` - Convert to integer (truncate real if needed)

### Acceptance Criteria

- [ ] `make_real` stores value correctly; postcondition `is_real_measurement: is_real` verified
- [ ] `make_real` rejects NaN values via precondition `not a_value.is_nan`
- [ ] `make_integer` stores value correctly; postcondition `is_integer_measurement: not is_real` verified
- [ ] `as_real` returns original value for real measurements
- [ ] `as_real` converts integer to real via `.to_double` for integer measurements
- [ ] `as_integer` returns original value for integer measurements
- [ ] `as_integer` truncates real to integer via `.truncated_to_integer` for real measurements
- [ ] Invariant `exactly_one_valid: (is_real and integer_value = 0) or (not is_real and real_value = 0.0)` holds
- [ ] Unit test `test_make_real_stores_value` passes
- [ ] Unit test `test_make_integer_stores_value` passes
- [ ] Unit test `test_conversion_real_to_integer` passes
- [ ] Compiles clean with zero warnings

### Implementation Notes

- Type-safe wrapper around REAL_64 or INTEGER
- Prevents confusion between measurement values and probabilities
- No external dependencies (ISE base only)
- Complexity: Trivial (wrapper pattern)

### Phase 2 Issues

None directly affecting MEASUREMENT.

### Dependencies

- Completes before: Task 2 (TRIAL_OUTCOME uses MEASUREMENT)

---

## Task 2: Implement TRIAL_OUTCOME Class

**Files:** src/trial_outcome.e (100 lines)
**Features Involved:**
- `make` - Create empty outcome ready for measurements
- `add_measurement (a_name: STRING; a_value: MEASUREMENT)` - Record named measurement
- `measurement_at (a_name: STRING): MEASUREMENT` - Retrieve measurement by name
- `has_measurement (a_name: STRING): BOOLEAN` - Test measurement existence
- `measurement_count: INTEGER` - Count of measurements
- `count: INTEGER` - Alias for measurement_count

### Acceptance Criteria

- [ ] `make` creates empty outcome; postcondition `is_empty: count = 0` verified
- [ ] `add_measurement` stores measurement with name; postcondition `count_incremented` verified
- [ ] `add_measurement` rejects duplicate names via precondition `unique_name: not has_measurement(a_name)`
- [ ] `add_measurement` maintains invariant `measurements_counts_match: measurements.count = measurement_names.count`
- [ ] `measurement_at` returns correct measurement for stored name
- [ ] `measurement_at` uses precondition `name_exists: has_measurement(a_name)` to guarantee non-void result
- [ ] `has_measurement` returns true only for added measurements
- [ ] `count` and `measurement_count` return same value; postcondition `consistent: Result = measurement_names.count` verified
- [ ] Unit test `test_add_measurement_increments_count` passes
- [ ] Unit test `test_measurement_at_retrieves_stored` passes
- [ ] Unit test `test_duplicate_name_rejection` passes
- [ ] Compiles clean with zero warnings

### Implementation Notes

- Two parallel ARRAYED_LIST collections: measurements and measurement_names
- Maintain index consistency: extend both lists together
- Pattern: TRIAL_OUTCOME collects results from a single trial

### Phase 2 Issues

None directly affecting TRIAL_OUTCOME (helper issue for MONTE_CARLO_EXPERIMENT addressed separately).

### Dependencies

- Depends on: Task 1 (MEASUREMENT)
- Completes before: Task 4 (MONTE_CARLO_EXPERIMENT uses TRIAL_OUTCOME)

---

## Task 3: Implement SIMULATION_STATISTICS Class

**Files:** src/simulation_statistics.e (110 lines)
**Features Involved:**
- `make (a_mean, a_std_dev, a_min, a_max: REAL_64; a_ci_95_lower, a_ci_95_upper, a_ci_99_lower, a_ci_99_upper: REAL_64; a_sample_size: INTEGER)` - Create immutable statistics
- `mean: REAL_64` - Return mean
- `std_dev: REAL_64` - Return standard deviation
- `min: REAL_64` - Return minimum value
- `max: REAL_64` - Return maximum value
- `ci_95: TUPLE [REAL_64, REAL_64]` - Return 95% confidence interval
- `ci_99: TUPLE [REAL_64, REAL_64]` - Return 99% confidence interval
- `sample_size: INTEGER` - Return sample size
- `confidence_interval (a_level: REAL_64): TUPLE [REAL_64, REAL_64]` - Return CI at specified level

### Acceptance Criteria

- [ ] `make` stores all 9 parameters; postconditions `mean_set`, `std_dev_set`, `ci_95_set`, `ci_99_set` verified
- [ ] `make` validates preconditions: `valid_std_dev: a_std_dev >= 0.0`
- [ ] `make` validates preconditions: `ci_95_ordered: a_ci_95_lower <= a_ci_95_upper`
- [ ] `make` validates preconditions: `ci_99_ordered: a_ci_99_lower <= a_ci_99_upper`
- [ ] `make` validates preconditions: `positive_sample_size: a_sample_size > 0`
- [ ] `mean` returns stored value; postcondition `not_nan: not Result.is_nan` verified
- [ ] `std_dev` returns stored value; postcondition `non_negative: Result >= 0.0` verified
- [ ] `min` and `max` return stored values
- [ ] `ci_95` returns tuple [lower, upper]; postcondition `ordered: Result[1] <= Result[2]` verified
- [ ] `ci_99` returns tuple [lower, upper]; postcondition `ordered` verified
- [ ] `confidence_interval(0.95)` returns ci_95
- [ ] `confidence_interval(0.99)` returns ci_99
- [ ] `confidence_interval` rejects invalid levels via precondition `valid_level: a_level = 0.95 or a_level = 0.99`
- [ ] `sample_size` returns stored value; postcondition `positive: Result > 0` verified
- [ ] Invariant `ci_99_wider_than_95: (ci_99_upper - ci_99_lower) >= (ci_95_upper - ci_95_lower)` holds
- [ ] Class is immutable (no modification after creation)
- [ ] Unit test `test_statistics_immutability` passes
- [ ] Unit test `test_ci_ordering` passes
- [ ] Compiles clean with zero warnings

### Implementation Notes

- Immutable result object: all fields set in `make`, no commands to modify
- TUPLE creation: `create Result; Result := [lower, upper]`
- Confidence intervals computed elsewhere; SIMULATION_STATISTICS just stores and retrieves
- No external dependencies except ISE base

### Phase 2 Issues

None directly affecting SIMULATION_STATISTICS creation; compute_statistics in Task 4 will populate values.

### Dependencies

- Depends on: None (ISE base only)
- Completes before: Task 4 (MONTE_CARLO_EXPERIMENT creates SIMULATION_STATISTICS)

---

## Task 4: Implement MONTE_CARLO_EXPERIMENT Class - Part A: Core Infrastructure

**Files:** src/monte_carlo_experiment.e (220 lines)
**Features Involved (Part A):**
- `make (a_trial_count: INTEGER)` - Create experiment
- `set_seed (a_seed: INTEGER)` - Configure random seed
- `set_trial_logic (a_logic: FUNCTION [TUPLE, TRIAL_OUTCOME])` - Configure trial agent
- `run_simulation` - Execute all trials (core loop)
- `outcome_at (a_index: INTEGER): TRIAL_OUTCOME` - Access trial result
- `outcome_count: INTEGER` - Query result count

### Acceptance Criteria (Part A)

- [ ] `make` initializes trial_count, seed_value, outcomes collection; postconditions `trial_count_set`, `is_empty`, `not_yet_run` verified
- [ ] `make` creates outcomes collection with capacity a_trial_count (pre-allocate for performance)
- [ ] `set_seed` stores seed value; postcondition `seed_set` verified
- [ ] `set_seed` enforces precondition `seed_non_negative: a_seed >= 0`
- [ ] `set_seed` enforces precondition `not_yet_run: not has_run` (prevent changing seed after run)
- [ ] `set_trial_logic` stores agent; postcondition `logic_set` verified
- [ ] `set_trial_logic` enforces precondition `logic_not_void: a_logic /= Void`
- [ ] `set_trial_logic` enforces precondition `not_yet_run: not has_run`
- [ ] `run_simulation` clears outcomes via `outcomes.wipe_out` before execution
- [ ] `run_simulation` executes trial_count iterations (from 1 to trial_count)
- [ ] `run_simulation` invokes agent via `if attached trial_logic_agent as l_agent then l_outcome := l_agent.item([])` (void-safe pattern)
- [ ] `run_simulation` appends outcome to outcomes collection via `outcomes.extend(l_outcome)`
- [ ] `run_simulation` sets has_run to True after completion; postcondition `has_been_run: has_run` verified
- [ ] `run_simulation` enforces precondition `logic_defined: trial_logic_agent /= Void`
- [ ] `run_simulation` enforces precondition `not_already_run: not has_run`
- [ ] `run_simulation` postcondition `outcomes_collected: outcome_count = trial_count` verified (all trials collected)
- [ ] `outcome_at (a_index)` uses 1-based indexing; precondition `valid_index: 1 <= a_index <= trial_count` enforced
- [ ] `outcome_at (a_index)` returns `outcomes [a_index - 1]` to convert 1-based user input to 0-based internal list (Phase 2 Issue #4 fix)
- [ ] `outcome_at` postcondition `result_attached: Result /= Void` verified
- [ ] `outcome_count` returns outcomes.count; postcondition `bounded: Result <= trial_count` verified
- [ ] Class invariant `trial_count_positive: trial_count > 0` maintained
- [ ] Class invariant `outcomes_bounded: outcomes.count <= trial_count` maintained
- [ ] Class invariant `if_run_then_complete: has_run implies outcomes.count = trial_count` maintained
- [ ] Unit test `test_make_initializes_experiment` passes
- [ ] Unit test `test_set_seed_stores_value` passes
- [ ] Unit test `test_run_simulation_executes_trials` passes
- [ ] Compiles clean with zero warnings

### Implementation Notes

- **CRITICAL FIX - Phase 2 Issue #4**: Use `outcomes [a_index - 1]` in outcome_at to handle 1-based user indexing vs 0-based internal list
- Core loop: 1-based iteration with agent invocation and outcome collection
- Attached check pattern for void-safety: `if attached trial_logic_agent as l_agent`
- Pre-allocate outcomes with `create outcomes.make (a_trial_count)` for performance

### Phase 2 Issues Addressed

- **Issue #5 (High - Already Correct)**: Precondition `logic_defined: trial_logic_agent /= Void` and attached check pattern are correct. No changes needed.
- **Issue #4 (Low - Indexing)**: Fix with `outcomes [a_index - 1]` conversion (already noted above in Acceptance Criteria).

### Dependencies

- Depends on: Task 1 (MEASUREMENT), Task 2 (TRIAL_OUTCOME), Task 3 (SIMULATION_STATISTICS)
- Continues to: Task 5 (Part B - extract_all_measurements and compute_statistics)

---

## Task 5: Implement MONTE_CARLO_EXPERIMENT Class - Part B: Statistics Extraction & Computation

**Files:** src/monte_carlo_experiment.e (220 lines)
**Features Involved (Part B):**
- `extract_all_measurements: ARRAYED_LIST [REAL_64]` - Collect all measurements from outcomes
- `compute_statistics (a_measurements: ARRAYED_LIST [REAL_64]): SIMULATION_STATISTICS` - Calculate statistics
- `statistics: SIMULATION_STATISTICS` - Query method that uses Part B features
- `confidence_interval (a_level: REAL_64): TUPLE [REAL_64, REAL_64]` - Extract CI from statistics

### Acceptance Criteria (Part B)

- [ ] `extract_all_measurements` returns ARRAYED_LIST [REAL_64]; postcondition `result_attached` verified
- [ ] `extract_all_measurements` iterates outcomes via `across outcomes as oc loop ... end`
- [ ] `extract_all_measurements` extracts measurement from each outcome (flatten nested structure)
- [ ] **PHASE 2 ISSUE #2 (Medium)**: `extract_all_measurements` populates Result list (not leave empty as current placeholder)
- [ ] `extract_all_measurements` handles void/attached states with `if attached oc.item as l_outcome` guards
- [ ] `extract_all_measurements` enforces precondition `has_run: has_run` (outcomes must be populated)
- [ ] `extract_all_measurements` postcondition ensures `result_attached: Result /= Void`
- [ ] `compute_statistics (a_measurements)` accepts ARRAYED_LIST [REAL_64] and computes aggregates
- [ ] **PHASE 2 ISSUE #1 (High)**: `compute_statistics` implements mean calculation: `sum / count`
- [ ] `compute_statistics` implements std_dev via `sqrt(sum((x - mean)^2) / count)` using simple_math.sqrt
- [ ] `compute_statistics` computes min via iteration (or sort): `across a_measurements as m loop if m < min then min := m end end`
- [ ] `compute_statistics` computes max via iteration (or sort): `across a_measurements as m loop if m > max then max := m end end`
- [ ] `compute_statistics` computes CI_95 and CI_99 via statistical formulas (integrate simple_math for percentile calculations)
- [ ] `compute_statistics` creates SIMULATION_STATISTICS with all 9 parameters filled (not dummy zeros as placeholder)
- [ ] `compute_statistics` returns non-void Result; postcondition `result_attached` verified
- [ ] `compute_statistics` enforces precondition `measurements_attached: a_measurements /= Void`
- [ ] `compute_statistics` enforces precondition `measurements_not_empty: a_measurements.count > 0`
- [ ] `statistics` calls extract_all_measurements and compute_statistics; returns aggregated result
- [ ] `statistics` enforces precondition `has_run: has_run` (experiment must have executed)
- [ ] `statistics` enforces precondition `outcomes_available: outcome_count > 0`
- [ ] `statistics` postcondition `result_sample_size: Result.sample_size = trial_count` verified
- [ ] `confidence_interval (a_level)` calls statistics and retrieves CI at level; returns tuple
- [ ] `confidence_interval` enforces precondition `valid_level: a_level = 0.95 or a_level = 0.99`
- [ ] Unit test `test_statistics_computation` passes with known measurements
- [ ] Unit test `test_confidence_interval_access` passes
- [ ] Integration test `test_experiment_with_normal_distribution` passes (with simple_probability)
- [ ] Compiles clean with zero warnings

### Implementation Notes

- **Statistics Calculations**:
  - Mean = sum of measurements / count
  - Variance = sum((x - mean)^2) / count
  - Std Dev = sqrt(variance) - use simple_math.sqrt
  - Min/Max = iterate and compare (or sort)
  - CI_95, CI_99: Use z-score method or t-distribution (integrate simple_math for percentile inverse)

- **Flattening Measurements**: TRIAL_OUTCOME contains measurements; iterate outcomes and extract from each
- **simple_math Integration**: Require sqrt, percentile inverse for CI calculation
- **Performance**: Pre-allocate Result in extract_all_measurements (create Result.make(trial_count))

### Phase 2 Issues Addressed

- **Issue #1 (High)**: Implement actual mean, std_dev, min, max, CI calculations (not return dummy zeros)
- **Issue #2 (Medium)**: Populate Result list by iterating outcomes and extracting measurements (not leave empty)

### Dependencies

- Depends on: Task 4 Part A (Core infrastructure completed first)
- Requires: simple_math library (sqrt, percentile functions)
- Completes before: Phase 5 testing

---

## Task 6: Implement TRIAL_LOGIC_CALLABLE Class

**Files:** src/trial_logic_callable.e (35 lines)
**Features Involved:**
- `execute: TRIAL_OUTCOME` - Deferred feature documenting trial logic contract
- Helper features for contract validation (optional)

### Acceptance Criteria

- [ ] Class is deferred (defines contract but not implementation)
- [ ] `execute` feature signature matches user agent pattern (no args, returns TRIAL_OUTCOME)
- [ ] Documentation clearly explains expected behavior (side-effect free, returns outcome with measurements)
- [ ] This class serves as documentation only; actual trial logic is user-provided agents
- [ ] Unit test `test_trial_logic_interface` passes (type checking only)
- [ ] Compiles clean with zero warnings

### Implementation Notes

- Protocol/documentation class (deferred)
- Helps users understand what trial logic should do
- Actual trial logic: user provides agent at runtime via `set_trial_logic`

### Phase 2 Issues

None - this is a documentation class.

### Dependencies

- None (documentation only)

---

## Task 7: Run Full Compilation & Verify Contracts

**Files:** All src/*.e, simple_montecarlo.ecf
**Goal:** Ensure all implementations compile and pass contract verification

### Acceptance Criteria

- [ ] Compilation succeeds: `cd d:\prod\simple_montecarlo && /d/prod/ec.sh -batch -config simple_montecarlo.ecf -target simple_montecarlo -c_compile` shows "System Recompiled."
- [ ] Zero compilation warnings
- [ ] Void-safety verified (void_safety="all")
- [ ] SCOOP compatibility verified (attached checks, no separate violations)
- [ ] All preconditions syntactically correct
- [ ] All postconditions syntactically correct
- [ ] All invariants syntactically correct
- [ ] Evidence file created: `.eiffel-workflow/evidence/phase4-compile.txt`

### Implementation Notes

- Must compile from project directory (D:\prod\simple_montecarlo)
- EIFGENs folder created in current directory
- Run after all classes (Tasks 1-6) complete

### Dependencies

- Depends on: Tasks 1-6 (all classes implemented)

---

## Task 8: Skeletal Test Framework Setup

**Files:** test/test_app.e, test/lib_tests.e
**Goal:** Prepare test infrastructure for Phase 5 detailed test implementation

### Acceptance Criteria

- [ ] test/test_app.e compiles as test runner
- [ ] test/lib_tests.e compiles with 25+ test method stubs
- [ ] Test stubs include proper documentation of what will be tested
- [ ] Test methods organized by class:
  - [ ] MEASUREMENT tests (3): creation, conversion, NaN handling
  - [ ] TRIAL_OUTCOME tests (3): empty creation, add measurement, retrieve, duplicate rejection
  - [ ] SIMULATION_STATISTICS tests (3): creation, CI access, confidence_interval
  - [ ] MONTE_CARLO_EXPERIMENT tests (4): creation, seed, logic, execution
  - [ ] Integration tests (2): experiment + distributions, statistics + math
  - [ ] Statistical validation (5): CI coverage, distribution sampling, bootstrap
  - [ ] Performance tests (3): 1K, 100K, 1M trials
  - [ ] Accessibility tests (2): personas 1-2
- [ ] Test app compiles clean
- [ ] Evidence: test skeleton ready for Phase 5 implementation

### Implementation Notes

- Test stubs documented in lib_tests.e (25+ methods)
- Phase 5 will implement test bodies
- Current stubs provide placeholder structure

### Dependencies

- Depends on: Task 7 (compilation successful)

---

## Task Execution Order (Dependency Graph)

```
Task 1 (MEASUREMENT)
  └─→ Task 2 (TRIAL_OUTCOME)
      └─→ Task 4a (MONTE_CARLO Part A)
          └─→ Task 5 (MONTE_CARLO Part B)

Task 3 (SIMULATION_STATISTICS) [Parallel with above]
  └─→ Task 5 (uses SIMULATION_STATISTICS)

Task 6 (TRIAL_LOGIC_CALLABLE) [Independent, parallel]

All above → Task 7 (Compilation verification)
           → Task 8 (Test framework setup)
```

### Recommended Schedule

1. **Week 1-2**: Tasks 1, 2, 3 (Core data classes - low complexity)
2. **Week 2-3**: Task 4a (Core experiment loop - medium complexity)
3. **Week 3-4**: Task 5 (Statistics calculations - integrate simple_math, simple_probability)
4. **Parallel**: Task 6 (Documentation class - trivial)
5. **End of Week 4**: Task 7 (Compilation gate)
6. **Phase 5**: Task 8 + 55 test implementations

---

## Success Criteria (Phase 4)

- ✓ All 8 tasks complete
- ✓ All code compiles clean (zero warnings)
- ✓ All unit tests pass (Task 8 framework ready for Phase 5)
- ✓ Contracts matched exactly (no unauthorized changes)
- ✓ simple_* dependencies integrated (simple_math, simple_probability, simple_mml)

---

## Phase 2 Issues Mapping

| Issue | Task(s) | Status |
|-------|---------|--------|
| Issue #1: compute_statistics placeholder | Task 5 | ADDRESSED - implement actual calculations |
| Issue #2: extract_all_measurements incomplete | Task 5 | ADDRESSED - populate Result list |
| Issue #3: make validation redundant | Task 4a | DECISION - reject (precondition sufficient) |
| Issue #4: outcome_at indexing | Task 4a | ADDRESSED - fix with [a_index - 1] |
| Issue #5: run_simulation agent validation | Task 4a | VERIFIED - already correct |

---

**Generated:** 2026-01-27
**Status:** READY FOR PHASE 4 IMPLEMENTATION
**Evidence File:** .eiffel-workflow/evidence/phase3-tasks.txt

