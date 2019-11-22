# This file creates plots and corresponding data in .csv files for PSID marriage outcomes

library(ggplot2)
library(gridExtra)
library(gtable)

# set the starting year for plots here:
year.start = 2001

# image parameters (units=inches)
img.height = 8
img.width = 8
img.res = 200

# single line plot
plotline1 <- function(varsrc, varname, xlabel, ylabel, ymult, ymin, ymax, title) {
	df.src = eval(parse(text=varsrc))
	pl = qplot(df.src[,"year"], ymult*df.src[,varname], geom="Line", xlab=xlabel, ylab=ylabel, ylim=c(ymin,ymax), main=title)
	ggsave(filename=paste(varsrc,"_",varname,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
	write.csv(file=paste(varsrc,"_",varname,".csv",sep=""), df.src[c("year",varname)], row.names=FALSE)
	return(pl)
}

# line plot of different series from same source
plotline2 <- function(varsrc, xvar, yvars, ydescs, xlabel, ylabel, ymult, ymin, ymax, title) {
	# create individual data frames and append them together
	fprefix = paste(varsrc,paste(yvars, collapse="_"),sep="_")
	df.master = NULL
	for(i in 1:length(yvars)) {
		df.temp = eval(parse(text=varsrc))
		df.temp["series"] = rep(ydescs[i], nrow(df.temp))
		df.temp = df.temp[c(xvar, yvars[i], "series")]
		names(df.temp)[2] = "y"
		df.master = rbind(df.master, df.temp)
	}
	
	# create plot
	pl = qplot(df.master[,xvar], ymult*df.master[,"y"], color=df.master[,"series"], geom="Line", xlab=xlabel, ylab=ylabel, ylim=c(ymin,ymax), main=title) + theme(legend.position="top") +  scale_colour_discrete(name = "Outcome")
	ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
	write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
	return(pl)
}

# line plot of the same series from different sources
plotlines <- function(snames, sdescs, xvar, yvar, xlabel, ylabel, ymult, ymin, ymax, title) {
	# create individual data frames and append them together
	df.master = NULL
	for(i in 1:length(snames)) {
		df.temp = eval(parse(text=paste(snames[i], "_summary",sep="")))
		if(sum(names(df.temp) == yvar) == 0) {
			print(paste("Error: variable",yvar,"does not exist in",snames[i]))
		} else {
				df.temp["scenario"] = rep(sdescs[i], nrow(df.temp))
			df.master = rbind(df.master, df.temp[c(xvar, yvar, "scenario")])
		}
	}
	
	# create plot
	pl = qplot(df.master[,xvar], ymult*df.master[,yvar], color=df.master[,"scenario"], geom="Line", xlab=xlabel, ylab=ylabel, ylim=c(ymin,ymax), main=title) + theme(legend.position="top")  +  scale_colour_discrete(name = "")
	ggsave(filename=paste(yvar,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")	
	write.csv(file=paste(yvar,".csv",sep=""), df.master, row.names=FALSE)
	return(pl)
}

# append ggplot objects plotA and plotB with x-axes aligned and output to pdf file name given by pdfname
# pdf size is currently 8 x 8, but this should be made adjustable
# plotA x-axis ticks and labels are removed; legend is moved to top
# plotB aspect ratio is squished, legend and title are removed
append.ggplots.8x8pdf <- function(plotA, plotB, pdfname) {
	tA = ggplot_gtable(ggplot_build(
		plotA + labs(x=NULL) + theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(), legend.position="top", plot.margin=unit(c(1,1,-1.5,1), "cm"))
	))

	tB = ggplot_gtable(ggplot_build(
		plotB + theme(aspect.ratio=0.2, legend.position="none", plot.margin=unit(c(-1,1,1,1), "cm")) + labs(title="")
	))
	maxWidth = unit.pmax(tA$widths[2:3], tB$widths[2:3])
	tA$widths[2:3] = maxWidth
	tB$widths[2:3] = maxWidth

	print(paste("Writing appended plots to",pdfname))
	pdf(file=pdfname, height=8, width=8)
	grid.arrange(tA, tB, ncol=1)
	dev.off()
}

############################## Population Outcomes ##############################


### Prevalence of marriage, cohab, single, widowed, partner death
yvars = c("pmarried","pcohab","psingle","pwidowed","ppartdied")
ydescs = c("Marriage","Cohabitation","Single (not partner death)","Widowed","Partner died")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Marital Status")

### Prevalence of marriage, cohab, single, widowed, partner death by gender
yvars = c("pmarried_male","pmarried_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Marriage by Gender")

yvars = c("pcohab_male","pcohab_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Cohabitation by Gender")

yvars = c("psingle_male","psingle_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Single by Gender")

yvars = c("pwidowed_male","pwidowed_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Widowhood by Gender")

yvars = c("ppartdied_male","ppartdied_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Partner Death by Gender")



### Prevalence of marriage ever, single ever, widowed ever
yvars = c("peverm","peversep","pwidowev")
ydescs = c("Ever married","Ever separated","Ever widowed")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Prevalence", 1.0, 0.0, 1.0, "Prevalence of Marital Status")


### Incidence by age group
# create individual data frames and append them together
yvars = c("imarried","icohab","isingle","iwidowed","ipartdied")
ydescs = c("Marriage","Cohabitation","Single (not partner death)","Widowed","Partner died")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(i in 1:length(yvars)) {
	for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["series"] = rep(ydescs[i], nrow(df.temp))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, paste(yvars[i],agesfx,sep=""), "series", "group")]
		names(df.temp)[2] = "y"
		df.master = rbind(df.master, df.temp)
	}
}
#df.master
	
