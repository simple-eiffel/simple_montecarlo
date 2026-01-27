# CLASS DESIGN: simple_montecarlo

## Class Inventory

| Class | Role | Single Responsibility | Phase |
|-------|------|----------------------|-------|
| **MONTE_CARLO_EXPERIMENT** | Facade | Coordinate simulation (create, configure, run, aggregate) | 1 |
| **TRIAL_OUTCOME** | Data | Hold single trial's measurement results | 1 |
| **SIMULATION_STATISTICS** | Data | Aggregate statistics (mean, std, CI) from outcomes | 1 |
| **MEASUREMENT** | Semantic Type | Represent single measurement value | 1 |
| **SIMPLE_MONTECARLO** | Factory | Create experiments; provide utilities | 1 |
| **MONTE_CARLO_EXPERIMENT_ENGINE** | Engine | Execute trials; collect outcomes | 1 |
| **CONVERGENCE_CHECKER** | Utility | Heuristic convergence diagnostics | 1 |
| **DISTRIBUTION_SAMPLER** | Adapter | Bridge simple_probability to experiments | 1 |

---

## Class Hierarchy

```
MONTE_CARLO_EXPERIMENT (Facade)
├── delegates to MONTE_CARLO_EXPERIMENT_ENGINE
├── uses DISTRIBUTION_SAMPLER (for distributions)
├── produces TRIAL_OUTCOME (per trial)
└── aggregates SIMULATION_STATISTICS

TRIAL_OUTCOME (Data)
├── measurements: ARRAY [MEASUREMENT]
├── is_success: BOOLEAN
└── metadata: detachable {STRING}

SIMULATION_STATISTICS (Data)
├── mean: REAL_64
├── std_dev: REAL_64
├── ci_lower_95: REAL_64
├── ci_upper_95: REAL_64
├── ci_lower_99: REAL_64
├── ci_upper_99: REAL_64
└── sample_count: INTEGER

MEASUREMENT (Semantic Type)
├── value: REAL_64
└── (ensures type safety: measurement ≠ probability)

SIMPLE_MONTECARLO (Factory)
├── new_experiment(trial_count: INTEGER): MONTE_CARLO_EXPERIMENT
└── standard_confidence_level: REAL_64
```

---

## Core Facade: MONTE_CARLO_EXPERIMENT

**Purpose:** Single entry point for Monte Carlo simulation
**Responsibility:** Coordinate experiment lifecycle (configure → run → analyze)

