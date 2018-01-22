import praw
import requests
import requests.auth
import pandas as pd
import settings

# authenticate: update settings.py
reddit = praw.Reddit(client_id=settings.client_id,
                     client_secret=settings.client_secret,
                     user_agent=settings.user_agent)

# test connection = true                
print(reddit.read_only)

# define start and end dates to scrape as Unix timestamps
start = 1512086400 #1512086400 = beginning of december 
end = 1512086460 #1514764800 = end of december

# scrape all posts' subreddits and creation dates
subs = []
dates = []
for submission in reddit.subreddit('all').submissions(start, end):
    subs.append(submission.subreddit)
    dates.append(datetime.datetime.fromtimestamp(submission.created))

# save to data frame 
df = pd.DataFrame(list(zip(subs, dates)))
df.columns = ['subreddit','date']
#df.to_csv('reddit.csv')
#print df
