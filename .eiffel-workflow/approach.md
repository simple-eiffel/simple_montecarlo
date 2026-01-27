# Implementation Approach: simple_montecarlo

**Phase:** Phase 4 (Implementation)
**Date:** 2026-01-27
**Status:** READY FOR REVIEW

---

## Overview

Implement feature bodies for 5 core classes + integration with simple_probability, simple_randomizer, simple_math, simple_mml.

---

## Implementation Strategy

### Phase 1 (Sequential Core - 2-3 weeks)

#### Class MEASUREMENT
- **Implementation:** Store real or integer internally; provide conversion methods
- **Complexity:** Trivial (wrapper around REAL_64 or INTEGER)
- **Dependencies:** None (ISE base only)

#### Class TRIAL_OUTCOME
- **Implementation:** ARRAYED_LIST [MEASUREMENT] with parallel ARRAYED_LIST [STRING] for names
- **Complexity:** Low (list management)
- **Dependencies:** ISE base, simple_mml (frame conditions on lists)
- **MML Integration:**
  - `measurements_model: MML_SEQUENCE [MEASUREMENT]`
  - Frame condition: measurements never shrink, only grow
  - Invariant: `measurements_model.count = measurement_names_model.count`

#### Class SIMULATION_STATISTICS
- **Implementation:** Immutable aggregation (all fields set in make, no modification)
- **Complexity:** Low (arithmetic/sorting for CI calculations)
- **Dependencies:** simple_math (for percentile calculations)
- **Computation:**
  - Mean: `sum(measurements) / count`
  - Std Dev: sqrt(sum((x - mean)^2) / count)
  - CI: Bootstrap or analytical (Normal theory for large N)

#### Class MONTE_CARLO_EXPERIMENT
- **Implementation:** Orchestrate trial execution, collect outcomes, aggregate
- **Complexity:** Medium (trial management + statistics aggregation)
- **Dependencies:** simple_probability (distributions), simple_randomizer (seeding), simple_math, simple_mml
- **Core Algorithm:**
  ```
  1. Initialize RNG with seed (via simple_randomizer)
  2. For trial = 1 to trial_count:
     a. Invoke user agent: trial_logic_agent.item([])
     b. Collect TRIAL_OUTCOME
     c. Store in outcomes collection (MML frame condition: count increases)
  3. Extract measurements from all outcomes
  4. Compute statistics via compute_statistics helper
  ```
- **MML Integration:**
  - `outcomes_model: MML_SEQUENCE [TRIAL_OUTCOME]`
  - Invariant: `outcomes_count = trial_count` (after run_simulation)
  - Postcondition: `outcomes_model.count = old outcomes_model.count + 1` (per trial)

---

## Dependency Integration

### simple_probability (Phase 1 DEPENDENCY)

**Key Classes Used:**
- `NORMAL_DISTRIBUTION`: Sample from Normal(μ, σ)
- `BETA_DISTRIBUTION`: Sample from Beta(α, β)
- `BINOMIAL_DISTRIBUTION`: Sample from Binomial(n, p)
- `EXPONENTIAL_DISTRIBUTION`: Sample from Exponential(λ)

**Integration Pattern:**
```eiffel
feature -- Distribution Sampling (Phase 1)
    sample_from_normal (a_mean, a_std_dev: REAL_64): REAL_64
        local
            l_dist: NORMAL_DISTRIBUTION
        do
            create l_dist.make (a_mean, a_std_dev, seed_value)
            Result := l_dist.sample
        ensure
            not_nan: not Result.is_nan
        end
```

**Tight Integration:**
- MONTE_CARLO_EXPERIMENT.set_trial_logic accepts agents that internally call sample_from_* methods
- Users can combine distribution sampling in their trial logic

### simple_randomizer (via simple_probability)

**Key Classes:**
- `RANDOMIZER`: Seeded RNG engine
- Accessed via simple_probability's seed control

