# DECISIONS: simple_montecarlo

## Decision Log

### D-001: Semantic API ("Experiment" not "Sampler")

**Question:** Should the library use statistical terminology (Sampler, RandomVariable, Distribution) or business/industrial terminology (Experiment, Trial, Outcome)?

**Options:**
1. **Statistical** (e.g., Sampler, RandomVariable): Precise, consistent with academic literature
   - Pros: Familiar to probabilists; formal semantics
   - Cons: Intimidates non-math developers; requires learning notation

2. **Semantic/Business** (e.g., Experiment, Trial, Outcome): Intuitive to industrial engineers
   - Pros: Lowers barrier; matches mental model; unique to Eiffel
   - Cons: Ambiguous for experts; might seem oversimplified

3. **Bilingual** (both APIs): Provide both, choose one as primary
   - Pros: Serve both audiences
   - Cons: Doubles API surface; confusing

**Decision:** **SEMANTIC API (Option 2) as primary; document mathematical equivalents in Phase 2**

**Rationale:**
- Target users (Personas 1, 2) think in terms of experiments, not samplers
- "Experiment" resonates: "I'm running 10K trials to understand system behavior"
- Uniquely positions Eiffel vs Python/Julia (which use statistical terminology)
- Can add mathematical layer in Phase 2 without breaking API

**Implications:**
- Class names: MONTE_CARLO_EXPERIMENT, TRIAL_LOGIC, TRIAL_OUTCOME, MEASUREMENT
- Documentation: Explain concept first (business), then connection to probability
- Glossary: Map semantic names to statistical terms

**Reversible:** YES (could add statistical API in Phase 2 as aliases)

---

### D-002: Integration Point: simple_probability

**Question:** Should simple_montecarlo depend on simple_probability, or reimplement distributions?

**Options:**
1. **Full dependency**: simple_montecarlo imports distributions from simple_probability
   - Pros: DRY; consistent; one source of truth for distribution implementations
   - Cons: Couples libraries; simple_montecarlo useless without simple_probability

2. **Partial integration**: Simple_montecarlo provides basic distributions; reuse advanced ones
   - Pros: Flexibility; independent usage
   - Cons: Code duplication; maintenance burden

3. **No dependency**: simple_montecarlo only works with user-defined distributions (agents)
   - Pros: Minimal coupling; maximum flexibility
   - Cons: Users must implement Normal, Beta, etc. themselves

**Decision:** **FULL DEPENDENCY (Option 1)**

**Rationale:**
- simple_probability being developed in parallel (research → spec phase)
- Monte Carlo + Probability are natural pair (sampling + distributions)
- Eiffel ecosystem principle: reuse simple_* libraries
- Non-math developers expect built-in distributions

**Implications:**
- Dependency: simple_montecarlo → simple_probability → simple_randomizer
- Sampling: `experiment.sample_from(NORMAL_DISTRIBUTION)`
- Integration: seamless; users think "experiments use distributions"

**Reversible:** Partially (could make distributions optional; agents sufficient for flexibility)

---

### D-003: Architecture: Agent-Based Trial Logic

**Question:** How should users define what each trial does?

**Options:**
1. **Inheritance**: Trial extends base class; override execute()
   - Pros: Statically verifiable; clear contracts
   - Cons: Boilerplate; rigid for simple cases

2. **Agent/Lambda**: Trial logic as code block (agent/closure)
   - Pros: Flexible; lightweight; Eiffel-natural (agents); brief syntax
   - Cons: Less type checking at compile time; code smells if complex

3. **DSL**: Domain-specific language for describing trials
   - Pros: Expressive; specific to MC concepts
   - Cons: New language to learn; overkill for Phase 1

**Decision:** **AGENT-BASED (Option 2)**

**Rationale:**
- Eiffel agents are powerful; natural fit
- Users write: `exp.set_trial_logic(agent do ... end)`
- Flexible: complex logic in agent; simple cases inline
- Consistent with Eiffel idioms (agents for callbacks)

**Implications:**
- TRIAL_LOGIC type = agent returning TRIAL_OUTCOME
- Example: `agent do result_a := measure_strategy_a; result_b := measure_strategy_b; Result.set_outcomes([result_a, result_b]) end`
- Phase 2: Optional base class for advanced users

**Reversible:** YES (could add inheritance layer if agents prove inadequate)

---

### D-004: Results Storage: In-Memory vs Streaming

**Question:** How to store trial outcomes? All in memory, or stream to disk?

**Options:**
1. **In-Memory (Phase 1)**: Store all TRIAL_OUTCOME objects in array
   - Pros: Simple; fast aggregate queries; typical for 10-100K trials
   - Cons: Memory issues for 1M+ trials
   - Limits: ~1M outcomes on typical systems (~1GB memory)

2. **Streaming**: Process outcomes on-the-fly; don't store all
   - Pros: Scalable to arbitrary size; constant memory
   - Cons: Complex (running statistics); can't access individual outcomes

3. **Hybrid**: In-memory for Phase 1; streaming upgrade Phase 2
   - Pros: MVP simple; upgrade path clear
   - Cons: API change needed later

