
# this function is run for a given fleet distribution and a given roadway (the roadway is defined by a speed, a slope, a load and a mode)
EFfunc <- function(roadway, speed, slope, load, pollutants, modes, distFile){

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
        d_pol <- subset(df, Pollutant==pollutant)
        d_cat <- subset(d_pol, Category==category)
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
        if (!is.na(slope)) {
            slope_string <- c('| for slope', slope, '%')
        }
        else {
            slope_string <- c('')
        }
        if (!is.na(load)) {
            load_string <- c('and for load', load, '|')
        }
        else {
            load_string <- c('')
        }
        #cat('...', pollutant, 'EF for', category, sum(out$EF*out$Fraction), 'g/Km', slope_string, load_string, '... \n')
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction))
        c_category <- c_category + 1
    }
    cat(roadway, ':', pollutant, 'EF for', categories_name, sum(ef_pol*categories_fraction), 'g/Km', slope_string, load_string, '\n')
    c_pollutant <- c_pollutant + 1
}

}

# read the EMEP/EEA data
df <- read.table("1.A.3.b.i-iv Road transport hot EFs Annex 2018_Dic.csv", sep=',', header=TRUE)

# read the options input file
source('EFcalculatoR_options.R')
