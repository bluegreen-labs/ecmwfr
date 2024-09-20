## New release v2.0.0 

Dear CRAN team,

This is a bugfix to the package which would halt the batch downloading
after one donwload completed (due to updates to the argument structure
after the recent API migration). This updates addresses this issue.

Stats on code coverage and test routines remain the same.

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
