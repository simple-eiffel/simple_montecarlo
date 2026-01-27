# PARSED REQUIREMENTS: simple_montecarlo

## Problem Summary

**Consolidated Problem:** Non-mathematically-trained software engineers and industrial developers in Eiffel lack accessible Monte Carlo simulation libraries. They need to quantify uncertainty and run stochastic experiments but cannot access the rich ecosystem available in Python (PyMC), Julia (Turing.jl), or R (stan). Current alternatives: learn deep math, context-switch to Python/R (losing type safety), or implement ad-hoc simulations (fragile, non-reusable).

**Solution:** simple_montecarlo provides semantic, accessible Monte Carlo simulation for Eiffel—designed for non-math developers using business/industrial mental models (Experiment, Trial, Outcome) instead of probabilistic notation.

---

## Scope

### In Scope (MUST) — Phase 1 MVP

**Core Monte Carlo Framework:**
- MONTE_CARLO_EXPERIMENT class (create, configure, run N trials)
- TRIAL_LOGIC agent interface (users define what each trial does)
- TRIAL_OUTCOME class (collect measurements per trial)
- SIMULATION_STATISTICS (aggregate: mean, std_dev, confidence intervals)
- Semantic API naming (Experiment, Trial, Outcome, Measurement)

**Integration:**
- Full integration with simple_probability distributions (Normal, Beta, Binomial, Exponential)
- Reproducible sampling via seed control
- Support for custom distributions via agent

**Key Features:**
- Confidence interval extraction (95%, 99%, arbitrary)
- In-memory outcome storage (up to ~1M trials)
- Type-safe probability (TRIAL_OUTCOME ≠ MEASUREMENT)
- SCOOP-compatible design (trials independent agents; Phase 2 execution)
- Design by Contract throughout

**Documentation:**
- Non-math introduction (no equations; plain English)
- 3 industrial use case examples (production planning, FMEA, A/B testing)
- Semantic/glossary mapping (business terms → probability concepts)

**Testing:**
- 50+ unit tests
- 90%+ code coverage
- Statistical validation (samples match theory)
- Performance benchmarks (1M trials < 30 seconds)

### In Scope (SHOULD) — Phase 1 if Time Permits

- Basic convergence heuristic ("When to stop sampling")
- Sample size calculator
- TRIAL_OUTCOME aggregation helpers
- Performance optimization

### In Scope (COULD) — Phase 1.5+

- Gelman-Rubin R̂ convergence statistic
- Multiple chain support
- Burn-in and thinning guidance
- Advanced results analysis

### Out of Scope — Phase 2+

- **MCMC inference** — Deferred (integrate with simple_probability posteriors Phase 2)
- **Variance reduction** — Phase 2 (antithetic, control variates, importance sampling)
- **Multivariate** — Phase 2+ (only univariate Phase 1)
- **Optimization under uncertainty** — Separate library
- **Machine learning integration** — separate simple_ml integration
- **Symbolic computation** — Never (not in Eiffel scope)

---

## Functional Requirements (Phase 1 MVP)

| ID | Requirement | Priority | Source | Acceptance Criteria |
|----|-----------|----------|--------|-----|
| **FR-001** | Create Monte Carlo experiment | MUST | 03-REQUIREMENTS | `create {MONTE_CARLO_EXPERIMENT}.make(trial_count := 10000)` → ready to configure |
| **FR-002** | Define trial logic via agent | MUST | 03-REQUIREMENTS | `exp.set_trial_logic(agent do ... end)` → agent stored; each trial invoked |
| **FR-003** | Run simulation (all trials) | MUST | 03-REQUIREMENTS | `exp.run_simulation()` → all trials executed; outcomes collected |
| **FR-004** | Aggregate statistics | MUST | 03-REQUIREMENTS | `exp.statistics()` returns SIMULATION_STATISTICS [mean, std_dev, ci_95, ci_99] |
| **FR-005** | Extract confidence interval | MUST | 03-REQUIREMENTS | `exp.confidence_interval(0.95)` returns [lower, upper] bounds |
| **FR-006** | Access individual outcomes | SHOULD | 03-REQUIREMENTS | `exp.outcome_at(index)` returns TRIAL_OUTCOME |
| **FR-007** | Reproducible seeding | MUST | 03-REQUIREMENTS | `exp.set_seed(42)` → repeated runs identical |
| **FR-008** | Sample from distributions | MUST | 03-REQUIREMENTS | Integrate simple_probability (Normal, Beta, Binomial, Exponential) |
| **FR-009** | Custom distribution agents | SHOULD | 03-REQUIREMENTS | User defines likelihood via agent; Monte Carlo samples |
| **FR-010** | Semantic naming | MUST | 04-DECISIONS (D-001) | API: Experiment, Trial, Outcome, Measurement (no math notation) |
| **FR-011** | Industrial example 1 | SHOULD | 03-REQUIREMENTS | Production capacity planning under uncertainty |
| **FR-012** | Industrial example 2 | SHOULD | 03-REQUIREMENTS | FMEA failure rate analysis |
| **FR-013** | Industrial example 3 | SHOULD | 03-REQUIREMENTS | Sensor noise uncertainty propagation |
| **FR-014** | Parameter inference | SHOULD | 03-REQUIREMENTS | Estimate distribution from trial outcomes |
| **FR-015** | Convergence check | SHOULD | 03-REQUIREMENTS | Heuristic: warn if n < 1000 for CIs |
| **FR-016** | Parallel-ready architecture | COULD | 03-REQUIREMENTS | Design supports trial parallelization (Phase 2 impl) |

