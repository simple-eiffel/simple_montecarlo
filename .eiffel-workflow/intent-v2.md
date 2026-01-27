# Intent (Refined): simple_montecarlo

**Status:** REFINED after AI review and stakeholder Q&A
**Date:** 2026-01-27
**Based on:** Phase 0 initial intent + AI probing questions + stakeholder answers

---

## Executive Summary

**simple_montecarlo** is a production-ready Monte Carlo simulation framework for Eiffel that makes stochastic modeling accessible to non-statistician engineers through semantic API design and accessible documentation.

**Core Innovation:** Business-language API (Experiment, Trial, Outcome, Measurement) + tight integration with simple_probability + educational approach to Design by Contract for collections.

**Target Users:** Manufacturing engineers, automotive safety engineers, IoT developers with domain expertise but no probability training.

**Phase 1 Deliverable:** Sequential MVP with 50+ tests, semantic API, integration with simple_probability, full documentation with 3 industrial examples.

---

## What: Clarified API Design

### Semantic Naming Definitions (Formal)

Derived from non-statistician mental models and tied to actual user actions:

| Term | Definition | User Action | Example |
|------|-----------|-------------|---------|
| **Experiment** | Container orchestrating multiple independent trials; configured once, executed N times | "Run my simulation 100,000 times" | `exp := create {MONTE_CARLO_EXPERIMENT}.make(10_000)` |
| **Trial** | Single execution of the user-defined process; captures one outcome per trial | "Run my process once, record result" | `agent do ... business_logic ... end` |
| **Outcome** | Result container from a single trial; may contain multiple measurements or metadata | "What was the result of this run?" | `trial_result: TRIAL_OUTCOME` with measurements array |
| **Measurement** | Type-safe numeric value from outcome; explicitly NOT a probability | "What value did I observe in this run?" | `height: MEASUREMENT` (cannot be confused with probability) |
| **Confidence Interval** | Range estimate for true parameter; plainly: "I'm 95% confident the true value is in [L, U]" | "What's my uncertainty bound?" | `exp.confidence_interval(0.95) → [lower, upper]` |

### Code Example Demonstrating Definitions

```eiffel
-- Manufacturing: "What's 99% confidence on daily production goal?"

exp := create {MONTE_CARLO_EXPERIMENT}.make(trial_count := 100_000)
exp.set_seed(42)

-- Define trial: simulate one day
exp.set_trial_logic(agent do
    daily_output := simulate_day_production(
        rate := 100,               -- units/hour
        variance := 0.1,           -- ±10%
        demand_variance := 0.15    -- ±15%
    )
    create outcome.make
    outcome.add_measurement("daily_units_produced", daily_output)
    Result := outcome
end)

-- Run all trials
exp.run_simulation()

-- Extract confidence bounds
stats := exp.statistics()
ci_99 := exp.confidence_interval(0.99)  -- [L, U] pair

-- Interpret plainly: "99% confident true daily output is between L and U units"
```

**Why this works for non-statisticians:**
- No Greek letters, no "μ", no "σ"
- Experiment/Trial/Outcome match how users think about running processes
- Measurement type prevents confusion: you can't accidentally treat probability as data value
- Confidence interval is plainly explained in interpretation section

---

## Why: Market Gap + Eiffel Advantage

### Market Validation

- Python PyMC: 50k+ GitHub stars, 18M+ downloads/month
- Julia Turing.jl, R Stan, Excel Crystal Ball: ubiquitous in industry
- **Eiffel gap:** Zero libraries; developers context-switch to Python (losing type safety)
- **Opportunity:** Type-safe, SCOOP-concurrent Monte Carlo in production systems

### Eiffel Competitive Advantages

| Capability | Eiffel | Python | Julia |
|-----------|--------|--------|-------|
| **Type-safe measurement** | `MEASUREMENT ≠ PROBABILITY` enforced at compile-time | Runtime only | Compile-time (but no semantic separation) |
| **SCOOP parallelism** | True parallelism; no GIL | Limited (GIL bottleneck) | Similar (no GIL) |
| **Void-safe** | Zero null-pointer exposure | NPE risk | Similar |
| **Semantic API** | Business naming unique to Eiffel | Notation-heavy (scipy, PyMC) | Notation-heavy (Turing) |
| **Contract-verified** | DBC + MML frame conditions | No formal verification | Limited verification |

---

## Users: Refined Personas with Concrete Workflows