**Integration:**
```eiffel
feature {NONE} -- Seeding
    initialize_rng
        local
            l_randomizer: RANDOMIZER
        do
            create l_randomizer.make_with_seed (seed_value)
            -- Pass to simple_probability's singleton or context
        end
```

### simple_math (Phase 1 DEPENDENCY)

**Key Functions:**
- `sqrt(x: REAL_64): REAL_64` for std_dev calculation
- `power(x: REAL_64; n: REAL_64): REAL_64` for percentile inverse

**Integration:**
```eiffel
feature {NONE} -- Statistics Computation
    compute_std_dev (a_measurements: ARRAYED_LIST [REAL_64]; a_mean: REAL_64): REAL_64
        local
            l_variance: REAL_64
        do
            -- Compute variance via sum of squared deviations
            l_variance := compute_variance (a_measurements, a_mean)
            Result := simple_math.sqrt (l_variance)
        ensure
            non_negative: Result >= 0.0
        end
```

### simple_mml (Phase 1 DEPENDENCY)

**Key Classes:**
- `MML_SEQUENCE [G]`: Model of ordered collection with frame conditions
- `MML_SET [G]`: Model of unordered collection

**Integration:**
```eiffel
feature {NONE} -- Model Queries (MML)
    outcomes_model: MML_SEQUENCE [TRIAL_OUTCOME]
        -- Frame condition: outcomes never shrink, only grow
        do
            create Result.make_from_array (outcomes.to_array)
        ensure
            count_consistent: Result.count = outcomes.count
            monotonic_growth: Result.count >= old outcomes.count
        end

    measurements_model: MML_SEQUENCE [MEASUREMENT]
        -- All measurements from all outcomes (flattened)
        local
            l_result: MML_SEQUENCE [MEASUREMENT]
            l_measurements: ARRAYED_LIST [MEASUREMENT]
        do
            create l_measurements.make (trial_count)
            across outcomes as o loop
                across o.measurements as m loop
                    l_measurements.extend (m)
                end
            end
            create Result.make_from_array (l_measurements.to_array)
        ensure
            non_empty: Result.count > 0
        end
```

---

## Testing Strategy (Phase 5)

### Unit Tests (30 tests)

**MEASUREMENT:**
- Creation: real, integer
- Conversion: real↔integer
- NaN handling

**TRIAL_OUTCOME:**
- Empty creation
- Add measurements
- Retrieve by name
- Duplicate name rejection
- Count consistency

**SIMULATION_STATISTICS:**
- Immutability (no modification after creation)
- CI ordering (95 ⊂ 99)
- Arithmetic correctness (mean, std_dev)

**MONTE_CARLO_EXPERIMENT:**
- Seed reproducibility
- Agent invocation
- Outcome aggregation
- Statistics computation

### Integration Tests (15 tests)

- Experiment + simple_probability distributions (Normal, Beta, Binomial, Exponential)
- Outcome collection + simple_mml frame conditions
- Statistics + simple_math calculations

### Statistical Validation Tests (5 tests)

- CI coverage: 95% of 95% CIs contain true parameter
- Distribution sampling: samples match theory (mean, std_dev)
- Bootstrap CI validation

### Performance Tests (3 tests)

- 1K trials: < 1 second
- 100K trials: < 5 seconds
- 1M trials: < 30 seconds

### Accessibility Tests (2 tests)

- Persona 1 (manufacturing): capacity planning example
- Persona 2 (automotive): FMEA failure rate example

---

## Implementation Order

1. **MEASUREMENT** (trivial, no dependencies)
2. **TRIAL_OUTCOME** (simple collection wrapper, depends on MEASUREMENT)
3. **SIMULATION_STATISTICS** (arithmetic, depends on simple_math)
4. **MONTE_CARLO_EXPERIMENT** (orchestration, depends on all above + simple_probability)
5. **Test Implementation** (Phase 5, depends on all classes)

---

## Potential Issues to Address

