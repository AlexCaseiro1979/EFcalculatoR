
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

# insert the pollutans here. Options: CO, NOx, VOC, PM Exhaust, FC, CH4
# this vector cannot be left empty
pollutants <- c('CO', 'NOx', 'PM Exhaust', 'VOC')

# insert the categories to be discriminated here. Options: Passenger Cars, Light Commercial Vehicles
# this vector cannot be left empty
categories <- c('Passenger Cars',
                'Light Commercial Vehicles')
categories_fraction <- c(0.814, 0.187)
# give a name for the group of categories, e.g. Light Vehicles
categories_name <- c('Light Vehicles')

# Insert the fuels to be discriminated here. Options: Petrol, Diesel, Petrol Hybrid, LPG Bifuel ~ LPG, LPG Bifuel ~ Petrol, CNG Bifuel ~ CNG, CNG Bifuel ~ Petrol
# this vector cannot be left empty
# one distribution per category
fuels <- list() ; fuels_fraction <- list()
fuels[[1]] <- c('Petrol', 'Diesel', 'LPG Bifuel ~ LPG')
fuels_fraction[[1]] <- c(0.34, 0.64, 0.008)
fuels[[2]] <- c('Petrol', 'Diesel')
fuels_fraction[[2]] <- c(0, 1)

# Insert the Segments to be discriminated here.
# the vector can be left empy. If so, segments_fraction has no consequence
segments <- list() ; segments_fraction <- list()
segments[[1]] <- c('Small', 'Medium', 'Large-SUV-Executive')
segments_fraction[[1]] <- c(0.55, 0.394, 0.056)
segments[[2]] <- list()
segments_fraction[[2]] <- list()

# Insert the euro standards to be discriminated here.
# the vector can be left empy. If so, euro_standards_fraction has no consequence
euro_standards <- list() ; euro_standards_fraction <- list()
euro_standards[[1]] <- c('Conventional', 'Euro 1', 'Euro 2', 'Euro 3', 'Euro 4', 'Euro 5', 'Euro 6 up to 2016', 'Euro 6 2017-2019', 'Euro 6 2020+')
euro_standards_fraction[[1]] <- c(0, 0, 0.152, 0.254, 0.191, 0.109, 0.078, 0.029, 0)
euro_standards_fraction[[1]] <- euro_standards_fraction[[1]]/sum(euro_standards_fraction[[1]])
euro_standards[[2]] <- c('Conventional', 'Euro 1', 'Euro 2', 'Euro 3', 'Euro 4', 'Euro 5', 'Euro 6 up to 2016', 'Euro 6 2017-2019', 'Euro 6 2020+')
euro_standards_fraction[[2]] <- c(0, 0, 0.035, 0.058, 0.044, 0.025, 0.018, 0.067, 0)
euro_standards_fraction[[2]] <- euro_standards_fraction[[2]]/sum(euro_standards_fraction[[2]])
# The division by the sum is to express the distribution up to 100% within each category

# Insert the technologies to be discriminated here. Options: GDI, PFI, GDI+GPF, DPF, DPF+SCR, LNT+DPF
# the vector can be left empy. If so, technologies_fraction has no consequence
technologies <- list() ; technologies_fraction <- list()
technologies[[1]] <- list()
technologies_fraction[[1]] <- list()
technologies[[2]] <- list()
technologies_fraction[[2]] <- list()

# insert here the driving modes to be discriminated here.
# categories Passenger Cars and Light Commercial Vehicles:
# this only makes sense for pollutants PM Exhaust and CH4. Options: Urban Peak, Urban Off Peak, Rural, Highway
# categories Heavy Duty Trucks and Buses:
# this only makes sense for pollutants CH4, NH3 and N2O
# if not needed, keep an empty vector.
modes <- c('', '', 'Highway', '')
