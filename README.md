Run this PowerShell script on a schedule (every 1 or 5 minutes) to document the number of established connections to 
an ArcGIS Server machine's internal Tomcat.  This script has to be run on the machine of interest (it does not work remotely)
The Tomcat thread pool for requests defaults to 150 for ArcGIS Server releases (thru 11.4, at least).  If you see
established connections approaching 150, you are at risk of exhausting that thread pool resource.  The symptoms of
exhaustion are not expressed clearly in any server side log.  So, it can be hard to "see" this problem.
This problem can occur when a site experiences a "heavy load" (some combination of many and long-running requests)
