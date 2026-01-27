<p align="center">
  <img src="docs/images/logo.png" alt="simple_montecarlo logo" width="200">
</p>

<h1 align="center">simple_montecarlo</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_montecarlo/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_montecarlo">GitHub</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Eiffel-25.02-purple.svg" alt="Eiffel 25.02">
  <img src="https://img.shields.io/badge/DBC-Contracts-green.svg" alt="Design by Contract">
</p>

Type-safe Monte Carlo simulation framework for Eiffel engineers.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 25 tests passing, 100% pass rate
- Type-safe measurements, flexible trial logic, comprehensive statistics
- Design by Contract throughout

## Overview

**simple_montecarlo** is a production-ready Monte Carlo simulation framework for Eiffel that makes stochastic experiments accessible to engineers without deep statistical expertise.

It offers **type-safe measurements**, **flexible trial logic**, and **comprehensive statistics** including mean, standard deviation, and confidence intervals.

## Quick Start

```eiffel
local
    l_exp: MONTE_CARLO_EXPERIMENT
    l_stats: SIMULATION_STATISTICS
do
    create l_exp.make (1000)
    l_exp.set_trial_logic (agent trial_logic)
    l_exp.run_simulation
    l_stats := l_exp.statistics

    print ("Mean: " + l_stats.mean.out + "%N")
    print ("95% CI: [" + l_stats.ci_95.first.out + ", "
           + l_stats.ci_95.second.out + "]%N")
end
```

## Features

- **Type-Safe Measurements** - Prevent confusion between values and probabilities
- **Flexible Trial Logic** - Define trial behavior via agents (closures)
- **Outcome Collection** - Gather results from each trial automatically
- **Statistics Aggregation** - Compute mean, std_dev, min/max, CIs automatically
- **Design by Contract** - Full preconditions, postconditions, invariants
- **Void-Safe** - void_safety="all" prevents null pointer errors
- **SCOOP Compatible** - Ready for concurrent execution (future)

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```
SIMPLE_EIFFEL=D:\prod
```

2. Add to ECF:
```xml
<library name="simple_montecarlo" location="$SIMPLE_EIFFEL/simple_montecarlo/simple_montecarlo.ecf"/>
```

## License

MIT License - see [LICENSE](LICENSE) file.

---

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.