### Persona 1: Manufacturing Process Engineer
- **Background:** High school math; understands variability, capacity, demand
- **NO background in:** Probability, statistics, simulation
- **Concrete task:** "I run 100 units/hour with ±10% variance; demand has ±15% variance. What's my 99% confidence I'll hit 1000-unit daily target?"
- **Success criteria:** Writes experiment in <15 minutes; understands output confidence interval without probability training
- **Skill level:** Basic Eiffel (loops, procedures, variables)

### Persona 2: Automotive Safety Engineer
- **Background:** FMEA expertise, reliability engineering, ISO 26262
- **NO background in:** Bayesian inference, MCMC, advanced statistics
- **Concrete task:** "System has 10 failure modes. I need 99.99% confidence that failure rate < 1 per 10^8 hours to meet ASIL D. Can I prove it?"
- **Success criteria:** Runs 1M-trial simulation; extracts CI; includes in safety certification report
- **Skill level:** Intermediate Eiffel (agents, design by contract)

### Persona 3: IoT/Sensor Systems Developer
- **Background:** Embedded systems, signal processing, uncertainty in measurements
- **NO background in:** Stochastic modeling, propagation of uncertainty formally
- **Concrete task:** "Sensor noise is ±0.5%. What's the impact on my final control output after 10 sensor reads?"
- **Success criteria:** Runs 10K trials; sees confidence bounds on output; integrates into production system
- **Skill level:** Intermediate-advanced Eiffel

---

## Acceptance Criteria: Clarified & Testable

### Semantic API Clarity
- [ ] Experiment, Trial, Outcome, Measurement have formal definitions (PASSED: above)
- [ ] Code examples show all 4 terms in realistic workflow (PASSED: manufacturing example)
- [ ] Glossary maps business terms ↔ probability/statistics terms (TO DO: Phase 1 docs)
- [ ] Non-programmer validates: "I understand what Experiment/Trial/Outcome/Measurement mean" (TO DO: user testing)

### Testing Strategy: Detailed Test Cases
- [ ] **Functional tests** for each method (50+ tests covering all features)
  - MONTE_CARLO_EXPERIMENT.make, set_seed, set_trial_logic, run_simulation, statistics, confidence_interval
  - TRIAL_OUTCOME creation, measurement addition, retrieval
  - SIMULATION_STATISTICS aggregation (mean, std_dev, ci_95, ci_99)
- [ ] **Edge case tests:**
  - trial_count = 1, 10, 10K, 1M (scale testing)
  - seed = 0, 1, 2^31-1 (seed boundary conditions)
  - agent returning same value every trial (zero variance)
  - agent returning extreme outliers (tail behavior)
- [ ] **Integration tests** with simple_probability
  - Sample from Normal(0, 1); verify mean ≈ 0, std_dev ≈ 1
  - Sample from Beta, Binomial, Exponential; verify distribution properties
- [ ] **Performance tests:** 1M trials < 30 seconds on reference hardware

### Confidence Interval Correctness: Statistical Power Analysis
- [ ] Theory validation:
  - Run experiment with known distribution (Normal μ=100, σ=15)
  - Generate 10K samples; extract 95% CI
  - Mathematically prove: CI contains μ with ~95% probability
  - Repeat 100 times; verify that ≥95 of 100 CIs contain true μ
- [ ] Empirical validation:
  - Compare against PyMC/Stan on same test cases
  - Results must match within 1% error margin
- [ ] User validation:
  - Persona 1 feedback: "Are these bounds sensible for my capacity planning?"
  - Persona 2 feedback: "Do I believe this CI for safety certification?"

### User Workflow: Basic Programming Prerequisite
- [ ] Users must understand:
  - Eiffel syntax: class creation, method calls, basic control flow
  - Agents: `agent do ... end` syntax and invocation
  - NOT required: probability, statistics, math, simulation concepts
- [ ] Acceptance: Persona 1 (no probability background) can write and run experiment solo

### Reproducibility: Seed Determinism Across Platforms
- [ ] Same seed produces identical results:
  - Windows 11, EiffelStudio 25.02, 64-bit
  - Linux (Ubuntu 22.04), EiffelStudio 25.02, 64-bit
  - MacOS (if supported), EiffelStudio 25.02
  - Test with seeds: 0, 1, 42, 2^31-1, random seeds
- [ ] Test with distributions: Normal, Beta, Binomial, Exponential
- [ ] Test with trial counts: 100, 10K, 1M
- [ ] Test with distinct agent logic: constant, linear, stochastic
- [ ] Acceptance: byte-for-byte identical sequence on any supported platform

