

import calendar
import datetime

import cdstoolbox as ct

@ct.application(
    title='',
    meta_title='Daily statistics calculated from ERA5 data',
    meta_description=(
        'This application allows users to compute and download '
        'selected daily statistics from a number of ERA5 datasets. '
        'It provides a simple tool for '
        'aggregating ERA5 data at daily frequency without having '
        'to download the original sub-daily resolution data. It '
        'is particularly useful for users who need the daily '
        'mean of ERA5 variables.'
    )
)
@ct.output.markdown()
def dummy_application():
    """
    This dummy application provides a link to a version of the application
    which is run as the user, not as the public application user.

    To run this application in you own toolbox environment you must delete this
    dummy application and redefine the main application.
    """

    return (
    '# To use the ERA5 daily statistics calculator please '
    'follow the link below, login is required.\n\n'
    '# [ERA5 daily statistics calculator]'
    '(https://cds.climate.copernicus.eu/apps/user-apps/'
    'app-c3s-daily-era5-statistics){:target="_blank"}'
)

def label_to_value_string(label):
    label = label.replace(' (relative)', '')
    value = label.replace(' ', '_').replace('-', '_').replace(',', '').lower()
    return value


def wrap_to_month(m):
    month = (m - 1) % 12 + 1
    return month


# PARAMETERS
today = datetime.date.today()
(day_today, month_today, year_today) = (today.day, today.month, today.year)

# I'm assuming
# - ERA5 hourly on single levels and pressure levels get published with a delay of 5 days;
# - ERA5-Land gets published with a delay of 2 month and 5 days,
# I'm adding one more day to be sure to also have the first day of the next
# month available (for "negative" time-zones)
if day_today >= 6:
    last_month_available_e5 = wrap_to_month(month_today - 1)
    last_month_available_e5l = wrap_to_month(month_today - 3)
else:
    last_month_available_e5 = wrap_to_month(month_today - 2)
    last_month_available_e5l = wrap_to_month(month_today - 4)
if (month_today - last_month_available_e5) > 0:
    last_year_available_e5 = year_today
else:
    last_year_available_e5 = (year_today - 1)
if (month_today - last_month_available_e5l) > 0:
    last_year_available_e5l = year_today
else:
    last_year_available_e5l = (year_today - 1)

# Temporal coverage of E5 and E5L are the same, we leave the seprate descriptions
# here in case temporal coverage differs in the future.
YEARS_E5 = [str(year) for year in range(1950, last_year_available_e5 + 1)]
YEARS_E5_LINK = {str(year): 'past' for year in YEARS_E5}
YEARS_E5_LINK[str(last_year_available_e5)] = 'last_e5'
YEARS_E5L = [str(year) for year in range(1950, last_year_available_e5l + 1)]
YEARS_E5L_LINK = {str(year): 'past' for year in YEARS_E5L}
YEARS_E5L_LINK[str(last_year_available_e5l)] = 'last_e5'

DESCRIPTION = (
    'This application allows users to compute and download selected '
    'daily statistics in local time (via the *Time zone* widget) '
    'of variables from a number of hourly ERA5 reanalysis datasets. '
    'Before computing the daily statistics the ERA5 hourly data can '
    'be subsampled in time (using the '
    '*Frequency* widget) and space (using the *Grid* and *Area* widget). '
    'Further details can be found in the application [Overview]'
    '(https://cds.climate.copernicus.eu/cdsapp#!/software/'
    'app-c3s-daily-era5-statistics?tab=overview){:target="_blank"}'
    ' and [Documentation](https://cds.climate.copernicus.eu/cdsapp#!/'
    'software/app-c3s-daily-era5-statistics?tab=doc){:target="_blank"}.\n\n'
#     'To use this application you must accept the terms and conditions of the '
#     '[Copernicus licence](https://cds.climate.copernicus.eu/api/v2/terms/'
#     'static/licence-to-use-copernicus-products.pdf){:target="_blank"}'
)

