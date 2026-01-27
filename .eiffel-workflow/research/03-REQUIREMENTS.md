# REQUIREMENTS: simple_montecarlo

## Functional Requirements (Phase 1 MVP)

| ID | Requirement | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| **FR-001** | Create Monte Carlo experiment | **MUST** | `create {MONTE_CARLO_EXPERIMENT}.make(trial_count := 10000)` → experiment ready |
| **FR-002** | Define trial logic (what to sample/measure) | **MUST** | `experiment.set_trial_logic(agent: TRIAL_LOGIC)` → each trial executes logic |
| **FR-003** | Run all trials and collect outcomes | **MUST** | `experiment.run_simulation()` → all 10K trials executed; outcomes stored |
| **FR-004** | Aggregate outcomes (mean, std, CI) | **MUST** | `experiment.statistics()` returns SIMULATION_STATISTICS with mean, std_dev, ci_95, ci_99 |
| **FR-005** | Extract confidence interval | **MUST** | `experiment.confidence_interval(0.95)` returns [lower, upper] bounds |
| **FR-006** | Access individual trial outcomes | **SHOULD** | `experiment.outcome_at(trial_index)` returns TRIAL_OUTCOME |
| **FR-007** | Reproducible sampling via seed | **MUST** | `experiment.set_seed(42)` → repeated runs produce identical outcomes |
| **FR-008** | Sample from any distribution | **MUST** | Integrate with simple_probability (Normal, Beta, Binomial, Exponential) |
| **FR-009** | Custom distribution support | **SHOULD** | User can define likelihood function via agent |
| **FR-010** | Semantic experiment naming | **MUST** | API uses: Experiment, Trial, Outcome, Measurement (no math notation) |
| **FR-011** | Industrial example 1: Process capacity** | **SHOULD** | Document: simulate production line with demand/equipment variance |
| **FR-012** | Industrial example 2: Failure rate analysis** | **SHOULD** | Document: Monte Carlo FMEA (failure rate estimation) |
| **FR-013** | Industrial example 3: Sensor uncertainty** | **SHOULD** | Document: propagate measurement noise through system |
| **FR-014** | Parameter inference (estimate distribution from samples)** | **SHOULD** | `NORMAL_DISTRIBUTION.estimate_from_trials(outcomes)` → fit distribution |
| **FR-015** | Convergence diagnostic (basic)** | **SHOULD** | Alert if sample size too small (heuristic: n < 1000 for CI) |
| **FR-016** | Batch trial execution (parallel ready)** | **COULD** | Architecture supports independent trials (Phase 2: SCOOP parallelization) |

---

## Non-Functional Requirements

| ID | Requirement | Category | Measure | Target |
|----|-----------|----------|---------|--------|
| **NFR-001** | Simulation accuracy | CORRECTNESS | Sample mean vs theory | Error < 1% for 10K samples |
| **NFR-002** | Confidence interval correctness | CORRECTNESS | CI contains true value | 95% of CI_95 contain true parameter |
| **NFR-003** | Type safety | SAFETY | Compile errors prevent mistakes | Cannot mix probability with measurement |
| **NFR-004** | Void safety | SAFETY | Zero null pointer errors | All instances attached; no Void unless explicit |
| **NFR-005** | SCOOP concurrency | CONCURRENCY | Data races | Zero when trials run in separate agents |
| **NFR-006** | Performance: run 1M trials | PERFORMANCE | Time to completion | < 30 seconds (CPU-bound) |
| **NFR-007** | Performance: single trial | PERFORMANCE | Latency per trial | < 100μs (mean + aggregation) |
| **NFR-008** | Memory: trial outcomes | EFFICIENCY | Memory per trial | < 100 bytes (outcome + measurement) |
| **NFR-009** | Documentation quality | DOCUMENTATION | Completeness | Every feature documented + 3 industrial examples |
| **NFR-010** | Non-math accessibility | USABILITY | Conceptual clarity | Non-statistician can run experiment without theory background |
| **NFR-011** | Test coverage | QUALITY | Line coverage | ≥ 90% |
| **NFR-012** | Build time | BUILD | Compile time | < 30s full rebuild |

---

## Semantic Accessibility Requirements

These address non-math developers' specific pain points and mental models.

