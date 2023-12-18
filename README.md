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

## Collections
The collection in the MongoDB is called `matches` and has the following structure:
```
[
  {
    "_id": {"$oid": "658063c3e8cf894998392f59"},
    "away_team": "Stuttgart ",
    "home_team": "Bayern ",
    "result": "3:0"
  }
]
```