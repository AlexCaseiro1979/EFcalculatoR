# this function produces a csv file with the EF discriminated by roadway, pollutant, category
writeOutputTable <- function(roadway, pollutant, category, EF, unit, data){

globalOut_names <- c('Roadway', 'Pollutant', 'Category', 'EF', 'Unit')

# initialize the output file
if (data=='init'){
    cat('Roadway', 'Pollutant', 'Category', 'EF', paste('unit', "\n", sep=''), sep=',', file = fileOut_csv)
}
# end of the output data table initialization

else {
    cat(roadway, pollutant, category, EF, paste(unit, "\n", sep=''), sep=',', file = fileOut_csv, append=TRUE)
}

}

# this function is run for a given fleet distribution and a given roadway (the roadway is defined by a speed, a length, a slope, a load and a mode)
EF_Group1 <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile){

source(distFile)

c_pollutant <- 1
for (pollutant in pollutants) {
    cat("\n")
    # initialize the FC, VOC or CH4 output data table (needed by other functions)
    if (pollutant=='FC') {
        outaux_names <- c('Roadway', 'Pollutant', 'Category', 'Fuel', 'FC_MJ_km_vehic')
        outaux <- data.frame(
        Roadway = character(),
        Pollutant = character(),
        Category = character(),
        Fuel = character(),
        FC_MJ_km_vehic = numeric()
        )
    }
    if (pollutant %in% c('VOC', 'CH4')) {
        outaux_names <- c('Roadway', 'Pollutant', 'Category', 'Fuel', 'Segment', 'Euro.Standard', 'EF')
        outaux <- data.frame(
        Roadway = character(),
        Pollutant = character(),
        Category = character(),
        Fuel = character(),
        Segment = character(),
        Euro.Standard = character(),
        EF = numeric()
        )
    }
    # end of the FC output data table initialization
    ef_pol <- c()
    c_category <- 1
    for (category in categories) {
        # initialize the output data table
        out_names <- c('Category', 'Fuel', 'Segment', 'Euro.Standard', 'EF',
                       'Fraction.Fuel', 'Fraction.Segment', 'Fraction.Euro.Standard', 'Fraction.Technology', 'Fraction')
        out <- data.frame(
        Category = character(),
        Fuel = character(),
        Segment = character(),
        Euro.Standard = character(),
        EF = numeric(),
        Fraction.Fuel = numeric(),
        Fraction.Segment = numeric(),
        Fraction.Euro.Standard = numeric(),
        Fraction.Technology = numeric(),
        Fraction = numeric()
        )
        # end of the output data table initialization
        speed <- speeds[c_category]
        # first subsettings: pollutant and category
        d_pol <- subset(df_Group1, Pollutant==pollutant)
        d_cat <- subset(d_pol, Category==category)
        # take care of discriminations that can be left empy
        if (modes[[c_category]][c_pollutant] != '') {
            d_cat_mod <- rbind(subset(d_cat, Pollutant==pollutant & Mode==''), subset(d_cat, Pollutant==pollutant & Mode==modes[[c_category]][c_pollutant]))
        }
        else {
            d_cat_mod <- d_cat
        }
        if (length(segments[[c_category]]) == 0) {
            segments[[c_category]] <- list() ; segments[[c_category]][[1]] <- unique(subset(d_cat_mod, Category==category)$Segment)
            segments_fraction[[c_category]] <- 1
        }
        if (length(euro_standards[[c_category]]) == 0) {
            euro_standards[[c_category]] <- list() ; euro_standards[[c_category]][[1]] <- unique(subset(d_cat_mod, Category==category)$Euro.Standard)
            euro_standards_fraction[[c_category]] <- 1
        }
        if (length(technologies[[c_category]]) == 0) {
            technologies[[c_category]] <- list() ; technologies[[c_category]][[1]] <- unique(subset(d_cat_mod, Category==category)$Technology)
            technologies_fraction[[c_category]] <- 1
        }
        # end of the discriminations that can be left empy
        # continue the subsetting
        c_fuel <- 1
        for (fuel in fuels[[c_category]]) {
            c_segment <- 1
            for (segment in segments[[c_category]]) {
                c_euro_standard <- 1
                for (euro_standard in euro_standards[[c_category]]) {
                    c_technology <- 1
                    for (technology in technologies[[c_category]]) {
                        d <- subset(d_cat_mod,
                            Fuel %in% fuel
                            & Segment %in% segment
                            & Euro.Standard %in% euro_standard
                            & Technology %in% technology
                            & Road.Slope %in% slope
                            & Load %in% load
                            )
                        if (nrow(d)>0) {
                            d$EF <- ( d$Alpha * speed**2 + d$Beta * speed + d$Gamma + d$Delta / speed ) / ( d$Epsilon * speed**2 + d$Zita * speed + d$Hta )
                            outd  <- data.frame(category, fuel, segment, euro_standard, mean(d$EF),
                                                fuels_fraction[[c_category]][c_fuel],
                                                segments_fraction[[c_category]][c_segment],
                                                euro_standards_fraction[[c_category]][c_euro_standard],
                                                technologies_fraction[[c_category]][c_fuel],
                                                fuels_fraction[[c_category]][c_fuel]
                                                    * segments_fraction[[c_category]][c_segment]
                                                    * euro_standards_fraction[[c_category]][c_euro_standard]
                                                    * technologies_fraction[[c_category]][c_technology]
                                                )
                            names(outd) <- out_names ; out <- rbind(out, outd)
                        }
                        c_technology <- c_technology + 1
                    }
                    if (pollutant %in% c('VOC', 'CH4')) {
                        #outauxd <- data.frame(roadway, pollutant, category, fuel, segment, euro_standard, sum(out$EF*out$Fraction))
                        outauxd <- data.frame(roadway, pollutant, category, fuel, segment, euro_standard, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction))
                        names(outauxd) <- outaux_names ; outaux <- rbind(outaux, outauxd)
                    }
                    c_euro_standard <- c_euro_standard + 1
                }
                c_segment <- c_segment + 1
            }
            #cat("\n\t", roadway, pollutant, category, fuel, sum(out$EF*out$Fraction))
            cat("\n\t", roadway, pollutant, category, fuel, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction))
                if (pollutant %in% c('FC')) {
                    #outauxd <- data.frame(roadway, pollutant, category, fuel, sum(out$EF*out$Fraction))
                    outauxd <- data.frame(roadway, pollutant, category, fuel, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction))
                    names(outauxd) <- outaux_names ; outaux <- rbind(outaux, outauxd)
                }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction))
        c_category <- c_category + 1
    }
    # create the strings for the output
    if (!is.na(slope)) {
        slope_string <- c(', for slope', slope, '%')
    }
    else {
        slope_string <- c('')
    }
    if (!is.na(load)) {
        load_string <- c('and for load', load, '.')
    }
    else {
        load_string <- c('')
    }
    if (pollutant != 'FC') {
        pol_string <- c(pollutant, 'EF for')
        umass_string <- c('g/(Km.vehicle) or ')
        utime_string <- c('g/(s.vehicle)')
    }
    else {
        pol_string <- c('Fuel consumption for')
        umass_string <- c('MJ/(Km.vehicle) or ')
        utime_string <- c('MJ/(s.vehicle)')
    }
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction), umass_string,
        sum(ef_pol*categories_fraction) * length / time, utime_string,
        slope_string, load_string)
    writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction) * length / time, utime_string, 'data')
    c_pollutant <- c_pollutant + 1
}

