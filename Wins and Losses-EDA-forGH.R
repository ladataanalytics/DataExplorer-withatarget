library(tidyverse)
library(dplyr)
library(DataExplorer)
#set working directory
setwd("YOUR WD")

library(rsconnect)

rsconnect::setAccountInfo(name='ladataanalytics',
                          token='YOUR TOKEN',
                          secret='YOUR SECRET')

#ibm sample data
pipeline <- read.csv("WA_Fn-UseC_-Sales-Win-Loss.csv")
#check the structure and summarize
str(pipeline)
summary(pipeline)

check<-as.data.frame(table(pipeline$Opportunity.Number))
#data contains some duplicate opportunity numbers
#unique = 77,829 out of 78,025

#look at some of the duplicates
opids <- as.data.frame(subset(pipeline, 
              Opportunity.Number == 7281765 | 
              Opportunity.Number == 8093335 |
              Opportunity.Number == 9782603 |
              Opportunity.Number == 4787647 |
              Opportunity.Number == 6704540
             ))
opids
#some are pure dups while others are not

#by opportunity number
#distinct: default is that only the first row is preserved
nrow(distinct(pipeline))#77,970
nrow(distinct(pipeline,Opportunity.Number))#77,829
#full dups is not far off from dups by id

#use data with full dups removed
pipeline_nodup<-
  pipeline %>% 
  distinct()
#77,970

#create data profile report
#with the interest being 
#whether the pipeline result is a win or loss

#remove opp number
pipeline_fin <- 
  pipeline_nodup %>% 
  dplyr::select (-c(Opportunity.Number))
#profiling exported to html
create_report(pipeline_fin,y="Opportunity.Result")

######################
#shiny app
######################
library(shiny)
ui<-shinyUI(fluidPage(titlePanel("Alfonso Berumen - LOS ANGELES DATA ANALYTICS"),
                      sidebarLayout(
                        sidebarPanel(
                          h5("DataExplorer: Wins and Losses")
                        ), 
                        mainPanel(
                          tabsetPanel(
                            tabPanel("HTML Output", 
                                     tags$iframe(style="height:400px; width:100%; scrolling=yes", 
                                                 src="report.html"))
                          )
                        ))
))

server <- function(input, output) {
}
shinyAppDir("YOUR APP DIRECTORY")

rsconnect::deployApp("YOUR DEPLOYMENT DIRECTORY", appName = "Wins and Losses",
                     appTitle = "Wins and Losses")

#psych package
library(psych)
mat<-describeBy(pipeline_fin,pipeline_fin$Opportunity.Result,mat=TRUE,digits=2)
mat