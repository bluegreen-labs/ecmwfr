import cdstoolbox as ct

layout = {
    'input_ncols': 3,
}

variables = {
    'Near-Surface Air Temperature': '2m_temperature',
    'Eastward Near-Surface Wind': '10m_u_component_of_wind',
    'Northward Near-Surface Wind': '10m_v_component_of_wind',
    'Sea Level Pressure': 'mean_sea_level_pressure',
    'Sea Surface Temperature': 'sea_surface_temperature',
}


@ct.application(title='Extract a time series and plot graph', layout=layout)
@ct.input.dropdown('var', label='Variable', values=variables.keys(), description='Sample variables')
@ct.input.text('lon', label='Longitude', type=float, default=75., description='Decimal degrees')
@ct.input.text('lat', label='Latitude', type=float, default=43., description='Decimal degrees')
@ct.output.livefigure()
def plot_time_series(var, lon, lat):
    """
    Application main steps:

    - set the application layout with 3 columns for the input and output at the bottom
    - retrieve a variable over a defined time range
    - select a location, defined by longitude and latitude coordinates
    - compute the daily average
    - show the result as a timeseries on an interactive chart

    """

    # Time range
    data = ct.catalogue.retrieve(
        'reanalysis-era5-single-levels',
        {
            'variable': variables[var],
            'grid': ['3', '3'],
            'product_type': 'reanalysis',
            'year': [
                '2008', '2009', '2010',
                '2011', '2012', '2013',
                '2014', '2015', '2016',
                '2017'
            ],
            'month': [
                '01', '02', '03', '04', '05', '06',
                '07', '08', '09', '10', '11', '12'
            ],
            'day': [
                '01', '02', '03', '04', '05', '06',
                '07', '08', '09', '10', '11', '12',
                '13', '14', '15', '16', '17', '18',
                '19', '20', '21', '22', '23', '24',
                '25', '26', '27', '28', '29', '30',
                '31'
            ],
            'time': ['00:00', '06:00', '12:00', '18:00'],
        }
    )

    # Location selection

    # Extract the closest point to selected lon/lat (no interpolation).
    # If wrong number is set for latitude, the closest available one is chosen:
    # e.g. if lat = 4000 -> lat = 90.
    # If wrong number is set for longitude, first a wrap in [-180, 180] is made,
    # then the closest one present is chosen:
    # e.g. if lon = 200 -> lon = -160.
    data_sel = ct.geo.extract_point(data, lon=lon, lat=lat)

    # Daily mean on selection
    data_daily = ct.climate.daily_mean(data_sel)

    fig = ct.chart.line(data_daily)

    # return fig
    return data_daily
