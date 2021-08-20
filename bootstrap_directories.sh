# Bash script to generate directories for bootstrapping the model

# needs a bootstrap number from Makefile to determine how many samples to run
MAXREP=$1

#echo $MAX

# Make sure the bootstrap directory already exists in FEM_CPP_settings and FEM_Stata/Estimates
mkdir -p ./FEM_CPP_settings/ELSA_core_bootstrap
mkdir -p ./FEM_Stata/Estimates/ELSA_core_bootstrap

i=1

while [ $i -le $MAXREP ]
do
    echo Brep: $i

    mkdir -p ./FEM_CPP_settings/ELSA_core_bootstrap/models_rep$i
    mkdir -p ./FEM_CPP_settings/ELSA_core_bootstrap/models_rep$i/crossvalidation

    mkdir -p ./FEM_Stata/Estimates/ELSA_core_bootstrap/models_rep$i

    ((i++))
done