| ID | Pain Point | Requirement | Verification |
|----|-----------|-----------|---|
| **PA-001** | "What is Monte Carlo?" | Explain via analogy (simulated sampling, experimentation) not theory | Documentation: non-math intro section |
| **PA-002** | "How many samples?" | Provide heuristic guidance (10K-1M depending on use case; show convergence) | Example shows "I ran 10K, checked CI width, still too wide, ran 100K" |
| **PA-003** | "How confident am I?" | Confidence intervals explained in plain language (95% = "95 out of 100 times, true value is in this range") | Documentation includes CI interpretation |
| **PA-004** | "What should I measure?" | TRIAL_OUTCOME clearly structured (what to put in; what to extract) | Example: "I recorded whether design succeeded, counted successes, got 92% confidence" |
| **PA-005** | "Is my estimate stable?" | Convergence heuristic: "If CI width stops changing with more samples, you're done" | Example code shows checking CI at 10K, 50K, 100K samples |
| **PA-006** | "How to interpret results?" | Translate statistical output to business language | Example: "99% confidence failure rate is ≤ 0.001% means extremely safe" |
| **PA-007** | "Can I compare two strategies?" | Two-sample comparison (run experiment for A, run for B, compare CIs) | Example: "Strategy A: 92% ± 2%, Strategy B: 89% ± 2%; B better if non-overlapping" |
| **PA-008** | "What if I have rare events?" | Warn about large sample requirements for rare events; suggest Phase 2 variance reduction | Documentation: "Rare events need 1M+ samples; variance reduction coming Phase 2" |

---

## Functional Requirements by Phase

### Phase 1 (MVP): Weeks 1-3

**MUST Deliver:**
1. MONTE_CARLO_EXPERIMENT class (create, configure, run)
2. TRIAL_LOGIC agent interface (what each trial does)
3. TRIAL_OUTCOME class (collected results)
4. SIMULATION_STATISTICS (mean, std, CI extraction)
5. Semantic API (Experiment, Trial, Outcome names; no Greek letters)
6. Integration with simple_probability distributions
7. Reproducible seeding
8. 50+ unit tests
9. Documentation: Non-math intro + 3 industrial examples

**SHOULD Deliver (if time):**
- Basic convergence check (sample size adequacy)
- TRIAL_OUTCOME aggregation helper
- Performance benchmarks

**Defers to Phase 2:**
- Convergence diagnostics (Gelman-Rubin R̂)
- Parallel SCOOP execution
- Variance reduction techniques
- Advanced output analysis

### Phase 1.5: Weeks 3-4 (Optional)

**COULD Add:**
- Gelman-Rubin R̂ statistic for multiple chains
- Burn-in handling for Bayesian sampling
- Sensitivity analysis helper

### Phase 2: Weeks 4-6

**SHOULD Add:**
- MCMC_SAMPLER (Metropolis-Hastings for Bayesian posteriors)
- Parallel trials via SCOOP
- Variance reduction (control variates, antithetic sampling)
- Integration with simple_probability posteriors

### Phase 3+: Future

**COULD Add:**
- Multi-level Monte Carlo
- Quasi-Monte Carlo
- Automated variance reduction
- Symbolic sensitivity analysis
- Integration with simple_ml (simulation-based training)

---

## Use Cases

### UC-001: Production Capacity Planning (Non-Math)

**Actor:** Manufacturing Process Engineer (no statistics training)

**Precondition:**
- Know production rate: 100 units/hour (nominal)
- Know variability: equipment downtime ±10%, demand varies ±15%
- Need: 99% confidence of meeting 1000-unit daily target

**Main Flow:**
1. Create experiment: `exp := create {MONTE_CARLO_EXPERIMENT}.make(trial_count := 100_000)`
2. Define trial: `exp.set_trial_logic(agent do ... simulate day ... return daily_output end)`
3. Run: `exp.run_simulation()`
4. Check results:
   - Mean output: 950 units
   - Confidence 99%: [920, 980]
   - Verdict: "Only 50-unit buffer for 1000-unit target; risky"

**Postcondition:**
- Business decision: increase capacity or reduce demand target

**Notes from Transcript:** "Uncertainty in real world is unavoidable." MC simulation makes it quantifiable.

---

### UC-002: Failure Rate Analysis (FMEA)

**Actor:** Automotive Safety Engineer

**Precondition:**
- System has 10 failure modes; know probability each
- Need: 99.99% confidence on system failure rate
- Standards: ASIL D requires < 1 failure per 10^8 hours

**Main Flow:**
1. Define trial: simulate system operation 1,000 hours; record failures
2. Run 1,000,000 trials (requires 10M simulated hours)
3. Extract CI:
   - Estimated failure rate: 1 per 10^7 hours
   - 99% CI: [0.5, 1.5] per 10^7 hours
4. Report: "System meets ASIL D with margin"

