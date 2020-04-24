# this function produces a csv file with the EF discriminated by roadway, pollutant, category
writeOutputTable <- function(roadway, pollutant, category, EF, unit, data){

globalOut_names <- c('Roadway', 'Pollutant', 'Category', 'EF', 'Unit')

# initialize the output file
if (data=='init'){
    cat('Roadway', 'Pollutant', 'Category', 'EF', paste('unit', "\n", sep=''), sep=',', file=fileOut_csv)
}
# end of the output data table initialization

else {
    cat(roadway, pollutant, category, EF, paste(unit, "\n", sep=''), sep=',', file=fileOut_csv, append=TRUE)
}

}

# this function produces a csv table per roadway, per pollutant and per fleet and computes the emissions per hour
writeEmissionTables <- function(file_EF, file_activity) {

EF <- read.csv(file_EF)
activity <- read.csv(file_activity, comment.char = '#')

for (roadway in as.character(unique(activity$Roadway))) {
  cat("\n\n", 'writing emission tables for ', roadway, "\n")
  # subset the EF table for the roadway
  sub_ef_roadway <- subset(EF, Roadway==roadway)
  # for each pollutant in the EF table for a given roadway
  for (pollutant in unique(sub_ef_roadway$Pollutant)) {
    cat("\t", pollutant, "\n")
    sub_ef_pollutant <- subset(sub_ef_roadway, Pollutant==pollutant)
    category_emission_dfs <- list()
    # for each category in the EF table for a given roadway and a given pollutant
    i <- 1 # counter for the list of data.frames
    for (category in as.character(unique(sub_ef_pollutant$Category))) {
      cat("\t\t", category, "\n")
      sub_ef_category <- subset(sub_ef_pollutant, Category==category)
      # this last subset should have two lines: positive and negative slope
      # or one line if the slope is 0
      # the output table for this category can now be made
      sub_activity <- subset(activity, Roadway==roadway & Category==category)
      emission_table <- sub_activity
      emission_table$Pollutant <- pollutant
      # the EF comes in g/vehicle
      emission_table$EF <- mean(sub_ef_category$EF)
      emission_table$EF_unit <- unique(sub_ef_category$unit)
      # Emission in mass emitted by all vehicles along the whole roadway per second during the integration IntegrationTime
      emission_table$Emission <- emission_table$EF * emission_table$n_vehicles / (emission_table$IntegrationTime*60*60)
      # set the unit
      unit_chars <- strsplit(as.character(unique(sub_ef_category$unit)), split="\\(|\\)|\\.|\\/")[[1]]
      emission_field_name <- paste(category, '_E_', unit_chars[1], '/s', sep='')
      colnames(emission_table)[which(colnames(emission_table)=='Emission')] <- emission_field_name
      emission_table$Category <- NULL
      colnames(emission_table)[which(colnames(emission_table)=='n_vehicles')] <- category
      emission_table$EF_unit <- NULL
      EF_unit <-paste(category, 'EF', as.character(unique(sub_ef_category$unit)), sep='_')
      colnames(emission_table)[which(colnames(emission_table)=='EF')] <- EF_unit
      category_emission_dfs[[i]] <- as.data.frame(emission_table)
      i <- i+1
      write.csv(as.data.frame(emission_table), paste(roadway, '_', pollutant, '_', category, '.csv', sep='_'), row.names=FALSE, quote=FALSE)
    }
    # now make the data.frame combined for all categories
    if (length(unique(sub_ef_pollutant$Category)) > 1 ) {
      merged <- do.call(cbind, category_emission_dfs)
      merged <- merged[, !duplicated(colnames(merged))]
      merged$EF <- rowSums(merged[ ,grepl("E_", names(merged))])
      write.csv(merged, paste(roadway, '_', pollutant, '.csv', sep='_'), row.names=FALSE, quote=FALSE)
    }
  }
}

}

# this function produces a csv table per roadway, per pollutant and per fleet and computes the emissions per hour
# for the grouped pollutants
writeEmissionTablesGroups <- function() {
for (i in seq(length(pollutantGroups))) {
  cat(paste("\n\n\tGrouping (summing) EFs for group", pollutantGroups[i], "\n"))
  listpolfiles <- c()
  for (pollutant in pollutantsInGroups[i][[1]]) {listpolfiles <- c(listpolfiles, list.files(pattern=pollutant))}
  polfilesToProcess <- c()
  for (polfile in listpolfiles) { if (length(strsplit(polfile, '_')[[1]])<7) {polfilesToProcess <- c(polfilesToProcess, polfile)} }
  polTable <- do.call(rbind, lapply(polfilesToProcess, read.csv))
  for (roadway in unique(polTable$Roadway)) {
    polTableRoadway <- subset(polTable, Roadway==roadway)
    polTableRoadwaySum <- data.frame(Roadway=character(),
                                     Hour=integer(),
                                     Pollutant=character(),
                                     EF=double() )
    for (hour in unique(polTableRoadway$Hour)) {
      polTableRoadwayHour <- subset(polTableRoadway, Hour==hour)
      SumEF <- sum(polTableRoadwayHour$EF)
      polTableRoadwaySum <- rbind(polTableRoadwaySum, data.frame(Roadway=roadway,
                                           Hour=hour,
                                           Pollutant=pollutantGroups[i],
                                           EF=SumEF) )
    }
  write.csv(polTableRoadwaySum, paste(roadway, '_', pollutantGroups[i], '.csv', sep='_'), row.names=FALSE, quote=FALSE)
  }
}
}



