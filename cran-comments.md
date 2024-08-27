## New release v2.0.0 

Dear CRAN team,

This is a major version increment due to the migration of the ECMWF APIs.

Hereby, the package will drop the support of the old API in favour of the
new one, confusingly still called "beta". I've added additional support for 
the Copernicus Emergency Management System (CEMS) data store. 

The workflows remain largely the same with data requests
backwards compatible with the previous versions. Some components such as
legacy support for the WebAPI are removed. This service should have been
removed a long time ago but is still there. However, use cases are few. I now 
refer to the older v1 package for WebAPI support.

For optimization, the batch processing script now also
checks for duplicate filenames and reports this as such, limiting 
accidental data overwrites. Consolidation of the APIs authentication 
leads to a more compact code base (thankfully), but creates some breaking
changes due to the omission of a 'user' argument (with a consistent default).

These breaking changes are well documented, and migration should be as simple
as providing the new Personal Access Token and removing the user argument in
API query functions.

Consolidation of the API as the advantage that mixed queries of various
services are now allowed. Mixing for example querying climate data from CDS,
with atmospheric data from ADS in one batch.

Kind regards,
Koen Hufkens

I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- local Ubuntu 22.04 install on R 4.4.1
- Ubuntu 22.04 on github actions (devel / release / macos / windows)
- codecove.io code coverage at ~66%

## local / github actions CI R CMD check results

0 errors | 0 warnings | 0 notes