DATASETS = [
    {
        'value': 'reanalysis-era5-single-levels',
        'label': f'ERA5 hourly data on single levels from 1950 to {last_year_available_e5} (including back extension)'
    },
    {
        'value': 'reanalysis-era5-pressure-levels',
        'label': f'ERA5 hourly data on pressure levels from 1950 to {last_year_available_e5} (including back extension)'
    },
    {'value': 'reanalysis-era5-land', 'label': f'ERA5-Land hourly data from 1950 to {last_year_available_e5l} (including back extension)'}
]
PRODUCT_TYPES = [
    {'value': 'reanalysis', 'label': 'Reanalysis'},
    {'value': 'ensemble_members', 'label': 'Ensemble members'},
    {'value': 'ensemble_mean', 'label': 'Ensemble mean'},
]
# define variables type
ACCUMULATED_FIELDS = [
    'large_scale_precipitation_fraction',
    'downward_uv_radiation_at_the_surface', 'boundary_layer_dissipation',
    'surface_sensible_heat_flux', 'surface_latent_heat_flux',
    'surface_solar_radiation_downwards', 'surface_thermal_radiation_downwards',
    'surface_net_solar_radiation', 'surface_net_thermal_radiation',
    'top_net_solar_radiation', 'top_net_thermal_radiation',
    'eastward_turbulent_surface_stress', 'northward_turbulent_surface_stress',
    'eastward_gravity_wave_surface_stress',
    'northward_gravity_wave_surface_stress', 'gravity_wave_dissipation',
    'top_net_solar_radiation_clear_sky', 'top_net_thermal_radiation_clear_sky',
    'surface_net_solar_radiation_clear_sky',
    'surface_net_thermal_radiation_clear_sky', 'toa_incident_solar_radiation',
    'vertically_integrated_moisture_divergence',
    'total_sky_direct_solar_radiation_at_surface',
    'clear_sky_direct_solar_radiation_at_surface',
    'surface_solar_radiation_downward_clear_sky',
    'surface_thermal_radiation_downward_clear_sky', 'surface_runoff',
    'sub_surface_runoff', 'snow_evaporation', 'snowmelt',
    'large_scale_precipitation', 'convective_precipitation', 'snowfall',
    'evaporation', 'runoff', 'total_precipitation', 'convective_snowfall',
    'large_scale_snowfall', 'potential_evaporation', 'total_evaporation',
    'evaporation_from_bare_soil', 'evaporation_from_the_top_of_canopy',
    'evaporation_from_open_water_surfaces_excluding_oceans',
    'evaporation_from_vegetation_transpiration',
]
MEAN_FIELDS = [
    'Mean boundary layer dissipation',
    'Mean convective precipitation rate', 'Mean convective snowfall rate',
    'Mean eastward gravity wave surface stress',
    'Mean eastward turbulent surface stress', 'Mean evaporation rate',
    'Mean gravity wave dissipation',
    'Mean large-scale precipitation fraction',
    'Mean large-scale precipitation rate',
    'Mean large-scale snowfall rate',
    'Mean northward gravity wave surface stress',
    'Mean northward turbulent surface stress',
    'Mean potential evaporation rate', 'Mean runoff rate',
    'Mean snow evaporation rate', 'Mean snowfall rate',
    'Mean snowmelt rate', 'Mean sub-surface runoff rate',
    'Mean surface direct short-wave radiation flux',
    'Mean surface direct short-wave radiation flux, clear sky',
    'Mean surface downward UV radiation flux',
    'Mean surface downward long-wave radiation flux',
    'Mean surface downward long-wave radiation flux, clear sky',
    'Mean surface downward short-wave radiation flux',
    'Mean surface downward short-wave radiation flux, clear sky',
    'Mean surface latent heat flux',
    'Mean surface net long-wave radiation flux',
    'Mean surface net long-wave radiation flux, clear sky',
    'Mean surface net short-wave radiation flux',
    'Mean surface net short-wave radiation flux, clear sky',
    'Mean surface runoff rate', 'Mean surface sensible heat flux',
    'Mean top downward short-wave radiation flux',
    'Mean top net long-wave radiation flux',
    'Mean top net long-wave radiation flux, clear sky',
    'Mean top net short-wave radiation flux',
    'Mean top net short-wave radiation flux, clear sky',
    'Mean total precipitation rate',
    'Mean vertically integrated moisture divergence'
]
# MEAN_FIELDS = [
#     label_to_value_string(lab) for lab in MEAN_FIELDS
# ]

