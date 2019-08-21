# Load ROCK Kibana Dashboards, Elastic Mappings, and Logstash configs

This repository is arranged using the logstash module structure. Note that using it as a logstash module is not yet tested, but the goal is to
get there. That said, there's currently two configurations in this repo. One for the "stable" configuration, and one for an [Elastic Common Schema](https://www.elastic.co/guide/en/ecs/current/ecs-base.html) configuration.

### Usage (ECS stable/current):
```
# Copy Elasticsearch mappings
cd ecs-configuration/elasticsearch
./import-index-templates.sh http://127.0.0.1:9200

# Load Kibana saved objects
cd ../kibana
./import-saved-items.sh http://127.0.0.1:5601

# Install Logstash configs and restart
cd ../logstash
sudo cp -a conf.d/*.conf /etc/logstash/conf.d/
sudo mkdir -p /etc/logstash/conf.d/ruby
sudo cp -a ruby/*.rb /etc/logstash/conf.d/ruby/
sudo chown -R logstash:logstash /etc/logstash/conf.d
sudo systemctl restart logstash
```

### Usage (Prior releases):  
```
# Copy Elasticsearch mappings
cd configuration/elasticsearch
./import-index-templates.sh http://127.0.0.1:9200

# Load Kibana saved objects
cd ../kibana
./import-saved-items.sh http://127.0.0.1:5601

# Install Logstash configs and restart
cd ../logstash
sudo cp -a *.conf /etc/logstash/conf.d/
sudo chown -R logstash:logstash /etc/logstash/conf.d
sudo systemctl restart logstash
```



----  
# Contributing  

Why yes! We would like your contributions!  Here's how:  

### Create Dashboards  
----  
*Create a search:*    
Something like `event.dataset:dns` in Kibana search, and add important fields to the table view. Then save the search.  Simple names are better.  

*Create a visualization:*  
For right now, you're on your own.  But name it similar to `LOGTYPE - Purpose`.  

*Create a dashboard:*  
Again, on your own.  Name it `SOMETHING DESCRIPTIVE BUT SHORT, SHORTER THAN THIS BECAUSE THIS IS SILLY`.  

So, visualizations are pinned to saved searches, dashboards use one or many visualizations.  In general, things should be structured this way.  If you go a different route, tell us why in your pull request.  

### Export Your Creation  
----  
Go into the respective tool dir of this repo (i.e. elasticsearch, kibana, etc) and use the export scripts. For logstash, just copy the configs and any ruby scripts.

```
cd configuration/elasticsearch
./export-index-templates.sh http://127.0.0.1:9200
cd ../kibana
./export-saved-items.sh http://127.0.0.1:5601
```

----

# Standards  

There aren't many, but here are a few:  
 *  We use dark themes.
 *  Try to keep the naming simple and consistent.  Nothing like "ZOMG hackerz in the wirez!!1!"  
 *  Your pull request has to load cleanly with the `import-saved-items.sh` and `import-index-templates.sh` and produce a valid configuration in Kibana or it will be closed.  Nothing personal, but we don't have time to patch up submissions. Right now we do this manually. We're working on continuous integration testing that will provide immediate feedback after a test run on the latest Elastic platform.
 *  Have fun.  
