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
            l_i: INTEGER
            l_found: BOOLEAN
        do
            -- Initialize with first measurement (will be overwritten if name matches)
            Result := measurements [1]

            -- Find measurement with matching name
            from l_i := 1
            until l_i > measurement_names.count or l_found
            loop
                if measurement_names [l_i].same_string (a_name) then
                    Result := measurements [l_i]
                    l_found := True
                end
                l_i := l_i + 1
            end
        ensure
            result_attached: Result /= Void
        end

    has_measurement (a_name: STRING): BOOLEAN
            -- Does outcome have measurement with this name?
        local
            l_i: INTEGER
        do
            from l_i := 1
            until l_i > measurement_names.count or Result
            loop
                if measurement_names [l_i].same_string (a_name) then
                    Result := True
                end
                l_i := l_i + 1
            end
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

    all_measurements: ARRAYED_LIST [MEASUREMENT]
            -- All measurements recorded in this outcome.
        do
            create Result.make (measurements.count)
            Result := measurements.twin
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

end