VARIABLES_LABELS = {
    'e5sl': [
        '10m u-component of wind', '10m v-component of wind',
        '2m dewpoint temperature', '2m temperature', 'Mean sea level pressure',
        'Mean wave direction', 'Mean wave period', 'Sea surface temperature',
        'Significant height of combined wind waves and swell',
        'Surface pressure', 'Total precipitation',
        '2m dewpoint temperature', '2m temperature', 'Ice temperature layer 1',
        'Ice temperature layer 2', 'Ice temperature layer 3',
        'Ice temperature layer 4',
        'Maximum 2m temperature since previous post-processing',
        'Mean sea level pressure',
        'Minimum 2m temperature since previous post-processing',
        'Sea surface temperature', 'Skin temperature', 'Surface pressure',
        '100m u-component of wind', '100m v-component of wind',
        '10m u-component of neutral wind', '10m u-component of wind',
        '10m v-component of neutral wind', '10m v-component of wind',
        '10m wind gust since previous post-processing',
        'Instantaneous 10m wind gust',
        'Mean boundary layer dissipation',
        'Mean convective precipitation rate', 'Mean convective snowfall rate',
        'Mean eastward gravity wave surface stress',
        'Mean eastward turbulent surface stress', 'Mean evaporation rate',
        'Mean gravity wave dissipation',
        'Mean large-scale precipitation fraction',
        'Mean large-scale precipitation rate',
        'Mean large-scale snowfall rate',
        'Mean northward gravity wave surface stress',
        'Mean northward turbulent surface stress',
        'Mean potential evaporation rate', 'Mean runoff rate',
        'Mean snow evaporation rate', 'Mean snowfall rate',
        'Mean snowmelt rate', 'Mean sub-surface runoff rate',
        'Mean surface direct short-wave radiation flux',
        'Mean surface direct short-wave radiation flux, clear sky',
        'Mean surface downward UV radiation flux',
        'Mean surface downward long-wave radiation flux',
        'Mean surface downward long-wave radiation flux, clear sky',
        'Mean surface downward short-wave radiation flux',
        'Mean surface downward short-wave radiation flux, clear sky',
        'Mean surface latent heat flux',
        'Mean surface net long-wave radiation flux',
        'Mean surface net long-wave radiation flux, clear sky',
        'Mean surface net short-wave radiation flux',
        'Mean surface net short-wave radiation flux, clear sky',
        'Mean surface runoff rate', 'Mean surface sensible heat flux',
        'Mean top downward short-wave radiation flux',
        'Mean top net long-wave radiation flux',
        'Mean top net long-wave radiation flux, clear sky',
        'Mean top net short-wave radiation flux',
        'Mean top net short-wave radiation flux, clear sky',
        'Mean total precipitation rate',
        'Mean vertically integrated moisture divergence',
        'Clear-sky direct solar radiation at surface',
        'Downward UV radiation at the surface',
        'Forecast logarithm of surface roughness for heat',
        'Instantaneous surface sensible heat flux',
        'Near IR albedo for diffuse radiation',
        'Near IR albedo for direct radiation', 'Surface latent heat flux',
        'Surface net solar radiation',
        'Surface net solar radiation, clear sky',
        'Surface net thermal radiation',
        'Surface net thermal radiation, clear sky',
        'Surface sensible heat flux',
        'Surface solar radiation downward, clear sky',
        'Surface solar radiation downwards',
        'Surface thermal radiation downward, clear sky',
        'Surface thermal radiation downwards', 'TOA incident solar radiation',
        'Top net solar radiation', 'Top net solar radiation, clear sky',
        'Top net thermal radiation', 'Top net thermal radiation, clear sky',
        'Total sky direct solar radiation at surface',
        'UV visible albedo for diffuse radiation',
        'UV visible albedo for direct radiation',
        'Cloud base height', 'High cloud cover', 'Low cloud cover',
        'Medium cloud cover', 'Total cloud cover',
        'Total column cloud ice water', 'Total column cloud liquid water',
        'Vertical integral of divergence of cloud frozen water flux',
        'Vertical integral of divergence of cloud liquid water flux',
        'Vertical integral of eastward cloud frozen water flux',
        'Vertical integral of eastward cloud liquid water flux',
        'Vertical integral of northward cloud frozen water flux',
        'Vertical integral of northward cloud liquid water flux',
        'Lake bottom temperature', 'Lake ice depth', 'Lake ice temperature',
        'Lake mix-layer depth', 'Lake mix-layer temperature',
        'Lake shape factor', 'Lake total layer temperature',
        # 'Lake cover', 'Lake depth',
        'Evaporation', 'Potential evaporation', 'Runoff', 'Sub-surface runoff',
        'Surface runoff',
        'Convective precipitation', 'Convective rain rate',
        'Instantaneous large-scale surface precipitation fraction',
        'Large scale rain rate', 'Large-scale precipitation',
        'Large-scale precipitation fraction',
        'Maximum total precipitation rate since previous post-processing',
        'Minimum total precipitation rate since previous post-processing',
        'Precipitation type', 'Total column rain water', 'Total precipitation',
        'Convective snowfall', 'Convective snowfall rate water equivalent',
        'Large scale snowfall rate water equivalent', 'Large-scale snowfall',
        'Snow albedo', 'Snow density', 'Snow depth', 'Snow evaporation',
        'Snowfall', 'Snowmelt', 'Temperature of snow layer',
        'Total column snow water',
        'Soil temperature level 1', 'Soil temperature level 2',
        'Soil temperature level 3', 'Soil temperature level 4',
        'Volumetric soil water layer 1', 'Volumetric soil water layer 2',
        'Volumetric soil water layer 3', 'Volumetric soil water layer 4',
        'Vertical integral of divergence of cloud frozen water flux',
        'Vertical integral of divergence of cloud liquid water flux',
        'Vertical integral of divergence of geopotential flux',
        'Vertical integral of divergence of kinetic energy flux',
        'Vertical integral of divergence of mass flux',
        'Vertical integral of divergence of moisture flux',
        'Vertical integral of divergence of ozone flux',
        'Vertical integral of divergence of thermal energy flux',
        'Vertical integral of divergence of total energy flux',
        'Vertical integral of eastward cloud frozen water flux',
        'Vertical integral of eastward cloud liquid water flux',
        'Vertical integral of eastward geopotential flux',
        'Vertical integral of eastward heat flux',
        'Vertical integral of eastward kinetic energy flux',
        'Vertical integral of eastward mass flux',
        'Vertical integral of eastward ozone flux',
        'Vertical integral of eastward total energy flux',
        'Vertical integral of eastward water vapour flux',
        'Vertical integral of energy conversion',
        'Vertical integral of kinetic energy',
        'Vertical integral of mass of atmosphere',
        'Vertical integral of mass tendency',
        'Vertical integral of northward cloud frozen water flux',
        'Vertical integral of northward cloud liquid water flux',
        'Vertical integral of northward geopotential flux',
        'Vertical integral of northward heat flux',
        'Vertical integral of northward kinetic energy flux',
        'Vertical integral of northward mass flux',
        'Vertical integral of northward ozone flux',
        'Vertical integral of northward total energy flux',
        'Vertical integral of northward water vapour flux',
        'Vertical integral of potential and internal energy',
        'Vertical integral of potential, internal and latent energy',
        'Vertical integral of temperature',
        'Vertical integral of thermal energy',
        'Vertical integral of total energy',
        'Vertically integrated moisture divergence',
        'Leaf area index, high vegetation', 'Leaf area index, low vegetation',
        'Air density over the oceans', 'Altimeter corrected wave height',
        'Altimeter wave height', 'Coefficient of drag with waves',
        'Free convective velocity over the oceans',
        'Maximum individual wave height', 'Mean direction of total swell',
        'Mean direction of wind waves', 'Mean period of total swell',
        'Mean period of wind waves', 'Mean square slope of waves',
        'Mean wave direction', 'Mean wave direction of first swell partition',
        'Mean wave direction of second swell partition',
        'Mean wave direction of third swell partition', 'Mean wave period',
        'Mean wave period based on first moment',
        'Mean wave period based on first moment for swell',
        'Mean wave period based on first moment for wind waves',
        'Mean wave period based on second moment for swell',
        'Mean wave period based on second moment for wind waves',
        'Mean wave period of first swell partition',
        'Mean wave period of second swell partition',
        'Mean wave period of third swell partition',
        'Mean zero-crossing wave period', 'Normalized energy flux into ocean',
        'Normalized energy flux into waves', 'Normalized stress into ocean',
        'Ocean surface stress equivalent 10m neutral wind direction',
        'Ocean surface stress equivalent 10m neutral wind speed',
        'Peak wave period',
        'Period corresponding to maximum individual wave height',
        'Significant height of combined wind waves and swell',
        'Significant height of total swell',
        'Significant height of wind waves',
        'Significant wave height of first swell partition',
        'Significant wave height of second swell partition',
        'Significant wave height of third swell partition',
        'Wave spectral directional width',
        'Wave spectral directional width for swell',
        'Wave spectral directional width for wind waves',
        'Wave spectral kurtosis', 'Wave spectral peakedness',
        'Wave spectral skewness',
        'Altimeter range relative correction', 'Benjamin-feir index',
        'Boundary layer dissipation', 'Boundary layer height', 'Charnock',
        'Convective available potential energy', 'Convective inhibition',
        'Duct base height', 'Eastward gravity wave surface stress',
        'Eastward turbulent surface stress', 'Forecast albedo',
        'Forecast surface roughness', 'Friction velocity',
        'Gravity wave dissipation',
        'Instantaneous eastward turbulent surface stress',
        'Instantaneous moisture flux',
        'Instantaneous northward turbulent surface stress', 'K index',
        'Mean vertical gradient of refractivity inside trapping layer',
        'Minimum vertical gradient of refractivity inside trapping layer',
        'Model bathymetry', 'Northward gravity wave surface stress',
        'Northward turbulent surface stress', 'Sea-ice cover',
        'Skin reservoir content', 'Total column ozone',
        'Total column supercooled liquid water', 'Total column water',
        'Total column water vapour', 'Total totals index',
        'Trapping layer base height', 'Trapping layer top height',
        'U-component stokes drift', 'V-component stokes drift',
        'Zero degree level'
    ],
    'e5pl': [
        'Divergence', 'Fraction of cloud cover', 'Geopotential',
        'Ozone mass mixing ratio', 'Potential vorticity', 'Relative humidity',
        'Specific cloud ice water content', 'Specific cloud liquid water content',
        'Specific humidity', 'Specific rain water content',
        'Specific snow water content', 'Temperature', 'U-component of wind',
        'V-component of wind', 'Vertical velocity', 'Vorticity (relative)'
    ],
    'e5l': [
        '2m dewpoint temperature', '2m temperature', 'Skin temperature',
        'Soil temperature level 1', 'Soil temperature level 2',
        'Soil temperature level 3', 'Soil temperature level 4',
        'Lake bottom temperature', 'Lake ice depth', 'Lake ice temperature',
        'Lake mix-layer depth', 'Lake mix-layer temperature',
        'Lake shape factor', 'Lake total layer temperature',
        'Snow albedo', 'Snow cover', 'Snow density', 'Snow depth',
        'Snow depth water equivalent', 'Snowfall', 'Snowmelt',
        'Temperature of snow layer',
        'Skin reservoir content',
        'Volumetric soil water layer 1', 'Volumetric soil water layer 2',
        'Volumetric soil water layer 3', 'Volumetric soil water layer 4',
        'Forecast albedo', 'Surface latent heat flux',
        'Surface net solar radiation',
        'Surface net thermal radiation',
        'Surface sensible heat flux',
        'Surface solar radiation downwards',
        'Surface thermal radiation downwards',
        'Evaporation from bare soil',
        'Evaporation from open water surfaces excluding oceans',
        'Evaporation from the top of canopy',
        'Evaporation from vegetation transpiration',
        'Potential evaporation', 'Runoff', 'Snow evaporation',
        'Sub-surface runoff', 'Surface runoff', 'Total evaporation',
        '10m u-component of wind', '10m v-component of wind',
        'Surface pressure', 'Total precipitation',
        'Leaf area index, high vegetation', 'Leaf area index, low vegetation'
    ]
}

