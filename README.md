# Load ROCK 2.0 Kibana Dashboards

### Usage:  
```
./load.sh -url http://127.0.0.1:9200
```  

----  
# Contributing  
  
Why yes! We would like your contributions!  Here's how:  
  
### Create Dashboards  
----  
*Create a search:*    
Something like `@meta.stream:logtype` or `event_type:eventtype` in Kibana search, then save the search.  Simple names are better.  

*Create a visualization:*  
For right now, you're on your own.  But name it similar to `LOGTYPE - Purpose`.  

*Create a dashboard:*  
Again, on your own.  Name it `SOMETHING DESCRIPTIVE BUT SHORT, SHORTER THAN THIS BECAUSE THIS IS SILLY`.  

So, visualizations are pinned to saved searches, dashboards use one or many visualizations.  In general, things should be structured this way.  If you go a different route, tell us why in your pull request.  
  
### Export Your Creation  
----  
I usually go into Kibana's "Management" section, then "Saved Objects", then delete all of the pre-existing stuff.  Hit the "Export Everything" button and you'll get an `export.json` download that only has your new goodies.  

At this point, make sure you have the utility `jq`. (Why don't you have jq?)  It's available for Linux and OSX, and maybe for some of those other OS's, but I haven't checked.

Take your `export.json` and do like so:  
`cat export.json | jq '.[]._source'`  

Each of those stanzas needs to be a separate file and goes in a corresponding folder under `dashboards`.  It'll make sense once you look in there. Go do it now, I'll wait.  

### Gotchas  
----  
Nothing worth doing is easy.  Welcome, brave traveler, here's the tippers I have to offer:  

*  A saved search with a title like `ENCABULATOR` will become `dashboards/search/encabulator.json`.  
*  A visualization using that search will need it's `"savedSearchId"` set to `encabulator`.  *Note:* lower case  
*  The visualization named `ENCABULATOR - Spirvel Bearing Side Fumbling` will be saved as `dashboards/visualization/encabulator-spirvel-bearing-side-fumbling.json`.  
*  The `ENCABULATOR` dashboard will be saved as `dashboards/dashboard/encabulator.json`.  
*  Within the dashboard's JSON file, the `id` of each visualization needs to be changed to all lower case.  
*  To test it out, go into Kibana's "Saved Objects" and delete everything.  Then run `./load.sh -url http://127.0.0.1:9200` to push the whole dashboards package into Kibana.  Validate that everything works as expected.


----

# Standards  
  
There aren't many, but here are a few:  
 *  We don't use dark themes.  Yes, network defense is dark and moody affair, but the dark theme isn't the default, so for consistency's sake, lets keep it light.  
 *  Try to keep the naming simple and consistent.  Nothing like "ZOMG hackerz in the wirez!!1!"  
 *  Your pull request has to load cleanly with the `load.sh` and test out in Kibana or it will be closed.  Nothing personal, but we don't have time to patch up submissions.  
 *  Have fun.  


