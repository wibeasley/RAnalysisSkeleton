rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
#####################################
## @knitr LoadPackages
# require(xtable)
require(knitr)
require(plyr)
require(scales) #For formating values in graphs
require(RColorBrewer)
# require(reshape2) #For converting wide to long
require(ggplot2) #For graphing
# require(mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.
#####################################
## @knitr DeclareGlobals
options(show.signif.stars=F) #Turn off the annotations on p-values

pathInput <- "./DataPhiFree/Derived/MotorTrendCarTest.rds"

HistogramDiscrete <- function( 
  dsObserved, 
  variableName, 
  levelsToExclude = character(0), 
  mainTitle = variableName, 
  xTitle = NULL, 
  yTitle = "Number of Included Records", 
  textSizePercentage = 6,
  binWidth = 1L) {
  
  if( !base::is.factor(dsObserved[, variableName]) )
    dsObserved[, variableName] <- base::factor(dsObserved[, variableName])
  
  dsObserved$IV <- base::ordered(dsObserved[, variableName], levels=rev(levels(dsObserved[, variableName])))
  
  dsCount <- plyr::count(dsObserved, vars=c("IV"))
#   if( base::length(levelsToExclude)>0 ) {
  dsCount <- dsCount[!(dsCount$IV %in% levelsToExclude), ]
  
  dsSummary <- plyr::ddply(dsCount, .variables=NULL, transform, Count=freq, Proportion = freq/sum(freq) )
  dsSummary$Percentage <- base::paste0(base::round(dsSummary$Proportion*100), "%")
  
  yTitle <- base::paste0(yTitle, " (n=", scales::comma(base::sum(dsSummary$freq)), ")")
  
  g <- ggplot2::ggplot(dsSummary, ggplot2::aes_string(x="IV", y="Count", fill="IV", label="Percentage"))
  g <- g + ggplot2::geom_bar(stat="identity")
  g <- g + ggplot2::geom_text(stat="identity", size=textSizePercentage, hjust=.8)
  g <- g + ggplot2::scale_y_continuous(labels=scales::comma_format())
  g <- g + ggplot2::labs(title=mainTitle, x=xTitle, y=yTitle)
  g <- g + ggplot2::coord_flip()
  
  g <- g + ggplot2::theme_bw(base_size=14) 
  g <- g + ggplot2::theme(legend.position = "none") 
  g <- g + ggplot2::theme(axis.text.x=ggplot2::element_text(colour="gray40"))
  g <- g + ggplot2::theme(axis.title.x=ggplot2::element_text(colour="gray40"))
  g <- g + ggplot2::theme(axis.text.y=ggplot2::element_text(size=14))
  g <- g + ggplot2::theme(panel.border = ggplot2::element_rect(colour="gray80"))
  g <- g + ggplot2::theme(axis.ticks.length = grid::unit(0, "cm"))
  
  return( g )
}
HistogramContinuous <- function( 
  dsObserved, 
  variableName, 
  binWidth = NULL, 
  mainTitle = variableName, 
  xTitle = paste0(variableName, " (each bin is ", scales::comma(binWidth), " units wide)"), 
  yTitle = "Frequency",
  roundedDigits = 0L
  ) {
  
  dsObserved <- dsObserved[!base::is.na(dsObserved[, variableName]), ]
  
  ds_mid_points <- base::data.frame(label=c("italic(X)[50]", "bar(italic(X))"), stringsAsFactors=FALSE)  
  ds_mid_points$value <- c(stats::median(dsObserved[, variableName]), base::mean(dsObserved[, variableName]))
  ds_mid_points$value_rounded <- base::round(ds_mid_points$value, roundedDigits)
  
  g <- ggplot2::ggplot(dsObserved, ggplot2::aes_string(x=variableName)) 
  g <- g + ggplot2::geom_bar(stat="bin", binwidth=binWidth, fill="gray70", color="gray90", position=ggplot2::position_identity())
  g <- g + ggplot2::geom_vline(xintercept=ds_mid_points$value, color="gray30")
  g <- g + ggplot2::geom_text(data=ds_mid_points, ggplot2::aes_string(x="value", y=0, label="value_rounded"), color="tomato", hjust=c(1, 0), vjust=.5)
  g <- g + ggplot2::scale_x_continuous(labels=scales::comma_format())
  g <- g + ggplot2::scale_y_continuous(labels=scales::comma_format())
  g <- g + ggplot2::labs(title=mainTitle, x=xTitle, y=yTitle)
  g <- g + ggplot2::theme_bw()
  
  ds_mid_points$top <- stats::quantile(ggplot2::ggplot_build(g)$panel$ranges[[1]]$y.range, .8)
  g <- g + ggplot2::geom_text(data=ds_mid_points, ggplot2::aes_string(x="value", y="top", label="label"), color="tomato", hjust=c(1, 0), parse=TRUE)
  return( g )  
}