# temporary fix to remove accumulated variables from ERA5-land:
VARIABLES_LABELS['e5l'] = [
    label for label in VARIABLES_LABELS['e5l']
    if label_to_value_string(label) not in ACCUMULATED_FIELDS
]

VARIABLES = {
    dataset: [
        {
            'label': label,
            'value': label_to_value_string(label)
        } for label in sorted(VARIABLES_LABELS[dataset])
    ] for dataset in [*VARIABLES_LABELS]
}

LEVELS = [
    '1', '2', '3', '5', '7', '10', '20', '30', '50',
    '70', '100', '125', '150', '175', '200', '225', '250', '300',
    '350', '400', '450', '500', '550', '600', '650', '700', '750',
    '775', '800', '825', '850', '875', '900', '925', '950', '975',
    '1000'
]

MONTHS = [
    {
        'label': month_name,
        'value': f'{month_num:02}'
    } for month_num, month_name in enumerate(calendar.month_name) if month_num
]
MONTHS_PAST_YEAR = MONTHS
MONTHS_CURRENT_YEAR_E5 = MONTHS[:last_month_available_e5]
MONTHS_CURRENT_YEAR_E5L = MONTHS[:last_month_available_e5l]

DAYS = [f'{day:02}' for day in range(1, 32)]
TIMES = [f'{hour:02}:00' for hour in range(0, 24)]

