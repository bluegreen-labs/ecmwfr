# ecmwfr <img src="man/figures/logo.png" align="right" height="138.5"/>

[![R-CMD-check](https://github.com/bluegreen-labs/ecmwfr/workflows/R-CMD-check/badge.svg)](https://github.com/bluegreen-labs/ecmwfr/actions)
[![codecov](https://codecov.io/gh/bluegreen-labs/ecmwfr/branch/master/graph/badge.svg)](https://codecov.io/gh/bluegreen-labs/ecmwfr)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/ecmwfr)](https://cran.r-project.org/package=ecmwfr)
[![Project Status: Active -- The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://cranlogs.r-pkg.org/badges/grand-total/ecmwfr)](https://cran.r-project.org/package=ecmwfr)
[![DOI](https://zenodo.org/badge/156325084.svg)](https://zenodo.org/badge/latestdoi/156325084)

Programmatic interface to the two [European Centre for Medium-Range
Weather Forecasts](https://www.ecmwf.int/) API services. The package
provides easy access to all available Data Stores from within R, matching and
expanding upon the ECMWF python tools. Support is provided for the 
[Climate Data Store](https://cds-beta.climate.copernicus.eu), the 
[Atmosphere Data Store](https://ads.atmosphere.copernicus.eu) and the
[Early Warning Data Store](https://cds.climate.copernicus.eu) (from the 
Copernicus Emergency Management Services).

## How to cite this package

You can cite this package like this "we obtained data from the European
Centre for Medium-Range Weather Forecasts API using the ecmwf R package
(Hufkens, Stauffer, and Campitelli 2019)". Here is the full
bibliographic reference to include in your reference list (don't forget
to update the 'last accessed' date):

> Hufkens, K., R. Stauffer, & E. Campitelli. (2019). ecmwfr:
> Programmatic interface to the two European Centre for Medium-Range
> Weather Forecasts API services. Zenodo.
> <http://doi.org/10.5281/zenodo.2647531>.

## Installation

### stable release

To install the current stable release use a CRAN repository:

``` r
install.packages("ecmwfr")
library("ecmwfr")
```

### development release

To install the development releases of the package run the following
commands:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("bluegreen-labs/ecmwfr")
library("ecmwfr")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("bluegreen-labs/ecmwfr", build_vignettes = TRUE)
library("ecmwfr")
```

## Use: ECMWF services

Create a ECMWF account by [self
registering](https://accounts.ecmwf.int/auth/realms/ecmwf/protocol/openid-connect/registrations?client_id=apps&response_type=code&scope=openid%20email&redirect_uri=https://www.ecmwf.int)
and retrieving your key at <https://api.ecmwf.int/v1/key/> after you log
in. The key is a long series of numbers and characters (X in the example
below).

``` json
{
    "url"   : "https://api.ecmwf.int/v1",
    "key"   : "XXXXXXXXXXXXXXXXXXXXXX",
    "email" : "john.smith@example.com"
}
```

## Use: Copernicus Data Stores (xDS)

Create a free CDS user account by [self
registering](https://cds.climate.copernicus.eu/user/register). Once your
user account has been verified you can get your personal *user ID* and
*key* by visiting the [user
profile](https://cds.climate.copernicus.eu/user). This information is
required to be able to retrieve data via the `ecmwfr` package. Use the
`ecmwf` [`wf_set_key`](references/wf_set_key.html) function to store
your login information in the system keyring (see below). Be aware, that
unlike the API key for the ECMWF API your `user` does not correspond to
the email address you use for the CDS login.

``` json
UID: 1234
API key: abcd1234-foo-bar-98765431-XXXXXXXXXX
```

### Setup

If you prefer to use your local keychain (rather than using the
`.cdsapirc` file) you have to save your login information first. The
package does not allow you to use your key inline in scripts to limit
security issues when sharing scripts on github or otherwise.

``` r
# set a key to the keychain
wf_set_key(user = "1234",
            key = "abcd1234-foo-bar-98765431-XXXXXXXXXX",
            service = "cds")

# you can retrieve the key using
wf_get_key(user = "1234")

# the output should be the key you provided
# "abcd1234-foo-bar-98765431-XXXXXXXXXX"

# Alternatively you can input your login info with an interactive request
wf_set_key(service = "cds")

# you will get a command line request to provide the required details
```

Before you can download any data you have to make sure to accept the
terms and conditions here: Before downloading and processing data from
CDS please make sure you accept the terms and conditions which can be
found here: [Copernicus Climate Data Store
Disclaimer/Privacy](https://cds.climate.copernicus.eu/disclaimer-privacy).

### Data Requests

To download data use the [`wf_request`](references/wf_request.html)
function, together with your *user ID* and a request string syntax [as
documented](https://confluence.ecmwf.int/display/WEBAPI/Brief+request+syntax#Briefrequestsyntax-Syntax).
Instead of `json` formatting the function uses a simple `R` list for all
the arguments. Be sure to specify the service you want to use in your
query in this case `cds`.

**Note**: the simplest way to get the requests is to go to the CDS
website which offers an interactive interface to create these requests.
E.g., for ERA-5 reanalysis:

-   [pressure level
    data](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-pressure-levels?tab=form)
-   [surface
    data](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form)
-   ...

``` r
# This is an example of a request for # downloading 'ERA-5' reanalysis data for
# 2000-04-04 00:00 UTC, temperature on # 850 hectopascal for an area covering 
# northern Europe.
# File will be stored as "era5-demo.nc" (netcdf format).
request <- list(
 "dataset_short_name" = "reanalysis-era5-pressure-levels",
 "product_type" = "reanalysis",
 "variable" = "temperature",
 "pressure_level" = "850",
 "year" = "2000",
 "month" = "04",
 "day" = "04",
 "time" = "00:00",
 "area" = "70/-20/00/60",
 "format" = "netcdf",
 "target" = "era5-demo.nc"
 )

# If you have stored your user login information
# in the keyring by calling cds_set_key you can
# call:
file <- wf_request(
 user     = "1234",   # user ID (for authentification)
 request  = request,  # the request
 transfer = TRUE,     # download the file
 path     = "."       # store data in current working directory
 )
```

The CDS services are quite fast, however, if you request a lot of
variables, multiple levels, and data over several years these requests
might take quite a while! **Note**: If you need to download larger
amounts of data it is suggested to split the downloads, e.g., download
the data in chunks (e.g., month-by-month, or year-by-year). A progress
indicator will keep you informed on the status of your request. Keep in
mind that all data downloaded will be buffered in memory limiting the
downloads to \~6GB on low end systems.

## File based keychains

On linux you can opt to use a file based keyring, instead of a GUI based
keyring manager. This is helpful for headless setups such as servers.
For this option to work linux users must set an environmental option.

``` r
options(keyring_backend="file")
```

You will be asked to provide a password to encrypt the keyring with.
Upon the start of each session you will be asked to provide this
password, unlocking all `ecmwfr` credentials for this session. Should
you ever forget the password just delete the file at:
`~/.config/r-keyring/ecmwfr.keyring` and re-enter all your credentials.

## Date specification

For those familiar with the old ECMWF *mars* syntax: CDS/ADS/CEMS does not accept
`date = "2000-01-01/to/2000-12-31"` specifications. It is possible to
specify one specific date via `date = "2000-01-01"` or multiple days via
`date = ["2000-01-01","2000-01-02","2000-10-20"]` or
`date = "YYYY-MM-DD/YYYY-MM-DD"`. Specifying the date as a range allows
you to sidestep the [ERA5T restricted access
issue](https://confluence.ecmwf.int/pages/viewpage.action?pageId=277352608&focusedCommentId=278530169).

## Citation

Hufkens, K., R. Stauffer, & E. Campitelli. (2019). ecmwfr: Programmatic
interface to the two European Centre for Medium-Range Weather Forecasts
API services. Zenodo. <http://doi.org/10.5281/zenodo.2647531>.

## Acknowledgements

This project is maintained by BlueGreen Labs (BV). This project was in the past
partially supported by the Belgian Science Policy office
COBECORE project (BELSPO; grant BR/175/A3/COBECORE), a "Fonds voor
Wetenschappelijk Onderzoek" travel grant (FWO; V438318N) and the Marie
Skłodowska-Curie Action (H2020 grant 797668). Logo design elements are
taken from the FontAwesome library according to [these
terms](https://fontawesome.com/license), where the globe element was
inverted and intersected.