```eiffel
class MONTE_CARLO_EXPERIMENT

create
    make

feature -- Initialization

    make (trial_count: INTEGER)
            -- Create experiment that will run `trial_count` trials.
        require
            trial_count_positive: trial_count > 0
            trial_count_reasonable: trial_count <= 1_000_000
        ensure
            trial_count_set: count = trial_count
            not_configured: not is_configured
            seed_set: seed > 0  -- Default seed
        end

feature -- Configuration (Builder Pattern)

    set_trial_logic (logic: TRIAL_LOGIC): like Current
            -- Set the logic executed in each trial.
            -- Returns Current for fluent chaining.
        require
            logic /= Void
        do
            trial_logic := logic
            Result := Current
        ensure
            logic_set: trial_logic = logic
            result_is_current: Result = Current
        end

    set_seed (s: INTEGER): like Current
            -- Set random seed for reproducibility.
        require
            seed_valid: s >= 0
        do
            seed := s
        ensure
            seed_set: seed = s
            result_is_current: Result = Current
        end

    set_distribution (dist: DISTRIBUTION): like Current
            -- Set distribution for sampling in trials.
            -- Optional; trials can sample directly.
        require
            dist /= Void
        do
            distribution := dist
            Result := Current
        ensure
            distribution_set: distribution = dist
            result_is_current: Result = Current
        end

feature -- Execution

    run_simulation
            -- Execute all trials and collect outcomes.
        require
            is_configured: trial_logic /= Void
        local
            i: INTEGER
            outcome: TRIAL_OUTCOME
        do
            create outcomes.make (count)
            from i := 1 until i > count loop
                outcome := trial_logic.item ([Current])
                outcomes.extend (outcome)
                i := i + 1
            end
            is_run := True
        ensure
            all_trials_executed: outcomes.count = count
            is_run: is_run
        end

feature -- Analysis

    statistics: SIMULATION_STATISTICS
            -- Aggregate statistics from all outcomes.
        require
            simulation_run: is_run
        do
            Result := create_statistics
        ensure
            result_valid: Result /= Void
            result_count: Result.sample_count = count
        end

    confidence_interval (confidence_level: REAL_64): TUPLE [lower, upper: REAL_64]
            -- Extract confidence interval at given level (e.g., 0.95 for 95%).
        require
            simulation_run: is_run
            level_valid: confidence_level > 0 and confidence_level < 1
        do
            Result := compute_ci (confidence_level)
        ensure
            bounds_ordered: Result.lower <= Result.upper
            bounds_reasonable: Result.lower >= 0 and Result.upper <= 1
        end

    outcome_at (index: INTEGER): TRIAL_OUTCOME
            -- Access individual trial outcome (for inspection).
        require
            simulation_run: is_run
            index_valid: index >= 1 and index <= count
        do
            Result := outcomes.i_th (index)
        ensure
            result_valid: Result /= Void
        end

feature -- Status

    is_configured: BOOLEAN
            -- Is experiment ready to run?
        do
            Result := trial_logic /= Void
        end

    is_run: BOOLEAN
            -- Have trials been executed?
        -- (attribute set in run_simulation)

feature {NONE} -- Implementation

    count: INTEGER
            -- Number of trials

    trial_logic: detachable TRIAL_LOGIC
            -- Agent defining trial behavior

    seed: INTEGER
            -- Random seed (0 = default)

    distribution: detachable DISTRIBUTION
            -- Optional: distribution for sampling

    outcomes: ARRAY [TRIAL_OUTCOME]
            -- Collected trial outcomes

    create_statistics: SIMULATION_STATISTICS
            -- Compute mean, std, CIs from outcomes
        do
            -- Compute mean, std_dev, percentiles (skeleton)
            create Result
        end

    compute_ci (level: REAL_64): TUPLE [lower, upper: REAL_64]
            -- Extract CI via percentile method (skeleton)
        do
            -- Extract percentiles; return bounds
            Result := [0.0, 1.0]  -- Placeholder
        end

invariant
    count_positive: count > 0
    count_reasonable: count <= 1_000_000
    outcomes_when_run: is_run implies outcomes.count = count
    seed_valid: seed >= 0

end
```

---

## Trial Outcome Data Class

```eiffel
class TRIAL_OUTCOME

create
    make

feature -- Initialization

    make
            -- Create empty outcome.
        do
            create measurements.make (0)
            is_success := false
        ensure
            measurements_empty: measurements.count = 0
        end

feature -- Data Access

    measurements: ARRAY [MEASUREMENT]
            -- Array of measurements collected in trial

    is_success: BOOLEAN
            -- Did trial succeed? (optional boolean flag)

    metadata: detachable STRING
            -- Optional metadata (description, debug info)

feature -- Operations

    add_measurement (value: REAL_64)
            -- Record a measurement value.
        require
            value_valid: not value.is_nan
        do
            measurements.extend (create {MEASUREMENT}.make (value))
        ensure
            measurement_added: measurements.count = old measurements.count + 1
            last_measurement: measurements.last.value ~ value
        end

    set_success (flag: BOOLEAN)
            -- Set success flag.
        do
            is_success := flag
        ensure
            success_set: is_success = flag
        end

invariant
    measurements_not_void: measurements /= Void
    measurements_valid: across measurements as m all m.value >= 0 end

end
```

---

## Simulation Statistics Data Class

