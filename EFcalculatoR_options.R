#######################################################################################

# FUNCTION FOR GROUP 1 POLLUTANTS

# the first variable for the function is the roadway name

# the second variable for the function are the speeds, in km/h
# one speed for each category in the fleet distribution file

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

EF_Group1('Test01',
        c(120,110),
        2, NA, NA,
        c('CO', 'NOx'),
        c('', ''),
        'distFleetLightweightPT.R')
EF_Group1('Test02',
        c(120,110),
        2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust'),
        c('', '', 'Highway'),
        'distFleetLightweightPT.R')
EF_Group1('Test03',
        c(120,110),
        2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC'),
        c('', '', 'Highway', ''),
        'distFleetLightweightPT.R')
EF_Group1('Test04',
        c(120,110),
        2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4'),
        c('', '', 'Highway', '', '', 'Highway'),
        'distFleetLightweightPT.R')
EF_Group1('Test05',
        c(80),
        2, 0.02, 0.5,
        c('CO'),
        c(''),
        'distFleetTrucksPT.R')
EF_Group1('Test06',
        c(80),
        2, 0.02, 0.5,
        c('CO', 'NOx'),
        c('', ''),
        'distFleetTrucksPT.R')
EF_Group1('Test07',
        c(80),
        2, 0.02, 0.5,
        c('CO', 'NOx', 'PM Exhaust', 'FC', 'CH4'),
        c('', '', 'Highway', '', 'Highway'),
        'distFleetTrucksPT.R')

#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF LENGTH TRAVELLED

# the first variable for the function is the roadway name

# the second variable for the function are the speeds, in km/h
# one speed for each category in the fleet distribution file

# the third variable for the function is the length of the roadway, in km

# the fourth variable for the function are the pollutants
# Options for Passenger Cars, Light Commercial Vehicles, Heavy Duty Trucks and Buses:
#       benzo(a)pyrene, PCDD, PCDF
# this vector cannot be left empty

# the fifth variable is the fleet distribution file

EF_perLength('Test08',
        c(120,110),
        2,
        c('benzo(a)pyrene', 'PCDD', 'PCDF'),
        'distFleetLightweightPT.R')

EF_perLength('Test09',
        c(80),
        2,
        c('benzo(a)pyrene', 'PCDD', 'PCDF'),
        'distFleetTrucksPT.R')


#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF FUEL CONSUMED

# options 1, 2, 3, 4, 5 and 8 are the same as for the function EF_Group1

# the sixth variable for the function are the pollutants
# Options are:
#   Pb, Cd, Cu, Cr, Ni, Se, Zn, Hg, As and SO2

# the seventh variable for the function is to be left empty

EF_perFuel('Test10',
        c(120,110),
        2, NA, NA,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2'),
        c(),
        'distFleetLightweightPT.R')
EF_perFuel('Test11',
        c(80),
        2, 0.02, 0.5,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2'),
        c(),
        'distFleetTrucksPT.R')


#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF FUEL CONSUMED

# options 1, 2, 3, 4, 5, 7 and 8 are the same as for the function EF_Group1

# Since there is the need to compute the EF of VOCs and CH4,
# option 7 (driving modes) should not be left empty.

# the sixth variable for the function are the pollutants
# Options are:
#   toluene, mp-xylene, o-xylene

EF_perVOC('Test12',
        c(120,110),
        2, NA, NA,
        c('toluene', 'mp-xylene', 'o-xylene'),
        c('Highway', 'Highway', 'Highway'),
        'distFleetLightweightPT.R')
EF_perVOC('Test13',
        c(80),
        2, 0.02, 0.5,
        c('toluene', 'mp-xylene', 'o-xylene'),
        c('Highway', 'Highway', 'Highway'),
        'distFleetTrucksPT.R')