**Decision:** **IN-MEMORY Phase 1; HYBRID Phase 2**

**Rationale:**
- Industrial use cases typically 10K-100K trials (fits memory)
- Users often want to inspect individual outcomes (debugging)
- Streaming complexity deferred to Phase 2
- Set expectation: "Phase 1 MVP for trials ≤ 1M; streaming Phase 2"

**Implications:**
- MONTE_CARLO_EXPERIMENT stores array of TRIAL_OUTCOME
- Memory: ~1KB per outcome * 1M = 1GB (acceptable)
- API: `outcome_at(index)` works; `stream_outcomes()` added Phase 2

**Reversible:** YES (API compatible with streaming backend Phase 2)

---

### D-005: Convergence Handling: Heuristic Phase 1, Diagnostic Phase 2

**Question:** How much convergence support in Phase 1 vs Phase 2?

**Options:**
1. **Full diagnostics** (Gelman-Rubin R̂): Proper statistical convergence checking
   - Pros: Rigorous; helps users know when to stop
   - Cons: Complex implementation; requires multiple chains

2. **Heuristic** (Phase 1): Rule of thumb ("n ≥ 1000 for CIs; n ≥ 30K for rare events")
   - Pros: Simple; sufficient for MVP; warnings are free
   - Cons: Not statistically rigorous; may miss convergence issues

3. **None** (Phase 1): User responsibility
   - Pros: Minimal implementation
   - Cons: Users may run too few samples; overconfident results

**Decision:** **HEURISTIC Phase 1; DIAGNOSTIC Phase 2**

