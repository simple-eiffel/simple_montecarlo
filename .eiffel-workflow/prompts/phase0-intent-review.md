# Intent Review Request

**Project:** simple_montecarlo (Eiffel Monte Carlo simulation framework)

**Instructions:** Review the intent document below and generate 7-10 probing questions to clarify vague language, identify missing requirements, and surface implicit assumptions.

## Review Criteria

Look for:
1. **Vague language:** Words like "accessible", "intuitive", "simple", "reasonable" without concrete definitions
2. **Missing edge cases:** What happens with empty outcomes? Division by zero? Extreme sample sizes?
3. **Untestable criteria:** Are acceptance criteria measurable and specific?
4. **Hidden dependencies:** What external systems/libraries are assumed?
5. **Scope ambiguity:** Is "out of scope" clearly defined and justified?
6. **API design gaps:** What methods are missing? What happens in error cases?
7. **User mental model gaps:** Do Personas 1-3 have realistic workflows?

## Output Format

Provide 7-10 probing questions. For each:
- **Quote** the phrase from intent.md that triggered the question
- **Why vague:** Explain the ambiguity
- **Options:** Offer 2-4 concrete alternatives the user can choose from
- **Impact:** How this affects implementation or testing

---

## Intent Document to Review

# Intent: simple_montecarlo

## What

**simple_montecarlo** is an accessible Monte Carlo simulation framework for Eiffel that enables non-mathematically-trained engineers to quantify uncertainty and run stochastic experiments.

It provides:
- A semantic API using business concepts (Experiment, Trial, Outcome, Measurement) instead of probabilistic notation
- Integration with simple_probability distributions (Normal, Beta, Binomial, Exponential)
- Confidence interval extraction and statistical aggregation
- Reproducible seeding for deterministic results
- SCOOP-compatible, void-safe, contract-verified implementation

**Phase 1 MVP:** Sequential single-trial execution with full statistical support.

**Phase 2+:** Parallel SCOOP execution, Bayesian inference, variance reduction techniques.

## Why

**Market Gap:**
- Industrial developers need stochastic simulation daily (manufacturing, automotive, IoT, finance)
- Python (PyMC, 50k+ stars), Julia (Turing.jl), R (Stan) dominate this space
- Eiffel has zero libraries; developers context-switch to Python/R, losing type safety

**Eiffel Competitive Advantages:**
- **Type safety:** Compile-time error prevention (TRIAL_OUTCOME ≠ MEASUREMENT)
- **SCOOP concurrency:** True parallelism without GIL (Phase 2)
- **Void safety:** Zero null-pointer bugs
- **Production reliability:** Design by Contract throughout

**Non-Math Accessibility:**
- Research validated (MIT transcripts) that stochastic thinking is learnable
- Semantic API (Experiment vs Sampler) resonates with business mental models
- Examples-first documentation engages non-statisticians
- Glossary bridges business language ↔ probability concepts

## Users

### Persona 1: Manufacturing Process Engineer
- **Background:** No statistics training; understands variability and targets
- **Need:** "What's my 99% confidence on meeting daily production goal?"
- **Mental Model:** Simulate 100,000 days; extract confidence interval
- **Success:** Runs 3-method experiment in <15 minutes without probability training

### Persona 2: Automotive Safety Engineer
- **Background:** Reliability/FMEA expertise; needs rigorous failure rate analysis
- **Need:** "Prove system meets ASIL D (< 1 failure per 10^8 hours) with 99.99% confidence"
- **Mental Model:** Monte Carlo sampling validates formal safety claims
- **Success:** Runs 1M-trial simulation; extracts confidence bounds for certification

### Persona 3: IoT/Sensor Systems Developer
- **Background:** Embedded systems expertise; uncertain measurement propagation
- **Need:** "What's sensor noise impact on final control output?"
- **Mental Model:** Run 10K trials; get uncertainty quantification on derived metric
- **Success:** Integrates uncertainty estimation into production IoT pipeline

## Acceptance Criteria

- [ ] Non-statistician can write Monte Carlo experiment without probability training
- [ ] Semantic API naming (Experiment, Trial, Outcome) is intuitive and unambiguous
- [ ] Confidence intervals work correctly (95% of 95% CIs contain true parameter)
- [ ] Performance: 1M trials complete in < 30 seconds
- [ ] Integration with simple_probability seamless (sample from Normal, Beta, Binomial, Exponential)
- [ ] Reproducible seeding works (identical seed → identical results)
- [ ] 50+ unit tests; 90%+ code coverage
- [ ] Type safety enforced: compile-time error prevents probability/measurement confusion
- [ ] SCOOP-compatible design (no blocking; trials can execute as separate agents Phase 2)
- [ ] Documentation includes:
  - Non-math introduction (no equations; plain English)
  - 3 industrial use case examples (production planning, FMEA, sensor uncertainty)
  - Semantic/glossary mapping (business terms ↔ probability concepts)
  - Plain-English interpretation guide for confidence intervals
- [ ] Void-safe (all instances attached; zero null-pointer exposure)
- [ ] Design by Contract throughout (require/ensure/invariant on all features)

## Out of Scope

