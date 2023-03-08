# ecmwfr 1.5.1

* `wf_request_batch()` logic patch, to keep running on a 202 http error

# ecmwfr 1.5.0

* `wf_request()` now accepts CDS Toolbox API workflow calls
* `wf_request_batch()` now checks for duplicated filenames and stops early.

# ecmwfr 1.4.0

* added `wf_request_batch()` to support parallel requests using R6 logic
* updated citation (pointing to global doi)

# ecmwfr 1.3.0

* updated code coverage to reflect changes
* R >= 3.6
* bluegreen-labs migration
* keychain issue fix, keychain in file now functional
* Atmospheric Data Store support

# ecmwfr 1.2.3

* fixed a bug on dataset naming convention double use

# ecmwfr 1.2.2

* automatic user detection from keyring user list
* obfuscate api key on command line
* add progress bar to all services
* add service name to keychain
* fix comma issue in CDS parser
* fixed stray documentation for non existing function argument
* keyword issue

# ecwmfr 1.2.1

* disabled all unit tests on CRAN
* Adding in support for rstudio batch processing

# ecwmfr 1.2.1

* disabled all networked unit tests on CRAN

# ecwmfr 1.2.0

* key management (breaking) changes
  * inclusion of a new interactive way to set API keys
  * unlock checks
* reshuffling the default order of `wf_request()` as to accomodate pipes
* new contributor Elio Campitelli lead dynamic query code `wf_archetype()`
  * allows for archetype functions to be created from a normal MARS request
  * helps with recurrent queries with an overall similar structure
* rstudio Addins for MARS and python based requests to list items
* logo on website
* documentation updated

# ecmwfr 1.1.0

* inclusion of Copernicus CDS services by Reto Tauffer
  * now covering most of the ECMWF climate data products
* consolidation of code by Reto Tauffer
  * integration in `wf_*()` vocabulary
  * simplification of code and error messages
* automated checks of the request statements
  * ensures a consistent vocabulary with limited parameters
* unit checks don't fail upon unavailable service
* changed order of arguments in `wf_request()`

# ecmwfr 1.0.1

* accidental CRAN violation fixed
* `wf_transfer()` separate downloads allowed
* checks for binary downloads (larger files)

# ecmwfr 1.0.0

* major version
* CRAN release

# ecmwfr 0.0.3

* unit checks with encrypted key
* good CI coverage >90%
* verbose feedback on `wf_request()`
* rOpenSci syntax and ok, gp() ok

# ecmwfr 0.0.2

* working version, yeah!

# ecmwfr 0.0.1

* experimental release
* trying to get things working