### Error Handling: Clear Preconditions
- [ ] Input validation (via preconditions):
  - `trial_count > 0` (error message: "trial_count must be positive")
  - `agent ≠ Void` (error message: "set_trial_logic before running simulation")
  - `seed ≥ 0` (error message: "seed must be non-negative")
- [ ] Runtime error recovery:
  - Out of memory → graceful failure with message "simulation too large for available memory"
  - Distribution sampling failure → clear message "distribution sampling failed: check parameters"
- [ ] Design by Contract:
  - Preconditions checked in debug mode
  - Postconditions verified for statistical results
  - Invariants on Experiment state (cannot run twice; must reset)
- [ ] Error messages for non-technical users:
  - Plain English, not developer-speak
  - Suggest fix: "increase seed to value < 2^31"

### Dependency Integration: Tight with simple_probability
- [ ] MONTE_CARLO_EXPERIMENT directly imports simple_probability
- [ ] Methods:
  - `sample_from_normal(μ: REAL_64, σ: REAL_64) → REAL_64`
  - `sample_from_beta(α: REAL_64, β: REAL_64) → REAL_64`
  - `sample_from_binomial(n: INTEGER, p: REAL_64) → INTEGER`
  - `sample_from_exponential(λ: REAL_64) → REAL_64`
- [ ] Tight integration:
  - postcondition on sample methods references simple_probability contracts
  - Experiment.statistics postcondition: uses simple_probability distribution theory
  - simple_probability version requirement: v1.0.0 or later (documented in ECF)
- [ ] Testing: unit tests simulate sampling from each distribution; validate mean/variance match theory

### MML Decision: Educational Framing for Collections
- [ ] Simple explanation in documentation:
  - "MML (Mathematical Modeling Language) is Eiffel's formal specification language"
  - "Frame condition: 'the collection of outcomes never shrinks, only grows'"
  - "Why this matters: ensures we don't lose trial results due to a bug"
- [ ] Real-world analogy:
  - "Imagine running 100,000 trials but forgetting to write down results from trials 50,000-75,000. MML prevents this."
- [ ] Phase 2 relevance:
  - "When we add parallel trials (Phase 2), MML ensures different agents can safely update the shared outcome collection"
- [ ] Model queries in Phase 1:
  - `outcomes_count: INTEGER` (number of outcomes recorded)
  - `outcomes_valid: BOOLEAN` (all outcomes have valid measurements)
  - invariant: `outcomes_count = trial_count` (after simulation completes)

### Documentation: Non-Math Introduction + 3 Industrial Examples
- [ ] **Non-math intro (3-5 pages):**
  - "What is Monte Carlo?" explained as experimentation, not theory
  - "When would you use it?" with relatable examples
  - "How does it work?" with plain-English algorithm walkthrough
  - No equations; maximum one visual (simple bar chart)

- [ ] **3 Industrial Examples:**
  1. **Production Capacity Planning** (Persona 1)
     - Code walkthrough: define trial, set variance, run simulation, extract CI
     - Interpretation: "99% confident output is 950-1050 units/day"
  2. **Failure Rate Analysis** (Persona 2)
     - Code walkthrough: simulate 10 failure modes, aggregate, get CI on system failure rate
     - Interpretation: "Certified ASIL D: <1 failure per 10^8 hours with 99% confidence"
  3. **Sensor Uncertainty Propagation** (Persona 3)
     - Code walkthrough: simulate sensor noise, 10 reads, final output
     - Interpretation: "Sensor noise leads to ±0.1 margin on final control value"

### Void-Safety & SCOOP Compatibility
- [ ] All classes void-safe: `void_safety=all` in ECF
- [ ] No detachable references to main data (TRIAL_OUTCOME, MEASUREMENT, SIMULATION_STATISTICS)
- [ ] Agent-based trial logic: `separate` trials ready for Phase 2 parallelism
- [ ] SCOOP-safe postconditions: no references to non-separate objects in concurrent context

---

## Phase 1 Deliverables: Refined Scope

### Core Implementation (5 Classes)

1. **MONTE_CARLO_EXPERIMENT**
   - Methods: make, set_seed, set_trial_logic, run_simulation, statistics, confidence_interval, outcome_at
   - Contracts: require trial_count > 0; ensure outcomes recorded = trial_count
   - MML: outcomes_model: MML_SEQUENCE [TRIAL_OUTCOME]