# create plot
pl = qplot(eval(parse(text=xvar)), y, color=series, geom="Line", xlab="Year", ylab="Incidence", ylim=c(0.0,0.25), main="Incidence of Marital Status by Age", data=df.master) + theme(legend.position="top") +  scale_colour_discrete(name = "Outcome") + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

### Incidence (count) of marriage, cohab, single, and death/widowhood by gender
psid_summary$died_lmarried_female = (psid_summary$start_pop_lmarried_female - psid_summary$end_pop_lmarried_female)*1e6
psid_summary$died_lmarried_male = (psid_summary$start_pop_lmarried_male - psid_summary$end_pop_lmarried_male)*1e6
psid_summary$singleratio = psid_summary$t_isingle_male / psid_summary$t_isingle_female
psid_summary$cohabratio = psid_summary$t_icohab_male / psid_summary$t_icohab_female
psid_summary$marriedratio = psid_summary$t_imarried_male / psid_summary$t_imarried_female


yvars = c("t_isingle_male","t_isingle_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Millions of people", 1e-6, 1.0, 4.0, "New singles (not partner death) by gender")

plotline1("psid_summary", "singleratio", "Year", "", 1.0, 0.75, 1.25, "Male/Female Ratio of New Singles (not partner death)")

### Total new singles by age group
# create individual data frames and append them together
yvars = c("t_isingle_male","t_isingle_female")
ydescs = c("Males","Females")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(i in 1:length(yvars)) {
	for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["series"] = rep(ydescs[i], nrow(df.temp))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, paste(yvars[i],agesfx,sep=""), "series", "group")]
		names(df.temp)[2] = "y"
		df.master = rbind(df.master, df.temp)
	}
}
#df.master

# create plot
pl = qplot(eval(parse(text=xvar)), y, color=series, geom="Line", xlab="Year", ylab="Millions of People", ylim=c(0,2.5), main="New Singles (not partner death) by Age", data=df.master) + theme(legend.position="top") +  scale_colour_discrete(name = "Outcome") + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

### Ratio of male-to-female new singles
# create individual data frames and append them together
yvars = c("r_isingle")
ydescs = c("Male/Female Ratio")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, "group")]
		df.temp$y = eval(parse(text=paste("psid_summary$t_isingle_male",agesfx,"/","psid_summary$t_isingle_female",agesfx,sep="")))
		df.master = rbind(df.master, df.temp)
}
#df.master