# this function is run for a given fleet distribution and a given roadway (the roadway is defined by a speed, a length, a slope, a load and a mode)
EF_Group1_pre <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile, writeOrNot){
  if (!(slope == 0 || is.na(slope))) {
    slopes <- c(-slope, slope)
  }
  else {
    slopes <- slope
  }
  for (s in slopes) {
    EF_Group1(roadway, speeds, length, s, load, pollutants, modes, distFile, writeOrNot)
  }
}

EF_Group1 <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile, writeOrNot){

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
                            #& Road.Slope %in% slope
                            #& Load %in% load
                            )
                        if (nrow(d)>0) {
			     if (!is.na(unique(d$Load))) {
			        d <- subset(d, Load==load)
			    }
			    if (!is.na(unique(d$Road.Slope))) {
			        d <- subset(d, Road.Slope==slope)
			    }
			    # if the set speed is larger than the max speed in the CORINAIR document, keep the max speed of the CORINAIR document:
			    if ( speed > min(d$Max.Speed..km.h., na.rm=TRUE) )
			    	{ speed <- min(d$Max.Speed..km.h., na.rm=TRUE) }
                            # Emission factor computed in g/(Km.vehicle):
                            d$EF <- ( d$Alpha * speed**2 + d$Beta * speed + d$Gamma + d$Delta / speed ) / ( d$Epsilon * speed**2 + d$Zita * speed + d$Hta )
			    d$EF[d$EF<0] <- 0
			    fractiond <- fuels_fraction[[c_category]][c_fuel] * segments_fraction[[c_category]][c_segment] * euro_standards_fraction[[c_category]][c_euro_standard] * technologies_fraction[[c_category]][c_technology]
                            outd  <- data.frame(category, fuel, segment, euro_standard, mean(d$EF),
                                                fuels_fraction[[c_category]][c_fuel],
                                                segments_fraction[[c_category]][c_segment],
                                                euro_standards_fraction[[c_category]][c_euro_standard],
                                                technologies_fraction[[c_category]][c_fuel],
                                                fractiond)
                            names(outd) <- out_names ; out <- rbind(out, outd)
			    #cat("\n+++", roadway, '--', pollutant, '--', category, '--', fuel, '--', segment, '--', euro_standard, '--', technology, '--', slope, '%: ', mean(d$EF), 'g/km/vehicle, fraction: ', fractiond)
                        }
                        c_technology <- c_technology + 1
                    }
                    if (pollutant %in% c('VOC', 'CH4')) {
                        outauxd <- data.frame(roadway, pollutant, category, fuel, segment, euro_standard, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction)/sum(subset(out, Fuel==fuel)$Fraction))
                        names(outauxd) <- outaux_names ; outaux <- rbind(outaux, outauxd)
                    }
                    c_euro_standard <- c_euro_standard + 1
                }
                c_segment <- c_segment + 1
            }
            cat("\n\t", roadway, pollutant, category, fuel, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction)/sum(subset(out, Fuel==fuel)$Fraction), 'g/km/vehicle')
            if (pollutant %in% c('FC')) {
                outauxd <- data.frame(roadway, pollutant, category, fuel, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction)/sum(subset(out, Fuel==fuel)$Fraction))
                names(outauxd) <- outaux_names ; outaux <- rbind(outaux, outauxd)
            }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        cat("\n\t\t", roadway, pollutant, category, sum(out$EF*out$Fraction/sum(out$Fraction)), 'g/km/vehicle')
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction/sum(out$Fraction)))
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
        umass_string <- c('g/vehicle') # unchanged EF from the 1.A.3.b.i-iv Road transport hot EFs Annex 2018_Dic.csv document is in g/km
    }
    else {
        pol_string <- c('Fuel consumption for')
        umass_string <- c('MJ/vehicle')
    }
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string, slope_string, load_string)
    if (writeOrNot != 'noWrite') {
      writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction)*length, umass_string, 'data')
    }
    c_pollutant <- c_pollutant + 1
}

