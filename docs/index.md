# Welcome to the English Future Elderly Model Documentation

See [the project github page](https://github.com/ld-archer/E_FEM) for more information and to access the code.

## About

The English Future Elderly Model (E-FEM) is a Microsimulation model adapted from the US-FEM in collaboration with researchers from the RAND corporation and the USC Leonard D. Schaeffer Institute for Public Policy & Government Service. The US-FEM is an economic-demographic microsimulation developed over the last decade.

## What is the English Future Elderly Model (E_FEM)?

The E-FEM is a dynamic microsimulation model created to test policy interventions on the economic and health outcomes of the population aged 50+ in England.

The primary data source for the E-FEM is the English Longitudinal Study of Ageing (ELSA), which is a longitudinal multidisciplinary study on a representative sample of the English population aged 50+, looking at all aspects of ageing in England. The study started in 2002 and so far has produced 9 waves of completed data, with a 10th currently being collected. The first wave of ELSA had a sample of 11,050 respondents aged 50+, and has refreshed the sample regularly since then (refreshed sample on waves 3, 4, 6, 7, and 9.) ELSA was designed to mimic the primary data source of the US-FEM (the US Health and Retirement Study (US-HRS)), which meant adapting the US-FEM to ELSA was possible with relatively little effort. The reliance on a single dataset in the E-­FEM is in contrast to many other microsimulation models, where often multiple sources of input data are required.

## Getting started

Requirements for getting the English FEM started are fairly complicated. The key reqs are listed in the table below:

| Requirement | Version | Notes |
| ----------- | ------- | ----- |
| GCC         |         | Verified working on Ubuntu 11.4.0-1ubuntu1~22.04, version should not be too important here compared to  |
| OpenMPI     | 1.10    | Exact version requirement,  newer versions of OpenMPI will not work.      |
| Stata       | SE or better |       |

The data required is [the English Longitudinal Study of Ageing](https://beta.ukdataservice.ac.uk/datacatalogue/studies/study?id=5050) available at this link from the UK Data Service. This data should be downloaded and held in a folder named ELSA above the top level of the project directory. By this I mean:

```
ELSA/
|    UKDA-5050-stata/
|        stata/
|            stata13_se/
|                {DATA_FILES}

E_FEM/
|    {PROJECT_FILES}
```

Once the requirements have been installed, the data has been downloaded, and the project repository has been cloned from the github repo, we can make the final preparations before running the model. NOTE: These processes (and pretty much everything else in the E_FEM) rely heavily on the use of Makefiles. I'm not sure if the software required to run make commands is present by default in most Linux distributions, but if not you will need to install it.

`make stata_extensions.txt`: Install stata extensions (some custom tools most often written by the Americans for some FEM specific processes).

`make FEM`: Compile the C++ files that the FEM is built on to generate the executable.

`make ELSA`: Run the harmonisation script provided by the [Gateway to Global Ageing](https://g2aging.org/). This will combine all the disparate data files into one, ensuring things such as unique and persistent ID values across waves, consistent naming conventions for variables etc.