#####################################
## @knitr LoadData
# 'ds' stands for 'datasets'
ds <- readRDS(pathInput)

#####################################
## @knitr TweakData
# 
# dropInfantWeightForGestationalAgeCategorySgaOrMissing <- (is.na(ds$InfantWeightForGestationalAgeCategory) | ds$InfantWeightForGestationalAgeCategory=="Sga")
# cat("Number of patients excluded b/c Missing or `SGA` for InfantWeightForGestationalAgeCategory: ", sum(dropInfantWeightForGestationalAgeCategorySgaOrMissing, na.rm=T))
# ds <- ds[!dropInfantWeightForGestationalAgeCategorySgaOrMissing, ]
# ds$InfantWeightForGestationalAgeCategory <- droplevels(ds$InfantWeightForGestationalAgeCategory)
# 
# cat("Number of infants excluded b/c premature age: ", sum(ds$PrematureInfant, na.rm=T))
# ds <- ds[!ds$PrematureInfant, ]
# 
# #Define the palettes
# colorCenter <- RColorBrewer::brewer.pal(n=3, name="Pastel1")[2:1]
# names(colorCenter) <- levels(ds$Center)
# colorCenterLight <- adjustcolor(colorCenter, alpha.f=.5)
# 
# # Create a dataset containing only OUHSC patients
# dsOuhsc <- ds[ds$Center=="OUHSC", ]
# 
# #Remove variables no longer necessary
# rm(dropInfantWeightForGestationalAgeCategorySgaOrMissing)
# ds$PrematureInfant <- NULL

#####################################
## @knitr Marginals
# Inspect continuous variables
HistogramContinuous(dsObserved=ds, variableName="QuarterMileInSeconds", binWidth=.5, roundedDigits=1)
HistogramContinuous(dsObserved=ds, variableName="DisplacementInchesCubed", binWidth=50, roundedDigits=1)

# Inspect discrete/categorical variables
HistogramDiscrete(dsObserved=ds, variableName="CarburetorCountF")
HistogramDiscrete(dsObserved=ds, variableName="ForwardGearCountF")

#####################################
## @knitr Scatterplots
g1 <- ggplot(ds, aes(x=GrossHorsepower, y=QuarterMileInSeconds, color=ForwardGearCountF)) + 
  geom_smooth(method="loess") +
  geom_point(shape=1) +
  theme_bw()
g1

g1 %+% aes(color=CarburetorCountF)
g1 %+% aes(color=CylinderCount)
g1 %+% aes(color=factor(CylinderCount))

g1 %+% aes(x=MilesPerGallon)
g1 %+% aes(x=MilesPerGallon, color=CarburetorCountF)
g1 %+% aes(x=MilesPerGallon, color=factor(CylinderCount))

#####################################
## @knitr Models

cat("============= Simple model that's just an intercept. =============")
m0 <- lm(QuarterMileInSeconds ~ 1, data=ds)
summary(m0)

cat("============= Model includes one predictor. =============")
m1 <- lm(QuarterMileInSeconds ~ 1 + MilesPerGallon, data=ds)
summary(m1)

cat("The one predictor is significantly tighter.")
anova(m0, m1)

cat("============= Model includes two predictors. =============")
m2 <- lm(QuarterMileInSeconds ~ 1 + MilesPerGallon + ForwardGearCountF, data=ds)
summary(m2)

cat("The two predictor is significantly tighter.")
anova(m1, m2)