### Phase 1 — OUT
- **MCMC inference** — Deferred to Phase 2 (requires posterior integration)
- **Variance reduction** — Deferred to Phase 2 (antithetic, importance sampling, etc.)
- **Multivariate distributions** — Phase 1 univariate only
- **Streaming/online aggregation** — Phase 1 in-memory only
- **Parallel execution** — Phase 1 sequential; Phase 2 SCOOP parallelism
- **Advanced convergence diagnostics** — Phase 1 heuristic only (n > 1000 warning); Phase 1.5 Gelman-Rubin R̂
- **Graphical output** — Phase 1 statistical aggregation only; Phase 2 may integrate simple_chart
- **Machine learning integration** — Separate library scope
- **Symbolic computation** — Never (not in Eiffel)

### Technical Constraints (Immutable)
- No external C libraries; inline C only if necessary
- No dependencies outside simple_* ecosystem + ISE base
- All code void-safe (void_safety=all)
- All code SCOOP-compatible (concurrency=scoop in ECF)

## Dependencies (REQUIRED - simple_* First Policy)

| Need | Library | Justification | Phase |
|------|---------|---------------|-------|
| **Probability distributions** | simple_probability | Core Monte Carlo requirement; natural pairing | Phase 1 DEPENDENCY |
| **Random number generation** | simple_randomizer | Foundation for all sampling | Phase 1 DEPENDENCY |
| **Math utilities** | simple_math | exp/log/sqrt for statistical calculations | Phase 1 DEPENDENCY |
| **Statistics aggregation** | simple_statistics | Mean, std_dev, percentile calculations | Phase 1 OPTIONAL |

**ISE-only (no simple_* equivalent):**
- `base` — Fundamental types (STRING, INTEGER, REAL_64, ARRAY, LIST)
- `time` — DATE, TIME, DATE_TIME classes

## MML Decision (REQUIRED)

**Does this library need MML (Mathematical Modeling Language) model queries for precise postconditions?**

**Decision: YES - Required**

**Rationale:**
- Collections are core (ARRAY/LIST for outcomes; HASH_TABLE potentially for distribution cache)
- Frame conditions on outcome collections are essential for contract verification
- Users may audit statistical correctness via MML postconditions
- SCOOP parallelism (Phase 2) requires frame conditions on shared data

**MML Usage:**
- `outcomes_model: MML_SEQUENCE [TRIAL_OUTCOME]` — Frame conditions on outcome collection growth
- `measurements_valid: across outcomes_model as o all o.is_valid end` — Invariant validation
- Phase 1 will include model queries; simple_mml is explicit dependency

## Innovation & Differentiation

| Innovation | Unique to Eiffel | Phase | Impact |
|-----------|------------------|-------|--------|
| **Semantic accessibility API** | Non-math naming (Experiment/Trial/Outcome) | Phase 1 | Non-statisticians can use without training |
| **Type-safe measurement** | TRIAL_OUTCOME ≠ MEASUREMENT distinction | Phase 1 | Compile-time bug prevention |
| **SCOOP-native parallelism** | True concurrency; no GIL | Phase 2 | Scales to 1B+ trials |
| **Industrial example focus** | Real-world use cases (production, FMEA, IoT) | Phase 1 docs | Bridges academia-industry gap |
| **Contract-verified correctness** | Design by Contract + model queries | Phase 1 | Provably correct statistics |

## Risks & Mitigation

| Risk | Probability | Impact | Mitigation |
|------|----------|--------|-----------|
| **Semantic API confuses probability experts** | MEDIUM | LOW | Add statistical aliases Phase 2; document equivalence glossary |
| **Non-math docs underwhelm target audience** | LOW | MEDIUM | User testing Phase 0.5; gather feedback from Personas 1-3 |
| **Performance insufficient for 1M+ trials** | LOW | MEDIUM | Optimize Phase 1.5; streaming Phase 2 |
| **Parallelism complexity (Phase 2)** | MEDIUM | MEDIUM | Design upfront Phase 1; separate SCOOP trial executor Phase 2 |
| **Eiffel adoption too low** | MEDIUM | HIGH | Market positioning; target industrial niches first |

## Phase 1 Deliverables

**Core Implementation:**
- `MONTE_CARLO_EXPERIMENT` — Main orchestrator class
- `TRIAL_LOGIC` — Agent interface for user-defined trial logic
- `TRIAL_OUTCOME` — Result aggregation per trial
- `SIMULATION_STATISTICS` — Aggregated statistics (mean, std_dev, confidence intervals)
- `MEASUREMENT` — Type-safe value container (prevents probability/measurement confusion)
- Integration with simple_probability distributions

**Testing:**
- 50+ unit tests covering all features
- Statistical validation (samples match theory)
- Reproducibility tests (seeding)
- Performance benchmarks

**Documentation:**
- API reference (semantic naming emphasis)
- Non-math introduction to Monte Carlo (3-4 pages, no equations)
- 3 industrial use case tutorials
- Glossary: business terms ↔ probability/statistics concepts
- Example code with line-by-line commentary

---

## Review Questions (TO BE FILLED BY AI REVIEWER)

Please generate 7-10 probing questions addressing:
1. API design ambiguities
2. User workflow gaps
3. Testing strategy gaps
4. Acceptance criteria measurability
5. Dependency/integration gaps
6. Error handling strategy
7. Performance assumptions
8. Documentation scope

---

**Next Step:** Return this file with AI's probing questions, then user answers clarify all ambiguities before Phase 1 Contracts specification.
