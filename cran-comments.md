## New release v2.0.4

Dear CRAN team,

This small update fixes an edge case in the RStudio Addin for conversion
of ECMWF python to R queries. Mention of the keyword `dataset` was filtered
properly only to select the first instance, not allowing multiple selections
which as cause for an error. No further changes were made.

Stats on code coverage and test routines remain the same as per previous
v2.0.3 release.

Kind regards,
Koen Hufkens

I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- local Ubuntu 22.04 install on R 4.4.1
- Ubuntu 22.04 on github actions (devel / release / macos / windows)
- codecove.io code coverage at ~70%

## local / github actions CI R CMD check results

0 errors | 0 warnings | 0 notes
