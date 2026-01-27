note
    description: "Trial logic callable specification (agent protocol)"
    design: "Defines the contract for user-provided trial logic agents"
    void_safety: "all"

deferred class TRIAL_LOGIC_CALLABLE

feature -- Trial Execution

    execute: TRIAL_OUTCOME
            -- Execute one trial and return outcome.
            -- Users implement this via agent: agent do ... business_logic ... end
        require
            preconditions_met: preconditions_satisfied
        deferred
        ensure
            outcome_valid: Result /= Void
            postconditions_met: postconditions_satisfied (Result)
        end

feature {NONE} -- Precondition Helpers

    preconditions_satisfied: BOOLEAN
            -- Are preconditions met for trial execution?
            -- Override in subclasses; default is always true.
        do
            Result := True
        end

feature {NONE} -- Postcondition Helpers

    postconditions_satisfied (a_outcome: TRIAL_OUTCOME): BOOLEAN
            -- Are postconditions met for trial outcome?
            -- Users may override; default: outcome is non-void with at least one measurement.
        do
            Result := a_outcome /= Void and a_outcome.count >= 0
        end

end
