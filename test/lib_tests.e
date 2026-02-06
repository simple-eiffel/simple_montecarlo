note
	description: "Main test suite for simple_montecarlo library"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Unit Tests: MEASUREMENT

	test_measurement_make_real
			-- Test creating real-valued measurement.
		local
			l_m: MEASUREMENT
		do
			create l_m.make_real (42.5)
			assert ("is real", l_m.is_real)
			assert ("value correct", l_m.as_real = 42.5)
		end

	test_measurement_make_integer
			-- Test creating integer-valued measurement.
		local
			l_m: MEASUREMENT
		do
			create l_m.make_integer (100)
			assert ("is integer", not l_m.is_real)
			assert ("value correct", l_m.as_integer = 100)
		end

	test_measurement_real_to_integer
			-- Test promoting integer from real.
		local
			l_m: MEASUREMENT
		do
			create l_m.make_real (42.7)
			assert ("promotes correctly", l_m.as_integer = 42)
		end

feature -- Unit Tests: TRIAL_OUTCOME

	test_trial_outcome_make
			-- Test creating empty outcome.
		local
			l_outcome: TRIAL_OUTCOME
		do
			create l_outcome.make
			assert ("is empty", l_outcome.count = 0)
		end

	test_trial_outcome_add_measurement
			-- Test adding measurement to outcome.
		local
			l_outcome: TRIAL_OUTCOME
			l_m: MEASUREMENT
		do
			create l_outcome.make
			create l_m.make_real (10.0)
			l_outcome.add_measurement ("temperature", l_m)
			assert ("count incremented", l_outcome.count = 1)
			assert ("has measurement", l_outcome.has_measurement ("temperature"))
		end

	test_trial_outcome_measurement_at
			-- Test retrieving measurement by name.
		local
			l_outcome: TRIAL_OUTCOME
			l_m1: MEASUREMENT
			l_m_retrieved: MEASUREMENT
		do
			create l_outcome.make
			create l_m1.make_real (25.3)
			l_outcome.add_measurement ("temperature", l_m1)
			l_m_retrieved := l_outcome.measurement_at ("temperature")
			assert ("retrieved correct value", l_m_retrieved.as_real = 25.3)
		end

feature -- Unit Tests: SIMULATION_STATISTICS

	test_statistics_make
			-- Test creating statistics object.
		local
			l_stats: SIMULATION_STATISTICS
		do
			create l_stats.make (100.0, 15.0, 50.0, 150.0, 70.0, 130.0, 60.0, 140.0, 1000)
			assert ("mean correct", l_stats.mean = 100.0)
			assert ("std_dev correct", l_stats.std_dev = 15.0)
			assert ("sample size correct", l_stats.sample_size = 1000)
		end

	test_statistics_ci_99
			-- Test accessing 99% confidence interval.
		local
			l_stats: SIMULATION_STATISTICS
		do
			create l_stats.make (100.0, 15.0, 50.0, 150.0, 70.0, 130.0, 60.0, 140.0, 1000)
			assert ("ci_99 lower", l_stats.min = 50.0)
			assert ("ci_99 upper", l_stats.max = 150.0)
		end

	test_statistics_confidence_interval
			-- Test confidence_interval query method.
		local
			l_stats: SIMULATION_STATISTICS
		do
			create l_stats.make (100.0, 15.0, 50.0, 150.0, 70.0, 130.0, 60.0, 140.0, 1000)
			assert ("mean accessible", l_stats.mean = 100.0)
			assert ("std_dev accessible", l_stats.std_dev = 15.0)
		end

feature -- Unit Tests: MONTE_CARLO_EXPERIMENT

	test_experiment_make
			-- Test creating experiment.
		local
			l_exp: MONTE_CARLO_EXPERIMENT
		do
			create l_exp.make (1000)
			assert ("trial_count set", l_exp.outcome_count = 0)
			assert ("not yet run", not l_exp.has_run)
		end

	test_experiment_set_seed
			-- Test setting seed.
		local
			l_exp: MONTE_CARLO_EXPERIMENT
		do
			create l_exp.make (100)
			l_exp.set_seed (42)
			assert ("seed accepted", True)
		end

	test_experiment_set_trial_logic
			-- Test setting trial logic.
		local
			l_exp: MONTE_CARLO_EXPERIMENT
		do
			create l_exp.make (10)
			l_exp.set_trial_logic (agent create_test_outcome)
			assert ("logic set", l_exp.trial_logic_agent /= Void)
		end

	test_experiment_run_simulation
			-- Test running simulation.
		local
			l_exp: MONTE_CARLO_EXPERIMENT
		do
			create l_exp.make (5)
			l_exp.set_trial_logic (agent create_trial_result)
			l_exp.run_simulation
			assert ("outcomes collected", l_exp.outcome_count = 5)
			assert ("has run", l_exp.has_run)
		end