OFFSETS = [
    '-12:00', '-11:00', '-10:00', '-09:00', '-08:00', '-07:00', '-06:00',
    '-05:00', '-04:00', '-03:00', '-02:00', '-01:00', '+00:00', '+01:00',
    '+02:00', '+03:00', '+04:00', '+05:00', '+06:00', '+07:00', '+08:00',
    '+09:00', '+10:00', '+11:00', '+12:00', '+13:00', '+14:00'
]
TIME_ZONES = [f'UTC{offset}' for offset in OFFSETS]

GRIDS_E5 = [
    '0.25/0.25', '0.5/0.5', '1.0/1.0', '1.5/1.5',
    '2.0/2.0', '2.5/2.5', '3.0/3.0'
]
GRIDS_E5L = [
    '0.1/0.1', '0.25/0.25', '0.5/0.5', '1.0/1.0', '1.5/1.5',
    '2.0/2.0', '2.5/2.5', '3.0/3.0'
]

STATISTICS = [
    {'label': 'Daily mean', 'value': 'daily_mean'},
    {'label': 'Daily minimum', 'value': 'daily_minimum'},
    {'label': 'Daily maximum', 'value': 'daily_maximum'},
    {'label': 'Daily mid-range', 'value': 'daily_mid_range'}
]
STATISTIC_TO_FUNCTION = {
    'daily_mean': 'mean',
    'daily_maximum': 'max',
    'daily_minimum': 'min',
    'daily_mid_range': 'mid-range'
}

RETRIEVAL_FREQUENCIES = ['1-hourly' , '3-hourly', '6-hourly']


def check_area_in_area_retrieve(area, area_retrieve):
    overlap = max(0, min(area['lon'][1], area_retrieve['lon'][1]) - max(area['lon'][0], area_retrieve['lon'][0]))
    return bool(overlap)


