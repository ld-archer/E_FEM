import os

x_max = int(os.environ["MAXBREP"])

x = 1
while (x <= x_max):
	if not os.path.isdir(str(os.environ["INPUT"]) + "/input_rep" + str(x)):
		os.makedirs(str(os.environ["INPUT"]) + "/input_rep" + str(x))

	if not os.path.isdir(str(os.environ["STER"]) + "/models_rep" + str(x)):
		os.makedirs(str(os.environ["STER"]) + "/models_rep" + str(x))

	if not os.path.isdir(str(os.environ["STER"]) + "/models_rep" + str(x) + "/crossvalidation"):
		os.makedirs(str(os.environ["STER"]) + "/models_rep" + str(x) + "/crossvalidation")

	if not os.path.isdir(str(os.environ["EST"]) + "/models_rep" + str(x)):
		os.makedirs(str(os.environ["EST"]) + "/models_rep" + str(x))

	x += 1

with open("bootstrap_directories.txt","w") as file:
	file.write("Bootstrap directories created")
