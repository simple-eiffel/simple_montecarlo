<p align="center">
  <svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <circle cx="100" cy="100" r="95" fill="#667eea" stroke="#fff" stroke-width="2"/>
    <text x="100" y="120" font-size="60" font-weight="bold" text-anchor="middle" fill="#fff">MC</text>
  </svg>
</p>

<h1 align="center">simple_montecarlo</h1>

<p align="center">
  <a href="https://simple-eiffel.github.io/simple_montecarlo/">Documentation</a> •
  <a href="https://github.com/simple-eiffel/simple_montecarlo">GitHub</a> •
  <a href="https://github.com/simple-eiffel/simple_montecarlo/issues">Issues</a>
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

For complete documentation, see [our docs site](https://simple-eiffel.github.io/simple_montecarlo/).

## Features

- Type-safe measurements (prevent confusion with probabilities)
- Flexible trial logic via agents (closures)
- Comprehensive statistics (mean, std_dev, min/max, confidence intervals)
- Design by Contract throughout
- Void-safe implementation
- SCOOP compatible

For detailed information, see the [User Guide](https://simple-eiffel.github.io/simple_montecarlo/user-guide.html).

## Installation

```bash
# Add to your ECF:
<library name="simple_montecarlo" location="$SIMPLE_EIFFEL/simple_montecarlo/simple_montecarlo.ecf"/>
```

## License

MIT License - See LICENSE file

## Support

- **Docs:** https://simple-eiffel.github.io/simple_montecarlo/
- **GitHub:** https://github.com/simple-eiffel/simple_montecarlo
- **Issues:** https://github.com/simple-eiffel/simple_montecarlo/issues
