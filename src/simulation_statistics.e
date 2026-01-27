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
