import os
import tweepy
import json
import random
from wr_crpapi import CRP, CRPApiError
from time import gmtime, strftime
try: 
  from config import *
except ImportError:
  TWITTER_ACCESS_TOKEN = os.environ['TWITTER_ACCESS_TOKEN']
  TWITTER_ACCESS_TOKEN_SECRET = os.environ['TWITTER_ACCESS_TOKEN_SECRET']
  TWITTER_CONSUMER_KEY = os.environ['TWITTER_CONSUMER_KEY']
  TWITTER_CONSUMER_SECRET = os.environ['TWITTER_CONSUMER_SECRET']
  OPENSECRETS_API_KEY = os.environ['OPENSECRETS_API_KEY']
  LOG_LOCAL = False


# ========= Bot configuration =========
bot_name = "WhoseRep"
logfile_name = bot_name + ".log"
# =====================================


# ========= US State codes =================================================
states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", 
          "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", 
          "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
          "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", 
          "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
# ==========================================================================


def create_tweet():
  """Create the tweet text"""
  # OpenSecrets auth
  CRP.apikey = OPENSECRETS_API_KEY

  # Select a random US state, the select one of its candidates at random
  state = random.choice(states)
  cand_dict = getRandomCandByState(state, CRP)

  # Choose a random contributor for cid (Candidate ID)
  contrib_dict = getRandomContribByCand(cand_dict['cid'], CRP)

  # Form tweet text
  text = 'Representative %s (%s-%s) accepted $%s from %s. src: OpenSecrets.org' % \
          (cand_dict['firstlast'], cand_dict['party'], state, \
          contrib_dict['amount'], contrib_dict['name'])
  return text


def tweet(text):
  """Tweet the text from the bot account"""
  # Twitter auth
  auth = tweepy.OAuthHandler(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
  auth.set_access_token(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
  api = tweepy.API(auth)

  try:
    api.update_status(text)
  except tweepy.TweepError as e:
    log(e.message)
  else:
    log("Tweeted: " + text)


def getRandomCandByState(state, crp_obj):
  """Choose a random candidate from the given state"""
  cand_dict = {}
  legislators = json.dumps(crp_obj.getLegislators.get(id=state))

  # Select a random legislator
  l_dict = json.loads(legislators)
  l_count = len(l_dict)

  #TODO: revisit this
  if (l_count == 0):
    log("Failed to get a legislator")
    quit()

  l_index = random.randint(0, l_count - 1)
  cand_dict = {
    'cid'       : l_dict[l_index]['@attributes']['cid'],
    'firstlast' : l_dict[l_index]['@attributes']['firstlast'],
    'party'     : l_dict[l_index]['@attributes']['party']
  }

  return cand_dict


def getRandomContribByCand(cid, crp_obj):
  """Choose a random contributor to the candidate given by cid"""
  contrib_dict = {}
  contributors = json.dumps(crp_obj.candContrib.get(cid=cid))
  c_dict = json.loads(contributors)
  c_count = len(c_dict)

  #TODO: revisit this
  if (c_count == 0):
    log("Failed to get a contributor")
    quit()

  c_index = random.randint(0, c_count - 1)
  contrib_dict = {
    'name'   : c_dict[c_index]['@attributes']['org_name'],
    'amount' : c_dict[c_index]['@attributes']['total']
  }

  return contrib_dict


def log(message):
  """Enter message in log file"""
  if LOG_LOCAL:
    path = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
    with open(os.path.join(path, logfile_name), 'a+') as f:
        t = strftime("%d %b %Y %H:%M:%S", gmtime())
        f.write("\n" + t + " " + message)
  else:
    # Heroku prints stdout and stderr to its Logplex
    print bot_name + ": " + message


if __name__ == "__main__":
  tweet_text = create_tweet()
  print tweet_text
  # tweet(tweet_text)
