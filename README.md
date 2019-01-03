[![Build Status](https://travis-ci.org/khufkens/ecmwfr.svg?branch=master)](https://travis-ci.org/khufkens/ecmwfr)
[![codecov](https://codecov.io/gh/khufkens/ecmwfr/branch/master/graph/badge.svg)](https://codecov.io/gh/khufkens/ecmwfr)
<a href="https://www.buymeacoffee.com/H2wlgqCLO" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" height="21px" ></a>

# ecmwfr

Programmatic interface to the ['ECMWF' web API services](https://confluence.ecmwf.int/display/WEBAPI/ECMWF+Web+API+Home). Allows for easy downloads of ECMWF [public data](http://apps.ecmwf.int/datasets/).

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
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("khufkens/ecmwfr")
library("ecmwfr")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

``` r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("khufkens/ecmwfr", build_vignettes = TRUE)
library("ecmwfr")
```

Create a ECMWF account by [self registering](https://apps.ecmwf.int/registration/) and retrieving your key at https://api.ecmwf.int/v1/key/ after you log in. The key is a long series of numbers and characters (X in the example below).

```json
{
    "url"   : "https://api.ecmwf.int/v1",
    "key"   : "XXXXXXXXXXXXXXXXXXXXXX",
    "email" : "john.smith@example.com"
}
```

## Use

### Setup

Before starting save the provided key to your local keychain. The package does not allow you to use your key inline in scripts to limit security issues when sharing scripts on github or otherwise.

```R
# set a key to the keychain
wf_set_key(email = "john.smith@example.com", key = "XXXXXXXXXXXXXXXXXXXXXX")

# you can retrieve the key using
wf_get_key(email = "john.smith@example.com")

# the output should be the key you provided
# "XXXXXXXXXXXXXXXXXXXXXX"
```

Before you can download any data you have to make sure to accept the terms and conditions here:
[https://apps.ecmwf.int/datasets/licences/general/](https://apps.ecmwf.int/datasets/licences/general/).

### Data Requests

To download data use the wf_request() function, together with your email and a request string syntax [as documented](https://confluence.ecmwf.int/display/WEBAPI/Brief+request+syntax#Briefrequestsyntax-Syntax). Instead of `json` formatting the function uses a simple `R` list for all the arguments.

```R
# this is an example of a request
my_request <- list(stream = "oper",
                  levtype = "sfc",
                  param = "165.128/166.128/167.128",
                  dataset = "interim",
                  step = "0",
                  grid = "0.75/0.75",
                  time = "00/06/12/18",
                  date = "2014-07-01/to/2014-07-31",
                  type = "an",
                  class = "ei",
                  area = "73.5/-27/33/45",
                  format = "netcdf",
                  target = "tmp.nc")

# an example download using fw_request()
# using the above request list()
# 
# data will be transferred to disk
# and saved in your home directory (~)
# set by the path argument

wf_request(
  email = "john.smith@example.com",
  transfer = TRUE,
  path = "~",
  request = my_request)

```

This operation might take a while. A progress indicator will keep you informed on the status of your request. Keep in mind that all data downloaded will be buffered in memory limiting the downloads to ~6GB on low end systems.

## Acknowledgements

This project was in part supported by the Belgian Science Policy office COBECORE project (BELSPO; grant BR/175/A3/COBECORE) and a "Fonds voor Wetenschappelijk Onderzoek" travel grant (FWO; V438318N).

