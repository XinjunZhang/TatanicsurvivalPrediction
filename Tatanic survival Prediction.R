data<-read.csv("Tatanic/train.csv",na.strings=c("","NA"))

library(dplyr)
library(caret)
library(rpart)
library(stringr)


data$Parch[data$Parch !=0]<-1
summary(data)

col_names<-c("Survived","Pclass","Sex","Age","Embarked","Parch")
data[,col_names] <- lapply(data[,col_names], factor)
data$Age<-as.numeric(data$Age)
data$SibSp<-as.numeric(data$SibSp)
summary(data)

data<-data[,-c(1,4,9,11)]
data<-na.omit(data)
summary(data)

set.seed(96)
inTrain <- createDataPartition(data$Survived, p = .8,
                               list = FALSE,
                               times = 1)
training <- data[inTrain,]
test <- data[-inTrain,]

rtGrid <- expand.grid(cp=seq(0.001, 0.2, by = 0.001))
# alpha is between 0 and 1: 0 (ridge), 1 (lasso).

########################################## training model
ctrl <- trainControl(method = "cv", number = 10,
                     verboseIter = T)
set.seed(1)
rtTune <- train(Survived~ ., data = training,   
                method = "rpart", 
                tuneGrid = rtGrid,
                metric='Kappa',
                trControl = ctrl)

rtTune
plot(rtTune)
rtTune$bestTune

fancyRpartPlot(rtTune$finalModel)

pr_ct <- predict(rtTune, newdata = test)


ct_CM <- confusionMatrix(pr_ct, test$Survived, positive = "1")
ct_CM

###ROC Curve
library(pROC)
probsTrain<-predict(rtTune,training,type = "prob")
rocCurve<-roc(response=training$Survived,predictor=probsTrain[,"1"],
              levels = levels(as.factor(training$Survived)))

plot(rocCurve,print.thres="best")

names(rocCurve)
rocCurve$thresholds
rocCurve$sensitivities

#Random Forest
set.seed(1)
rfTune<-train(Survived~.,data=training,method="rf",
              trControl=trainControl(method="cv",number=5),metric="Kappa",
              prox=TRUE,allowParallel=TRUE)

rfTune
plot(rfTune)
rfTune$bestTune


#prediction for randomForest

pr_ct <- predict(rfTune, newdata = test)


ct_CM <- confusionMatrix(pr_ct, test$Survived, positive = "1")
ct_CM
library(pROC)
probsTrain<-predict(rfTune,training,type = "prob")
rocCurve<-roc(response=training$Survived,predictor=probsTrain[,"1"],
              levels = levels(as.factor(training$Survived)))

plot(rocCurve,print.thres="best")

names(rocCurve)
rocCurve$thresholds
rocCurve$sensitivities
