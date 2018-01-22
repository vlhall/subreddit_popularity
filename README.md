# Billboard's Hot 25 [Subreddits]

An exploration of Reddit's API using Python and R. 

Problem inspired by Professor Colin Rundel (Duke University, Department of Statistical Science)'s popular assignment to his students.

## Background
The self-proclaimed "Front page of the Internet", Reddit is a discussion-based website where users post content to any of thousands  of subreddits, each representing a general (or very, very niche) interest. Reddit has made a robust API available, granting access to the website's extreme amount of content, mostly produced in the form of subreddit posts and comments. Today, we challenge ourselves: can we create a Billboard-style (http://www.billboard.com/charts/hot-100) ranking for subreddit popularity?

## Analysis
Our first challenge is accessing the data. Reddit's API is available through the Python Reddit API Wrapper (PRAW), so in scrape.py, we connect to the API and pull down data for a given time period, specified by Unix timestamps. For the sake of easy reproducibility, three hours' worth of data has been stored in a .csv and included among our files. Ideally, a user has the resources available to pull a large amount of data and store it on a distributed database - though not a guarantee, this possibility is accounted for via the use of SparkR later on in the analysis.

Now that the data has been acquired, we move into R and leverage the package `SparkR` to connect to and manipulate our data. analysis.Rmd describes this process in detail and showcases the results. 

## Results
Reddit is a goldmine when it comes to Big Data, so it comes as no surprise that over the course of just one hour, popular subreddits receive hundreds of new posts. Those familiar with Reddit might not be surprised to find that over the course of three hours on December 1, 2017 (the data captured in our .csv), r/AskReddit, r/Showerthoughts, and r/aww consistently appear in the Top 25. But can we predict exactly when and where they'll land in our rankings? Sounds like a predictive modeling problem to me...
