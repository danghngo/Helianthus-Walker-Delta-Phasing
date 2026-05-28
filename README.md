# Helianthus — 10,800-Satellite Constellation Modeling

Helianthus is a MATLAB-based satellite constellation modeling project focused on Walker-Delta phasing, orbital propagation, and collision-avoidance analysis for a large-scale elliptical LEO constellation.

The project simulates a 10,800-satellite architecture arranged across 30 orbital planes with 360 satellites per plane. The goal is to evaluate whether structured phasing can support safe deployment at extreme constellation scale, especially near high-density orbital regions such as apogee, where satellites move more slowly and close-approach risk increases.

---

## Project Summary

This project models a large-scale Walker-Delta-style satellite constellation and studies how phasing logic can reduce collision risk across orbital planes.

The Helianthus case study uses:

* 30 orbital planes
* 360 satellites per plane
* 10,800 total satellites
* Elliptical LEO orbit
* Perigee: 200 km
* Apogee: 2000 km
* Semi-major axis: 7,271 km
* Eccentricity: 0.1205
* Inclination: 53 degrees
* RAAN spacing: 12 degrees
* Walker phasing parameter: f = 4

The simulation analyzes node deconfliction, apogee-region clustering, and minimum inter-satellite separation across propagated satellite trajectories.

---

## Why It Matters

Large satellite constellations require careful orbital design to prevent close approaches and collision risk. Even when orbital planes are regularly spaced, satellites may still cluster in high-risk regions such as apogee, where orbital velocity is lower and density can increase.

Helianthus studies how structured phasing can help:

* stagger satellites across orbital planes
* prevent simultaneous node crossings
* identify high-risk orbital regions
* evaluate closest-approach behavior
* support scalable constellation design and safety analysis

This project demonstrates applied mathematical modeling, orbital simulation, collision-avoidance reasoning, and technical visualization in an aerospace context.

---

## Methods and Pipeline

The simulation workflow includes:

1. **Define constellation parameters**
   Set orbital planes, satellites per plane, inclination, RAAN spacing, eccentricity, perigee, apogee, and Walker phasing parameter.

2. **Generate phased initial satellite states**
   Apply Walker-Delta-style phase offsets to stagger satellites across orbital planes.

3. **Identify the high-risk apogee subset**
   Filter the top 10% of satellites closest to apogee, where orbital velocity is slowest and satellite density is highest.

4. **Propagate orbital trajectories**
   Track satellite positions over time using orbital geometry and anomaly propagation.

5. **Compute closest approaches**
   Evaluate pairwise Euclidean distances among the apogee-region subset.

6. **Analyze minimum-distance behavior**
   Identify critical close-approach cases and visualize separation statistics.

7. **Generate visualizations**
   Produce constellation diagrams, violin plots, and kernel density estimate plots to summarize separation behavior.

---

## Key Results

* Simulated a 10,800-satellite constellation across 30 orbital planes.
* Applied Walker-Delta phasing to temporally stagger node crossings.
* Identified the apogee region as the highest-density and highest-risk area.
* Filtered the top 10% near-apogee subset, corresponding to 1,080 satellites.
* Evaluated closest approaches across approximately 581,000 satellite pairs.
* Demonstrated that structured phasing can support collision-free large-scale deployment under the modeled assumptions.
* Produced KDE and violin visualizations to analyze minimum-separation behavior.

---

## Repository Structure

```text
Helianthus-Constellation-Modeling/
│
├── README.md
├── src/
│   ├── README.md
│   └── HelianthusFinally.m
│
├── figures/
│   ├── README.md
│   └── representative project figures
│
└── presentation/
    ├── README.md
    └── Helianthus project presentation
```

---

## Source Code

The main MATLAB script is located in:

```text
src/HelianthusFinally.m
```

This script contains the primary Helianthus simulation workflow, including constellation setup, Walker phasing logic, apogee-region filtering, trajectory propagation, closest-approach analysis, and visualization generation.

---

## Representative Figures

Representative figures are included in the `figures/` folder. These may include:

* Helianthus constellation visualization
* 8-orbit and 12-orbit violin plots
* 8-orbit and 12-orbit KDE plots
* separation-distance visualizations
* apogee-region analysis figures

---

## Presentation

The project presentation is included in the `presentation/` folder. It summarizes the Walker-Delta phasing concept, constellation setup, apogee risk analysis, visualizations, and main findings.

---

## How to Run

Open MATLAB and run:

```matlab
HelianthusFinally
```

The script is designed as a research simulation and visualization workflow. Depending on local MATLAB settings and available toolboxes, figure paths or plotting sections may need minor adjustment.

---

## Tools and Skills Demonstrated

* MATLAB
* Orbital mechanics
* Walker-Delta constellation design
* Satellite phasing
* Collision-avoidance analysis
* Pairwise distance computation
* Apogee-region filtering
* KDE and violin visualization
* Large-scale simulation
* Aerospace modeling and technical communication

---

## Public Sharing Note

This repository contains a sanitized academic/research version of the Helianthus constellation modeling project. It is intended to demonstrate the mathematical modeling, simulation workflow, and collision-avoidance analysis approach.

Any proprietary, sensitive, restricted, or non-public project materials have been excluded.

---

## Author

Dang H. Ngo
M.S., Computational Applied Mathematics
California State University, Fullerton
