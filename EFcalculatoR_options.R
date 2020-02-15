#######################################################################################

# FUNCTION TO INITIATE THE OUTPUT

# define the rootname of the output files

fileOut <- 'TestAll'

# this produces a csv file with the following fields:
# Roadway, Pollutant, Category, EF, unit
# do not modify the following two lines
fileOut_csv <- paste(fileOut,'_EF.csv', sep='')
writeOutputTable('roadway', 'pollutant', 'category', 'EF', 'unit', 'init')

#######################################################################################

# FUNCTION FOR GROUP 1 POLLUTANTS

# the first variable for the function is the roadway name

# the second variable for the function are the speeds, in km/h
# one speed for each category in the fleet distribution file

# the third variable for the function is the length of the roadway, in km

# the fourth variable for the function is the slope
# Options are: -0.06, -0.04, -0.02, 0.00, 0.02, 0.04, 0.06
# this only makes sense for categories Heavy Duty Trucks and Buses
# keep NA for categories Passenger Cars, Light Commercial Vehicles and L-category
# keep NA for pollutants CH4, NH3 and N2O within categories Heavy Duty Trucks and Buses

# the fifth variable for the function is the load
# Options are: 0.0, 0.5, 1.0
# this only makes sense for categories Heavy Duty Trucks and Buses
# keep NA for categories Passenger Cars, Light Commercial Vehicles and L-category

# the sixth variable for the function are the pollutants
# Options for Passenger Cars and Light Commercial Vehicles:
#       CO, NOx, VOC, PM Exhaust, FC, CH4
# Options for Heavy Duty Trucks and Buses:
#       CO, NOx, VOC, FC, CH4, NH3, N2O, PM Exhaust
# this vector cannot be left empty

# the seventh variable for the function are the driving modes to be discriminated here.
# discrimination by pollutant within discrimination by category
# categories Passenger Cars and Light Commercial Vehicles:
#   this only makes sense for pollutants PM Exhaust and CH4.
#   Options: Urban Peak, Urban Off Peak, Rural, Highway
# categories Heavy Duty Trucks and Buses:
#   this only makes sense for pollutants CH4, NH3 and N2O
#   Options: Urban Peak, Urban Off Peak, Rural, Highway
# L-Categories:
#   for Mopeds: all pollutants; for Motorcycles: PM Exhaust, CH4, NH3, N2O
# if not needed, keep an empty vector.

# the eighth variable is the fleet distribution file

EF_Group1_pre('via01',
        c(120,110,80),
        2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4'),
        list(c('', '', 'Highway', '', '', 'Highway'),
             c('', '', 'Highway', '', '', 'Highway'),
             c('Highway', 'Highway', 'Highway', 'Highway', 'Highway', 'Highway')),
        'distFleetLightweightPT.R',
        'write')

EF_Group1_pre('via01',
        c(80,90),
        2, 0.02, 0.5,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4', 'NH3', 'N2O'),
        list(c('', '', '', '', '', 'Highway', 'Highway', 'Highway'),
             c('', '', '', '', '', 'Highway', 'Highway', 'Highway')),
        'distFleetHeavyweightPT.R',
        'write')

EF_Group1_pre('via02',
        c(60,60,50),
        2, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4'),
        list(c('', '', 'Highway', '', '', 'Highway'),
             c('', '', 'Highway', '', '', 'Highway'),
             c('Highway', 'Highway', 'Highway', 'Highway', 'Highway', 'Highway')),
        'distFleetLightweightPT.R',
        'write')

EF_Group1_pre('via02',
        c(50,50),
        3, 0.04, 0.5,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4', 'NH3', 'N2O'),
        list(c('', '', '', '', '', 'Highway', 'Highway', 'Highway'),
             c('', '', '', '', '', 'Highway', 'Highway', 'Highway')),
        'distFleetHeavyweightPT.R',
        'write')

#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF LENGTH TRAVELLED

# the first variable for the function is the roadway name

# the second variable for the function are the speeds, in km/h
# one speed for each category in the fleet distribution file

# the third variable for the function is the length of the roadway, in km

# the fourth variable for the function are the pollutants
# Options for Passenger Cars, Light Commercial Vehicles, Heavy Duty Trucks and Buses:
#       benzo(a)pyrene, PCDD, PCDF, PM Brakes, PM Road paved, PM Tyres, CO2 lubricant
# this vector cannot be left empty

# the fifth variable is the fleet distribution file

EF_perLength('via01',
        c(120,110,90),
        2,
        c('benzo(a)pyrene', 'PCDD', 'PCDF', 'PM Brakes', 'PM Road paved', 'PM Tyres', 'CO2 lubricant'),
        'distFleetLightweightPT.R',
        'write')

EF_perLength('via01',
        c(80,90),
        2,
        c('benzo(a)pyrene', 'PCDD', 'PCDF', 'PM Brakes', 'PM Road paved', 'PM Tyres', 'CO2 lubricant'),
        'distFleetHeavyweightPT.R',
        'write')

EF_perLength('via02',
        c(60,60,50),
        2,
        c('benzo(a)pyrene', 'PCDD', 'PCDF', 'PM Brakes', 'PM Road paved', 'PM Tyres', 'CO2 lubricant'),
        'distFleetLightweightPT.R',
        'write')

