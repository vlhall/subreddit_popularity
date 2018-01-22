import praw
import requests
import requests.auth
import pandas as pd
import settings

# authenticate: imported from settings.py
reddit = praw.Reddit(client_id=settings.client_id,
                     client_secret=settings.client_secret,
                     user_agent=settings.user_agent)

# test connection = true                
print(reddit.read_only)

# EDIT: define start and end dates to scrape as Unix timestamps
start = 1512086400 # = December 1, 2017, 12:00AM (UTC)
end = 1512097200 # = December 1, 2017, 3:00AM (UTC)

# scrape posts from all subreddits, include subreddit and creation date
subs = []
dates = []
for submission in reddit.subreddit('all').submissions(start, end):
    subs.append(submission.subreddit)
    dates.append(datetime.datetime.fromtimestamp(submission.created))

# save to data frame 
df = pd.DataFrame(list(zip(subs, dates)))
df.columns = ['subreddit','date']
#df.to_csv('reddit.csv')