def retrieve_reanalysis(dataset, variable, pressure_level, product_type, year, month, day, time, grid, area):
    request = {
        'variable': variable,
        'product_type': product_type,
        'year': year,
        'month': month,
        'day': day,
        'time': time,
        'grid': grid,
        'area': [area['lat'][1], area['lon'][0], area['lat'][0], area['lon'][1]]
    }
    if pressure_level != '-':
        request['pressure_level'] = pressure_level

    data = ct.catalogue.retrieve(dataset, request)

    return data


def add_necessary_data(
        data, dataset, variable, pressure_level, product_type, year, month, grid, area, time_shift
):
    time_shift_sign = time_shift[0]
    if time_shift_sign == '-':
        datetime_to_add = (
                datetime.datetime(int(year), int(month), 1) +
                datetime.timedelta(
                    days=calendar.monthrange(int(year), int(month))[1]
                )
        )
        if datetime_to_add > datetime.datetime(1978, 12, 31):
            dataset = dataset.replace('-preliminary-back-extension', '')
        data_to_add = retrieve_reanalysis(
            dataset, variable, pressure_level, product_type, datetime_to_add.year,
            f'{datetime_to_add.month:02}', f'{datetime_to_add.day:02}',
            TIMES, grid, area
        )
        data = concat([data, data_to_add], dim='time')
    elif int(time_shift[:2].strip(':')):
        datetime_to_add = (
                datetime.datetime(int(year), int(month), 1) -
                datetime.timedelta(days=1)
        )
        if datetime_to_add < datetime.datetime(1979, 1, 1):
            dataset = dataset.replace('-preliminary-back-extension', '')
            dataset = dataset + '-preliminary-back-extension'
        data_to_add = retrieve_reanalysis(
            dataset, variable, pressure_level, product_type, datetime_to_add.year,
            f'{datetime_to_add.month:02}', f'{datetime_to_add.day:02}',
            TIMES, grid, area
        )
        data = concat([data_to_add, data], dim='time')

    return data


def daily_midrange(data):
    daily_min = ct.cube.resample(data, freq='D', how='min')
    daily_max = ct.cube.resample(data, freq='D', how='max')
    daily_midrange = (daily_min + daily_max) / 2

    return daily_midrange


def concat(data_list, **kwargs):

    coords = [list(ct.cdm.get_coordinates(data)) for data in data_list]
    non_common_coords = list(reduce(lambda x, y: set(x)^set(y), coords))

    concat_list = [ct.cdm.drop_coordinates(data, non_common_coords)
                   for data in data_list]
    result = ct.cube.concat(concat_list, **kwargs)
    return result


# layout preferences
variable_widget_md = 6
level_widget_md = 3
year_widget_md = 2
grid_widget_md = 5

variable_widget_sm = 12
level_widget_sm = 6
year_widget_sm = 6
grid_widget_sm = 4

layout = ct.Layout(rows=7, justify='center', fluid=False)

layout.add_widget(row=0, markdown=DESCRIPTION)
# layout.add_widget(row=1, content='licence')

layout.add_widget(row=2, content='dataset', md=9, sm=12, v_align='flex-end')
layout.add_widget(row=2, content='product_type', md=3, sm=12, v_align='flex-end')

layout.add_widget(row=3, content='variable_e5sl', md=variable_widget_md, sm=variable_widget_sm, v_align='flex-end')
layout.add_widget(row=3, content='variable_e5pl', md=variable_widget_md, sm=variable_widget_sm, v_align='flex-end')
layout.add_widget(row=3, content='variable_e5l', md=variable_widget_md, sm=variable_widget_sm, v_align='flex-end')
layout.add_widget(row=3, content='pressure_level_e5sl', md=level_widget_md, sm=level_widget_sm, v_align='flex-end')
layout.add_widget(row=3, content='pressure_level_e5pl', md=level_widget_md, sm=level_widget_sm, v_align='flex-end')
layout.add_widget(row=3, content='pressure_level_e5l', md=level_widget_md, sm=level_widget_sm, v_align='flex-end')
layout.add_widget(row=3, content='statistic', md=3, sm=6, v_align='flex-end')

layout.add_widget(row=4, content='year_e5sl', md=year_widget_md, sm=year_widget_sm, v_align='flex-end')
layout.add_widget(row=4, content='year_e5pl', md=year_widget_md, sm=year_widget_sm, v_align='flex-end')
layout.add_widget(row=4, content='year_e5l', md=year_widget_md, sm=year_widget_sm, v_align='flex-end')
layout.add_widget(row=4, content='month', md=3, sm=6, v_align='flex-end')
layout.add_widget(row=4, content='time_zone', md=4, sm=6, v_align='flex-end')
layout.add_widget(row=4, content='frequency', md=3, sm=6, v_align='flex-end')

