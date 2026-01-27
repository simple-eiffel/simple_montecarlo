# Eiffel Contract Review Request - Ollama

**Project:** simple_montecarlo (Monte Carlo simulation framework)

**Instructions for Ollama:** Review the contracts below for obvious design problems, weak preconditions, missing invariants, and edge cases. Focus on:
1. Preconditions that are just `True` (too weak)
2. Postconditions that don't actually constrain anything
3. Missing invariants
4. Obvious edge cases not handled
5. Missing model queries for collection attributes
6. Missing frame conditions (what did NOT change)

Find 5-10 issues if they exist. For each issue:
- **ISSUE**: [description]
- **LOCATION**: [class.feature]
- **SEVERITY**: [High/Medium/Low]
- **SUGGESTION**: [how to fix]

---

## CONTRACT SPECIFICATIONS

### CLASS: MEASUREMENT

```eiffel
note
    description: "Type-safe measurement value from trial outcome"
    design: "Prevents confusion between probability and observed measurement"
    void_safety: "all"

class MEASUREMENT

create
    make_real, make_integer

feature {NONE} -- Initialization

    make_real (a_value: REAL_64)
            -- Create measurement with real value.
        require
            not_nan: not a_value.is_nan
        do
            is_real := True
            real_value := a_value
            integer_value := 0
        ensure
            is_real_measurement: is_real
            value_set: real_value = a_value
        end

    make_integer (a_value: INTEGER)
            -- Create measurement with integer value.
        do
            is_real := False
            integer_value := a_value
            real_value := 0.0
        ensure
            is_integer_measurement: not is_real
            value_set: integer_value = a_value
        end

feature -- Access

    as_real: REAL_64
            -- Measurement as real; promotes integer if needed.
        do
            if is_real then
                Result := real_value
            else
                Result := integer_value.to_double
            end
        ensure
            not_nan: not Result.is_nan
        end

    as_integer: INTEGER
            -- Measurement as integer; truncates real if needed.
        do
            if is_real then
                Result := real_value.truncated_to_integer
            else
                Result := integer_value
            end
        end

    is_real: BOOLEAN
            -- Is this a real-valued measurement?

    real_value: REAL_64
            -- Real-valued measurement (0 if is_real is false).

    integer_value: INTEGER
            -- Integer-valued measurement (0 if is_real is true).

invariant
    at_least_one_type: is_real or not is_real
    exactly_one_valid: (is_real and integer_value = 0) or (not is_real and real_value = 0.0)

end
```

### CLASS: TRIAL_OUTCOME

```eiffel
note
    description: "Result container from single Monte Carlo trial"
    void_safety: "all"

class TRIAL_OUTCOME

create
    make

feature {NONE} -- Initialization

    make
            -- Create empty outcome ready for measurements.
        do
            create measurements.make (10)
            create measurement_names.make (10)
        ensure
            is_empty: count = 0
        end

feature -- Access

    measurement_at (a_name: STRING): MEASUREMENT
            -- Measurement with given name; Void if not found.
        require
            name_exists: has_measurement (a_name)
        local
            l_index: INTEGER
        do
            l_index := measurement_names.index_of (a_name, 1)
            check l_index > 0 end  -- Guaranteed by precondition
            Result := measurements [l_index]
        ensure
            result_attached: Result /= Void
        end

    has_measurement (a_name: STRING): BOOLEAN
            -- Does outcome have measurement with this name?
        do
            Result := measurement_names.has (a_name)
        end

    measurement_count: INTEGER
            -- Number of measurements recorded.
        do
            Result := measurements.count
        ensure
            non_negative: Result >= 0
            consistent: Result = measurement_names.count
        end

    count: INTEGER
            -- Alias for measurement_count.
        do
            Result := measurement_count
        end

feature -- Modification

    add_measurement (a_name: STRING; a_value: MEASUREMENT)
            -- Record measurement with name.
        require
            name_not_empty: not a_name.is_empty
            value_attached: a_value /= Void
            unique_name: not has_measurement (a_name)
        do
            measurements.extend (a_value)
            measurement_names.extend (a_name)
        ensure
            count_incremented: measurement_count = old measurement_count + 1
            measurement_stored: has_measurement (a_name)
            new_value: measurement_at (a_name) = a_value
        end

feature {NONE} -- Implementation

    measurements: ARRAYED_LIST [MEASUREMENT]
            -- Recorded measurements.

    measurement_names: ARRAYED_LIST [STRING]
            -- Names of measurements (parallel to measurements).

invariant
    measurements_counts_match: measurements.count = measurement_names.count
    no_duplicate_names: measurement_names.count = measurement_names.count
        -- (Note: full uniqueness check deferred to Phase 4 implementation via model query)

end
```

