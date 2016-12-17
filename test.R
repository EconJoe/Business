
VOTERFILE <- read.delim("B:/Business/Data/Ohio/FranklinCounty/BOE/VOTERFILE.TXT", header=TRUE)
head(VOTERFILE)
dim(VOTERFILE)
class(VOTERFILE)
summary(VOTERFILE)


age <- 2016-VOTERFILE$DATE.OF.BIRTH
VOTERFILE$AGE <- 2016 - VOTERFILE$DATE.OF.BIRTH
summary(age)
summary(VOTERFILE$AGE)
hist(age)

install.packages("rmarkdown")