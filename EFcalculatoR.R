
# this function is run for a given fleet distribution and a given roadway (the roadway is defined by a speed, a slope, a load and a mode)
EF_Group1 <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile){

source(distFile)

c_pollutant <- 1
for (pollutant in pollutants) {
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
        # end of the output data table
        speed <- speeds[c_category]
        # first subsettings: pollutant and category
        d_pol <- subset(df_Group1, Pollutant==pollutant)
        d_cat <- subset(d_pol, Category==category)
        # take care of discriminations that can be left empy
        if (modes[c_pollutant] != '') {
            d_cat_mod <- rbind(subset(subset(d_cat, Pollutant==pollutant), Mode==''), subset(d_cat, Pollutant==pollutant & Mode==modes[c_pollutant]))
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
                    c_euro_standard <- c_euro_standard + 1
                }
                c_segment <- c_segment + 1
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
    cat(roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction), umass_string,
        sum(ef_pol*categories_fraction) * length / time, utime_string,
        slope_string, load_string, '\n')
    c_pollutant <- c_pollutant + 1
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
    cat(roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction), umass_string,
        sum(ef_pol*categories_fraction) * length / time, utime_string,
        '\n')
    c_pollutant <- c_pollutant + 1
}

}

# read the EMEP/EEA data
df_Group1 <- read.table("1.A.3.b.i-iv Road transport hot EFs Annex 2018_Dic.csv", sep=',', header=TRUE)
df_perLength <- read.table('EFperLength.csv', sep=',', header=TRUE, comment.char='#')

# read the options input file
source('EFcalculatoR_options.R')
