# SCOPE: simple_montecarlo

## Problem Statement

**In one sentence:** Non-mathematically-trained software engineers and industrial developers lack a simple, accessible library for Monte Carlo simulation and stochastic reasoning in Eiffel—requiring them to either understand deep mathematical concepts or switch to Python/R for probabilistic computation.

### What's Wrong Today

**The Gap:**
- Industrial developers (IoT, systems, process optimization, reliability engineers) need to solve real problems involving uncertainty, randomness, and probabilistic reasoning
- These problems naturally map to Monte Carlo methods (simulation, sampling, uncertainty quantification)
- Monte Carlo is presented as "hard math" — notation-heavy, theorem-laden, intimidating to non-statisticians
- Eiffel has NO Monte Carlo library (simple_probability handles distributions; simple_montecarlo handles experiments/simulations)
- Developers either:
  1. Struggle to learn the math (wrong mental model; too much theory)
  2. Switch to Python/R (lose type safety, SCOOP concurrency, production stability)
  3. Implement ad-hoc simulations (fragile, non-reusable, error-prone)

### Who Experiences This

| User Type | Problem | Pain Level |
|-----------|---------|------------|
| **IoT/Sensor System Developer** | "How do I quantify uncertainty in noisy measurements?" | HIGH |
| **Reliability Engineer** | "What's the failure probability of this system over 10 years?" | HIGH |
| **Process Optimization Specialist** | "What's the best order-timing strategy under demand uncertainty?" | HIGH |
| **Automotive/Aviation Systems Engineer** | "What's the Monte Carlo failure rate of this control algorithm?" | HIGH |
| **Financial Systems Developer** | "How do I model portfolio risk with stochastic simulation?" | MEDIUM |
| **QA/Testing Engineer** | "How do I generate synthetic test scenarios with controlled randomness?" | MEDIUM |
| **Business Analyst (technical background)** | "Can I model 'what-if' scenarios under uncertainty?" | MEDIUM |

### Impact of Not Solving

- Developers resort to Python/R scripts (fragmentation, maintenance burden)
- Ad-hoc simulations lack rigor (correctness not validated, contracts ignored)
- Uncertainty not properly quantified (overconfidence in deterministic models)
- Eiffel loses developers to Python/R in problem domains that need stochastic reasoning
- Risk of embedded systems deploying without proper uncertainty analysis

---

## Target Users & Their Needs

### Persona 1: Industrial Process Engineer (Non-Math)

**Background:** 15 years manufacturing/process control; familiar with programming; no formal statistics training

**Needs:**
- "Show me how to predict if my production line will miss capacity targets given weather/equipment randomness"
- Semantic mental model: "Simulate the process 10,000 times with random variations → tell me failure rate"
- NOT interested in: theory, proofs, Greek letters, p-values
- VERY interested in: concrete results, confidence bounds, easy visualization

**Pain:** Understands the business problem but not probability theory; current tools too abstract

---

### Persona 2: Automotive Safety Engineer

**Background:** 10 years embedded systems safety; disciplined about fault analysis; statistical novice

**Needs:**
- "Monte Carlo simulation for FMEA (Failure Mode & Effects Analysis)"
- "How many simulated faults until 99.99% confidence in failure rate?"
- "Compare two control strategies under noise"
- Semantic mental model: "Run experiment 1,000,000 times with random failures → measure outcomes"

**Pain:** Has the mental model but needs library to execute it; doesn't know sampling variance, convergence, confidence intervals

---

### Persona 3: Data/Analytics Developer with Strong Business Sense

**Background:** SQL, Python data analysis; understands "95% confidence" intuitively; wants to apply in Eiffel

**Needs:**
- "Bring Monte Carlo methods I know from Python into type-safe Eiffel"
- Semantic mental model: "Sample, measure, aggregate → infer population behavior"
- Wants: Library that maps to mental model; explains terminology clearly

**Pain:** Eiffel ecosystem lacks stochastic simulation tools; forced to context-switch to Python

---

## Success Criteria

### MVP Success (Phase 1)

