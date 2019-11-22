library(survival)
library(xlsx)

source(file="ggkm.R")
source(file="ggkm_nostrat.R")

# list of disease condition variables that have been switched off
condlist = c("cancre", "diabe", "hearte", "hibpe", "lunge", "stroke")
# human-readable description of disease conditions 
conddesc = c("cancer", "diabetes", "heart disease", "hypertension", "lung disease", "stroke")

xlabel1 = "Years after disease incidence (after age 51-52 if no disease)"
xlabel2 = "Years after disease incidence"
tstep = 10
max.x = 77

pdf(file="/dev/null")
pdf(file="disease_survival_plots.pdf")

# create a blank workbook
outwb = createWorkbook()

for(i in 1:length(condlist)) {
	cond = condlist[i]
	name = paste("no_",cond,"_survival",sep="")
	load(file=paste(name,".Rdata",sep=""))

	df1.tmp = eval(parse(text=name))
	s1.tmp = survfit(Surv(time=survtime) ~ strata(eval(parse(text=cond))), data=df1.tmp, weights=initwt)
	print(s1.tmp)
	stratalab1 = c(paste("no",conddesc[i]), paste(conddesc[i]))
	# basic plot, stratified by presenece disease condition
	dev.set(dev.prev())
	pl = ggkm(s1.tmp, ystrataname="After age 51-52: ", returns=TRUE, timeby=tstep, main=paste("Survival for scenario of no",conddesc[i],"by age 51-52"),xlabs=xlabel1,ylabs="Survival probability",ystratalabs=stratalab1,pval=FALSE)
	# adjust legend position and other details
	times = seq(0, max.x, by=tstep)
	dev.set(dev.next())
	print(pl + 
		theme(legend.position = "top") + 
		scale_x_continuous(xlabel1, breaks = times, limits = c(0, max.x))
	)
	
	sheet1 = createSheet(outwb, sheetName=conddesc[i])
	risk.data1 = data.frame(time = s1.tmp$time, n.risk = s1.tmp$n.risk,
    n.event = s1.tmp$n.event, surv = s1.tmp$surv, strata = summary(s1.tmp, censored = T)$strata)
	levels(risk.data1$strata) <- stratalab1
  addDataFrame(risk.data1, sheet1, row.names=FALSE)
        
	# now, create survival curves for people who got the disease, but stratify by age of incidence = 50, 65, 80
	df2.tmp = df1.tmp[eval(parse(text=paste("df1.tmp$",cond)))==1,]
	df2.tmp = df2.tmp[(df2.tmp$inc_year==2012)|(df2.tmp$inc_year==2024)|(df2.tmp$inc_year==2038),]
	s2.tmp = survfit(Surv(time=survtime) ~ strata(factor(inc_year)), data=df2.tmp, weights=initwt)
	print(s2.tmp)
	stratalab2 = c("Age 53-54", "Age 65-66", "Age 79-80")
	dev.set(dev.prev())
	pl = ggkm(s2.tmp, ystrataname="Age of incidence: ", returns=TRUE, timeby=tstep, main=paste("Survival for no",conddesc[i],"scenario by age of incidence"), xlabs=xlabel2,ylabs="Survival probability",ystratalabs=stratalab2,pval=FALSE)
	# adjust legend position and other details
	times = seq(0, max.x, by=tstep)
	dev.set(dev.next())
	print(pl + 
		theme(legend.position = "top") + 
		scale_x_continuous(xlabel2, breaks = times, limits = c(0, max.x))
	)
	
	sheet2 = createSheet(outwb, sheetName=paste(conddesc[i],"by age"))
	risk.data2 = data.frame(time = s2.tmp$time, n.risk = s2.tmp$n.risk,
    n.event = s2.tmp$n.event, surv = s2.tmp$surv, strata = summary(s2.tmp, censored = T)$strata)
	levels(risk.data2$strata) <- stratalab2
  addDataFrame(risk.data2, sheet2, row.names=FALSE)

	
}

### plots for the no change (status quo) scenario
print("Creating status quo plots")
cond = "change"
name = paste("no_",cond,"_survival",sep="")
load(file=paste(name,".Rdata",sep=""))

df1.tmp = eval(parse(text=name))
s1.tmp = survfit(Surv(time=df1.tmp$survtime) ~ 1, data=df1.tmp, weights=initwt)
print(s1.tmp)
dev.set(dev.prev())
pl = ggkm.nostrat(s1.tmp, returns=TRUE, timeby=tstep, main=paste("Survival for status quo scenario"),xlabs=xlabel1,ylabs="Survival probability",pval=FALSE)
# adjust legend position and other details
times = seq(0, max.x, by=tstep)
dev.set(dev.next())
print(pl + 
	theme(legend.position = "top") + 
	scale_x_continuous("Year after age 51-52", breaks = times, limits = c(0, max.x))
)
	
sheet1 = createSheet(outwb, sheetName="status quo")
risk.data1 = data.frame(time = s1.tmp$time, n.risk = s1.tmp$n.risk,
   n.event = s1.tmp$n.event, surv = s1.tmp$surv)
addDataFrame(risk.data1, sheet1, row.names=FALSE)

dev.off()
warnings()

saveWorkbook(outwb, "disease_survival_estimates.xlsx")