### MML Integration Complexity

**Challenge:** Frame conditions on outcome collection must be correct to guarantee correctness.

**Mitigation:**
- Use MML_SEQUENCE for all collection-based models
- Explicit frame conditions: `|=|` for unchanged collections
- Invariant: count consistency across parallel lists
- Unit tests verify model queries match implementation

### Seed Reproducibility Across Platforms

**Challenge:** RNG algorithms may differ between Windows/Linux due to floating-point rounding.

**Target:** Byte-identical sequence with same seed on same platform; statistically identical on different platforms.

**Mitigation:**
- Use simple_randomizer's standardized algorithm (not platform-specific)
- Test on Windows/Linux with known seed values
- Document platform-specific results in README

### Performance: 1M Trials in < 30 seconds

**Challenge:** 30 seconds / 1M trials = 30 microseconds per trial average.

**Mitigation:**
- Agent invocation is fast (Eiffel native); no interpretation overhead
- List extension optimized (pre-allocated size)
- Arithmetic computation vectorized if possible
- Benchmark early (Phase 5) and optimize if needed

### Non-Statistician Usability

**Challenge:** Error messages must be actionable for non-technical users.

**Mitigation:**
- Plain English error messages (not jargon)
- Suggest fixes: "trial_count must be positive; 0 or negative not allowed"
- Documentation glossary bridges business ↔ probability terms
- Examples show copy-paste patterns

---

## Phase 1 → Phase 2 Transition

**What Phase 1 Completed:**
- ✓ Contracts (require/ensure/invariant) for all 5 classes
- ✓ Void-safe, SCOOP-compatible design
- ✓ Test skeleton (25+ test methods documented)

**What Phase 2 Validates:**
- Contracts are correctly specified (no gaps or redundancy)
- Implementation approach is feasible within 3-4 weeks
- MML integration adds minimal complexity
- Dependencies are well-understood

**What Phase 4 Implements:**
- Feature bodies matching contracts exactly
- Integration with simple_probability, simple_randomizer, simple_math, simple_mml
- Full test suite implementation
- Documentation and examples

---

## Success Criteria

1. ✓ Contracts compile void-safe and SCOOP-compatible (Phase 1 DONE)
2. → Contracts pass adversarial review (Phase 2 IN PROGRESS)
3. → Implementation matches contracts exactly (Phase 4)
4. → All 55 tests pass (Phase 5)
5. → 90%+ code coverage (Phase 5)
6. → 1M trials < 30 seconds (Phase 5)
7. → Non-math user can run example solo (Phase 5)

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|----------|--------|-----------|
| MML integration too complex | LOW | MEDIUM | Simple frame conditions; design upfront |
| RNG seed reproducibility issues | LOW | MEDIUM | Use simple_randomizer; test early |
| Performance insufficient for 1M trials | LOW | MEDIUM | Profile Phase 5; optimize hot paths |
| simple_probability API mismatch | MEDIUM | HIGH | Clarify API during Phase 4; adapt if needed |
| Test implementation takes too long | MEDIUM | MEDIUM | Parallel test development Phase 5 |

**All risks are mitigatable; no blockers.**

---

## Timeline Estimate

- Phase 2 Review: 1-2 days (human effort)
- Phase 3 Tasks: 1 day (break contracts into tasks)
- Phase 4 Implementation: 3-4 weeks
- Phase 5 Verification: 2-3 weeks

**Total Phase 1 MVP:** 6-8 weeks

**Phase 1.5 (Convergence diagnostics):** +1 week (if demand high)

**Phase 2 (Bayesian + parallel):** +4-6 weeks

---

## References

- **Contracts:** `src/*.e` files (all 5 classes with full require/ensure/invariant)
- **Dependencies:** intent-v2.md (section: Dependencies)
- **Test Plan:** intent-v2.md (section: Testing)
- **Success Criteria:** intent-v2.md (section: Success Criteria)