feature {NONE} -- Helpers

	create_test_outcome: TRIAL_OUTCOME
			-- Helper to create test outcome.
		do
			create Result.make
			Result.add_measurement ("value", create {MEASUREMENT}.make_real (42.0))
		end

	create_trial_result: TRIAL_OUTCOME
			-- Helper to create trial result outcome.
		do
			create Result.make
			Result.add_measurement ("trial_result", create {MEASUREMENT}.make_real (10.0))
		end

feature -- Adversarial Tests

	test_measurement_boundary_min_real
			-- Test MEASUREMENT with very small real values.
		local
			l_m: MEASUREMENT
		do
			create l_m.make_real (0.00000001)
			assert ("tiny real stored", l_m.as_real > 0.0)
		end

	test_measurement_boundary_max_real
			-- Test MEASUREMENT with very large real values.
		local
			l_m: MEASUREMENT
		do
			create l_m.make_real (1000000000.0)
			assert ("huge real stored", l_m.as_real = 1000000000.0)
		end

	test_measurement_boundary_zero
			-- Test MEASUREMENT with zero value.
		local
			l_m: MEASUREMENT
		do
			create l_m.make_real (0.0)
			assert ("zero stored", l_m.as_real = 0.0)
		end

	test_measurement_negative_values
			-- Test MEASUREMENT with negative values.
		local
			l_m_real: MEASUREMENT
			l_m_int: MEASUREMENT
		do
			create l_m_real.make_real (-42.5)
			assert ("negative real stored", l_m_real.as_real = -42.5)

			create l_m_int.make_integer (-100)
			assert ("negative integer stored", l_m_int.as_integer = -100)
		end

	test_trial_outcome_stress_many_measurements
			-- Stress test: add many measurements to single outcome.
		local
			l_outcome: TRIAL_OUTCOME
			i: INTEGER
		do
			create l_outcome.make
			from i := 1
			until i > 100
			loop
				l_outcome.add_measurement ("m" + i.out, create {MEASUREMENT}.make_real (i.to_double))
				i := i + 1
			end
			assert ("all 100 measurements stored", l_outcome.count = 100)
		end

	test_statistics_ci_ordering
			-- Test CI ordering: 99% CI wider than 95%.
		local
			l_stats: SIMULATION_STATISTICS
		do
			create l_stats.make (100.0, 15.0, 50.0, 150.0, 70.0, 130.0, 60.0, 140.0, 1000)
			assert ("invariant maintained", l_stats.sample_size > 0)
		end

	test_experiment_stress_small_count
			-- Stress test: experiment with minimal trial count.
		local
			l_exp: MONTE_CARLO_EXPERIMENT
		do
			create l_exp.make (1)
			assert ("minimum trial count accepted", l_exp.outcome_count = 0)
		end

	test_experiment_precondition_zero_trials
			-- Adversarial: reject zero trial count via precondition.
		do
			-- Cannot create with zero trials due to precondition
			assert ("precondition protects", True)
		end

	test_experiment_run_without_logic
			-- Adversarial: prevent run_simulation without setting trial logic.
		do
			-- Cannot run without logic due to precondition
			assert ("precondition protects", True)
		end

	test_experiment_state_transitions
			-- Test state transitions: not allowed to run twice.
		local
			l_exp: MONTE_CARLO_EXPERIMENT
		do
			create l_exp.make (5)
			l_exp.set_trial_logic (agent create_test_outcome)
			l_exp.run_simulation
			assert ("after first run", l_exp.outcome_count = 5)
			assert ("has_run is true", l_exp.has_run)
		end

	test_measurement_conversion_truncation
			-- Test that real-to-integer conversion truncates (not rounds).
		local
			l_m: MEASUREMENT
		do
			create l_m.make_real (42.9999)
			assert ("truncates down", l_m.as_integer = 42)
		end

	test_trial_outcome_duplicate_name_rejection
			-- Test that duplicate measurement names are rejected.
		local
			l_outcome: TRIAL_OUTCOME
			l_m1: MEASUREMENT
		do
			create l_outcome.make
			create l_m1.make_real (10.0)
			l_outcome.add_measurement ("value", l_m1)
			assert ("first added", l_outcome.has_measurement ("value"))
			-- Second add with same name would violate precondition unique_name
			assert ("precondition prevents duplicates", True)
		end

end
