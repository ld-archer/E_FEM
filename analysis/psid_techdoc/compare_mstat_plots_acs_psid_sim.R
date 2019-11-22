# This file creates plots and corresponding data in .csv files for comparing marital status 
# in ACS, the PSID data used for transition model estimation, and the early years of the
# FAM simulation

library(ggplot2)
library(gridExtra)
library(gtable)

# image parameters (units=inches)
img.height = 8
img.width = 8
img.res = 200

fname = "marriage_results_combined.Rdata"
print(fname)
load(file=fname) 
ls()

df.name = "marriage_results_combined"

vars.inc = c("married","widowed","cohab","single")

##### Incidence (proportion) by age and sex
ymax.inc.p = c(0.21, 0.075, 0.075, 0.09)
for(i in 1:length(vars.inc)) {
	yvar = paste("i",vars.inc[i],sep="")
	ymax = ymax.inc.p[i]
	title = paste("Incidence of",vars.inc[i],"(proportion)")
	print(paste("Creating plot:",title))
	pl = qplot(year, eval(parse(text=yvar)), color=source, geom="Line", xlab="Year", ylab="Incidence", ylim=c(0.0,ymax), main=title, data=eval(parse(text=df.name))) + theme(legend.position="top") +  scale_colour_discrete(name = "Source") + facet_grid(Age ~ Sex)
	ggsave(filename=paste(yvar,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
	print(pl)
}

##### Incidence (count) by age and sex
ymax.inc.t = c(2.36, 1.42, 1.38, 1.1)
for(i in 1:length(vars.inc)) {
	yvar = paste("t_i",vars.inc[i],sep="")
	ymax = ymax.inc.t[i]
	title = paste("Incidence of",vars.inc[i],"(count)")
	print(paste("Creating plot:",title))
	pl = qplot(year, eval(parse(text=paste(yvar))), color=source, geom="Line", xlab="Year", ylab="Incidence (millions)", ylim=c(0.0,ymax), main=title, data=eval(parse(text=df.name))) + theme(legend.position="top") +  scale_colour_discrete(name = "Source") + facet_grid(Age ~ Sex)
	ggsave(filename=paste(yvar,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
	print(pl)
}

vars.prev = c("married","widowed","cohab","single")

##### Prevalence (proportion) by age and sex
ymax.prev.p = c(0.82, 0.45, 0.25, 0.5)
for(i in 1:length(vars.prev)) {
	yvar = paste("p",vars.prev[i],sep="")
	ymax = ymax.prev.p[i]
	title = paste("Prevalence of",vars.prev[i],"(proportion)")
	print(paste("Creating plot:",title))
	pl = qplot(year, eval(parse(text=yvar)), color=source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.0,ymax), main=title, data=eval(parse(text=df.name))) + theme(legend.position="top") +  scale_colour_discrete(name = "Source") + facet_grid(Age ~ Sex)
	ggsave(filename=paste(yvar,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
	print(pl)
}

##### Prevalence (count) by age and sex
ymax.prev.t = c(21, 9.95, 5.78, 11.5)
for(i in 1:length(vars.prev)) {
	yvar = paste("t_",vars.prev[i],sep="")
	ymax = ymax.prev.t[i]
	title = paste("Prevalence of",vars.prev[i],"(count)")
	print(paste("Creating plot:",title))
	pl = qplot(year, eval(parse(text=yvar)), color=source, geom="Line", xlab="Year", ylab="Prevalence (millions)", ylim=c(0.0,ymax), main=title, data=eval(parse(text=df.name))) + theme(legend.position="top") +  scale_colour_discrete(name = "Source") + facet_grid(Age ~ Sex)
	ggsave(filename=paste(yvar,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
	print(pl)
}



