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
