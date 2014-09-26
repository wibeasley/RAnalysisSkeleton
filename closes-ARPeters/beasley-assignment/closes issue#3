#The following code is meant to provide the z-scores for the collection of sleep statistics within
# each feeding scenario.

sleepstats<-as.numeric(ds[,8])
sleepstats.scenario1<-sleepstats[1:45]
sleepstats.scenario2<-sleepstats[46:90]
sleepstats.scenario3<-sleepstats[91:135]


sleepZscenario1<-as.numeric(scale(sleepstats.scenario1))
sleepZscenario2<-as.numeric(scale(sleepstats.scenario2))
sleepZscenario3<-as.numeric(scale(sleepstats.scenario3))

#This section combines the three vectors into one, and adds it on to the end of the ds.
sleepZintrascenario<-c(sleepZscenario1, sleepZscenario2, sleepZscenario3)
ds<-c(ds, sleepZintrascenario)

#==========================================

#I am making the judgement call that all subjects who's intra-scenario sleep z-scores are less than -1.5
#  are to be ommitted from further study, so they can get some sleep. 
#  The following code identifies and removes sleep values of ommitted subjects.

sdev.scenario1<-sd(sleepstats.scenario1)
sdev.scenario2<-sd(sleepstats.scenario2)
sdev.scenario3<-sd(sleepstats.scenario3)

sleepstat.scenario1.cutoff<-mean(sleepstats.scenario1-(1.5*sdev.scenario1))
sleepstat.scenario2.cutoff<-mean(sleepstats.scenario2-(1.5*sdev.scenario2))
sleepstat.scenario3.cutoff<-mean(sleepstats.scenario3-(1.5*sdev.scenario3))

sleepstat.scenario1.censored<-ifelse(sleepstats.scenario1<sleepstat.scenario1.cutoff, NA, sleepstats.scenario1)
sleepstat.scenario2.censored<-ifelse(sleepstats.scenario2<sleepstat.scenario2.cutoff, NA, sleepstats.scenario2)
sleepstat.scenario3.censored<-ifelse(sleepstats.scenario3<sleepstat.scenario3.cutoff, NA, sleepstats.scenario3)

#The following line of code combines the three vectors of modifed sleep scores and combines them into a single
#  vector. This vector can then be printed, column-bound to the data-set, or be used to replace the unmodifed sleep
#  scores.

sleepstats.censored<-c(sleepstat.scenario1.censored, sleepstat.scenario2.censored, sleepstat.scenario3.censored)

#==========================================

#After having censored certain subjects, the following code will creat a vector of
#  z-scores calculated using the censored sleep stats. Alternatively, one could use the scaling code from above,
#  assuming the vector of censored sleep statistics has replaced the uncensored column of sleep statistics. 

sleepZscenario1.corrected<-as.numeric(scale(sleepstat.censored[1:45]))
sleepZscenario2.corrected<-as.numeric(scale(sleepstats.censored[46:90]))
sleepZscenario3.corrected<-as.numeric(scale(sleepstats.censored[91:135]))
sleepZintrascenario.corrected<-c(sleepZscenario1.corrected, sleepZscenario2.corrected, sleepZscenario3.corrected)
