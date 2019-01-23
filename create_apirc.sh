#!/bin/bash

cat <<EOF > ~/.cdsapirc
url: https://cds.climate.copernicus.eu/api/v2
key: ${CDSAPIUSER}:${CDSAPIKEY}
EOF

cat <<EOF > ~/.ecmwfapirc
{
    "url"   : "https://api.ecmwf.int/v1",
    "key"   : "${ECMWFAPIKEY}",
    "email" : "${ECMWFAPIEMAIL}"
}
EOF

