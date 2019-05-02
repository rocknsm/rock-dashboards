# Load ROCK 2.2 Kibana Dashboards

This repository is arranged using the logstash module structure. Note that using it as a logstash module is not yet tested, but the goal is to
get there. That said, there's currently two configurations in this repo. One for the "stable" configuration, and one for an [Elastic Common Schema](https://github.com/elastic/ecs) configuration. The ECS config will become the stable configuration but for now is tech preview.

### Usage (stable):  
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
sudo systemctl restart logstash
```

### Usage (ECS tech preview):
```
# Copy Elasticsearch mappings
cd ecs-configuration/elasticsearch
./import-index-templates.sh http://127.0.0.1:9200

# Load Kibana saved objects
cd ../kibana
./import-saved-items.sh http://127.0.0.1:5601

# Install Logstash configs and restart
cd ../logstash
sudo systemctl stop logstash
# Backing up your old logstash configs, ECS is completely different and merging the two is not logical
sudo mv /etc/logstash/conf.d{,.BAK} 
sudo mkdir /etc/logstash/conf.d/
sudo cp -a conf.d/*.conf /etc/logstash/conf.d/
sudo mkdir -p /etc/logstash/ruby
sudo cp -a ruby/*.rb /etc/logstash/ruby/
sudo chown -R logstash:logstash /etc/logstash/conf.d/ /etc/logstash/ruby/
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
 *  We don't use dark themes.  Yes, network defense is dark and moody affair, but the dark theme isn't the default, so for consistency's sake, lets keep it light.  
 *  Try to keep the naming simple and consistent.  Nothing like "ZOMG hackerz in the wirez!!1!"  
 *  Your pull request has to load cleanly with the `import-saved-items.sh` and `import-index-templates.sh` and produce a valid configuration in Kibana or it will be closed.  Nothing personal, but we don't have time to patch up submissions. Right now we do this manually. We're working on continuous integration testing that will provide immediate feedback after a test run on the latest Elastic platform.
 *  Have fun.  
