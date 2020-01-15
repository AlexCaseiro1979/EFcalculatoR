
# insert the categories to be discriminated here. Options: Passenger Cars, Light Commercial Vehicles, Heavy Duty Trucks, Buses
# this vector cannot be left empty
categories <- c('Heavy Duty Trucks',
                'Buses')
categories_fraction <- c(0.95, 0.05)
# give a name for the group of categories, e.g. Light Vehicles, Trucks, Buses
categories_name <- c('Heavy Vehicles')

# insert the fuels to be discriminated here.
# # discrimination by categories
# Options for Passenger Cars, Light Commercial Vehicles:
#       Petrol, Diesel, Petrol Hybrid, LPG Bifuel ~ LPG, LPG Bifuel ~ Petrol, CNG Bifuel ~ CNG, CNG Bifuel ~ Petrol
# Options for Heavy Duty Trucks: Petrol, Diesel
# Options for Buses: Diesel, CNG, Biodiesel
# this vector cannot be left empty
# one distribution per category
fuels <- list() ; fuels_fraction <- list()
fuels[[1]] <- c('Diesel')
fuels_fraction[[1]] <- c(1)
fuels[[2]] <- c('Diesel')
fuels_fraction[[2]] <- c(1)

# insert the segments to be discriminated here.
# discrimination by categories
# Options for Passenger Cars: Mini, Small, Medium, Large-SUV-Executive, 2-Stroke
# Options for Light Commercial Vehicles: N1-I, N1-II, N1-III
# Options for Heavy Duty Trucks: >3,5 t, Rigid <=7,5 t, Rigid 7,5 - 12 t, Rigid 12 - 14 t, Rigid 14 - 20 t, Rigid 20 - 26 t, Rigid 26 - 28 t, Rigid 28 - 32 t, Rigid >32 t
#       Articulated 14 - 20 t, Articulated 20 - 28 t, Articulated 28 - 34 t, Articulated 34 - 40 t, Articulated 40 - 50 t, Articulated 50 - 60 t
# Options for Buses: Urban Buses Midi <=15 t, Urban Buses Standard 15 - 18 t, Urban Buses Articulated >18 t, Coaches Standard <=18 t, Coaches Articulated >18 t
#       Urban CNG Buses, Urban Biodiesel Buses
# the vector can be left empy. If so, segments_fraction has no consequence and the EFs are averaged through the segments
segments <- list() ; segments_fraction <- list()
segments[[1]] <- c('Rigid <=7,5 t', 'Rigid 7,5 - 12 t', 'Rigid 12 - 14 t', 'Rigid 14 - 20 t', 'Rigid 20 - 26 t', 'Rigid 26 - 28 t', 'Rigid 28 - 32 t', 'Rigid >32 t',
                   'Articulated 14 - 20 t', 'Articulated 20 - 28 t', 'Articulated 28 - 34 t', 'Articulated 34 - 40 t', 'Articulated 40 - 50 t', 'Articulated 50 - 60 t'
                  )
segments_fraction[[1]] <- c(0.085453486, 0.026218683, 0.013206448, 0.05156341, 0.001359487, 0.010973004, 0, 0.373664789,
                            0.05156341, 0.012332492, 0.006409011, 0, 0.367255778, 0
                           )
segments[[2]] <- c('Urban Buses Midi <=15 t', 'Urban Buses Standard 15 - 18 t', 'Urban Buses Articulated >18 t', 'Coaches Standard <=18 t', 'Coaches Articulated >18 t',
                   'Urban CNG Buses', 'Urban Biodiesel Buses'
                  )
segments_fraction[[2]] <- c(0.07040202, 0.008156924, 0.421441057, 0.078558943, 0.421441057
                           )

# insert the euro standards to be discriminated here.
# discrimination by categories
# Options for Passenger Cars: Euro 4, Euro 5, Euro 6 up to 2016, Euro 6 2017-2019, Euro 6 2020+, PRE ECE, ECE 15/00-01, ECE 15/02, ECE 15/03
#       ECE 15/04, Improved Conventional, Open Loop, Euro 1, Euro 2, Euro 3, Conventional, Euro 6
# Options for Light Commercial Vehicles: Conventional, Euro 1, Euro 2, Euro 3, Euro 4, Euro 5, Euro 6 up to 2016, Euro 6 2017-2019, Euro 6 2020+
#       Euro 6 up to 2017, Euro 6 2018-2020, Euro 6 2021+
# Options for Heavy Duty Trucks: Conventional, Euro I, Euro II, Euro III, Euro IV, Euro V, Euro VI
# Options for Buses: Conventional, Euro I, Euro II, Euro III, Euro IV, Euro V, Euro VI, EEV
# the vector can be left empy. If so, euro_standards_fraction has no consequence and the EFs are averaged through the Euro standards
euro_standards <- list() ; euro_standards_fraction <- list()
euro_standards[[1]] <- c('Conventional', 'Euro I', 'Euro II', 'Euro III', 'Euro IV', 'Euro V', 'Euro IV')
euro_standards_fraction[[1]] <- c(0, 0, 0.159, 0.264, 0.204, 0.119, 0.096+0.048)
euro_standards_fraction[[1]] <- euro_standards_fraction[[1]]/sum(euro_standards_fraction[[1]])
# The division by the sum is to express the distribution up to 100% within each category
euro_standards[[2]] <- c('Conventional', 'Euro I', 'Euro II', 'Euro III', 'Euro IV', 'Euro V', 'Euro IV', 'EEV')
euro_standards_fraction[[2]] <- c(0, 0, 0.021, 0.034, 0.027, 0.016, 0.0126+0.0062)
euro_standards_fraction[[2]] <- euro_standards_fraction[[2]]/sum(euro_standards_fraction[[2]])

# Insert the technologies to be discriminated here.
# discrimination by categories
# Options for Passenger Cars and for Light Commercial Vehicles: GDI, PFI, GDI+GPF, DPF, DPF+SCR, LNT+DPF
# Options for Heavy Duty Trucks and for Buses : SCR, EGR, DPF+SCR
# the vector can be left empy. If so, technologies_fraction has no consequence and the EFs are averaged through the technologies
# The EMEP/EEA document advises 75% for SCR and 25% for EGR for Heavy duty vehicles
technologies <- list() ; technologies_fraction <- list()
#technologies[[1]] <- list()
#technologies_fraction[[1]] <- list()
technologies[[1]] <- c('SCR', 'EGR')
technologies_fraction[[1]] <- c(0.75, 0.25)
technologies[[2]] <- c('SCR', 'EGR')
technologies_fraction[[2]] <- c(0.75, 0.25)

# Insert the concepts to be discriminated here.
# discrimination by categories
# this only makes sense for Diesel vehicles, relevant only for emission factors per length travelled
# Options for Diesel lightweight vehicles : Direct Injection (DI) and Indirect Injection (IDI)
# Options for  Heavy Duty Trucks and for Buses : Direct Injection (DI)
# the vector can be left empy. If so, concepts_fraction has no consequence and the EFs are averaged through the concepts
# The EMEP/EEA document advises 50% for DI and 50% for IDI
concepts <- list() ; concepts_fraction <- list()
concepts[[1]] <- list()
concepts_fraction[[1]] <- list()
concepts[[2]] <- list()
concepts_fraction[[2]] <- list()