2. **TRIAL_OUTCOME**
   - Stores measurements from single trial
   - Methods: add_measurement, measurement_at, measurement_count
   - Immutable after creation (frozen for Phase 1)

3. **MEASUREMENT**
   - Type-safe numeric value (REAL_64 or INTEGER)
   - Prevents accidental probability/measurement confusion
   - Cannot be compared directly to PROBABILITY type (Phase 2)

4. **SIMULATION_STATISTICS**
   - Aggregated results: mean, std_dev, min, max, ci_95, ci_99
   - Computed once via statistics() method
   - Immutable result object

5. **TRIAL_LOGIC** (Agent Signature)
   - `agent returning TRIAL_OUTCOME`
   - Called once per trial by framework
   - No framework restrictions on what trial logic does

### Testing: Detailed Plan

- **Unit tests** (30 tests): each class method, edge cases, contracts
- **Integration tests** (15 tests): Experiment + simple_probability sampling
- **Statistical validation tests** (5 tests): CI correctness, distribution sampling
- **Performance tests** (3 tests): 1K, 100K, 1M trial scaling
- **Accessibility tests** (2 tests): Personas 1 & 2 can write and understand output

**Total: 55 tests; 90%+ coverage of production code**

### Documentation

- API reference (all 5 classes, all methods)
- Non-math introduction to Monte Carlo (4 pages)
- 3 industrial use case tutorials (1-2 pages each) with full working code
- Glossary: 15 business ↔ probability/statistics term pairs
- Error codes and recovery guide for users

### Build Artifacts

- ECF configuration: `simple_montecarlo.ecf`
- F_code compiled binary
- GitHub repository with README, CHANGELOG, LICENSE
- Finalized production-ready release v1.0.0

---

## Dependencies (Final)

| Dependency | Type | Reason | Phase |
|------------|------|--------|-------|
| **simple_probability** | REQUIRED | Distribution sampling core to all experiments | Phase 1 |
| **simple_randomizer** | REQUIRED (via simple_probability) | RNG foundation for reproducible seeding | Phase 1 |
| **simple_math** | REQUIRED | exp/log/sqrt for statistical calculations | Phase 1 |
| **simple_mml** | REQUIRED | Frame conditions for outcome collection integrity | Phase 1 |
| **ISE base** | REQUIRED | Core types: STRING, ARRAY, HASH_TABLE, exceptions | Phase 1 |
| **simple_statistics** | OPTIONAL | Mean/std_dev helpers (might use simple_math instead) | Phase 1 |

---

## Success Criteria Summary

**Phase 1 is complete when:**

1. ✓ All 5 core classes compile void-safe and SCOOP-compatible
2. ✓ 55 tests pass; 90%+ code coverage
3. ✓ Persona 1 runs manufacturing example without probability training
4. ✓ Confidence intervals validated against theory (95% of 95% CIs contain true parameter)
5. ✓ 1M trials execute in < 30 seconds
6. ✓ Same seed produces identical results on Windows/Linux
7. ✓ Documentation complete: non-math intro + 3 examples + glossary
8. ✓ simple_probability integration works seamlessly (can sample from Normal/Beta/Binomial/Exponential)
9. ✓ Error messages are clear and actionable for non-technical users
10. ✓ Production binaries finalized; GitHub repo ready for v1.0.0 release

---

## Next Steps

**Approved for Phase 1 Contracts specification.**

→ Run: `/eiffel.contracts d:\prod\simple_montecarlo`

This will generate:
- Class skeletons with require/ensure/invariant contracts
- Test class skeletons
- Ready for implementation in Phase 4

---

## Appendix: Answer Summary from AI Review

| Question | Stakeholder Answer |
|----------|-------------------|
| Q1: API Design Clarity | A) Define formal definitions in terms of user actions |
| Q2: Test Strategy | A) Specify detailed test cases for all features and edge cases |
| Q3: CI Validation | A) Use statistical power analysis under controlled conditions |
| Q4: User Prerequisites | A) Understand basic programming (Eiffel syntax, agents) |
| Q5: Reproducibility | A) Byte-identical results across Windows/Linux/MacOS |
| Q6: Error Handling | A) Focus on input validation via preconditions |
| Q7: simple_probability Integration | A) Tight integration with direct method calls |
| Q8: MML Rationale | A) Educational framing explaining frame conditions plainly |

**Evidence:** All answers incorporated into intent-v2.md above.
