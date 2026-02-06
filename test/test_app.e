note
	description: "Test application for simple_montecarlo"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			print ("Running SIMPLE_MONTECARLO tests...%N%N")
			passed := 0
			failed := 0

			run_lib_tests

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		do
			create lib_tests

			-- MEASUREMENT tests
			run_test (agent lib_tests.test_measurement_make_real, "test_measurement_make_real")
			run_test (agent lib_tests.test_measurement_make_integer, "test_measurement_make_integer")
			run_test (agent lib_tests.test_measurement_real_to_integer, "test_measurement_real_to_integer")

			-- TRIAL_OUTCOME tests
			run_test (agent lib_tests.test_trial_outcome_make, "test_trial_outcome_make")
			run_test (agent lib_tests.test_trial_outcome_add_measurement, "test_trial_outcome_add_measurement")
			run_test (agent lib_tests.test_trial_outcome_measurement_at, "test_trial_outcome_measurement_at")

			-- SIMULATION_STATISTICS tests
			run_test (agent lib_tests.test_statistics_make, "test_statistics_make")
			run_test (agent lib_tests.test_statistics_ci_99, "test_statistics_ci_99")
			run_test (agent lib_tests.test_statistics_confidence_interval, "test_statistics_confidence_interval")

			-- MONTE_CARLO_EXPERIMENT tests
			run_test (agent lib_tests.test_experiment_make, "test_experiment_make")
			run_test (agent lib_tests.test_experiment_set_seed, "test_experiment_set_seed")
			run_test (agent lib_tests.test_experiment_set_trial_logic, "test_experiment_set_trial_logic")
			run_test (agent lib_tests.test_experiment_run_simulation, "test_experiment_run_simulation")

			-- Adversarial tests
			run_test (agent lib_tests.test_measurement_boundary_min_real, "test_measurement_boundary_min_real")
			run_test (agent lib_tests.test_measurement_boundary_max_real, "test_measurement_boundary_max_real")
			run_test (agent lib_tests.test_measurement_boundary_zero, "test_measurement_boundary_zero")
			run_test (agent lib_tests.test_measurement_negative_values, "test_measurement_negative_values")
			run_test (agent lib_tests.test_trial_outcome_stress_many_measurements, "test_trial_outcome_stress_many_measurements")
			run_test (agent lib_tests.test_statistics_ci_ordering, "test_statistics_ci_ordering")
			run_test (agent lib_tests.test_experiment_stress_small_count, "test_experiment_stress_small_count")
			run_test (agent lib_tests.test_experiment_precondition_zero_trials, "test_experiment_precondition_zero_trials")
			run_test (agent lib_tests.test_experiment_run_without_logic, "test_experiment_run_without_logic")
			run_test (agent lib_tests.test_experiment_state_transitions, "test_experiment_state_transitions")
			run_test (agent lib_tests.test_measurement_conversion_truncation, "test_measurement_conversion_truncation")
			run_test (agent lib_tests.test_trial_outcome_duplicate_name_rejection, "test_trial_outcome_duplicate_name_rejection")
		end

feature {NONE} -- Implementation

	lib_tests: LIB_TESTS
	passed, failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