EF_perLength('via02',
        c(50,50),
        2,
        c('benzo(a)pyrene', 'PCDD', 'PCDF', 'PM Brakes', 'PM Road paved', 'PM Tyres', 'CO2 lubricant'),
        'distFleetHeavyweightPT.R',
        'write')

#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF FUEL CONSUMED

# options 1, 2, 3, 4, 5 and 8 are the same as for the function EF_Group1_pre

# the sixth variable for the function are the pollutants
# Options are:
#   Pb, Cd, Cu, Cr, Ni, Se, Zn, Hg, As, SO2 and CO2 fuel
#   NH3 lightweigth and N2O lightweigth for Lightweight vehicles (Tier 1 calculation)

# the seventh variable for the function is to be left as one empty string
# for each category in the fleet distribution file, within a list

EF_perFuel_pre('via01',
        c(120,110,90),
        2, NA, NA,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2', 'CO2 fuel', 'NH3 lightweigth', 'N2O lightweigth'),
        list(c(''),c(''),c('')),
        'distFleetLightweightPT.R',
        'write')

EF_perFuel_pre('via01',
        c(80,90),
        2, 0.02, 0.5,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2', 'CO2 fuel'),
        list(c(''),c('')),
        'distFleetHeavyweightPT.R',
        'write')

EF_perFuel_pre('via02',
        c(60,60,50),
        2, NA, NA,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2', 'CO2 fuel', 'NH3 lightweigth', 'N2O lightweigth'),
        list(c(''),c(''),c('')),
        'distFleetLightweightPT.R',
        'write')

EF_perFuel_pre('via02',
        c(50,50),
        2, 0.04, 0.5,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2', 'CO2 fuel'),
        list(c(''),c('')),
        'distFleetHeavyweightPT.R',
        'write')


#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF VOCS PRODUCED

# options 1, 2, 3, 4, 5, 7 and 9 are the same as for the function EF_Group1_pre

# Since there is the need to compute the EF of VOCs and CH4,
# option 7 (driving modes for VOCs) is to be left as one empty string
# for each category in the fleet distribution file, within a list
# option 8 (driving modes) should not be left empty for CH4.

# the sixth variable for the function are the pollutants
# Options are:
#   toluene, mp-xylene, o-xylene, benzene

EF_perVOC_pre('via01',
        c(120,110,90),
        2, NA, NA,
        c('toluene', 'mp-xylene', 'o-xylene', 'benzene'),
        list(c(''),c(''),c(''),c('')),
        c('Highway', 'Highway', 'Highway', 'Highway'),
        'distFleetLightweightPT.R',
        'write')

EF_perVOC_pre('via01',
        c(80,90),
        2, 0.02, 0.5,
        c('toluene', 'mp-xylene', 'o-xylene', 'benzene'),
        list(c(''),c(''),c(''),c('')),
        c('Highway', 'Highway', 'Highway', 'Highway'),
        'distFleetHeavyweightPT.R',
        'write')

EF_perVOC_pre('via02',
        c(60,60,50),
        2, NA, NA,
        c('toluene', 'mp-xylene', 'o-xylene', 'benzene'),
        list(c(''),c(''),c(''),c('')),
        c('Highway', 'Highway', 'Highway', 'Highway'),
        'distFleetLightweightPT.R',
        'write')

EF_perVOC_pre('via02',
        c(50,50),
        2, 0.04, 0.5,
        c('toluene', 'mp-xylene', 'o-xylene', 'benzene'),
        list(c(''),c(''),c(''),c('')),
        c('Highway', 'Highway', 'Highway', 'Highway'),
        'distFleetHeavyweightPT.R',
        'write')


#######################################################################################

# FUNCTION FOR PM from unpaved road (road dust from unpaved road), industrial sites

# the first variable for the function is the roadway name
# the second variable is the average vehicle weight for the different categories considered (tons)
# the third variable is the mean vehichle speed (km/h) for the different categories
# the fourth variable is the distribuition (sum=1) for the different categories
# the fifth variable is the surface material silt content (%)
# the sixth variable is the length of the roadway in km

# EF_rd_unpaved_ind('Test05a',
#         c(10, 15, 20),
#         c(25, 25, 25),
#         c(0.2, 0.6, 0.1),
#         0.094,
#         2,
#         'write')


#######################################################################################

# FUNCTIONS TO PRODUCE THE FINAL TABLES

# this produces a csv file per roadway per pollutant per fleet
# the files have the following fields:
# Roadway, Fleet, Hour, activity, EF, unit
activity_csv <- 'activity.csv'
writeEmissionTables(fileOut_csv, activity_csv)

pollutantGroups <- c('PM10', 'xylene', 'Dioxins+Furans', 'CO2', 'NH3_all', 'N2O_all')
pollutantsInGroups <- list(c('PM Exhaust', 'PM Tyres', 'PM Brakes', 'PM Road paved'),
                           c('o-xylene', 'mp-xylene'),
                           c('PCDD', 'PCDF'),
                           c('CO2 fuel', 'CO2 lubricant'),
                           c('NH3', 'NH3 lightweight'),
                           c('N2O', 'N2O lightweight'))
writeEmissionTablesGroups()
