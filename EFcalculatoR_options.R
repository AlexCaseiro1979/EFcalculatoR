# the first variable for the function is the roadway name

# the second variable for the function is the speed, in km/h

# the third variable for the function is the length of the roadway, in km

# the fourth variable for the function is the slope
# Options are: -0.06, -0.04, -0.02, 0.00, 0.02, 0.04, 0.06
# this only makes sense for categories Heavy Duty Trucks and Buses
# keep NA for categories Passenger Cars and Light Commercial Vehicles
# keep NA for pollutants CH4, NH3 and N2O within categories Heavy Duty Trucks and Buses

# the fifth variable for the function is the load
# Options are: 0.0, 0.5, 1.0
# this only makes sense for categories Heavy Duty Trucks and Buses
# keep NA for categories Passenger Cars and Light Commercial Vehicles

# the sixth variable for the function are the pollutants
# Options for Passenger Cars and Light Commercial Vehicles:
#       CO, NOx, VOC, PM Exhaust, FC, CH4
# Options for Heavy Duty Trucks and Buses:
#       CO, NOx, VOC, FC, CH4, NH3, N2O, PM Exhaust
# this vector cannot be left empty

# the seventh variable for the function are the driving modes to be discriminated here.
# discrimination by pollutant
# categories Passenger Cars and Light Commercial Vehicles:
#   this only makes sense for pollutants PM Exhaust and CH4.
#   Options: Urban Peak, Urban Off Peak, Rural, Highway
# categories Heavy Duty Trucks and Buses:
#   this only makes sense for pollutants CH4, NH3 and N2O
#   Options: Urban Peak, Urban Off Peak, Rural, Highway
# if not needed, keep an empty vector.

# the eighth variable is the fleet distribution file

EFfunc('Test01', 120, 2, NA, NA,
        c('CO', 'NOx'),
        c('', ''),
        'distLightweight.R')
EFfunc('Test02', 120, 2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust'),
        c('', '', 'Highway'),
        'distLightweight.R')
EFfunc('Test03', 120, 2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC'),
        c('', '', 'Highway', ''),
        'distLightweight.R')
EFfunc('Test04', 120, 2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4'),
        c('', '', 'Highway', '', '', 'Highway'),
        'distLightweight.R')
EFfunc('Test05', 80, 2, 0.02, 0.5,
        c('CO'),
        c(''),
        'distTrucks.R')
EFfunc('Test06', 80, 2, 0.02, 0.5,
        c('CO', 'NOx'),
        c('', ''),
        'distTrucks.R')
EFfunc('Test07', 80, 2, 0.02, 0.5,
        c('CO', 'NOx', 'PM Exhaust'),
        c('', '', 'Highway'),
        'distTrucks.R')