# create plot
pl = qplot(eval(parse(text=xvar)), y, geom="Line", xlab="Year", ylab="", ylim=c(0.4,1.6), main="Male/Female Ratio of New Singles (not partner death) by Age", data=df.master) + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

yvars = c("t_icohab_male","t_icohab_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Millions of people", 1e-6, 1.0, 4.0, "New cohabs by gender")

plotline1("psid_summary", "cohabratio", "Year", "", 1.0, 0.75, 1.25, "Male/Female Ratio of New Cohabs")

### Total new cohabs by age group
# create individual data frames and append them together
yvars = c("t_icohab_male","t_icohab_female")
ydescs = c("Males","Females")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(i in 1:length(yvars)) {
	for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["series"] = rep(ydescs[i], nrow(df.temp))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, paste(yvars[i],agesfx,sep=""), "series", "group")]
		names(df.temp)[2] = "y"
		df.master = rbind(df.master, df.temp)
	}
}
#df.master
	
# create plot
pl = qplot(eval(parse(text=xvar)), y, color=series, geom="Line", xlab="Year", ylab="Millions of People", ylim=c(0,3), main="New Cohabs by Age", data=df.master) + theme(legend.position="top") +  scale_colour_discrete(name = "Outcome") + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

### Ratio of male-to-female new cohabs
# create individual data frames and append them together
yvars = c("r_icohab")
ydescs = c("Male/Female Ratio")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, "group")]
		df.temp$y = eval(parse(text=paste("psid_summary$t_icohab_male",agesfx,"/","psid_summary$t_icohab_female",agesfx,sep="")))
		df.master = rbind(df.master, df.temp)
}
#df.master

# create plot
pl = qplot(eval(parse(text=xvar)), y, geom="Line", xlab="Year", ylab="", ylim=c(0.55,1.45), main="Male/Female Ratio of New Cohabs by Age", data=df.master) + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

yvars = c("t_imarried_male","t_imarried_female")
ydescs = c("Males","Females")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Millions of people", 1e-6, 3.0, 6.0, "New marriages by gender")

plotline1("psid_summary", "marriedratio", "Year", "", 1.0, 0.8, 1.2, "Male/Female Ratio of New Marriages")

### Total new marriages by age group
# create individual data frames and append them together
yvars = c("t_imarried_male","t_imarried_female")
ydescs = c("Males","Females")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(i in 1:length(yvars)) {
	for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["series"] = rep(ydescs[i], nrow(df.temp))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, paste(yvars[i],agesfx,sep=""), "series", "group")]
		names(df.temp)[2] = "y"
		df.master = rbind(df.master, df.temp)
	}
}
#df.master
	
# create plot
pl = qplot(eval(parse(text=xvar)), y, color=series, geom="Line", xlab="Year", ylab="Millions of People", ylim=c(0,3.5), main="New Marriages by Age", data=df.master) + theme(legend.position="top") +  scale_colour_discrete(name = "Outcome") + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

### Ratio of male-to-female new marriages
# create individual data frames and append them together
yvars = c("r_imarried")
ydescs = c("Male/Female Ratio")
xvar = "year"
agebins = c("2535","3545","4555","5565","65p")
varsrc = "psid_summary"
fprefix = paste(varsrc,paste(yvars, collapse="_"),paste(agebins, collapse="_"),sep="_")
df.master = NULL
for(agesfx in agebins) {
		df.temp = eval(parse(text=varsrc))
		df.temp["group"] = rep(agesfx, nrow(df.temp))
		df.temp = df.temp[c(xvar, "group")]
		df.temp$y = eval(parse(text=paste("psid_summary$t_imarried_male",agesfx,"/","psid_summary$t_imarried_female",agesfx,sep="")))
		df.master = rbind(df.master, df.temp)
}
#df.master

# create plot
pl = qplot(eval(parse(text=xvar)), y, geom="Line", xlab="Year", ylab="", ylim=c(-0.1,2.1), main="Male/Female Ratio of New Marriages by Age", data=df.master) + facet_wrap(~ group, ncol=1)
ggsave(filename=paste(fprefix,".pdf",sep=""), plot=pl, width=img.width, height=img.height, units="in")
write.csv(file=paste(fprefix,".csv",sep=""), df.master, row.names=FALSE)
pl