if (pollutant %in% c('FC', 'VOC', 'CH4')) {
    return(outaux)
}

}

EF_perLength <- function(roadway, speeds, length, pollutants, distFile){

source(distFile)

c_pollutant <- 1
for (pollutant in pollutants) {
    ef_pol <- c()
    c_category <- 1
    for (category in categories) {
        # initialize the output data table
        out_names <- c('Category', 'Fuel', 'Concept', 'Euro.Standard', 'EF',
                       'Fraction.Fuel', 'Fraction.Concept', 'Fraction.Euro.Standard', 'Fraction')
        out <- data.frame(
        Category = character(),
        Fuel = character(),
        Concept = character(),
        Euro.Standard = character(),
        EF = numeric(),
        Fraction.Fuel = numeric(),
        Fraction.Concept = numeric(),
        Fraction.Euro.Standard = numeric(),
        Fraction = numeric()
        )
        # end of the output data table
        speed <- speeds[c_category]
        # first subsettings: pollutant and category
        d_pol <- subset(df_perLength, Pollutant==pollutant)
        d_cat <- subset(d_pol, Category==category)
        # continue the subsetting
        c_fuel <- 1
        for (fuel in fuels[[c_category]]) {
            # take care of discriminations that can be left empy
            if (length(concepts[[c_category]]) == 0) {
                concepts[[c_category]] <- unique(subset(d_cat, Category==category & Fuel==fuel)$Concept)
                concepts_fraction[[c_category]] <- 1
            }
            # end of the discriminations that can be left empy
            c_concept <- 1
            for (concept in concepts[[c_category]]) {
                c_euro_standard <- 1
                for (euro_standard in euro_standards[[c_category]]) {
                    d <- subset(d_cat,
                        Fuel %in% fuel
                        & Concept %in% concept
                        & Euro.Standard %in% euro_standard
                        )
                    if (nrow(d)>0) {
                        outd  <- data.frame(category, fuel, concept, euro_standard, mean(d$EF_ug_km),
                                            fuels_fraction[[c_category]][c_fuel],
                                            concepts_fraction[[c_category]][c_concept],
                                            euro_standards_fraction[[c_category]][c_euro_standard],
                                            fuels_fraction[[c_category]][c_fuel]
                                                * concepts_fraction[[c_category]][c_concept]
                                                * euro_standards_fraction[[c_category]][c_euro_standard]
                                            )
                        names(outd) <- out_names ; out <- rbind(out, outd)
                    }
                    c_euro_standard <- c_euro_standard + 1
                }
                c_concept <- c_concept + 1
            }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction))
        c_category <- c_category + 1
    }
    # create the strings for the output
    pol_string <- c(pollutant, 'EF for')
    umass_string <- c('g/(Km.vehicle) or ')
    utime_string <- c('g/(s.vehicle)')
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat("\n\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction), umass_string,
        sum(ef_pol*categories_fraction) * length / time, utime_string)
    writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction) * length / time, utime_string, 'data')
    c_pollutant <- c_pollutant + 1
}

}