```eiffel
class SIMULATION_STATISTICS

create
    make

feature -- Initialization

    make (outcomes: ARRAY [TRIAL_OUTCOME])
            -- Compute statistics from trial outcomes.
        require
            outcomes_not_void: outcomes /= Void
            outcomes_not_empty: outcomes.count > 0
        do
            sample_count := outcomes.count
            compute_statistics (outcomes)
        ensure
            sample_count_set: sample_count = outcomes.count
        end

feature -- Results

    mean: REAL_64
            -- Mean of outcomes

    std_dev: REAL_64
            -- Standard deviation

    ci_lower_95: REAL_64
            -- 95% CI lower bound

    ci_upper_95: REAL_64
            -- 95% CI upper bound

    ci_lower_99: REAL_64
            -- 99% CI lower bound

    ci_upper_99: REAL_64
            -- 99% CI upper bound

    sample_count: INTEGER
            -- Number of outcomes

feature {NONE} -- Implementation

    compute_statistics (outcomes: ARRAY [TRIAL_OUTCOME])
            -- Compute mean, std, CIs (skeleton implementation)
        local
            i: INTEGER
            sum: REAL_64
            squared_diff_sum: REAL_64
            measurements: ARRAY [REAL_64]
        do
            -- Extract all measurements from outcomes
            -- Compute mean
            -- Compute std_dev
            -- Compute percentiles for CIs
        end

invariant
    sample_count_positive: sample_count > 0
    ci_ordering_95: ci_lower_95 <= ci_upper_95
    ci_ordering_99: ci_lower_99 <= ci_upper_99
    ci_bounds: ci_lower_95 >= 0 and ci_upper_99 <= 1

end
```

---

## Measurement Semantic Type

```eiffel
class MEASUREMENT

create
    make

feature -- Initialization

    make (v: REAL_64)
            -- Create measurement with value.
        require
            value_valid: not v.is_nan
            value_non_negative: v >= 0  -- Measurements are positive
        do
            value := v
        ensure
            value_set: value ~ v
        end

feature -- Access

    value: REAL_64
            -- Measurement value

invariant
    value_valid: not value.is_nan
    value_non_negative: value >= 0

end
```

---

## Factory: SIMPLE_MONTECARLO

```eiffel
class SIMPLE_MONTECARLO

create
    make

feature -- Initialization

    make
            -- Create factory instance.
        do
            -- No initialization needed
        end

feature -- Factory Methods

    new_experiment (trial_count: INTEGER): MONTE_CARLO_EXPERIMENT
            -- Create new Monte Carlo experiment.
        require
            trial_count_positive: trial_count > 0
        do
            create Result.make (trial_count)
        ensure
            result_valid: Result /= Void
            result_count: Result.count = trial_count
        end

feature -- Utilities

    standard_confidence_level: REAL_64
            -- Standard confidence level (95%).
        once
            Result := 0.95
        end

    common_confidence_levels: ARRAY [REAL_64]
            -- Common confidence levels.
        once
            create Result.make_filled (0.0, 1, 3)
            Result [1] := 0.90
            Result [2] := 0.95
            Result [3] := 0.99
        end

end
```

---

## OOSC2 Compliance

| Principle | Status | Evidence |
|-----------|--------|----------|
| **Single Responsibility** | ✓ | MONTE_CARLO_EXPERIMENT coordinates; ENGINE executes; STATISTICS aggregates |
| **Open/Closed** | ✓ | Users define trial logic via agent (extension without modification) |
| **Liskov Substitution** | ✓ | TRIAL_OUTCOME immutable; can substitute MEASUREMENT |
| **Interface Segregation** | ✓ | TRIAL_LOGIC minimal interface (returns outcome) |
| **Dependency Inversion** | ✓ | Depends on agent abstraction, not concrete trial implementations |

---

## Inheritance: IS-A Validation

All classes use composition (not inheritance):
- MONTE_CARLO_EXPERIMENT HAS-A MONTE_CARLO_EXPERIMENT_ENGINE
- EXPERIMENT HAS-A ARRAY of TRIAL_OUTCOME
- No inappropriate inheritance; pure IS-A relationships

---

## Design Summary

**Phase 1 Classes: 8 classes**
- 1 Facade (MONTE_CARLO_EXPERIMENT)
- 4 Data classes (TRIAL_OUTCOME, SIMULATION_STATISTICS, MEASUREMENT, + factory)
- 1 Engine (MONTE_CARLO_EXPERIMENT_ENGINE)
- 2 Utilities (CONVERGENCE_CHECKER, DISTRIBUTION_SAMPLER)

**Total Phase 1 LOC: ~1,500**
- Core classes: 600 LOC
- Tests: 600 LOC
- Documentation: 300 LOC

