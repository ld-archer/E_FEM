# Retrieve environment variables
local_root <- Sys.getenv("ROOT")


# Define paths based on local_root
local_path <- file.path(local_root, "FEM_Stata")
indata <- file.path(local_root, "base_data")
outdata <- file.path(local_root, "input_data")
output_dir <- file.path(local_root, "output")

# Optionally, set these as global options so they can be accessed easily across the project
options(local_path = local_path,
        indata = indata,
        outdata = outdata,
        output_dir = output_dir)

# To access later in the script, you can use:
# getOption("local_path")
# getOption("indata")
# getOption("outdata")
# getOption("output_dir")
