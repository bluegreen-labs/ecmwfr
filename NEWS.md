# ecwmfr 1.2.0

* key management changes
  * inclusion of a new interactive way to set API keys
  * unlock checks
* reshuffling the default order of `wf_request()` as to accomodate pipes
* new contributor Elio Campitelli lead dynamic query code `wf_archetype()`
  * allows for archetype functions to be created from a normal MARS request
  * helps with recurrent queries with an overal similar structure
* RStudio Addins for MARS and python based requests to list items
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

* working verion, yeah!

# ecmwfr 0.0.1

* experimental release
* trying to get things working