---

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-----------|----------|---------|--------|
| **NFR-001** | Simulation accuracy | CORRECTNESS | Sample mean error vs theory | < 1% for 10K samples |
| **NFR-002** | CI correctness | CORRECTNESS | 95% CIs contain true parameter | Validated via bootstrap/theory |
| **NFR-003** | Type safety | SAFETY | Compile-time error prevention | Cannot mix TRIAL_OUTCOME with MEASUREMENT |
| **NFR-004** | Void safety | SAFETY | Null pointer errors | Zero (all instances attached) |
| **NFR-005** | SCOOP concurrency | CONCURRENCY | Data races | Zero when trials use separate agents |
| **NFR-006** | Performance (1M trials) | PERFORMANCE | Execution time | < 30 seconds |
| **NFR-007** | Performance (per trial) | PERFORMANCE | Latency per trial | < 100μs |
| **NFR-008** | Memory efficiency | EFFICIENCY | Bytes per outcome | < 100 bytes |
| **NFR-009** | Documentation | DOCUMENTATION | Completeness | Every feature + 3 examples |
| **NFR-010** | Non-math accessibility | USABILITY | Conceptual clarity | Non-statistician can use without math training |
| **NFR-011** | Test coverage | QUALITY | Line coverage | ≥ 90% |
| **NFR-012** | Build time | BUILD | Full rebuild | < 30 seconds |

---

## Semantic Accessibility Requirements

| ID | Pain Point | Requirement | Verification |
|----|-----------|-----------|---|
| **PA-001** | "What is MC?" | Explain via experimentation (not theory) | Non-math intro section in docs |
| **PA-002** | "How many samples?" | Heuristic guidance (10K-1M examples) | Example: check CI at 10K, 50K, 100K |
| **PA-003** | "How confident?" | CI explained plainly (95% = "true value in range 95 out of 100 times") | Documentation with interpretation |
| **PA-004** | "What to measure?" | TRIAL_OUTCOME structure guides usage | Example: "I recorded successes, got 92% ± 2% confidence" |
| **PA-005** | "Is estimate stable?" | Convergence heuristic (CI width stabilization) | Example code shows convergence checking |
| **PA-006** | "Interpret results?" | Business language translation | Example: "99% confidence failure ≤ 0.001% = safe" |
| **PA-007** | "Compare strategies?" | Two-sample comparison pattern | Example: A vs B with CI overlap check |
| **PA-008** | "Rare events?" | Warn about sample requirements | Documentation: "Rare events need 1M+; Phase 2 variance reduction" |

---

## Constraints (simple_* First)

| ID | Constraint | Type | Immutable |
|----|-----------|------|-----------|
| **C-001** | Use simple_probability for distributions | ECOSYSTEM | YES |
| **C-002** | Use simple_randomizer for RNG | ECOSYSTEM | YES |
| **C-003** | SCOOP-compatible | TECHNICAL | YES |
| **C-004** | Void-safe (void_safety=all) | TECHNICAL | YES |
| **C-005** | Design by Contract (require/ensure/invariant) | TECHNICAL | YES |
| **C-006** | No external C files | TECHNICAL | YES |
| **C-007** | Semantic types (no math notation in public API) | DESIGN | YES |

---

## Decisions Already Made (From Research Phase)

| ID | Decision | Rationale | Phase |
|----|----------|-----------|-------|
| **D-001** | Semantic API (Experiment vs Sampler) | Non-math developers mental model | Research |
| **D-002** | Full simple_probability dependency | Natural pairing; ecosystem principle | Research |
| **D-003** | Agent-based trial logic | Flexible; Eiffel-natural; lightweight | Research |
| **D-004** | In-memory Phase 1; streaming Phase 2 | Simple MVP; upgrade path clear | Research |
| **D-005** | Heuristic convergence Phase 1; diagnostic Phase 2 | Non-math users won't understand R̂ | Research |
| **D-006** | Semantic types (TRIAL_OUTCOME ≠ MEASUREMENT) | Type safety advantage | Research |
| **D-007** | Sequential Phase 1; parallel Phase 2 | Reduces complexity; trivial to add later | Research |
| **D-008** | Examples-first documentation | Engage non-math audience | Research |
| **D-009** | DBC + Exceptions hybrid | Eiffel + pragmatism | Research |
| **D-010** | Staged MVP (Phase 1 → 1.5 → 2) | Reduces risk; clear gates | Research |

---

## Innovations to Implement