| Criterion | Measure |
|-----------|---------|
| **Persona 1 can run a simulation** | "I created a SIMPLE_MONTE_CARLO instance, ran 10k samples, got a failure probability. Confidence interval shows uncertainty range." |
| **Persona 2 understands convergence** | "I ran samples until convergence (R̂ < 1.01); confidence that my estimate is stable." |
| **Persona 3 has familiar API** | "API feels like NumPy/pandas for sampling and aggregation; I can write simulations without learning new concepts." |
| **No math background required** | Documentation has zero equations for core usage; plain-English explanations of all concepts. |
| **Concrete industrial example** | "I solved my actual production capacity planning problem with this library." |
| **Type safety advantage clear** | "Library prevented me from mixing probability with regular numbers via type system." |

### Full Success (Phase 2+)

| Criterion | Measure |
|-----------|---------|
| **Advanced users enabled** | "I used parallel MCMC chains with SCOOP for Bayesian inference." |
| **Integration with simple_probability** | "I defined Bayesian priors and used Monte Carlo to sample posteriors." |
| **Performance at scale** | "I ran 100M samples on distributed Eiffel system without slowdown." |
| **Community contributions** | "Multiple domain-specific applications (finance, engineering, science) built on library." |

---

## Scope Boundaries

### In Scope (MUST) — Phase 1 MVP

**Core Monte Carlo:**
1. **Monte Carlo Experiment Framework**
   - Create experiment (define what to sample, what to measure)
   - Run N trials with random sampling
   - Collect outcomes (measurements)
   - Aggregate results (mean, variance, confidence intervals)

2. **Sampling from Distributions**
   - Integrate with simple_probability (sample from Normal, Beta, Binomial, etc.)
   - Support custom distributions (user-defined)
   - Reproducible sampling via seed

3. **Uncertainty Quantification**
   - Point estimate (mean of samples)
   - Confidence intervals (95%, 99%, etc.)
   - Standard error calculation
   - Convergence diagnostics (simple: sample size sufficiency)

4. **Industrial Examples (Documentation)**
   - Production capacity planning (process simulation)
   - Failure rate analysis (reliability)
   - Sensor uncertainty quantification
   - Portfolio risk assessment

5. **Semantic API (Non-Math Friendly)**
   - Experiment, Trial, Outcome classes
   - Plain-English method names (run_simulation, get_confidence_interval)
   - No mathematical notation in public API
   - Extensive documentation with business examples

6. **Testing & Validation**
   - Statistical tests (samples match theoretical distribution)
   - Convergence validation
   - Performance benchmarks

### In Scope (SHOULD) — Phase 1 if Time Permits

- Advanced convergence diagnostics (Gelman-Rubin R̂ statistic)
- Parallel simulation (independent trials via SCOOP)
- Variance reduction techniques (antithetic sampling, control variates)
- Sensitivity analysis (how outputs depend on inputs)

### Out of Scope

- **Bayesian MCMC inference** — Phase 2 (integrate with simple_probability, run posterior sampling)
- **Optimization under uncertainty** — Separate library (simple_stochastic_optimization)
- **Machine Learning** — Separate domain (simple_ml, simple_neural)
- **Time-series simulation** — Phase 2+ (stochastic processes, Markov chains)
- **Advanced variance reduction** — Phase 2+ (importance sampling, stratified sampling)
- **Symbolic computation** — Never (not in scope for Eiffel)

### Deferred to Future

- **Gaussian Process regression** → Phase 3
- **Approximate Bayesian Computation (ABC)** → Phase 3
- **Multilevel Monte Carlo** → Phase 3
- **Quasi-Monte Carlo** → Phase 3
- **Machine Learning via simulation** → Phase 3 (integration with simple_ml)

---

## Constraints

### Technical Constraints (Immutable)

| Constraint | Reason | Impact |
|-----------|--------|--------|
| **SCOOP-compatible** | Eiffel ecosystem standard; multiple concurrent trials | Each trial must have local state; no global RNG state |
| **Void-safe (void_safety=all)** | Type safety requirement | All distributions attached; no null references |
| **Design by Contract** | Eiffel philosophy | Every feature has require/ensure/invariant |
| **Integrate simple_probability** | Leverage existing library | Monte Carlo uses simple_probability distributions |
| **No external C** | simple_* ecosystem pattern | Pure Eiffel; inline C only if needed (Phase 2+) |
| **Type-safe probability** | Eiffel advantage over Python | Probability ∉ REAL_64; use semantic types |

