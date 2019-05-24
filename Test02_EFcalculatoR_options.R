
# insert the speed here, in km/h
speed <- 120

# insert the slope here. Options are: -0.06, -0.04, -0.02, 0.00, 0.02, 0.04, 0.06
# this only makes sense for categories Heavy Duty Trucks and Buses
# keep NA for categories Passenger Cars and Light Commercial Vehicles
# keep NA for pollutants CH4, NH3 and N2O within categories Heavy Duty Trucks and Buses
slope <- c(NA)

# insert the slope here. Options are: 0.0, 0.5, 1.0
# this only makes sense for categories Heavy Duty Trucks and Buses
# keep NA for categories Passenger Cars and Light Commercial Vehicles
load <- c(NA)

# insert the pollutans here
# Options: CO, NOx, VOC, PM Exhaust, FC, CH4 for categories Passenger Cars and Light Commercial Vehicles
# this vector cannot be left empty
pollutants <- c('CO', 'NOx', 'PM Exhaust')

# insert here the driving modes to be discriminated here.
# discrimination by pollutant
# categories Passenger Cars and Light Commercial Vehicles:
# this only makes sense for pollutants PM Exhaust and CH4. Options: Urban Peak, Urban Off Peak, Rural, Highway
# categories Heavy Duty Trucks and Buses:
# this only makes sense for pollutants CH4, NH3 and N2O
# if not needed, keep an empty vector.
modes <- c('', '', 'Highway')

# insert the categories to be discriminated here. Options: Passenger Cars, Light Commercial Vehicles, Heavy Duty Trucks, Buses
# this vector cannot be left empty
categories <- c('Passenger Cars',
                'Light Commercial Vehicles')
categories_fraction <- c(0.814, 0.187)
# give a name for the group of categories, e.g. Light Vehicles
categories_name <- c('Light Vehicles')

# insert the fuels to be discriminated here.
# # discrimination by categories
# Options for Passenger Cars, Light Commercial Vehicles:
# Petrol, Diesel, Petrol Hybrid, LPG Bifuel ~ LPG, LPG Bifuel ~ Petrol, CNG Bifuel ~ CNG, CNG Bifuel ~ Petrol
# Options for Heavy Duty Trucks: Petrol, Diesel
# Options for Buses: Diesel, CNG, Biodiesel
# this vector cannot be left empty
# one distribution per category
fuels <- list() ; fuels_fraction <- list()
fuels[[1]] <- c('Petrol', 'Diesel', 'LPG Bifuel ~ LPG')
fuels_fraction[[1]] <- c(0.34, 0.64, 0.008)
fuels[[2]] <- c('Petrol', 'Diesel')
fuels_fraction[[2]] <- c(0, 1)

# insert the segments to be discriminated here.
# discrimination by categories
# Options for Passenger Cars: Mini, Small, Medium, Large-SUV-Executive, 2-Stroke
# Options for Light Commercial Vehicles: N1-I, N1-II, N1-III
# Options for Heavy Duty Trucks: >3,5 t, Rigid <=7,5 t, Rigid 7,5 - 12 t, Rigid 12 - 14 t, Rigid 14 - 20 t, Rigid 20 - 26 t, Rigid 26 - 28 t, Rigid 28 - 32 t, Rigid >32 t
#       Articulated 14 - 20 t, Articulated 20 - 28 t, Articulated 28 - 34 t, Articulated 34 - 40 t, Articulated 40 - 50 t, Articulated 50 - 60 t
# Options for Buses: Urban Buses Midi <=15 t, Urban Buses Standard 15 - 18 t, Urban Buses Articulated >18 t, Coaches Standard <=18 t, Coaches Articulated >18 t
#       Urban CNG Buses, Urban Biodiesel Buses
# the vector can be left empy. If so, segments_fraction has no consequence
segments <- list() ; segments_fraction <- list()
segments[[1]] <- c('Small', 'Medium', 'Large-SUV-Executive')
segments_fraction[[1]] <- c(0.55, 0.394, 0.056)
segments[[2]] <- list()
segments_fraction[[2]] <- list()

# insert the euro standards to be discriminated here.
# discrimination by categories
# Options for Passenger Cars: Euro 4, Euro 5, Euro 6 up to 2016, Euro 6 2017-2019, Euro 6 2020+, PRE ECE, ECE 15/00-01, ECE 15/02, ECE 15/03
#       ECE 15/04, Improved Conventional, Open Loop, Euro 1, Euro 2, Euro 3, Conventional, Euro 6
# Options for Light Commercial Vehicles: Conventional, Euro 1, Euro 2, Euro 3, Euro 4, Euro 5, Euro 6 up to 2016, Euro 6 2017-2019, Euro 6 2020+
#       Euro 6 up to 2017, Euro 6 2018-2020, Euro 6 2021+
# Options for Heavy Duty Trucks: Conventional, Euro I, Euro II, Euro III, Euro IV, Euro V, Euro VI
# Options for Buses: Conventional, Euro I, Euro II, Euro III, Euro IV, Euro V, Euro VI, EEV
# the vector can be left empy. If so, euro_standards_fraction has no consequence
euro_standards <- list() ; euro_standards_fraction <- list()
euro_standards[[1]] <- c('Conventional', 'Euro 1', 'Euro 2', 'Euro 3', 'Euro 4', 'Euro 5', 'Euro 6 up to 2016', 'Euro 6 2017-2019', 'Euro 6 2020+')
euro_standards_fraction[[1]] <- c(0, 0, 0.152, 0.254, 0.191, 0.109, 0.078, 0.029, 0)
euro_standards_fraction[[1]] <- euro_standards_fraction[[1]]/sum(euro_standards_fraction[[1]])
euro_standards[[2]] <- c('Conventional', 'Euro 1', 'Euro 2', 'Euro 3', 'Euro 4', 'Euro 5', 'Euro 6 up to 2016', 'Euro 6 2017-2019', 'Euro 6 2020+')
euro_standards_fraction[[2]] <- c(0, 0, 0.035, 0.058, 0.044, 0.025, 0.018, 0.067, 0)
euro_standards_fraction[[2]] <- euro_standards_fraction[[2]]/sum(euro_standards_fraction[[2]])
# The division by the sum is to express the distribution up to 100% within each category

# Insert the technologies to be discriminated here.
# discrimination by categories
# Options for Passenger Cars and for Light Commercial Vehicles: GDI, PFI, GDI+GPF, DPF, DPF+SCR, LNT+DPF
# Options for Heavy Duty Trucks and for Buses : SCR, EGR, DPF+SCR
# the vector can be left empy. If so, technologies_fraction has no consequence
technologies <- list() ; technologies_fraction <- list()
technologies[[1]] <- list()
technologies_fraction[[1]] <- list()
technologies[[2]] <- list()
technologies_fraction[[2]] <- list()
