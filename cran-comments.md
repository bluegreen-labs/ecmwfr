## New release v1.5.0 

Dear CRAN team,

This is a major version increase due to the migration of the ECMWF APIs.

Hereby, the package will drop the support of the old API in favour of the
new one. I've added additional support for the Copernicus Emergency Management
System (CEMS) data store. Workflows remain largely the same with data requests
backwards compatible with the previous versions. Some components such as
legacy support for the WebAPI are removed as well, but remain available
through a github install should this be needed (although the service is also
scheduled for removal). For optimization, the batch processing script now also
checks for duplicate filenames and reports this as such, limiting 
accidental data overwrites.

Consolidation of the APIs leads to a more compact code base (thankfully).

Kind regards,
Koen Hufkens

I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- local Ubuntu 22.04 install on R 4.4.1
- Ubuntu 22.04 on github actions (devel / release / macos / windows)
- codecove.io code coverage at ~72%

## local / github actions CI R CMD check results

0 errors | 0 warnings | 0 notes
