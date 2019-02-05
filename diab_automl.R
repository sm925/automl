##Automl in R:

library(data.table)
library(h2o)
library(GGally)

# https://www.kaggle.com/uciml/pima-indians-diabetes-database link to data
diab <- read.csv("diabetes.csv", header = T, stringsAsFactors = F)
summary(diab)
str(diab)

setDT(diab)
setnames(diab, "Outcome", "diabetes")

head(diab)

ggcorr(diab)

diab <- diab[, diabetes := as.factor(diabetes)]
nrows <- nrow(diab)
index <- sample(1:nrows, 0.8 * nrows)  
train <- diab[index,]                 
test <- diab[-index,]                  


y <- "diabetes"
x <- setdiff(names(train), c("diabetes"))


h2o.init()
train <- as.h2o(train)
test <- as.h2o(test)

aml <- h2o.automl(y = y, x = x,
                  training_frame = train,
                  max_runtime_secs = 999999999,
                  max_models = 10,
                  seed = 1
)

rm(list=setdiff(ls(), c("train", "test", "aml")))

lb <- aml@leaderboard
print(lb, n = nrow(lb))

aml@leader
pred <- h2o.predict(aml, test) 
h2o.performance(model = aml@leader, newdata = test)
