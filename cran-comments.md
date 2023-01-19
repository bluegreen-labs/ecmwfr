## New release v1.5.0 

Dear CRAN team,

This is a major version increase as it adds a new workflow feature to the package.

Workflows allow for the execution of scripts on the ECMWF servers, within the
context of the ECMWF Copernicus Data Store toolbox framework. This adds crucial
support for server side aggregation and limits download overheads. 

For example, you can query a single pixel and multiple hourly data points to be
summarized to a daily time series. Previously, vast amounts of data needed to be
downloaded locally before aggregation. Such an example is excluded in the
documentation, but applications are plenty and not limited to data aggregation.

For optimization, the batch processing script now also checks for duplicate
filenames and reports this as such limiting data overwrites.

Kind regards,
Koen Hufkens

I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- local Ubuntu 22.04 install on R 4.2
- Ubuntu 20.04 on github actions (devel / release / macos / windows)
- codecove.io code coverage at ~72%

## local / github actions CI R CMD check results

0 errors | 0 warnings | 0 notes
