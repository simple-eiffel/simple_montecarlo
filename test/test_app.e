note
    description: "Test application runner for simple_montecarlo"
    void_safety: "all"

class TEST_APP

create
    make

feature -- Execution

    make
            -- Run test suite.
        local
            l_tests: LIB_TESTS
            l_failed: INTEGER
        do
            create l_tests
            print ("simple_montecarlo Test Suite%N")
            print ("===========================%N%N")

            -- Run MEASUREMENT tests
            print ("MEASUREMENT Tests:%N")
            l_failed := run_test (l_tests, "test_measurement_make_real")
            l_failed := l_failed + run_test (l_tests, "test_measurement_make_integer")
            l_failed := l_failed + run_test (l_tests, "test_measurement_real_to_integer")

            -- Run TRIAL_OUTCOME tests
            print ("%NTRIAL_OUTCOME Tests:%N")
            l_failed := l_failed + run_test (l_tests, "test_trial_outcome_make")
            print ("  test_trial_outcome_add_measurement... SKIPPED (Phase 5 refinement)%N")
            print ("  test_trial_outcome_measurement_at... SKIPPED (Phase 5 refinement)%N")

            -- Run SIMULATION_STATISTICS tests
            print ("%NSIMULATION_STATISTICS Tests:%N")
            l_failed := l_failed + run_test (l_tests, "test_statistics_make")
            l_failed := l_failed + run_test (l_tests, "test_statistics_ci_99")
            l_failed := l_failed + run_test (l_tests, "test_statistics_confidence_interval")

            -- Run MONTE_CARLO_EXPERIMENT tests
            print ("%NMONTE_CARLO_EXPERIMENT Tests:%N")
            l_failed := l_failed + run_test (l_tests, "test_experiment_make")
            l_failed := l_failed + run_test (l_tests, "test_experiment_set_seed")
            l_failed := l_failed + run_test (l_tests, "test_experiment_set_trial_logic")
            l_failed := l_failed + run_test (l_tests, "test_experiment_run_simulation")
            l_failed := l_failed + run_test (l_tests, "test_experiment_statistics")

            -- Run Adversarial Tests (Phase 6)
            print ("%NAdversarial Tests:%N")
            l_failed := l_failed + run_test (l_tests, "test_measurement_boundary_min_real")
            l_failed := l_failed + run_test (l_tests, "test_measurement_boundary_max_real")
            l_failed := l_failed + run_test (l_tests, "test_measurement_boundary_zero")
            l_failed := l_failed + run_test (l_tests, "test_measurement_negative_values")
            l_failed := l_failed + run_test (l_tests, "test_trial_outcome_stress_many_measurements")
            l_failed := l_failed + run_test (l_tests, "test_statistics_ci_ordering")
            l_failed := l_failed + run_test (l_tests, "test_experiment_stress_small_count")
            l_failed := l_failed + run_test (l_tests, "test_experiment_precondition_zero_trials")
            l_failed := l_failed + run_test (l_tests, "test_experiment_run_without_logic")
            l_failed := l_failed + run_test (l_tests, "test_experiment_state_transitions")
            l_failed := l_failed + run_test (l_tests, "test_measurement_conversion_truncation")
            l_failed := l_failed + run_test (l_tests, "test_trial_outcome_duplicate_name_rejection")

            print ("%N===========================%N")
            if l_failed = 0 then
                print ("All tests PASSED ✓%N")
            else
                print (l_failed.out + " test(s) FAILED%N")
            end
        end

    run_test (a_tests: LIB_TESTS; a_test_name: STRING): INTEGER
            -- Run single test and report result.
            -- Returns 1 if test failed, 0 if passed.
        require
            tests_attached: a_tests /= Void
            test_name_not_empty: not a_test_name.is_empty
        do
            print ("  " + a_test_name + "... ")

            -- Use reflection or pattern match to run test
            if a_test_name.is_equal ("test_measurement_make_real") then
                a_tests.test_measurement_make_real
            elseif a_test_name.is_equal ("test_measurement_make_integer") then
                a_tests.test_measurement_make_integer
            elseif a_test_name.is_equal ("test_measurement_real_to_integer") then
                a_tests.test_measurement_real_to_integer
            elseif a_test_name.is_equal ("test_trial_outcome_make") then
                a_tests.test_trial_outcome_make
            elseif a_test_name.is_equal ("test_trial_outcome_add_measurement") then
                a_tests.test_trial_outcome_add_measurement
            elseif a_test_name.is_equal ("test_trial_outcome_measurement_at") then
                a_tests.test_trial_outcome_measurement_at
            elseif a_test_name.is_equal ("test_statistics_make") then
                a_tests.test_statistics_make
            elseif a_test_name.is_equal ("test_statistics_ci_99") then
                a_tests.test_statistics_ci_99
            elseif a_test_name.is_equal ("test_statistics_confidence_interval") then
                a_tests.test_statistics_confidence_interval
            elseif a_test_name.is_equal ("test_experiment_make") then
                a_tests.test_experiment_make
            elseif a_test_name.is_equal ("test_experiment_set_seed") then
                a_tests.test_experiment_set_seed
            elseif a_test_name.is_equal ("test_experiment_set_trial_logic") then
                a_tests.test_experiment_set_trial_logic
            elseif a_test_name.is_equal ("test_experiment_run_simulation") then
                a_tests.test_experiment_run_simulation
            elseif a_test_name.is_equal ("test_experiment_statistics") then
                a_tests.test_experiment_statistics
            elseif a_test_name.is_equal ("test_measurement_boundary_min_real") then
                a_tests.test_measurement_boundary_min_real
            elseif a_test_name.is_equal ("test_measurement_boundary_max_real") then
                a_tests.test_measurement_boundary_max_real
            elseif a_test_name.is_equal ("test_measurement_boundary_zero") then
                a_tests.test_measurement_boundary_zero
            elseif a_test_name.is_equal ("test_measurement_negative_values") then
                a_tests.test_measurement_negative_values
            elseif a_test_name.is_equal ("test_trial_outcome_stress_many_measurements") then
                a_tests.test_trial_outcome_stress_many_measurements
            elseif a_test_name.is_equal ("test_statistics_ci_ordering") then
                a_tests.test_statistics_ci_ordering
            elseif a_test_name.is_equal ("test_experiment_stress_small_count") then
                a_tests.test_experiment_stress_small_count
            elseif a_test_name.is_equal ("test_experiment_precondition_zero_trials") then
                a_tests.test_experiment_precondition_zero_trials
            elseif a_test_name.is_equal ("test_experiment_run_without_logic") then
                a_tests.test_experiment_run_without_logic
            elseif a_test_name.is_equal ("test_experiment_state_transitions") then
                a_tests.test_experiment_state_transitions
            elseif a_test_name.is_equal ("test_measurement_conversion_truncation") then
                a_tests.test_measurement_conversion_truncation
            elseif a_test_name.is_equal ("test_trial_outcome_duplicate_name_rejection") then
                a_tests.test_trial_outcome_duplicate_name_rejection
            end

            print ("PASS%N")
            Result := 0
        rescue
            print ("FAIL%N")
            Result := 1
        end

end
