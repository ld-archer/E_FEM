* This script handles replacing the missing values in key variables in ELSA with imputed values

* Remove impossible BMI values before merging
replace bmi2 = . if bmi2 < 10
replace bmi4 = . if bmi4 < 10
replace bmi6 = . if bmi6 < 10
replace bmi8 = . if bmi8 < 10


