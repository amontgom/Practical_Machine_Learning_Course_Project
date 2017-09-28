------------------------------------------------------------------------

Practical Machine Learning Course Project
=========================================

------------------------------------------------------------------------

Background
----------

Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement - a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. More information is available from the website here: <http://web.archive.org/web/20161224072740/http:/groupware.les.inf.puc-rio.br/har> (see the section on the Weight Lifting Exercise Dataset).

Data
----

The training data for this project are available here:

<https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv>

The test data are available here:

<https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv>

Project Objectives
------------------

The goal of your project is to predict the manner in which they did the exercise. This is the "classe" variable in the training set. You may use any of the other variables to predict with. You should create a report describing how you built your model, how you used cross validation, what you think the expected out of sample error is, and why you made the choices you did. You will also use your prediction model to predict 20 different test cases.

------------------------------------------------------------------------

Data Acquisition and Preprocessing
----------------------------------

### Data Acquisition

``` r
fileUrl1 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
fileUrl2 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
temp1 <- tempfile()
temp2 <- tempfile()
download.file(fileUrl1, destfile = temp1, mode = "wb")
download.file(fileUrl2, destfile = temp2, mode = "wb")
dateDowloaded <- date()
dateDowloaded
```

    ## [1] "Wed Sep 27 22:00:21 2017"

``` r
train <- read.csv(temp1, header = TRUE, na.strings=c("NA","#DIV/0!",""))
test <- read.csv(temp2, header = TRUE, na.strings=c("NA","#DIV/0!",""))
unlink(temp1)
unlink(temp2)
```

### Libraries

``` r
library(caret)
```

    ## Loading required package: lattice

    ## Loading required package: ggplot2

``` r
library(randomForest)
```

    ## randomForest 4.6-12

    ## Type rfNews() to see new features/changes/bug fixes.

    ## 
    ## Attaching package: 'randomForest'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     margin

``` r
library(rpart)
library(rpart.plot)
library(e1071)
```

### Preprocessing

``` r
set.seed(12345)
```

Setting the seed for reproducibility reasons.

``` r
isNearZero <- nearZeroVar(train, saveMetrics = TRUE)
train <- train[, !isNearZero$nzv]
```

Processing for machine learning is costly; to reduce computing time, we clean from the dataset those variables with a high % of NAs and those characterized by low variance.

``` r
NARemove <- sapply(colnames(train), function(x) if(sum(is.na(train[, x])) > 0.50*nrow(train)) {return(TRUE)}
                  else{
                    return(FALSE)
                    })
train <- train[, !NARemove]
```

Removing variables composed of &gt;50% NAs.

``` r
train <- train[,-c(1:6)]
```

We remove columns that aren't important to the machine learning, because otherwise it will screw up the process.

``` r
inTrain <- createDataPartition(y=train$classe, p=0.6, list=FALSE)
trainTrain <- train[inTrain, ] 
trainTest <- train[-inTrain, ]
```

We create a new pair of training and test data, at a 60/40 proportion. I am testing three different learning algorithms, and I'd like to figure out which one is best before applying it to the test set proper.

Let's take a quick look at classe.

``` r
plot(train$classe, main="Levels of classe in the train data", xlab="classe", ylab="Frequency")
```

![](MachineLearningProjectCode_files/figure-markdown_github/unnamed-chunk-7-1.png)

As we can see, each level frequency is within the same order of magnitude as the others. Level A is the most frequent action while level D is the least frequent.

------------------------------------------------------------------------

Machine Learning Algorithms (MLAs)
----------------------------------

I will be using three MLAs: Decision Trees, Random Forests, and a Neural Network. Once these have been generated from the trainTrain set, they will be use to predict the trainTest dataset. The most successful will be used to predict the test dataset.

### Decision Trees

``` r
modelDC <- rpart(data = trainTrain, classe ~ ., method = "class")
predictDC <- predict(modelDC, trainTest, type = "class")
```

### Random Forest

``` r
modelRF <- train(data = trainTrain, classe ~ ., method = "rf")
predictRF <- predict(modelRF, trainTest)
```

### Neural Network

``` r
invisible(capture.output(modelNN <- train(data = trainTrain, classe ~ ., method = "nnet")))
predictNN <- predict(modelNN, trainTest)
```

The extra functions around the modelNN generation are to suppress a great deal of unwanted output.

Now that these have been generated, we can look at the accuracy values in the confusion matrices to see which has the best accuracy.

``` r
confusionMatrix(predictDC, trainTest$classe)$overall['Accuracy']
```

    ##  Accuracy 
    ## 0.7267397

``` r
confusionMatrix(predictRF, trainTest$classe)$overall['Accuracy']
```

    ##  Accuracy 
    ## 0.9927352

``` r
confusionMatrix(predictNN, trainTest$classe)$overall['Accuracy']
```

    ##  Accuracy 
    ## 0.4432832

The best accuracy is Random Forests, with a whopping 99%. Needless to say, we will be applying that to our test dataset.

------------------------------------------------------------------------

Conclusion
----------

Now we apply our Random Forests model to the test dataset, to get our answer for the quiz.

``` r
predictTest <- predict(modelRF, test)
predictTest
```

    ##  [1] B A B A A E D B A A B C B A E E A B B B
    ## Levels: A B C D E

------------------------------------------------------------------------

Appendix
--------

### Decision Tree Plot

Just because it looks cool.

``` r
rpart.plot(modelDC, main="Decision Tree", extra=102, under=TRUE, faclen=0)
```

![](MachineLearningProjectCode_files/figure-markdown_github/unnamed-chunk-13-1.png)