**Postcondition:**
- Safety certification supported by rigorous MC analysis

---

### UC-003: Bayesian A/B Testing (Phase 2)

**Actor:** QA Engineer testing feature impact

**Precondition:**
- Control: 920/1000 users successful (92% rate)
- Treatment: 940/1000 users successful (94% rate)
- Question: "Is treatment better with high confidence?"

**Main Flow (Phase 2: Integration with simple_probability):**
1. Create priors: Beta(1,1) for both (uninformed)
2. Update from data: Beta(920,80) for control, Beta(940,60) for treatment
3. Monte Carlo: sample 100K from both posteriors
4. Compare: treatment > control in 94% of samples
5. Verdict: "94% confidence treatment is better"

**Postcondition:**
- Data-driven decision with Bayesian confidence

---

## Constraints & Limits

### Hard Constraints

| Constraint | Reason | Impact |
|-----------|--------|--------|
| **SCOOP-compatible** | Eiffel ecosystem standard | Trials have local state; no global RNG |
| **Void-safe** | Type safety; prevent null errors | All outcomes attached (never Void) |
| **Design by Contract** | Eiffel philosophy | Every feature has require/ensure/invariant |
| **Integrate simple_probability** | Leverage existing distributions | Simple_montecarlo depends on simple_probability |
| **No external C** | Eiffel ecosystem pattern | Pure Eiffel; inline C only if needed Phase 2 |
| **Semantic types** | Type safety advantage over Python | TRIAL_OUTCOME type ≠ MEASUREMENT type |

### Soft Constraints

| Constraint | Phase | Justification |
|-----------|-------|---|
| **100K max trials per experiment Phase 1** | Phase 1 | Simplifies results storage; Phase 2 adds streaming |
| **Single RNG seed per experiment** | Phase 1 | Simpler; Phase 2 adds per-trial seeds |
| **No automatic visualisation** | Phase 1 | Integrate simple_chart Phase 2 |

---

## Acceptance Criteria: Phase 1 Complete

**Definition of "MVP shipped":**

- [ ] MONTE_CARLO_EXPERIMENT works end-to-end
- [ ] 50+ unit tests pass
- [ ] SIMULATION_STATISTICS returns correct mean/std/CI
- [ ] Confidence intervals validated (95% CI contains true value)
- [ ] Reproducibility: same seed → same outcomes
- [ ] Integration with simple_probability tested (Normal, Beta, Binomial sample)
- [ ] 3 industrial examples documented with code
- [ ] Non-math introduction document complete
- [ ] Semantic API validated (no confusing math notation)
- [ ] Performance: 1M trials < 30 seconds
- [ ] Code coverage ≥ 90%
- [ ] Zero void safety violations
- [ ] SCOOP concurrency design reviewed (Phase 2 ready)
- [ ] Ready to ship v1.0.0

---

## Traceability Matrix

| Requirement | Implementation | Test | Documentation |
|----|---|---|---|
| FR-001 (Experiment creation) | MONTE_CARLO_EXPERIMENT.make | test_creation | README example |
| FR-002 (Trial logic) | set_trial_logic(agent) | test_agent_invocation | Semantic API guide |
| FR-003 (Run simulation) | run_simulation() | test_execution_10k | API docs |
| FR-004 (Aggregate stats) | statistics() | test_statistics_correctness | Non-math intro |
| FR-005 (CI extraction) | confidence_interval(0.95) | test_ci_accuracy | Tutorial |
| FR-007 (Seeding) | set_seed(INT) | test_reproducibility | Example code |
| FR-008 (Integration) | Use DISTRIBUTION from simple_probability | test_distribution_sampling | Tutorial |
| FR-010 (Semantic API) | Class naming (not Greek) | test_api_readability | Glossary |
| PA-001 ("What is MC?") | Non-math intro section | User feedback | Documentation |
| PA-002 ("How many samples?") | Heuristic + example | Persona testing | Tutorial |

---

## Requirements Summary

**Phase 1 MVP is tightly scoped:**
- General Monte Carlo experiment framework
- Integration with simple_probability distributions
- Semantic API for non-math developers
- ~1,500 LOC
- 3-4 weeks development
- 90%+ test coverage
- Ready for production use

**Phase 2 extends with:**
- Convergence diagnostics
- Parallel sampling via SCOOP
- Variance reduction techniques
- Integration with Bayesian posteriors

**Eiffel Advantage:**
- Type-safe probability
- SCOOP native concurrency
- Production reliability
- Semantic API (vs cryptic notation)