if (pollutant %in% c('FC', 'VOC', 'CH4')) {
    return(outaux)
}

}

EF_perLength <- function(roadway, speeds, length, pollutants, distFile, writeOrNot){

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
        if (pollutant == 'PM Tyres') {
          if (speed<40) {speed_corr_factor <- 1.39}
          if (speed>=40 & speed<=90) {speed_corr_factor <- -0.0094*speed+1.78}
          if (speed>90) {speed_corr_factor <- 0.902}
         }
        if (pollutant == 'PM Brakes') {
          if (speed<40) {speed_corr_factor <- 1.67}
          if (speed>=40 & speed<=95) {speed_corr_factor <- -0.027*speed+2.75}
          if (speed>95) {speed_corr_factor <- 0.185}
         }
        if (pollutant != 'PM Tyres' & pollutant != 'PM Brakes') {speed_corr_factor <- 1}
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
                        outd  <- data.frame(category, fuel, concept, euro_standard, mean(d$EF_ug_km)*1e-6*speed_corr_factor, # convert from ug to g
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
    umass_string <- c('g/vehicle') # EF from the EFperLength.csv document: from ug/km to g/km
    # end the strings for the output
    # the output
    cat("\n\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string)
    if (writeOrNot != 'noWrite') {
      writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction)*length, umass_string, 'data')
    }
    c_pollutant <- c_pollutant + 1
}

}

EF_perFuel_pre <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile, writeOrNot){
  if (!(slope == 0 || is.na(slope))) {
    slopes <- c(-slope, slope)
  }
  else {
    slopes <- slope
  }
  for (s in slopes) {
      EF_perFuel(roadway, speeds, length, s, load, pollutants, modes, distFile, writeOrNot)
  }
}

EF_perFuel <- function(roadway, speeds, length, slope, load, pollutants, modes, distFile, writeOrNot){

source(distFile)
df_specEnergy <- read.table('SpecificEnergy.csv', sep=',', header=TRUE, comment.char='#')

# get the fuel consumption with the function EF_Group1
fuelComp <- EF_Group1(roadway, speeds, length, slope, load, c('FC'), modes, distFile, 'noWrite')
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
                EF <- EF * 1e-3 # from mg to g
                outd  <- data.frame(category, fuel, EF, fuels_fraction[[c_category]][c_fuel])
                names(outd) <- out_names ; out <- rbind(out, outd)
            }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction, na.rm=TRUE))
        c_category <- c_category + 1
    }
    # create the strings for the output
    pol_string <- c(pollutant, 'EF for')
    umass_string <- c('g/vehicle')
    # end the strings for the output
    # the output
    cat("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string)
    if (writeOrNot != 'noWrite') {
      writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction)*length, umass_string, 'data')
    }
    c_pollutant <- c_pollutant + 1
}

}

EF_perVOC_pre <- function(roadway, speeds, length, slope, load, pollutants, modesVOC, modesCH4, distFile, writeOrNot){
  if (!(slope == 0 || is.na(slope))) {
    slopes <- c(-slope, slope)
  }
  else {
    slopes <- slope
  }
  for (s in slopes) {
      EF_perVOC(roadway, speeds, length, s, load, pollutants, modesVOC, modesCH4, distFile, writeOrNot)
  }
}

EF_perVOC <- function(roadway, speeds, length, slope, load, pollutants, modesVOC, modesCH4, distFile, writeOrNot){

source(distFile)

# get the VOCs and CH$ EF with the function EF_Group1
efVOC <- EF_Group1(roadway, speeds, length, slope, load, c('VOC'), modesVOC, distFile, 'noWrite')
efCH4 <- EF_Group1(roadway, speeds, length, slope, load, c('CH4'), modesCH4, distFile, 'noWrite')
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
                    # Emission factor computed in g/(Km.vehicle)
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
    umass_string <- c('g/vehicle')
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string)
    if (writeOrNot != 'noWrite') {
      writeOutputTable(roadway, pollutant, categories_name, sum(ef_pol*categories_fraction)*length, umass_string, 'data')
    }
    c_pollutant <- c_pollutant + 1
}

}

# read the EMEP/EEA data
df_Group1 <- read.table("1.A.3.b.i-iv Road transport hot EFs Annex 2018_Dic.csv", sep=',', header=TRUE)
df_perLength <- read.table('EFperLength.csv', sep=',', header=TRUE, comment.char='#')
df_perFuel <- read.table('EFperFuel.csv', sep=',', header=TRUE, comment.char='#')
df_perVOC <- read.table('EFperVOC.csv', sep=',', header=TRUE, comment.char='#')


# read the options input file
source('EFcalculatoR_options.R')
