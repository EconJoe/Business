
library(tree)
library(randomForest)

mydata <- read.csv("B:/Business/Data/rftest.csv")

mylogit <- glm(target ~ cum_vote_G + cum_vote_G_pres + cum_vote_G_midt +
                 cum_vote_P_D + cum_vote_P_R + cum_vote_P_O + cum_vote_P_T +
                 cum_vote_P_D_pres + cum_vote_P_R_pres + cum_vote_P_O_pres + cum_vote_P_T_pres + 
                 cum_vote_P_D_midt + cum_vote_P_R_midt + cum_vote_P_O_midt + cum_vote_P_T_midt, 
               data = mydata, family = "binomial")
summary(mylogit)
logitprob=predict(mylogit, data=mydata, type="response")
hist(logitprob)

# Convert target into a factor variable for decision tree and random forest classifcation.
mydata$target <- factor(mydata$target)


mytree <- tree(target ~ cum_vote_G + cum_vote_G_pres + cum_vote_G_midt +
                             cum_vote_P_D + cum_vote_P_R + cum_vote_P_O + cum_vote_P_T +
                             cum_vote_P_D_pres + cum_vote_P_R_pres + cum_vote_P_O_pres + cum_vote_P_T_pres + 
                             cum_vote_P_D_midt + cum_vote_P_R_midt + cum_vote_P_O_midt + cum_vote_P_T_midt,
                             data=mydata)
summary(mytree)


set.seed(1)
myrf <- randomForest(target ~ cum_vote_G + cum_vote_G_pres + cum_vote_G_midt +
                      cum_vote_P_D + cum_vote_P_R + cum_vote_P_O + cum_vote_P_T +
                      cum_vote_P_D_pres + cum_vote_P_R_pres + cum_vote_P_O_pres + cum_vote_P_T_pres + 
                      cum_vote_P_D_midt + cum_vote_P_R_midt + cum_vote_P_O_midt + cum_vote_P_T_midt,
                      data=mydata)
rfprob = predict(myrf, mydata, type="prob")
summary(myrf)
myrf
summary(treeprob[, 1])
summary(treeprob[, 2])


