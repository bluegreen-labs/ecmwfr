
# TODO/Questions

* Is the `transfer = FALSE` a good option?
* The order of the input arguments to `wf_request` are a bit confusing to me.
  I've changed them for cds, I think it would be good to have the same for
  both (`wf_request` and `cds_request`). Currently:
  * `cds_request(user, request, transfer = TRUE, ...)`
  * `wf_request(email, path = tempdir(), time_out = 3600, transfer = FALSE, request = list(...), ...)`
  * **Thoughts**: for me the `request` is (after user/email) the most important
    input. Furthermore I am not sure whether a '_default request_' should be provided.
* If `transfer = FALSE` the http request is returned containing request id or download
  url which can be used for `wf_transfer`. If this is an intended feature one should
  give a bit more guidance to the end-user with a small example how this could be
  used.
* Examples, in general, should be extended (`\dontrun`, `\donttest` stuff).

* I've put some download-examples/tests into the `inst` directory. This will
  be ignored when building the package. **Note**: that some examples
  (e.g., `download_ecmwf_ifs.R`) require a non-public ECMWF user account.


# ecmwfr with CDS support (Reto)

* Allows to use local `.ecmwfapirc` and `.cdsapirc` files (as the python
  package does) to provide the user login details.
* Support for climate data store (CDS) including
  `cds_set_key` and `cds_get_key` (wrapper functions) and
  `cds_retrieve` which is slighty different (different authentification).
* New function `wf_key_from_file` reads email/key from `.ecmwfapirc` file.
  Moved `keyring` from `import` to `suggets` (only used if `wf_set_key`,
  `wf_get_key` or the `cds_*` wrappers are called).

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
