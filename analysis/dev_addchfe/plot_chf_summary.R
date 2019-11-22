library(foreign)
library(ggplot2)

# image parameters (units=inches)
img.height = 8
img.width = 8
img.res = 200

chf = read.dta("chf_summary.dta")
chf.allage = chf[is.na(chf$agegrp),]
chf.byage = chf[!is.na(chf$agegrp),]

title = "Prevalence of any heart disease (ages 50+)"
pl = qplot(year, hearte, color=Source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.1,0.4), main=title, data=chf.allage) + theme(legend.position="right")  +  scale_colour_discrete(name = "Source")
ggsave(filename="hearte_allage.pdf", plot=pl, width=img.width, height=img.height, units="in")	
print(pl)

title = "Prevalence of any heart disease by age"
pl = qplot(year, hearte, color=Source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.075,0.675), main=title, facets=Age ~ ., data=chf.byage) + theme(legend.position="right")  +  scale_colour_discrete(name = "Source")
ggsave(filename="hearte_byage.pdf", plot=pl, width=img.width, height=img.height, units="in")	
print(pl)

title = "Prevalence of CHF (ages 50+)"
pl = qplot(year, chfe, color=Source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.0,0.2), main=title, data=chf.allage) + theme(legend.position="right")  +  scale_colour_discrete(name = "Source")
ggsave(filename="chfe_allage.pdf", plot=pl, width=img.width, height=img.height, units="in")	
print(pl)

title = "Prevalence of CHF by age"
pl = qplot(year, chfe, color=Source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.0,0.4), main=title, facets=Age ~ ., data=chf.byage) + theme(legend.position="right")  +  scale_colour_discrete(name = "Source")
ggsave(filename="chfe_byage.pdf", plot=pl, width=img.width, height=img.height, units="in")	
print(pl)

title = "Prevalence of CHF among any heart disease (ages 50+)"
pl = qplot(year, chfe_hearte, color=Source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.1,0.5), main=title, data=chf.allage) + theme(legend.position="right")  +  scale_colour_discrete(name = "Source")
ggsave(filename="chfe_hearte_allage.pdf", plot=pl, width=img.width, height=img.height, units="in")	
print(pl)

title = "Prevalence of CHF among any heart disease by age"
pl = qplot(year, chfe_hearte, color=Source, geom="Line", xlab="Year", ylab="Prevalence", ylim=c(0.1,0.6), main=title, facets=Age ~ ., data=chf.byage) + theme(legend.position="right")  +  scale_colour_discrete(name = "Source")
ggsave(filename="chfe_hearte_byage.pdf", plot=pl, width=img.width, height=img.height, units="in")	
print(pl)