### CLASS: SIMULATION_STATISTICS

```eiffel
note
    description: "Aggregated statistics from Monte Carlo simulation"
    void_safety: "all"
    design: "Immutable result object; cannot be modified after creation"

class SIMULATION_STATISTICS

create
    make

feature {NONE} -- Initialization

    make (a_mean, a_std_dev, a_min, a_max: REAL_64;
          a_ci_95_lower, a_ci_95_upper: REAL_64;
          a_ci_99_lower, a_ci_99_upper: REAL_64;
          a_sample_size: INTEGER)
            -- Create statistics from aggregated trial results.
        require
            valid_std_dev: a_std_dev >= 0.0
            mean_not_nan: not a_mean.is_nan
            std_dev_not_nan: not a_std_dev.is_nan
            ci_95_ordered: a_ci_95_lower <= a_ci_95_upper
            ci_99_ordered: a_ci_99_lower <= a_ci_99_upper
            ci_95_not_nan: not a_ci_95_lower.is_nan and not a_ci_95_upper.is_nan
            ci_99_not_nan: not a_ci_99_lower.is_nan and not a_ci_99_upper.is_nan
            positive_sample_size: a_sample_size > 0
        do
            mean_value := a_mean
            std_dev_value := a_std_dev
            min_value := a_min
            max_value := a_max
            ci_95_lower_value := a_ci_95_lower
            ci_95_upper_value := a_ci_95_upper
            ci_99_lower_value := a_ci_99_lower
            ci_99_upper_value := a_ci_99_upper
            sample_size_value := a_sample_size
        ensure
            mean_set: mean_value = a_mean
            std_dev_set: std_dev_value = a_std_dev
            sample_size_set: sample_size_value = a_sample_size
            ci_95_set: ci_95_lower_value = a_ci_95_lower and ci_95_upper_value = a_ci_95_upper
            ci_99_set: ci_99_lower_value = a_ci_99_lower and ci_99_upper_value = a_ci_99_upper
        end

feature -- Access

    mean: REAL_64
            -- Mean of all trial outcomes.
        do
            Result := mean_value
        ensure
            not_nan: not Result.is_nan
        end

    std_dev: REAL_64
            -- Standard deviation of trial outcomes.
        do
            Result := std_dev_value
        ensure
            non_negative: Result >= 0.0
            not_nan: not Result.is_nan
        end

    min: REAL_64
            -- Minimum trial outcome.
        do
            Result := min_value
        end

    max: REAL_64
            -- Maximum trial outcome.
        do
            Result := max_value
        end

    ci_95: TUPLE [REAL_64, REAL_64]
            -- 95% confidence interval [lower, upper].
        do
            create Result
            Result := [ci_95_lower_value, ci_95_upper_value]
        ensure
            ordered: Result.integer_item (1) <= Result.integer_item (2)
        end

    ci_99: TUPLE [REAL_64, REAL_64]
            -- 99% confidence interval [lower, upper].
        do
            create Result
            Result := [ci_99_lower_value, ci_99_upper_value]
        ensure
            ordered: Result.integer_item (1) <= Result.integer_item (2)
        end

    sample_size: INTEGER
            -- Number of trials used in aggregation.
        do
            Result := sample_size_value
        ensure
            positive: Result > 0
        end

    confidence_interval (a_level: REAL_64): TUPLE [REAL_64, REAL_64]
            -- Confidence interval at given level; supports 0.95 and 0.99.
        require
            valid_level: a_level = 0.95 or a_level = 0.99
        do
            if a_level = 0.95 then
                Result := ci_95
            else
                Result := ci_99
            end
        ensure
            result_attached: Result /= Void
            ordered: Result.integer_item (1) <= Result.integer_item (2)
        end

feature {NONE} -- Implementation

    mean_value: REAL_64
    std_dev_value: REAL_64
    min_value: REAL_64
    max_value: REAL_64
    ci_95_lower_value: REAL_64
    ci_95_upper_value: REAL_64
    ci_99_lower_value: REAL_64
    ci_99_upper_value: REAL_64
    sample_size_value: INTEGER

invariant
    std_dev_non_negative: std_dev_value >= 0.0
    ci_95_ordered: ci_95_lower_value <= ci_95_upper_value
    ci_99_ordered: ci_99_lower_value <= ci_99_upper_value
    ci_99_wider_than_95: (ci_99_upper_value - ci_99_lower_value) >= (ci_95_upper_value - ci_95_lower_value)
    sample_size_positive: sample_size_value > 0

end
```

