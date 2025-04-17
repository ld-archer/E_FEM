# Workflow

The E_FEM can be split into 3 phases: data preparation, simulation, and post-processing. The following sections will provide a brief overview of each, with much more detail in the specific pages for each phase.

## Data Preparation

The data preparation phase consists of a number of scripts written in Stata. The goal in this phase is to harmonise the raw data files from the gateway to global ageing data repository using a script they provide, wrangle the data into a format that the simualtion engine can use, and to estimate statistical models to manage the transitions in the simulation. See the Data Preparation page for more details including links to data and scripts. Data preparation covers a number of processes that run via scripts in all corners of the repository, but the vast majority of these scripts are kept in `FEM_Stata/Makedata/ELSA/`.

## Simulation

The simulation phase directly follows the data preparation phase, and perhaps not too surprisingly is where we run the simulation for the individuals in the prepared dataset. The simulation phase consists of a number of scripts written in C++. This phase is complicated, diverse, and difficult to debug (for a non-C++ coder like me)...

In the directory named `FEM_CPP/`, you will find all the C++ files that run the simulation. Some notable scripts are Vars, HealthModule, the various Intervention modules (see Intervention docs page), and various Regression modules if you want to see how the transition modules function.

## Post-Processing

Post-processing has generally been done by myself in a more bespoke fashion than the previous 2 phases. More often than not, I have taken the output data produced by the simulation (in the form of .csv files) and loaded them into R in order to run further analyses or produce visualisations. I will go into more detail about some of the scripts I have created in this section.
