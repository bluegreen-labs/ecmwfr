## New release v2.0.2

Dear CRAN team,

This is a bugfix to the package which would fail downloads of certain
products due to the handling of unknown query fields. I now sanitize
the requests further.

This update addresses this issue. No further changes were made.
Given the final migration to the new API at ECMWF you may expect many
more small bug fixes as the API is poorly documented.

Stats on code coverage and test routines remain the same as per previous
v2.0.1 release.

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
