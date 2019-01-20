
# ecmwfr with CDS support (Reto)

* Added support for climate data store (CDS) including
  `cds_set_key` and `cds_get_key` (wrapper functions) and
  `cds_retrieve` which is slighty different (different authentification).
* Added `wf_key_from_file`, reads email/key from `.ecmwfapirc` file.
  Moved `keyring` from `import` to `suggets` (only used if `wf_set_key`,
  `wf_get_key` or the `cds_*` wrappers are called.

# ecmwfr 1.0.0

* major version
* CRAN release

# ecmwfr 0.0.3

* unit checks with encrypted key
* good CI coverage >90%
* verbose feedback on wf_request()
* rOpenSci syntax and ok, gp() ok

# ecmwfr 0.0.2

* working verion, yeah!

# ecmwfr 0.0.1

* experimental release
* trying to get things working