### CLASS: MONTE_CARLO_EXPERIMENT

```eiffel
note
    description: "Main Monte Carlo experiment orchestrator"
    design: "Coordinates trial execution, outcome collection, and statistical aggregation"
    void_safety: "all"

class MONTE_CARLO_EXPERIMENT

create
    make

feature {NONE} -- Initialization

    make (a_trial_count: INTEGER)
            -- Create experiment for `a_trial_count` trials.
        require
            positive_trial_count: a_trial_count > 0
        do
            trial_count := a_trial_count
            seed_value := 0
            create outcomes.make (a_trial_count)
            trial_logic_agent := Void
            has_run := False
        ensure
            trial_count_set: trial_count = a_trial_count
            is_empty: outcome_count = 0
            not_yet_run: not has_run
        end

feature -- Configuration

    set_seed (a_seed: INTEGER)
            -- Set random seed for reproducible results.
        require
            seed_non_negative: a_seed >= 0
            not_yet_run: not has_run
        do
            seed_value := a_seed
        ensure
            seed_set: seed_value = a_seed
        end

    set_trial_logic (a_logic: FUNCTION [TUPLE, TRIAL_OUTCOME])
            -- Set the trial logic agent.
        require
            logic_not_void: a_logic /= Void
            not_yet_run: not has_run
        do
            trial_logic_agent := a_logic
        ensure
            logic_set: trial_logic_agent = a_logic
        end

feature -- Execution

    run_simulation
            -- Execute all trials and collect outcomes.
        require
            logic_defined: trial_logic_agent /= Void
            not_already_run: not has_run
        local
            l_index: INTEGER
            l_outcome: TRIAL_OUTCOME
        do
            outcomes.wipe_out
            from l_index := 1
            until l_index > trial_count
            loop
                if attached trial_logic_agent as l_agent then
                    l_outcome := l_agent.item ([])
                    outcomes.extend (l_outcome)
                end
                l_index := l_index + 1
            end
            has_run := True
        ensure
            outcomes_collected: outcome_count = trial_count
            has_been_run: has_run
            outcomes_model_valid: outcomes_count = trial_count
        end

feature -- Statistics

    statistics: SIMULATION_STATISTICS
            -- Compute and return aggregated statistics.
        require
            has_run: has_run
            outcomes_available: outcome_count > 0
        local
            l_measurements: ARRAYED_LIST [REAL_64]
        do
            l_measurements := extract_all_measurements
            Result := compute_statistics (l_measurements)
        ensure
            result_attached: Result /= Void
            result_sample_size: Result.sample_size = trial_count
        end

    confidence_interval (a_level: REAL_64): TUPLE [REAL_64, REAL_64]
            -- Extract confidence interval at given level (0.95 or 0.99).
        require
            has_run: has_run
            valid_level: a_level = 0.95 or a_level = 0.99
        local
            l_stats: SIMULATION_STATISTICS
        do
            l_stats := statistics
            Result := l_stats.confidence_interval (a_level)
        ensure
            result_attached: Result /= Void
            ordered: Result.integer_item (1) <= Result.integer_item (2)
        end

feature -- Access

    outcome_at (a_index: INTEGER): TRIAL_OUTCOME
            -- Outcome from trial number `a_index` (1-indexed).
        require
            has_run: has_run
            valid_index: 1 <= a_index and a_index <= trial_count
        do
            Result := outcomes [a_index]
        ensure
            result_attached: Result /= Void
        end

    outcome_count: INTEGER
            -- Number of outcomes recorded.
        do
            Result := outcomes.count
        ensure
            non_negative: Result >= 0
            bounded: Result <= trial_count
        end

feature {NONE} -- Model Queries (MML - Phase 4)

    outcomes_count: INTEGER
            -- Model query: count of outcomes (for invariants).
        do
            Result := outcomes.count
        end

    outcomes_valid: BOOLEAN
            -- Model query: all outcomes have valid measurements.
        do
            Result := across outcomes as oc all oc.count > 0 end
        end

feature -- Status (for contracts)

    has_run: BOOLEAN
            -- Has simulation been executed?

feature -- Configuration (for contracts)

    trial_count: INTEGER
            -- Number of trials to execute.

feature {NONE} -- Implementation

    seed_value: INTEGER
            -- Random seed for reproducibility.

feature -- Trial Logic (for contracts)

    trial_logic_agent: detachable FUNCTION [TUPLE, TRIAL_OUTCOME]
            -- User-defined trial logic (Void until set).

    outcomes: ARRAYED_LIST [TRIAL_OUTCOME]
            -- Collected outcomes from all trials.

    extract_all_measurements: ARRAYED_LIST [REAL_64]
            -- Extract all measurements from all outcomes.
        require
            has_run: has_run
        do
            create Result.make (trial_count)
        ensure
            result_attached: Result /= Void
        end

    compute_statistics (a_measurements: ARRAYED_LIST [REAL_64]): SIMULATION_STATISTICS
            -- Compute statistics from measurements.
        require
            measurements_attached: a_measurements /= Void
            measurements_not_empty: a_measurements.count > 0
        do
            create Result.make (0, 0, 0, 0, 0, 0, 0, 0, trial_count)
        ensure
            result_attached: Result /= Void
        end

invariant
    trial_count_positive: trial_count > 0
    seed_non_negative: seed_value >= 0
    outcomes_non_negative: outcomes.count >= 0
    outcomes_bounded: outcomes.count <= trial_count
    outcomes_counts_match: outcomes_count = outcomes.count
    if_run_then_complete: has_run implies outcomes.count = trial_count

end
```

---

## IMPLEMENTATION APPROACH

See: `.eiffel-workflow/approach.md` for full implementation details including:
- Dependency integration (simple_probability, simple_randomizer, simple_math, simple_mml)
- Testing strategy (55 tests across unit, integration, statistical validation, performance)
- MML frame conditions for outcome collections
- Reproducibility requirements
- Performance targets (1M trials < 30 seconds)

---

## PLEASE PROVIDE REVIEW FINDINGS

Format each issue as:
```
**ISSUE #N**: [description]
**LOCATION**: [class.feature]
**SEVERITY**: [High/Medium/Low]
**SUGGESTION**: [how to fix]
```

Find 5-10 issues if they exist, or confirm "No issues found" if contracts are solid.

