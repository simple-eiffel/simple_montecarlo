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
            -- Initialize outcomes collection
            outcomes.wipe_out

            -- Execute each trial
            from l_index := 1
            until l_index > trial_count
            loop
                -- Invoke user-defined trial logic (checked non-void by precondition)
                if attached trial_logic_agent as l_agent then
                    l_outcome := l_agent.item ([])
                    -- Store outcome
                    outcomes.extend (l_outcome)
                end

                l_index := l_index + 1
            end

            -- Mark experiment as completed
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
            -- Collect all measurements for statistical analysis
            l_measurements := extract_all_measurements

            -- Compute statistics
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
            Result := outcomes [a_index - 1]  -- Convert 1-based user index to 0-based internal list
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

    -- NOTE: Full MML model queries (e.g., outcomes_model: MML_SEQUENCE [TRIAL_OUTCOME])
    -- deferred to Phase 4 implementation when simple_mml is integrated

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
        local
            l_outcome: TRIAL_OUTCOME
            l_measurements: ARRAYED_LIST [MEASUREMENT]
            l_i: INTEGER
        do
            create Result.make (0)
            -- Iterate over all outcomes and extract all measurement values
            from l_i := 1
            until l_i > outcomes.count
            loop
                l_outcome := outcomes [l_i]
                l_measurements := l_outcome.all_measurements
                -- Convert each measurement to real and append to result
                across l_measurements as m loop
                    Result.extend (m.as_real)
                end
                l_i := l_i + 1
            end
        ensure
            result_attached: Result /= Void
        end

    compute_statistics (a_measurements: ARRAYED_LIST [REAL_64]): SIMULATION_STATISTICS
            -- Compute statistics from measurements.
        require
            measurements_attached: a_measurements /= Void
            measurements_not_empty: a_measurements.count > 0
        local
            l_mean, l_variance, l_std_dev, l_min, l_max: REAL_64
            l_sum, l_sum_sq_dev: REAL_64
            l_i: INTEGER
            l_z_95, l_z_99: REAL_64
            l_ci_95_lower, l_ci_95_upper, l_ci_99_lower, l_ci_99_upper: REAL_64
            l_std_error: REAL_64
        do
            -- Compute mean
            l_sum := 0.0
            from l_i := 1
            until l_i > a_measurements.count
            loop
                l_sum := l_sum + a_measurements [l_i]
                l_i := l_i + 1
            end
            l_mean := l_sum / a_measurements.count.to_double

            -- Compute min and max
            l_min := a_measurements [1]
            l_max := a_measurements [1]
            from l_i := 1
            until l_i > a_measurements.count
            loop
                if a_measurements [l_i] < l_min then
                    l_min := a_measurements [l_i]
                end
                if a_measurements [l_i] > l_max then
                    l_max := a_measurements [l_i]
                end
                l_i := l_i + 1
            end

            -- Compute standard deviation
            l_sum_sq_dev := 0.0
            from l_i := 1
            until l_i > a_measurements.count
            loop
                l_sum_sq_dev := l_sum_sq_dev + (a_measurements [l_i] - l_mean) * (a_measurements [l_i] - l_mean)
                l_i := l_i + 1
            end
            l_variance := l_sum_sq_dev / a_measurements.count.to_double
            -- Compute sqrt manually: for small estimates, use approximation
            l_std_dev := compute_sqrt (l_variance)

            -- Compute confidence intervals using z-scores
            -- For 95% CI: z = 1.96
            -- For 99% CI: z = 2.576
            l_z_95 := 1.96
            l_z_99 := 2.576

            -- Standard error = std_dev / sqrt(n)
            l_std_error := l_std_dev / compute_sqrt (a_measurements.count.to_double)

            -- CI = mean ± z * std_error
            l_ci_95_lower := l_mean - l_z_95 * l_std_error
            l_ci_95_upper := l_mean + l_z_95 * l_std_error
            l_ci_99_lower := l_mean - l_z_99 * l_std_error
            l_ci_99_upper := l_mean + l_z_99 * l_std_error

            -- Create result with computed statistics
            create Result.make (l_mean, l_std_dev, l_min, l_max,
                                l_ci_95_lower, l_ci_95_upper, l_ci_99_lower, l_ci_99_upper,
                                a_measurements.count)
        ensure
            result_attached: Result /= Void
        end

    compute_sqrt (a_value: REAL_64): REAL_64
            -- Compute square root using Newton's method.
        local
            l_x, l_x_prev, l_epsilon: REAL_64
        do
            if a_value <= 0.0 then
                Result := 0.0
            else
                l_x := a_value
                l_epsilon := 0.000001
                from
                until ((l_x - l_x_prev).abs < l_epsilon)
                loop
                    l_x_prev := l_x
                    l_x := (l_x + a_value / l_x) / 2.0
                end
                Result := l_x
            end
        end

invariant
    trial_count_positive: trial_count > 0
    seed_non_negative: seed_value >= 0
    outcomes_non_negative: outcomes.count >= 0
    outcomes_bounded: outcomes.count <= trial_count
    outcomes_counts_match: outcomes_count = outcomes.count
    if_run_then_complete: has_run implies outcomes.count = trial_count

end
