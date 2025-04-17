# Simulation

There are far too many files included in this section to list them all, but it would be useful to mention at least a few of them. I will come back to this at some point.

Some key scripts to mention though are:

## Vars.cpp/.h

Define every variable included in the simulation. If it isn't in these scripts, it will cause the model to fail. Also in here the lag map and probability map are defined. The lag map links the current and lagged values, and the probability map links variables with their associated probability variable (e.g. cancre is linked to pcancre, which is a variable that denotes the probability of getting cancer in the next wave).

## HealthModule

This script is complicated. The long and short of it (I think) is that this module includes a lot of logic to decide when to run specific transition models. For example, the smoke\_start model only runs when the simulation is running either psid or ELSA data, and the person did not smoke in the previous wave (l2smoken == 0). Also, this module includes a lot of the logical 'accounting' to ensure data always makes sense. i.e. if smoken == 1 (smokes now) then smokev must also == 1 (smoked ever).

## InterventionFactory

This module is where new interventions are created in a way that the model can access them. There is a list each for both Initial interventions and yearly interventions, and you can also register custom interventions that have been written as C++ files (see WeightLossPill.cpp for an example from the American model, or ReduceBMI.cpp from the English model).

## ELSA_vars.txt

This file is not a CPP file but should be mentioned alongside them (mostly as it doesn't fit in any other category)·

This file is found in FEM_CPP_Settings/, and is used alongside the Vars.cpp/.h script mentioned above. The purpose of this file is to define variables, but I think only when they are fully derived from other ELSA variables. For example, the 'disabled' variable is defined as:

`disabled = adl1 | adl2 | adl3 | iadl1 | iadl2p | nhmliv`

This means that the disabled variable is true (1) if any of the adl or iadl (or nhmliv) variables are true. The confusing thing about this file is that it follows no known syntax from any particular scheme, and instead a custom parser has been written in the C++ scripts to read and interpret this file. Something I do not fully understand right now is when to use the Vars.cpp/.h and when to use this file. I am also unsure as to whether variables defined in ELSA\_vars.txt should also be defined in the C++ files.