EF_perFuel <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile){

source(distFile)
df_specEnergy <- read.table('SpecificEnergy.csv', sep=',', header=TRUE, comment.char='#')

# get the fuel consumption with the function EF_Group1
fuelComp <- EF_Group1(roadway, speeds, length, slope, load, c('FC'), modes, distFile)
cat("\n", roadway, '----------------------------- finished computing the Fuel consumption...')

c_pollutant <- 1
for (pollutant in pollutants) {
    ef_pol <- c()
    c_category <- 1
    for (category in categories) {
        # initialize the output data table
        out_names <- c('Category', 'Fuel', 'EF', 'Fraction')
        out <- data.frame(
        Category = character(),
        Fuel = character(),
        EF = numeric(),
        Fraction = numeric()
        )
        # end of the output data table
        speed <- speeds[c_category]
        # first subsettings: pollutant and category
        d_pol <- subset(df_perFuel, Pollutant==pollutant)
        d_cat <- subset(d_pol, Category==category)
        # continue the subsetting
        c_fuel <- 1
        for (fuel in fuels[[c_category]]) {
            d <- subset(d_cat,Fuel %in% fuel)
            if (nrow(d)>0) {
                EF <- mean(d$k_mg_kgFuel) * subset(fuelComp, Category==category & Fuel==fuel)$FC_MJ_km_vehic / subset(df_specEnergy, Fuel==fuel)$Specific_Energy_MJ_Kg
                outd  <- data.frame(category, fuel, EF, fuels_fraction[[c_category]][c_fuel])
                names(outd) <- out_names ; out <- rbind(out, outd)
            }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction))
        c_category <- c_category + 1
    }
    # create the strings for the output
    pol_string <- c(pollutant, 'EF for')
    umass_string <- c('mg/(Km.vehicle) or ')
    utime_string <- c('mg/(s.vehicle)')
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction), umass_string,
        sum(ef_pol*categories_fraction) * length / time, utime_string)
    writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction) * length / time, utime_string, 'data')
    c_pollutant <- c_pollutant + 1
}

}

