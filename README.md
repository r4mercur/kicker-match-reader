# kicker-match-reader


This application is a simple tool for getting Match results
from the biggest german football site [kicker.de](https://www.kicker.de/).
If they change their HTML structure, this tool will not work anymore.

## Installation

```
bundle install
```

## Docker Setup MongoDB

Docker Image
```
docker build -t kicker-match-reader .
```

Docker Run
```
docker run -d -p 27017:27017 --name kicker-match-reader kicker-match-reader
```

## Leagues
The following leagues are supported: All which are listed on [kicker.de](https://www.kicker.de/)
and they have URI like this: `https://www.kicker.de/bundesliga/spieltag/2020-21/10`

## Collections
The collection in the MongoDB is called `matches` and has the following structure:
```
[
  {
    "_id": {"$oid": "658092cbe8cf8932389dc883"},
    "away_team": "FC Elche ",
    "home_team": "UD Levante ",
    "matchday": "10",
    "result": "3:0",
    "season": "2020-21"
  }
]
```