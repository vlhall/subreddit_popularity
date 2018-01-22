## set system paths (if necessary)
# Sys.setenv(JAVA_HOME="")
# Sys.setenv(SPARK_HOME="")
# .libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R/lib"), .libPaths()))
if (("SparkR" %in% rownames(installed.packages())) == FALSE){
  install.packages("SparkR")
}
library(SparkR)

# additional packages
if (("magrittr" %in% rownames(installed.packages())) == FALSE){
  install.packages("magrittr")
}

if (("dplyr" %in% rownames(installed.packages())) == FALSE){
  install.packages("dplyr")
}
library(magrittr)
library(dplyr)

## start session with desired number of cores, import data
sc <- sparkR.session("local[4]")

# in this case, data is imported from a local file -
# depending on the constraints of your own machine, you may wish to connect to the data differently 
df <- read.df("reddit.csv", "csv", header = "true", inferSchema = "true", na.strings = "NA")

## manipulate data

# create columns for month, day, hour, minute, and day of week
res = select(df, df$subreddit, df$date) 
res = mutate(res, month = month(res$date), day = dayofmonth(res$date), hour = hour(res$date), minute = minute(res$date))

# EDIT: over what time periods do you want to compare your data? (OPTIONS: month, day, hour, minute)
grp <- "hour"

# EDIT: which periods do you want to compare? (OPTIONS: month = 1-12, day = 1-7, hour = 0-23, minute = 0-59)
i <- 3
j <- 4
k <- 5

# get post counts by subreddit at level of the prior selection
if (grp == "month"){
  res = group_by(res, res$month, res$subreddit) %>% count()
  col <- 2
}
if (grp == "day"){
  res = group_by(res, res$month, res$day, res$subreddit) %>% count()
  col <- 3
}
if (grp == "hour"){
  res = group_by(res, res$month, res$day, res$hour, res$subreddit) %>% count()
  col <- 4
}
if (grp == "minute"){
  res = group_by(res, res$month, res$day, res$hour, res$minute, res$subreddit) %>% count()
  col <- 5
}

# filter and rank subreddit popularity
res_i = filter(res, res[[grp]] == i) %>% arrange(., desc(.$count)) %>% head(n=25)
res_j = filter(res, res[[grp]] == j) %>% arrange(., desc(.$count)) %>% head(n=25)
res_k = filter(res, res[[grp]] == k) %>% arrange(., desc(.$count)) %>% head(n=25)
res_i$rank_i = c(1:25)
res_j$rank_j = c(1:25)
res_k$rank_k = c(1:25)

# transform back to Spark dataframe 
i_s = as.DataFrame(res_i)
j_s = as.DataFrame(res_j)
k_s = as.DataFrame(res_k)

## calculate changes in rank

# join first and second groups, calculate change
join = join(i_s, j_s, i_s$"subreddit" == j_s$"subreddit", "outer")
colnames(join)[col] <- 'sub'
change = select(join, join$sub, join$rank_i - join$rank_j)

# join change in rank back to group j's data
w_change = join(j_s, change, j_s$"subreddit" == change$"sub", "outer")
res_j = select(w_change, w_change$subreddit, w_change$count, w_change$`(rank_i - rank_j)`) %>%
  rename(., rank_change = .$`(rank_i - rank_j)`) %>% arrange(., desc(.$count)) %>% head(n=25)

# join second and third groups, calculate change
join = join(j_s, k_s, j_s$"subreddit" == k_s$"subreddit", "outer")
colnames(join)[col] <- 'sub'
change = select(join, join$sub, join$rank_j - join$rank_k)

# join change in rank back to group k's data
w_change = join(k_s, change, k_s$"subreddit" == change$"sub", "outer")
res_k = select(w_change, w_change$subreddit, w_change$count, w_change$`(rank_j - rank_k)`) %>%
  rename(., rank_change = .$`(rank_j - rank_k)`) %>% arrange(., desc(.$count)) %>% head(n=25)

## view results
res_i
res_j
res_k
