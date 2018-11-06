[![Build Status](https://travis-ci.org/khufkens/ecmwfr.svg?branch=master)](https://travis-ci.org/khufkens/ecmwfr)
<a href="https://www.buymeacoffee.com/H2wlgqCLO" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" height="21px" ></a>
<a href="https://liberapay.com/khufkens/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg" height="21px"></a>

# ecmwfr

Programmatic interface to the ['ECMWF' web API services](https://modis.ornl.gov/data/modis_webservice.html). Allows for easy downloads of ECMWF data.

## Installation

To install the toolbox in R run the following commands in a R terminal

```R
if(!require(devtools)){install.packages(devtools)}
devtools::install_github("khufkens/ecmwfr")
library("ecmwfr")
```

## Use

Before starting, acquire a ECMWF API token, and set a key to your local keychain. The package does not allow you to set your token inline as a function argument to limit security issues when sharing scripts on github or otherwise.

```R
# set key
wf_set_key(email = "test@mail.com", key = "123")

# get key
wf_get_key(email = "test@mail.com")
```
Downloading data

```R
# download data ...
```

## Acknowledgements

This project was in part supported by the Belgian Science Policy office COBECORE project (BELSPO; grant BR/175/A3/COBECORE) and a "Fonds voor Wetenschappelijk Onderzoek" travel grant (FWO; V438318N).