**Rationale:**
- Phase 1 users are non-statisticians (won't understand R̂ anyway)
- Heuristics good enough: "If CI width stable, you're done"
- Document warnings: "n < 1000: results unreliable; n < 30K: rare events unreliable"
- Phase 2 adds proper diagnostics for experts

**Implications:**
- Phase 1: `experiment.recommend_sample_size(desired_ci_width)` → estimate n
- Contracts warn if n < recommended value
- Phase 2: Adds Gelman-Rubin R̂ for multiple chains

**Reversible:** YES (heuristic can be replaced with diagnostic Phase 2)

---

### D-006: Type Safety: Semantic Types vs Type Aliases

**Question:** Should TRIAL_OUTCOME be semantic type or alias to data structure?

**Options:**
1. **Semantic Type** (TRIAL_OUTCOME = new class for outcome):
   - Pros: Prevents mixing outcomes with measurements; type safety
   - Cons: More classes; slightly verbose

2. **Type Alias** (TRIAL_OUTCOME = TUPLE/CLASS):
   - Pros: Simpler implementation; familiar patterns
   - Cons: Less type safety; could confuse OUTCOME with MEASUREMENT

3. **Phantom Types** (TRIAL_OUTCOME[MEASUREMENT_TYPE]):
   - Pros: Maximum type safety (Phase 2 innovation)
   - Cons: Advanced Eiffel; overkill for Phase 1

**Decision:** **SEMANTIC TYPE (Option 1); PHANTOM TYPES Phase 2 (innovation)**

**Rationale:**
- Unique to Eiffel (Python has no equivalent)
- Compile-time error: can't accidentally pass measurement as outcome
- Aligns with Eiffel philosophy (type safety)
- Phantom types reserved for Phase 2 research

**Implications:**
- Class TRIAL_OUTCOME { measurements: ARRAY [MEASUREMENT]; is_success: BOOLEAN; }
- Phase 2: TRIAL_OUTCOME[T] where T = type of measurement

**Reversible:** YES (phantom types additive; no API breakage)

---

### D-007: Parallelism: Design for Phase 2, Don't Force Phase 1

**Question:** Should Phase 1 support parallel execution via SCOOP?

**Options:**
1. **Parallel Phase 1**: Design with SCOOP; run trials in parallel agents now
   - Pros: Showcase Eiffel advantage; leverage SCOOP
   - Cons: Complex; harder to debug; serialization overhead

2. **Sequential Phase 1, Parallel Phase 2**: Single-threaded now; parallelizable later
   - Pros: Simple; reliable; clean API transition
   - Cons: Misses Phase 1 opportunity; users impatient

3. **Optional parallel**: Both sequential and parallel modes
   - Pros: Flexibility
   - Cons: Two code paths; testing burden

**Decision:** **SEQUENTIAL Phase 1 (design for Phase 2)**

**Rationale:**
- Phase 1 focus: correctness, usability, semantic API
- 1M sequential trials < 30s (acceptable)
- SCOOP parallelism adds complexity (concurrency bugs, reproducibility)
- Phase 2 adds parallel execution when architecture proven
- Trivial to parallelize: each trial independent

**Implications:**
- Phase 1: run_simulation() → for i=1 to n do execute_trial(i) end
- Phase 2: set_parallel_execution(true) → use SCOOP agents for trials
- No API changes needed (backward compatible)

**Reversible:** YES (parallelization is backend change; API stable)

---

### D-008: Documentation Strategy: Business Examples First

**Question:** How to structure documentation for non-math audience?

**Options:**
1. **Top-down (Theory First)**: Start with probability theory; build to examples
   - Pros: Logical; comprehensive
   - Cons: Lost audience in first 5 pages

2. **Bottom-up (Examples First)**: Start with "production problem"; show code; explain
   - Pros: Intuitive; motivated; non-math readers engage
   - Cons: Later sections seem abstract

3. **Parallel (Two Tracks)**: Math track + Business track
   - Pros: Serve both audiences
   - Cons: Maintenance burden; some readers confused which to follow

**Decision:** **BOTTOM-UP (Examples First); Math track Phase 2**

**Rationale:**
- Non-math is primary audience
- "Show me a problem I recognize, then show code" = most effective teaching
- Theory explained in context (not upfront)
- Experts can skip to API docs

**Implications:**
- README: "Production Capacity Planning Example" (no equations)
- Tutorial 1: Failure rate analysis (step-by-step walkthrough)
- API Docs: Formal specifications
- Glossary: Map industrial terms to probability concepts
- Phase 2: Add "For Statisticians" track

**Reversible:** YES (reorganize docs without code changes)

---

### D-009: Error Handling: Contracts vs Exceptions

**Question:** Should failures be handled via Design by Contract or exceptions?

**Options:**
1. **DBC Only** (Preconditions + Invariants):
   - Pros: Eiffel-native; compile-time contracts
   - Cons: Runtime failures for violated contracts; no recovery

2. **Exceptions** (try/catch blocks):
   - Pros: Recoverable errors; runtime handling
   - Cons: Python-style; not Eiffel-native; error paths complex

3. **Hybrid** (DBC for logic; Exceptions for resources):
   - Pros: Best of both; logical errors caught early; resource failures handled
   - Cons: More code

**Decision:** **HYBRID (Option 3)**

**Rationale:**
- Invalid parameters (n_trials < 1) → Contract violation (logic error)
- Out of memory (1M trials with complex outcomes) → Exception (resource error)
- Distribution creation error → Exception (e.g., Normal with sigma ≤ 0)

**Implications:**
- Preconditions: `n_trials > 0`, `confidence ∈ (0, 1)`, etc.
- Invariants: experiment consistency (outcomes_count = n_trials after run)
- Exceptions: define MEMORY_ALLOCATION_ERROR, INVALID_DISTRIBUTION_ERROR

**Reversible:** YES (can add/remove exceptions without API change)

---

### D-010: Phase Boundaries: When to Add MCMC, Bayesian, Variance Reduction

**Question:** What's the clear boundary between Phase 1, 1.5, 2?

**Options:**
1. **Aggressive Phase 1**: Include MCMC, Bayesian, convergence diagnostics
   - Pros: Comprehensive immediately
   - Cons: Bloated MVP; slips schedule

2. **Minimal Phase 1**: Only core experiment framework
   - Pros: Tight, ship fast
   - Cons: Limited; might seem incomplete

3. **Staged MVP** (current plan):
   - Phase 1: Core (Experiment, Trial, Outcome, basic CI) → 2-3 weeks
   - Phase 1.5: Convergence diagnostics (R̂) → 3-4 weeks
   - Phase 2: MCMC, Bayesian, parallelism → 4-6 weeks

**Decision:** **STAGED MVP (Option 3)**

**Rationale:**
- Phase 1 ships v1.0 (production-ready for deterministic MC)
- Phase 1.5 optional (convergence diagnostics if demand high)
- Phase 2 elevates to Bayesian integration
- Clear Go/No-Go decision points
- Reduces schedule risk

**Implications:**
- Phase 1 release: v1.0.0 (general MC simulation)
- Phase 1.5 release: v1.1.0 (convergence diagnostics)
- Phase 2 release: v2.0.0 (MCMC + Bayesian)
- No API breakage between versions

**Reversible:** YES (phases independent; no lockstep dependencies)

---

## Summary of Decisions

| Decision | Chosen | Rationale | Risk |
|----------|--------|-----------|------|
| **Semantic API** | Experiment/Trial/Outcome | Non-math mental model | Low (can add statistical aliases) |
| **Integration: simple_probability** | Full dependency | Distributions from library | Low (natural pairing) |
| **Trial Logic** | Agents | Flexible; Eiffel-natural | Low (can add inheritance) |
| **Results Storage** | In-memory Phase 1 | Simple; sufficient for MVP | Medium (streaming Phase 2) |
| **Convergence** | Heuristic Phase 1 | Non-math users won't understand R̂ | Low (upgrade Phase 2) |
| **Type Safety** | Semantic types | Unique advantage | Low (phantom types Phase 2) |
| **Parallelism** | Phase 2 only | Adds complexity; focus Phase 1 | Low (trivial to add) |
| **Documentation** | Examples-first | Engage non-math audience | Low (reorganize anytime) |
| **Error Handling** | DBC + Exceptions | Eiffel + pragmatism | Low (mature approach) |
| **Phasing** | Staged MVP | Reduces schedule risk | Low (clear gates) |

**All decisions reversible with Phase gates; none lock architecture.**

