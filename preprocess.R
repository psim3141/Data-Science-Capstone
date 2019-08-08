##
## rickPredict - a Word Prediction app
##
## Developed by Patrick Simon, August 2019
## for the Capstone project of the JHU Data Science Specialization
##
## This code pre-processes the raw HC corpora data into the
## five n-gram data tables that are the basis for the app.
##

library(tidytext)
library(tidyverse)
library(dplyr)
library(sentimentr)
library(quanteda)
library(data.table)
library(stringr)

## make reproducible
set.seed(481516)

## read in all three files, sample ~20% each
i <- 0
lines <- character()
con <- file("final/en_US/en_US.twitter.txt", "r") 
while (i < 2300000){
        lines <- append(lines,readLines(con, 100000))
        i <- i +100000
}
close.connection(con)
rlines <- sample(lines,460000)

i <- 0
lines <- character()
con <- file("final/en_US/en_US.blogs.txt", "r") 
while (i < 890000){
        lines <- append(lines,readLines(con, 89000))
        i <- i +89000
}
close.connection(con)
rlines2 <- sample(lines,178000)

i <- 0
lines <- character()
con <- file("final/en_US/en_US.news.txt", "r") 
while (i < 1000000){
        lines <- append(lines,readLines(con, 100000))
        i <- i +100000
}
close.connection(con)
rlines3 <- sample(lines,200000)

## combine and save sample
lines <- c(rlines,rlines2,rlines3)
write.csv(lines,file="all_sample.txt")



## tokenize
ldf <- as_data_frame(lines)
tokens_sent <- ldf %>% unnest_tokens(sentences, value, token="sentences")

## profanity filtering (this takes a long time)
prof <- profanity(tokens_sent$sentences,
                  profanity_list = unique(tolower(lexicon::profanity_alvarez)))

ps <- tokens_sent[prof[which(prof$profanity_count >= 1),]$element_id,]
cleanSent <- tokens_sent %>% anti_join(ps)



## 1-grams
xt <- tokens(cleanSent$sentences,remove_numbers=T,remove_punct=T,remove_symbols=T,
             remove_twitter=T,remove_url=T,verbose=T)
xdf <- dfm(xt,verbose=T)
ts <- textstat_frequency(xdf)

ts1 <- ts
ts1min <- ts1[ts1$frequency > 3,1:2]
dt1s <- as.data.table(ts1min)
dt1s[,"start":= ""]
colnames(dt1s)[1] <- "end"



## 2-grams
xtn2 <- tokens_ngrams(xt,2,concatenator = " ")
xdf2 <- dfm(xtn2,verbose=T)
ts2 <- textstat_frequency(xdf2)

ts2min <- ts2[ts2$frequency > 3,1:2]
dt2s <- as.data.table(ts2min)
dt2s[,c("start","end") := tstrsplit(feature," ",fixed=TRUE)]
dt2s[,"feature":=NULL]



## 3-grams
xtn3 <- tokens_ngrams(xt,3,concatenator = " ")
xdf3 <- dfm(xtn3,verbose=T)
ts3 <- textstat_frequency(xdf3)

ts3min <- ts3[ts3$frequency > 3,1:2]
dt3s <- as.data.table(ts3min)
dt3s[,c("s1","s2","end") := tstrsplit(feature," ",fixed=TRUE)]
dt3s[,"start":= paste(s1,s2)]
dt3s[,c("feature","s1","s2"):=NULL]



## 4-grams
xtn4 <- tokens_ngrams(xt,4,concatenator = " ")
xdf4 <- dfm(xtn4,verbose=T)
ts4 <- textstat_frequency(xdf4)

ts4min <- ts4[ts4$frequency > 3,1:2]
dt4s <- as.data.table(ts4min)
dt4s[,c("s1","s2","s3","end") := tstrsplit(feature," ",fixed=TRUE)]
dt4s[,"start":= paste(s1,s2,s3)]
dt4s[,c("feature","s1","s2","s3"):=NULL]



## 5-grams
xtn5 <- tokens_ngrams(xt,5,concatenator = " ")
xdf5 <- dfm(xtn5,verbose=T)
ts5 <- textstat_frequency(xdf5)

ts5min <- ts5[ts5$frequency > 3,1:2]
dt5s <- as.data.table(ts5min)
dt5s[,c("s1","s2","s3","s4","end") := tstrsplit(feature," ",fixed=TRUE)]
dt5s[,"start":= paste(s1,s2,s3,s4)]
dt5s[,c("feature","s1","s2","s3","s4"):=NULL]


## How large are these tables? Not too bad.
print(object.size(dts1),units="MiB")
print(object.size(dts2),units="MiB")
print(object.size(dts3),units="MiB")
print(object.size(dts4),units="MiB")
print(object.size(dts5),units="MiB")



## Now we pre-calculate the scores
dt5s$score <- 0
dt4s$score <- 0
dt3s$score <- 0
dt2s$score <- 0
dt1s$score <- 0

## Use smaller copies of the tables during parts of the calculation
dt5m <- copy(dt5s)
dt5m[,c("s1","s2","s3","end2") := tstrsplit(start," ",fixed=TRUE)]
dt5m[,"start2":= paste(s1,s2,s3)]
dt5m[,c("end","s1","s2","s3","score","start"):=NULL]

dt4m <- copy(dt4s)
dt4m[,c("s1","s2","end2") := tstrsplit(start," ",fixed=TRUE)]
dt4m[,"start2":= paste(s1,s2)]
dt4m[,c("end","s1","s2","score","start"):=NULL]

dt3m <- copy(dt3s)
dt3m[,c("start2","end2") := tstrsplit(start," ",fixed=TRUE)]
dt3m[,c("end","score","start"):=NULL]

dt2m <- copy(dt2s)
colnames(dt2m)[2] <- c("end2")
dt2m[,c("end","score"):=NULL]

score <- numeric()
for (i in 1:dim(dt5s)[1]){
        dti <- dt5m[i]
        score[i] <- dti$frequency/(dt4s[start==dti$start2&end==dti$end2]$frequency)
        if (i %% 10000 == 0) print(i)
}
dt5s$score <- score

score <- numeric()
for (i in 1:dim(dt4s)[1]){
        dti <- dt4m[i]
        score[i] <- dti$frequency/(dt3s[start==dti$start2&end==dti$end2]$frequency)
        if (i %% 10000 == 0) print(i)
}
dt4s$score <- score

score <- numeric()
for (i in 1:dim(dt3s)[1]){
        dti <- dt3m[i]
        score[i] <- dti$frequency/(dt2s[start==dti$start2&end==dti$end2]$frequency)
        if (i %% 10000 == 0) print(i)
}
dt3s$score <- score

score <- numeric()
for (i in 1:dim(dt2s)[1]){
        dti <- dt2m[i]
        score[i] <- dti$frequency/(dt1s[end==dti$end2]$frequency)
        if (i %% 10000 == 0) print(i)
}
dt2s$score <- score

## save tables
saveRDS(dt1s,file="rickPredict/www/dt1s.RData")
saveRDS(dt2s,file="rickPredict/www/dt2s.RData")
saveRDS(dt3s,file="rickPredict/www/dt3s.RData")
saveRDS(dt4s,file="rickPredict/www/dt4s.RData")
saveRDS(dt5s,file="rickPredict/www/dt5s.RData")