### Ecosystem Constraints

| Constraint | Implication |
|-----------|------------|
| **Use simple_randomizer for RNG** | Leverage existing; ensure reproducibility |
| **Use simple_math for numerics** | Reuse exp/log/sqrt; avoid ISE stdlib |
| **Integration point: simple_probability** | Distributions come from simple_probability |
| **Future integration: simple_bayes (Phase 2)** | Monte Carlo ↔ Bayesian posterior sampling |

### Resource Constraints

| Constraint | Impact |
|-----------|--------|
| **Phase 1: 3-4 weeks** | MVP scope tightly controlled; Phase 2 defers advanced features |
| **No external data files** | All computation on-the-fly; no Monte Carlo lookup tables |
| **Team: 1-2 developers** | Design must be simple; no complex infrastructure |

---

## Assumptions to Validate

| ID | Assumption | Risk if False | Validation Strategy |
|----|-----------|---------------|---------------------|
| **A-1** | Non-math developers can understand Monte Carlo via business framing | HIGH | User testing with Personas 1, 2; feedback on API naming |
| **A-2** | Semantic API (Experiment/Trial/Outcome) resonates with industrial users | HIGH | Prototype; test naming with target users |
| **A-3** | Type-safe probability is competitive advantage (vs Python) | MEDIUM | Demonstrate type errors caught at compile time |
| **A-4** | SCOOP concurrency for parallel trials is valuable | MEDIUM | Profile performance; gather demand |
| **A-5** | Confidence intervals are well-understood by non-statisticians | MEDIUM | Test comprehension in documentation |
| **A-6** | Integration with simple_probability is natural (users expect distributions) | MEDIUM | Architecture review; API consistency check |
| **A-7** | 10K-1M sample sizes sufficient for MVP use cases | LOW | Theory validates; convergence analysis proves it |

---

## Research Questions

**What is Monte Carlo conceptually, stripped of math?**
- How do practitioners think about it (business/industrial framing)?
- What analogies work best? (simulation, sampling, experimentation)
- How does it differ from optimization? From Bayesian inference?

**What are the key pain points for non-math developers?**
- Terminology confusion (confidence interval vs credible interval vs prediction interval)?
- Convergence: how many samples are enough?
- Variance: when is my estimate good enough?

**How do successful libraries (NumPy, SciPy, PyMC) expose Monte Carlo?**
- What naming conventions work? (sample, experiment, trial, outcome?)
- How do they teach uncertainty quantification?
- What documentation patterns resonate?

**How can Eiffel's type system differentiate simple_montecarlo?**
- Can we prevent mixing probability with measurements via types?
- Can semantic types (TRIAL_OUTCOME, MEASUREMENT) clarify intent?
- How does SCOOP parallel simulation compare to Python's GIL?

**What industrial use cases exist for Eiffel?**
- IoT systems with noisy sensors (example: environmental monitoring)
- Reliability engineering (example: FMEA Monte Carlo)
- Manufacturing optimization (example: production capacity planning)
- Embedded systems safety (example: failure rate estimation)

---

## Success Metrics (Phase 1 MVP)

| Metric | Target |
|--------|--------|
| **Code Coverage** | ≥ 90% |
| **Unit Tests** | 50+ tests |
| **Integration Examples** | 3 industrial use cases (working end-to-end) |
| **Documentation** | Non-math overview + semantic API guide + 3 tutorials |
| **Performance** | Run 1M samples in < 10 seconds |
| **Type Safety** | Compile-time errors prevent probability/measurement confusion |
| **SCOOP Readiness** | Concurrent trials possible (design verified; Phase 2 implements) |
| **User Feedback** | 3+ Personas validate API naming and examples |

---

## Known Unknowns

- **How many samples until convergence?** Varies by problem; library should help diagnose
- **What confidence level is "standard"?** 95%? 99%? Documentation should explain both
- **Should Monte Carlo compute Bayesian posteriors?** Phase 2 question; Phase 1 focuses on frequentist simulation
- **How to visualize confidence intervals?** Integration with simple_chart (future)
- **How to handle rare events?** Variance reduction (Phase 2); Phase 1 warns about sample requirements