layout.add_widget(row=5, content='grid_e5', md=grid_widget_md, sm=grid_widget_sm)
layout.add_widget(row=5, content='grid_e5l', md=grid_widget_md, sm=grid_widget_sm)
layout.add_widget(row=5, content='area', md=7, sm=8, v_align='flex-end')

layout.add_widget(row=6, content='output-0', md=9, sm=12, v_align='flex-end')
layout.add_widget(row=6, content='output-1', md=9, sm=12, v_align='flex-end')
layout.add_widget(row=6, content='[submit]', md=3, sm=12, v_align='flex-end')

PRODUCT_TYPE_DESCRIPTION = 'ERA5 product type'
CATEGORY_DESCRIPTION = 'ERA5 variable category'
VARIABLE_DESCRIPTION = 'ERA5 variable (list depending on selected Category)'
LEVEL_DESCRIPTION = 'Pressure level (if applicable)'

# @ct.application(   # To run in your own environment, uncomment this line
@ct.child(          # To run in your own environment, comment out this line
    title='Daily statistics calculated from ERA5 data',
    autorun=False, layout=layout,
    meta_title='Daily statistics calculated from ERA5 data',
    meta_description='This application allows users to compute and download '
                     'selected daily statistics from a number of ERA5 datasets. '
                     'It provides a simple tool for '
                     'aggregating ERA5 data at daily frequency without having '
                     'to download the original sub-daily resolution data. It '
                     'is particularly useful for users who need the daily '
                     'mean of ERA5 variables.',
#     sync_query_string=False
)
# @ct.input.checkbox(
#     'licence', label=' ',
#     values=['I agree to the terms and conditions.']
# )
@ct.input.dropdown(
    'dataset', label='Dataset', values=DATASETS,
    link={
        'reanalysis-era5-single-levels': ['product_type_e5sl', 'variable_e5sl', 'level_e5sl', 'year_e5sl', 'grid_e5'],
        'reanalysis-era5-pressure-levels': ['product_type_e5pl', 'variable_e5pl', 'level_e5pl', 'year_e5pl', 'grid_e5'],
        'reanalysis-era5-land': ['product_type_e5l', 'variable_e5l', 'level_e5l', 'year_e5l', 'grid_e5l']
    })