yvars = c("t_iwidowed_male","died_lmarried_female")
ydescs = c("Male widowhood","Married female mortality")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Millions of people", 1e-6, 0.0, 3.0, "Widowhood for males")

yvars = c("died_lmarried_male","t_iwidowed_female")
ydescs = c("Married male mortality","Female widowhood")
plotline2("psid_summary", "year", yvars, ydescs, "Year", "Millions of people", 1e-6, 1.0, 4.0, "Widowhood for females")




#### stuff from another project for example
#### Prevalence of cancer under different scenarios
#plotlines(sname, sdesc, xvar="year", yvar="pcancre", "Year", "Prevalence (%)", ymult=100.0, 0, 25, "Prevalence of Cancer")
#
#### Cancer population size under different scenarios
#plotlines(sname, sdesc, xvar="year", yvar="tcancre", "Year", "Population size (millions)", ymult=1.0, 0, 35, "Cancer Population Size")
#
#### Age 65+ cancer population size under different scenarios
#plotlines(sname, sdesc, xvar="year", yvar="tcancre65p", "Year", "Population size (millions)", ymult=1.0, 0, 35, "Age 65+ Cancer Population Size")
#
#### Average age of Cancer population under different scenarios
#pl.age_cancre = plotlines(sname, sdesc, xvar="year", yvar="avg_age_cancre", "Year", "Age (years)", ymult=1.0, 70, 82.5, "Average Age of Cancer Patients")
#
#### Average age of age 65+ cancer population under different scenarios
#pl.age_cancre65p = plotlines(sname, sdesc, xvar="year", yvar="avg_age_cancre65p", "Year", "Age (years)", ymult=1.0, 70, 82.5, "Average Age of Cancer Patients Age 65+")
#
#### Cancer population recieving treatment under different scenarios
#plotlines(sname[-1], sdesc[-1], xvar="year", yvar="tcancre_trtmt", "Year", "Population size (millions)", ymult=1.0, 0, 27, "Cancer Population Receiving Treatment")
#
#### Age 65+ cancer population recieving treatment under different scenarios
#plotlines(sname[-1], sdesc[-1], xvar="year", yvar="tcancre_trtmt65p", "Year", "Population size (millions)", ymult=1.0, 0, 27, "Age 65+ Cancer Population Receiving Treatment")
#
#
############################### Cost Outcomes ##############################
#
#### Total medical costs for new cancer patients (designer drug scenario vs. status quo)
##srcs = c(rep("desdrug_summary",2), "nodesdrug_summary")
##yvars = c("new_totmd_mcbs_trtmt", "new_totmd_mcbs_notrtmt", "new_totmd_mcbs_notrtmt")
##descs = c("Treated", "Not Treated", "No Treatment (status quo)")
##maint = "Total Medical Costs for New Cancer Patients\nDesigner Drug Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Billions of Dollars (2009)", ymult=1e-9, ymin=0, ymax=1.5e3, title=maint, outname="desdrug_totcost")
#
#### Total medical costs for final phase cancer patients (PC magic pill scenario vs. status quo)
##srcs = c("pcmagicpill_summary", "nodesdrug_summary")
##yvars = c("new_totmd_mcbs_trtmt", "new_totmd_mcbs_died_cancre")
##descs = c("Treated", "No Treatment (status quo)")
##maint = "Total Medical Costs for Final Phase Cancer Patients\nPC Magic Pill Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Billions of Dollars (2009)", ymult=1e-9, ymin=0, ymax=1.5e3, title=maint, outname="pcmagic_totcost")
#
#### Total medical costs for new cancer patients 65+ (designer drug scenario vs. status quo)
##srcs = c(rep("desdrug_summary",2), "nodesdrug_summary")
##yvars = c("new_totmd_mcbs_trtmt65p", "new_totmd_mcbs_notrtmt65p", "new_totmd_mcbs_notrtmt65p")
##descs = c("Treated", "Not Treated", "No Treatment (status quo)")
##maint = "Total Medical Costs for New Cancer Patients Age 65+\nDesigner Drug Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Billions of Dollars (2009)", ymult=1e-9, ymin=0, ymax=1.5e3, title=maint, outname="desdrug_totcost65p")
#
#### Total medical costs for final phase cancer patients 65+ (PC magic pill scenario vs. status quo)
##srcs = c("pcmagicpill_summary", "nodesdrug_summary")
##yvars = c("new_totmd_mcbs_trtmt65p", "new_totmd_mcbs_died_cancre65p")
##descs = c("Treated", "No Treatment (status quo)")
##maint = "Total Medical Costs for Final Phase Cancer Patients Age 65+\nPC Magic Pill Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Billions of Dollars (2009)", ymult=1e-9, ymin=0, ymax=1.5e3, title=maint, outname="pcmagic_totcost65p")
#
#### Average medical costs for new cancer patients (designer drug scenario vs. status quo)
##srcs = c("desdrug_summary","nodesdrug_summary")
##yvars = c("avgmd_mcbs_trtmt", "avgmd_mcbs_notrtmt")
##descs = c("Treated", "Not Treated/No Treatment (status quo)")
##maint = "Average Medical Costs for New Cancer Patients\nDesigner Drug Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Dollars (2009)", ymult=1.0, ymin=0, ymax=1.25e6, title=maint, outname="desdrug_avgcost")
#
#### Average medical costs for final phase cancer patients (PC magic pill scenario vs. status quo)
##srcs = c("pcmagicpill_summary", "nodesdrug_summary")
##yvars = c("avgmd_mcbs_trtmt", "avgmd_mcbs_died_cancre")
##descs = c("Treated", "No Treatment (status quo)")
##maint = "Average Medical Costs for Final Phase Cancer Patients\nPC Magic Pill Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Dollars (2009)", ymult=1.0, ymin=0, ymax=1.25e6, title=maint, outname="pcmagic_avgcost")
#
#### Average medical costs for new cancer patients 65+ (designer drug scenario vs. status quo)
##srcs = c("desdrug_summary","nodesdrug_summary")
##yvars = c("avgmd_mcbs_trtmt65p", "avgmd_mcbs_notrtmt65p")
##descs = c("Treated", "Not Treated/No Treatment (status quo)")
##maint = "Average Medical Costs for New Cancer Patients Age 65+\nDesigner Drug Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Dollars (2009)", ymult=1.0, ymin=0, ymax=1.25e6, title=maint, outname="desdrug_avgcost65p")
#
#### Average medical costs for final phase cancer patients 65+ (PC magic pill scenario vs. status quo)
##srcs = c("pcmagicpill_summary", "nodesdrug_summary")
##yvars = c("avgmd_mcbs_trtmt65p", "avgmd_mcbs_died_cancre65p")
##descs = c("Treated", "No Treatment (status quo)")
##maint = "Average Medical Costs for Final Phase Cancer Patients Age 65+\nPC Magic Pill Scenario"
##plotmultiline(srcs, descs, "year", yvars, "Year", ylabel="Dollars (2009)", ymult=1.0, ymin=0, ymax=1.25e6, title=maint, outname="pcmagic_avgcost65p")
#
#### Total medical costs in cancer population
#plotlines(sname, sdesc, xvar="year", yvar="new_totmd_mcbs_cancre", "Year", ylabel="Billions of Dollars (2009)", ymult=1e-9, ymin=0, ymax=5e3, "Total Medical Costs in Cancer Population")
#
#### Total medical costs in cancer population age 65+
#plotlines(sname, sdesc, xvar="year", yvar="new_totmd_mcbs_cancre65p", "Year", ylabel="Billions of Dollars (2009)", ymult=1e-9, ymin=0, ymax=5e3, "Total Medical Costs in Cancer Population Age 65+")
#
#### Average medical costs in cancer population
#plotlines(sname, sdesc, xvar="year", yvar="avgmd_mcbs_cancre", "Year", ylabel="Dollars (2009)", ymult=1.0, ymin=0, ymax=1.8e5, "Average Medical Costs in Cancer Population")
#
#### Average medical costs in cancer population age 65+
#plotlines(sname, sdesc, xvar="year", yvar="avgmd_mcbs_cancre65p", "Year", ylabel="Dollars (2009)", ymult=1.0, ymin=0, ymax=1.8e5, "Average Medical Costs in Cancer Population Age 65+")
#
############################### QoL Outcomes ##############################
#### Average degree of pain among cancer patients who experience pain
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="avgcdegpain_cancre_pain", "Year", "Pain Score", ymult=1.0, 0, 3, "Average Degree of Pain in Cancer Population Experiencing Pain")
#append.ggplots.8x8pdf(pl1, pl.age_cancre +  ylab("Mean Age"), pdfname="avgcdegpain_cancre_pain_age.pdf")
#
#### Average degree of pain among cancer patients who experience pain 65+
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="avgcdegpain_cancre_pain65p", "Year", "Pain Score", ymult=1.0, 0, 3, "Average Degree of Pain in Cancer Population Experiencing Pain Age 65+")
#append.ggplots.8x8pdf(pl1, pl.age_cancre65p +  ylab("Mean Age"), pdfname="avgcdegpain_cancre_pain65p_age.pdf")
#
#### Prevalence of clinically significant pain in cancer patients
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="pcdegreepain2p_cancre", "Year", "Prevalence (%)", ymult=100, 0, 35, "Prevalence of Clinically Significant Pain in Cancer Patients")
#append.ggplots.8x8pdf(pl1, pl.age_cancre +  ylab("Mean Age"), pdfname="pcdegreepain2p_cancre_age.pdf")
#
#### Prevalence of clinically significant pain in cancer patients age 65+
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="pcdegreepain2p_cancre65p", "Year", "Prevalence (%)", ymult=100, 0, 35, "Prevalence of Clinically Significant Pain in Cancer Patients Age 65+")
#append.ggplots.8x8pdf(pl1, pl.age_cancre65p +  ylab("Mean Age"), pdfname="pcdegreepain2p_cancre65p_age.pdf")
#
#### Prevalence of 2+ ADL difficulties in Cancer Patients
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="padl2p_cancre", "Year", "Prevalence (%)", ymult=100, 0, 25, "Prevalence of 2+ ADL Difficulties in Cancer Patients")
#append.ggplots.8x8pdf(pl1, pl.age_cancre +  ylab("Mean Age"), pdfname="padl2p_cancre_age.pdf")
#
#### Prevalence of 2+ ADL difficulties in Cancer Patients age 65+
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="padl2p_cancre65p", "Year", "Prevalence (%)", ymult=100, 0, 25, "Prevalence of 2+ ADL Difficulties in Cancer Patients Age 65+")
#append.ggplots.8x8pdf(pl1, pl.age_cancre65p +  ylab("Mean Age"), pdfname="padl2p_cancre65p_age.pdf")
#
#### Prevalence of 2+ IADL difficulties in Cancer Patients
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="piadl2p_cancre", "Year", "Prevalence (%)", ymult=100, 0, 12, "Prevalence of 2+ IADL Difficulties in Cancer Patients")
#append.ggplots.8x8pdf(pl1, pl.age_cancre +  ylab("Mean Age"), pdfname="piadl2p_cancre_age.pdf")
#
#### Prevalence of 2+ IADL difficulties in Cancer Patients age 65+
#pl1 = plotlines(sname, sdesc, xvar="year", yvar="piadl2p_cancre65p", "Year", "Prevalence (%)", ymult=100, 0, 12, "Prevalence of 2+ IADL Difficulties in Cancer Patients Age 65+")
#append.ggplots.8x8pdf(pl1, pl.age_cancre65p +  ylab("Mean Age"), pdfname="piadl2p_cancre65p_age.pdf")
#


######### create dummy file to tell make when script finished #########
cat(file="dummy_plots.txt","This is a dummy file for R plots in the make process")
#######################################################################