
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

data<-read.csv("Tatanic/train.csv",na.strings=c("","NA"))
testdata<-read.csv("Tatanic/test.csv",na.strings=c("","NA"))

str(data)

library(dplyr)
library(caret)
library(rpart)
library(stringr)
library(rattle)
library(pROC)
library(randomForest)


data$Parch[data$Parch !=0]<-1
data$SibSp[data$SibSp !=0]<-1

col_names<-c("Survived","Pclass","Sex","Age","Embarked","Parch", "SibSp")
data[,col_names] <- lapply(data[,col_names], factor)
data$Age<-as.numeric(data$Age)
data$Fare<-as.numeric(data$Fare)

data<-data[,-c(1,4,9,11,12)]

data<-na.omit(data)


set.seed(96)
inTrain <- createDataPartition(data$Survived, p = .8,
                               list = FALSE,
                               times = 1)
training <- data[inTrain,]
test <- data[-inTrain,]

set.seed(1)
rfTune<-randomForest(Survived ~ Sex+SibSp+Parch+Age+Pclass,data=training,importance=T,proximity=T,type="class")
plot(rfTune)
 

library(shiny)


shinyServer(function(input, output,session) {
  output$preImage <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('titanic-sink.jpg'))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = paste("Image number"))
    
  }, deleteFile = FALSE)

  output$values <- renderPrint({
    list(Name = input$text, Sex = as.factor(ifelse(input$Sex!=0,"female","male")),
         SibSp= as.factor(ifelse(as.numeric(input$Marriage)+as.numeric(input$Sib)!=0,1,0)),
         Parch=as.factor(ifelse(as.numeric(input$Parents)+as.numeric(input$Children)!=0,1,0)),
         Age = as.numeric(input$num1),Pclass= as.factor(input$Pclass))
 
  })
  output$prediction<-renderPrint({predict(rfTune,
                                          newdata=cbind(Sex = as.factor(ifelse(input$Sex!=0,"female","male")),
                                          SibSp= as.factor(ifelse(as.numeric(input$Marriage)+as.numeric(input$Sib)!=0,1,0)),
                                          Parch=as.factor(ifelse(as.numeric(input$Parents)+as.numeric(input$Children)!=0,1,0)),
                                          Age = as.numeric(input$num1),Pclass= as.factor(input$Pclass)))
  })

})