| ID | Innovation | Design Impact | Phase |
|----|-----------|---------------|-------|
| **I-001** | Semantic accessibility API | Non-math naming (Experiment/Trial/Outcome) unique to Eiffel | Phase 1 |
| **I-002** | Semantic types for safety | Type system prevents probability/measurement confusion | Phase 1 |
| **I-003** | SCOOP-native parallelism | True concurrency (no GIL); parallel MC chains | Phase 2 |
| **I-004** | Industrial example focus | Real-world use cases (production, FMEA, IoT) | Phase 1 docs |
| **I-005** | Agent-based flexibility | Users define trial logic concisely | Phase 1 |
| **I-006** | Integration with simple_probability | Seamless distribution + experiment pairing | Phase 1 |
| **I-007** | Production reliability | Type-safe, void-safe, contract-verified | Phase 1 |

---

## Risks to Address in Design

| ID | Risk | Mitigation Strategy | Priority |
|----|------|---------------------|----------|
| **RISK-001** | Semantic API confuses experts | Document statistical equivalents Phase 2; add aliases | MEDIUM |
| **RISK-002** | Non-math docs miss audience | User testing Phase 0.5; gather feedback | MEDIUM |
| **RISK-003** | Performance insufficient >1M trials | Optimize Phase 1.5; streaming Phase 2 | LOW |
| **RISK-004** | Parallelism complexity (Phase 2) | Design upfront Phase 1; simple execution model | LOW |
| **RISK-005** | Eiffel adoption too low | Market positioning Phase 0; targeted outreach | MEDIUM |

---

## Use Cases (From Research)

### UC-001: Production Capacity Planning

**Actor:** Manufacturing Process Engineer (no statistics training)

**Precondition:**
- Know production rate (100 units/hour) and variability (±10%)
- Know demand variability (±15%)
- Need: 99% confidence of meeting 1000-unit daily target

**Main Flow:**
1. `exp := create {MONTE_CARLO_EXPERIMENT}.make(trial_count := 100_000)`
2. `exp.set_trial_logic(agent do ... simulate_day_production(variance) ... end)`
3. `exp.run_simulation()`
4. `stats := exp.statistics(); ci := exp.confidence_interval(0.99)`
5. Result: "Only 50-unit buffer; risky" → Business decision: increase capacity

**Postcondition:**
- Confidence interval informs capacity planning decision

---

### UC-002: FMEA Failure Rate Analysis

**Actor:** Automotive Safety Engineer

**Precondition:**
- System has 10 failure modes; probabilities known
- Need: 99.99% confidence on system failure rate
- Standards: ASIL D requires < 1 failure per 10^8 hours

**Main Flow:**
1. Define trial: simulate 1,000 hours; record failures
2. Run 1,000,000 trials
3. Extract CI: Estimated rate 1 per 10^7; 99% CI [0.5, 1.5] per 10^7
4. Report: "System meets ASIL D"

**Postcondition:**
- Safety certification supported by rigorous MC analysis

---

### UC-003: Bayesian A/B Testing (Phase 2)

**Actor:** QA Engineer

**Precondition:**
- Control: 920/1000 users successful (92%)
- Treatment: 940/1000 users successful (94%)
- Question: "Is treatment better?"

**Main Flow (Phase 2):**
1. Prior: Beta(1,1) for both
2. Update from data: Beta(920,80) and Beta(940,60)
3. MC sample 100K from both posteriors
4. Compare: treatment > control in 94% of samples
5. Verdict: "94% confidence treatment is better"

**Postcondition:**
- Data-driven decision with Bayesian confidence

---

## Requirements Traceability (Phase 1)

| Requirement | Design Element | Test Strategy | Documentation |
|----|---|---|---|
| FR-001 (Create experiment) | MONTE_CARLO_EXPERIMENT.make | test_creation | API reference |
| FR-002 (Trial logic) | set_trial_logic(agent) | test_agent_invocation | Semantic guide |
| FR-003 (Run simulation) | run_simulation() | test_full_execution | Tutorial |
| FR-004 (Statistics) | statistics() | test_stats_accuracy | Non-math intro |
| FR-005 (CI) | confidence_interval(p) | test_ci_coverage | Example code |
| FR-007 (Seeding) | set_seed(n) | test_reproducibility | Example |
| FR-008 (Distributions) | Integration with simple_probability | test_distribution_sampling | Tutorial |
| FR-010 (Semantic) | Class naming (no Greek) | test_api_readability | Glossary |
| NFR-001 (Accuracy) | Algorithms tested | test_vs_theory | Benchmark report |
| PA-001 (What is MC) | Non-math intro | User feedback | Documentation intro |

---

## Phase 1 MVP Scope

**Clear deliverables:**
- MONTE_CARLO_EXPERIMENT framework
- TRIAL_LOGIC agent interface
- TRIAL_OUTCOME data class
- SIMULATION_STATISTICS aggregator
- Integration with simple_probability
- Semantic API (no math notation)
- 50+ unit tests, 90%+ coverage
- Non-math documentation + 3 examples

**Estimated LOC:** 1,500
**Timeline:** 3-4 weeks
**Ready for implementation:** YES