@ct.input.dropdown('product_type', label='Product type', values=PRODUCT_TYPES, when='product_type_e5sl')
@ct.input.dropdown('product_type', label='Product type', values=PRODUCT_TYPES, when='product_type_e5pl')
@ct.input.dropdown('product_type', label='Product type', values=[PRODUCT_TYPES[0]], when='product_type_e5l')
@ct.input.dropdown('variable_e5sl', label='Variable', values=VARIABLES['e5sl'], when='variable_e5sl')
@ct.input.dropdown('variable_e5pl', label='Variable', values=VARIABLES['e5pl'], when='variable_e5pl')
@ct.input.dropdown('variable_e5l', label='Variable', values=VARIABLES['e5l'], when='variable_e5l')
@ct.input.dropdown('pressure_level_e5sl', label='Pressure level (hPa)', values=['-', ], when='level_e5sl')
@ct.input.dropdown('pressure_level_e5pl', label='Pressure level (hPa)', values=LEVELS, when='level_e5pl', default='850')
@ct.input.dropdown('pressure_level_e5l', label='Pressure level (hPa)', values=['-', ], when='level_e5l')
@ct.input.dropdown('statistic', label='Statistic', values=STATISTICS, default='daily_mean')
@ct.input.dropdown('year_e5sl', label='Year', values=YEARS_E5[::-1], link=YEARS_E5_LINK, when='year_e5sl')
@ct.input.dropdown('year_e5pl', label='Year', values=YEARS_E5[::-1], link=YEARS_E5_LINK, when='year_e5pl')
@ct.input.dropdown('year_e5l', label='Year', values=YEARS_E5L[::-1], link=YEARS_E5L_LINK, when='year_e5l')
@ct.input.dropdown('month', label='Month', values=MONTHS_PAST_YEAR, when='past')
@ct.input.dropdown('month', label='Month', values=MONTHS_CURRENT_YEAR_E5, when='last_e5')
@ct.input.dropdown('frequency', label='Frequency', values=RETRIEVAL_FREQUENCIES)
@ct.input.dropdown('time_zone', label='Time zone', values=TIME_ZONES, default='UTC+00:00')
@ct.input.dropdown('grid_e5', label='Grid (DD)', values=GRIDS_E5, when='grid_e5')
@ct.input.dropdown('grid_e5l', label='Grid (DD)', values=GRIDS_E5L, when='grid_e5l', default='0.1/0.1')
@ct.input.extent('area', label='Geographical area', default={'lat': [-90, 90], 'lon': [-180, 180]}, compact=True)
@ct.output.download()
@ct.output.markdown()
def application(
    # licence='True',
    dataset='reanalysis-era5-single-levels', product_type='reanalysis',
    variable='2m_temperature', variable_e5sl='2m_temperature', variable_e5pl='2m_temperature', variable_e5l='2m_temperature',
    pressure_level='-', pressure_level_e5sl='-', pressure_level_e5pl='-', pressure_level_e5l='-',
    statistic='daily_mean',
    year=YEARS_E5[-1], year_e5sl=YEARS_E5[-1], year_e5pl=YEARS_E5[-1], year_e5l=YEARS_E5[-1],
    month=MONTHS_CURRENT_YEAR_E5[-1]['value'], frequency='1-hourly', time_zone='UTC+00:00',
    grid='0.25/0.25', grid_e5='0.25/0.25', grid_e5l='0.25/0.25',
    area={'lat': [-90, 90], 'lon': [-180, 180]}
):
    # if not licence:
    #     return (
    #         ct.output.NULL_RESULT,
    #         '**Please agree to the terms and conditions**'
    #     )

    for year_all in (year_e5sl, year_e5pl, year_e5l):
        if year_all != YEARS_E5[-1]:
            year = year_all
    if int(year) < 1979 and dataset != 'reanalysis-era5-land':
        dataset = dataset + '-preliminary-back-extension'

    for variable_all in (variable_e5sl, variable_e5pl, variable_e5l):
        if variable_all != '2m_temperature':
            variable = variable_all

    for pressure_level_all in (pressure_level_e5sl, pressure_level_e5pl, pressure_level_e5l):
        if pressure_level_all != '-':
            pressure_level = pressure_level_all

    statistic = STATISTIC_TO_FUNCTION[statistic]

    frequency = int(frequency.split('-')[0])

    for grid_all in (grid_e5, grid_e5l):
        if grid_all != '0.25/0.25':
            grid = grid_all
    if grid != '0.1/0.1':
        areas_retrieve = [{'lat': [-90, 90], 'lon': [-180, 180]}]
    else:
        # retrieve is splitted for resources availability
        areas_retrieve_all = [
            {'lat': [-90, 90], 'lon': [-180, -90.05]}, {'lat': [-90, 90], 'lon': [-90, -0.05]},
            {'lat': [-90, 90], 'lon': [0, 89.95]}, {'lat': [-90, 90], 'lon': [90, 180]}
        ]
        areas_retrieve = []
        for area_retrieve in areas_retrieve_all:
            if check_area_in_area_retrieve(area, area_retrieve):
                areas_retrieve.append(area_retrieve)

    daily_stat_concat = []

    for area_retrieve in areas_retrieve:

        data = retrieve_reanalysis(
            dataset, variable, pressure_level, product_type, year, month, DAYS, TIMES, grid, area_retrieve
        )

        # shift time coordinates
        time_shift = time_zone.replace('UTC', '')
        # In accumulated and mean fields, fields are cumulated/averaged over
        # the hour preceding the timestamp. On the contrary, 00:00 is
        # associated to the day starting at 00:00 by resample. So, to correctly
        # compute daily quantities, accumulated and mean fields have to be
        # shifted one hour back before aggregation
        if variable in (ACCUMULATED_FIELDS + MEAN_FIELDS):
            new_shift = int(time_shift[:3]) - 1
            time_shift = f'{new_shift}:00'
        time_shift = time_shift.replace('+', '')

        # retrieve and concat other data, if needed
        data = add_necessary_data(
            data, dataset, variable, pressure_level, product_type, year, month, grid, area_retrieve, time_shift
        )

        # keep only selected region
        if area != {'lat': [-90, 90], 'lon': [-180, 180]}:
            data = ct.cube.select(
                data, extent=(
                    area['lon'][0], area['lon'][1],
                    area['lat'][0], area['lat'][1]
                )
            )

        if int(time_shift.replace(':', '')):
            data_shifted = ct.cube.shift_coordinates(
                data, {'time': f'{time_shift}:00'}
            )
        else:
            data_shifted = data

        # subset with chosen frequency
        if frequency != 1:
            data_shifted = ct.cube.select(
                data_shifted, start_time=f'{year}-{month}-01 00:00:00',
                step_time=frequency
            )

        # compute daily statistic
        if statistic != 'mid-range':
            daily_stat = ct.cube.resample(
                data_shifted, freq='D', how=statistic
            )
        else:
            daily_stat = daily_midrange(data_shifted)

        # keep only selected month
        daily_stat = ct.cube.select(daily_stat, time=f'{year}-{month}')

        # concat
        if not daily_stat_concat:
            daily_stat_concat = daily_stat
        else:
            daily_stat_concat = concat(
                [daily_stat_concat, daily_stat], dim='lon'
            )

    return daily_stat_concat, ct.output.NULL_RESULT

