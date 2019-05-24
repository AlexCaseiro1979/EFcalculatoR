# read the EMEP/EEA data
df <- read.table("1.A.3.b.i-iv Road transport hot EFs Annex 2018_Dic.csv", sep=',', header=TRUE)

source('EFcalculatoR_options.R')

c_pollutant <- 1
for (pollutant in pollutants) {
    if (modes[c_pollutant] != '') {
        df <- subset(df, Mode==modes[c_pollutant])
    }
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
        if (length(segments[[c_category]]) == 0) {
            segments[[c_category]] <- list() ; segments[[c_category]][[1]] <- unique(subset(df, Category==category)$Segment)
            segments_fraction[[c_category]] <- 1
        }
        if (length(euro_standards[[c_category]]) == 0) {
            euro_standards[[c_category]] <- list() ; euro_standards[[c_category]][[1]] <- unique(subset(df, Category==category)$Euro.Standard)
            euro_standards_fraction[[c_category]] <- 1
        }
        if (length(technologies[[c_category]]) == 0) {
            technologies[[c_category]] <- list() ; technologies[[c_category]][[1]] <- unique(subset(df, Category==category)$Technology)
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
                        d <- subset(df,
                            Pollutant==pollutant
                            & Category==category
                            & Fuel %in% fuel
                            & Segment %in% segment
                            & Euro.Standard %in% euro_standard
                            & Technology %in% technology)
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
        cat(pollutant, 'EF for', category, sum(out$EF*out$Fraction), 'g/Km \n')
        c_category <- c_category + 1
    }
    c_pollutant <- c_pollutant + 1
}