EF_perVOC <- function(roadway, speeds, length, slope, load, pollutants, modesVOC, modesCH4, distFile){

source(distFile)

# get the VOCs and CH$ EF with the function EF_Group1
efVOC <- EF_Group1(roadway, speeds, length, slope, load, c('VOC'), modesVOC, distFile)
efCH4 <- EF_Group1(roadway, speeds, length, slope, load, c('CH4'), modesCH4, distFile)
cat("\n", roadway, '----------------------------- finished computing the VOCs and CH4 EF...')

c_pollutant <- 1
for (pollutant in pollutants) {
    ef_pol <- c()
    c_category <- 1
    for (category in categories) {
        # initialize the output data table
        out_names <- c('Category', 'Fuel', 'Euro.Standard', 'EF',
                       'Fraction.Fuel', 'Fraction.Euro.Standard', 'Fraction')
        out <- data.frame(
        Category = character(),
        Fuel = character(),
        Euro.Standard = character(),
        EF = numeric(),
        Fraction.Fuel = numeric(),
        Fraction.Euro.Standard = numeric(),
        Fraction = numeric()
        )
        # end of the output data table
        speed <- speeds[c_category]
        # first subsettings: pollutant and category
        d_pol <- subset(df_perVOC, Pollutant==pollutant)
        d_cat <- subset(d_pol, Category==category)
        # continue the subsetting
        c_fuel <- 1
        for (fuel in fuels[[c_category]]) {
            c_euro_standard <- 1
            for (euro_standard in euro_standards[[c_category]]) {
                d <- subset(d_cat,
                            Fuel %in% fuel
                            & Euro.Standard %in% euro_standard
                            )
                if (nrow(d)>0) {
                    EF <- mean(d$percent_wt_NMVOC) / 100
                          ( mean(subset(efVOC, Category==category & Fuel==fuel & Euro.Standard == euro_standard )$EF) # VOCs
                          - mean(subset(efCH4, Category==category & Fuel==fuel & Euro.Standard == euro_standard )$EF) # minus CH4
                          )
                    outd  <- data.frame(category, fuel, euro_standard, EF,
                                        fuels_fraction[[c_category]][c_fuel],
                                        euro_standards_fraction[[c_category]][c_euro_standard],
                                        fuels_fraction[[c_category]][c_fuel] * euro_standards_fraction[[c_category]][c_euro_standard]
                                        )
                    names(outd) <- out_names ; out <- rbind(out, outd)
                }
                c_euro_standard <- c_euro_standard + 1
            }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction))
        c_category <- c_category + 1
    }
    # create the strings for the output
    pol_string <- c(pollutant, 'EF for')
    umass_string <- c('g/(Km.vehicle) or ')
    utime_string <- c('g/(s.vehicle)')
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction), umass_string,
        sum(ef_pol*categories_fraction) * length / time, utime_string)
    writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction) * length / time, utime_string, 'data')
    c_pollutant <- c_pollutant + 1
}

}

EF_rd_unpaved_ind <- function(roadway, weights, speeds, fractions, silt, length){

PM <- list()
PM[[1]] <- c('PM10', 1.5, 0.9, 0.45) # pollutant, k, a, b
PM[[2]] <- c('PM2.5', 0.15, 0.9, 0.45) # pollutant, k, a, b
cat("\n")
for (j in seq(length(PM))) {
    EFs_mass <- c()
    EFs_time <- c()
    for (i in length(weights)) {
        EF_mass <- as.numeric(PM[[j]][2]) * (silt/12)**as.numeric(PM[[j]][3]) * (weights[i]/3)**as.numeric(PM[[j]][4]) * 281.9 # in g/(Km.vehicle)
        time = length / speeds[i] * (60*60)
        EF_time <- EF_mass * length / time # in g/(s.vehicle)
        EFs_mass <- c(EFs_mass, EF_mass)
        EFs_time <- c(EFs_time, EF_time)
    }
    umass_string <- c('g/(Km.vehicle) or ')
    utime_string <- c('g/(s.vehicle)')
    cat("\n", roadway, ':', PM[[j]][1], 'for unpaved road', sum(EFs_mass), umass_string, sum(EFs_time), utime_string)
    writeOutputTable(roadway, PM[[j]][1], 'category', sum(EFs_mass), utime_string, 'data')
}

}

EF_rd_unpaved_pub <- function(){



}

# read the EMEP/EEA data
df_Group1 <- read.table("1.A.3.b.i-iv Road transport hot EFs Annex 2018_Dic.csv", sep=',', header=TRUE)
df_perLength <- read.table('EFperLength.csv', sep=',', header=TRUE, comment.char='#')
df_perFuel <- read.table('EFperFuel.csv', sep=',', header=TRUE, comment.char='#')
df_perVOC <- read.table('EFperVOC.csv', sep=',', header=TRUE, comment.char='#')


# read the options input file
source('EFcalculatoR_options.R')
