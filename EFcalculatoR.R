

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
  cat_no_cat(paste("\n\n", 'writing emission tables for ', roadway, "\n", sep=''),2)
  # subset the EF table for the roadway
  sub_ef_roadway <- subset(EF, Roadway==roadway)
  # for each pollutant in the EF table for a given roadway
  for (pollutant in unique(sub_ef_roadway$Pollutant)) {
    cat_no_cat(paste("\t", pollutant, "\n", sep=''),2)
    sub_ef_pollutant <- subset(sub_ef_roadway, Pollutant==pollutant)
    category_emission_dfs <- list()
    # for each category in the EF table for a given roadway and a given pollutant
    i <- 1 # counter for the list of data.frames
    for (category in as.character(unique(sub_ef_pollutant$Category))) {
      cat_no_cat(paste("\t\t", category, "\n", sep=''),2)
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
  cat_no_cat(paste("\n\n\tGrouping (summing) EFs for group", pollutantGroups[i], "\n"),2)
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
    cat_no_cat("\n",1)
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
			    if (length(unique(d$Load))>1 && !is.na(unique(d$Load))) {
			        d <- subset(d, Load==load)
			    }
			    if (length(unique(d$Road.Slope))>1 && !is.na(unique(d$Road.Slope))) {
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
			    cat_no_cat(paste("\n+++", roadway, '--', pollutant, '--', category, '--', fuel, '--', segment, '--', euro_standard, '--', technology, '--', slope, '%: ', mean(d$EF), 'g/km/vehicle, fraction: ', fractiond),2)
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
            cat_no_cat(paste("\n\t", roadway, pollutant, category, fuel, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction)/sum(subset(out, Fuel==fuel)$Fraction), 'g/km/vehicle'),1)
            if (pollutant %in% c('FC')) {
                outauxd <- data.frame(roadway, pollutant, category, fuel, sum(subset(out, Fuel==fuel)$EF * subset(out, Fuel==fuel)$Fraction)/sum(subset(out, Fuel==fuel)$Fraction))
                names(outauxd) <- outaux_names ; outaux <- rbind(outaux, outauxd)
            }
            c_fuel <- c_fuel + 1
        }
        # end the subsetting
        cat_no_cat(paste("\n\t\t", roadway, pollutant, category, sum(out$EF*out$Fraction/sum(out$Fraction)), 'g/km/vehicle'),1)
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
    cat_no_cat(c("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string, slope_string, load_string),1)
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
        out_names <- c('Category', 'Fuel', 'Segment', 'Concept', 'Euro.Standard', 'EF',
                       'Fraction.Fuel', 'Fraction.Segment', 'Fraction.Concept', 'Fraction.Euro.Standard', 'Fraction')
        out <- data.frame(
        Category = character(),
        Fuel = character(),
	Segment = character(),
        Concept = character(),
        Euro.Standard = character(),
        EF = numeric(),
        Fraction.Fuel = numeric(),
        Fraction.Segment = numeric(),
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
	    if (length(segments[[c_category]]) == 0) {
                segments[[c_category]] <- unique(subset(d_cat, Category==category & Fuel==fuel)$Segment)
                segments_fraction[[c_category]] <- 1
            }
            # end of the discriminations that can be left empy
            c_segment <- 1
            for (segment in segments[[c_category]]) {
		    c_concept <- 1
		    for (concept in concepts[[c_category]]) {
			c_euro_standard <- 1
			for (euro_standard in euro_standards[[c_category]]) {
			    d_fes <- subset(d_cat,
			        Fuel %in% fuel
			        & Euro.Standard %in% euro_standard
			        )
			    if (nrow(d_fes)>0) {
				# if the concepts list in the distribution is not empty
                                # (if it is empty, i.e. '', it has been changed to the list
                                # of uniques from d_cat, From there it cannot be '', but it can be NA)
				# but the concepts in the EFperLength is empty
				if (!is.na(concept) && is.na(unique(d_fes$Concept))) {
				    concept <- unique(d_fes$Concept)
				}
				# if the segments list in the distribution is not empty
                                # (if it is empty, i.e. '', it has been changed to the list
                                # of uniques from d_cat. From there it cannot be '', but it can be NA)
				# but the segments in the EFperLength is empty
				if (!is.na(segment) && is.na(unique(d_fes$Segment))) {
				    segment <- unique(d_fes$Segment)
				}
				d <- subset(d_fes,
				    Segment %in% segment
				    & Concept %in% concept
				    )

				if (nrow(d)>0) {
				    outd  <- data.frame(category, fuel, segment, concept, euro_standard,
                                            mean(d$EF_ug_km)*1e-6*speed_corr_factor, # convert from ug to g
			    		    fuels_fraction[[c_category]][c_fuel],
					    segments_fraction[[c_category]][c_segment],
					    concepts_fraction[[c_category]][c_concept],
					    euro_standards_fraction[[c_category]][c_euro_standard],
					    fuels_fraction[[c_category]][c_fuel]
                                            * segments_fraction[[c_category]][c_fuel]
					    * concepts_fraction[[c_category]][c_concept]
					    * euro_standards_fraction[[c_category]][c_euro_standard]
					    )
				    names(outd) <- out_names ; out <- rbind(out, outd)
				}
			    }
			    c_euro_standard <- c_euro_standard + 1
			}
			c_concept <- c_concept + 1
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
    pol_string <- c(pollutant, 'EF for')
    umass_string <- c('g/vehicle') # EF from the EFperLength.csv document: from ug/km to g/km
    # end the strings for the output
    # the output
    cat_no_cat(paste("\n\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string),1)
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
df_specEnergy <- read.table('specificEnergy.csv', sep=',', header=TRUE, comment.char='#')

# get the fuel consumption with the function EF_Group1
fuelComp <- EF_Group1(roadway, speeds, length, slope, load, c('FC'), modes, distFile, 'noWrite')
cat_no_cat(paste("\n\n", roadway, '----------------------------- finished computing the Fuel consumption...'),1)

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
    cat_no_cat(paste("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string),1)
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

# get the VOCs and CH4 EF with the function EF_Group1
efVOC <- EF_Group1(roadway, speeds, length, slope, load, c('VOC'), modesVOC, distFile, 'noWrite')
efCH4 <- EF_Group1(roadway, speeds, length, slope, load, c('CH4'), modesCH4, distFile, 'noWrite')
cat_no_cat(paste("\n\n", roadway, '----------------------------- finished computing the VOCs and CH4 EF...'),1)

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
                    EF <- mean(d$percent_wt_NMVOC) / 100 *
                          ( mean(subset(efVOC, Category==category & Fuel==fuel & Euro.Standard == euro_standard )$EF, na.rm=TRUE) # VOCs given as CH1.85
                            * (12+4)/(12+1.85) # convert from CH1.85 to CH4
                          - mean(subset(efCH4, Category==category & Fuel==fuel & Euro.Standard == euro_standard )$EF, na.rm=TRUE) # minus CH4
                          )
                    if (is.na(EF) | EF < 0) { EF <- NA }
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
        ef_pol <- c(ef_pol, sum(out$EF*out$Fraction, na.rm=TRUE))
        c_category <- c_category + 1
    }
    # create the strings for the output
    pol_string <- c(pollutant, 'EF for')
    umass_string <- c('g/vehicle')
    # end the strings for the output
    # the output
    time = length / speed * (60*60)
    cat_no_cat(paste("\n", roadway, ':', pol_string, categories_name, sum(ef_pol*categories_fraction)*length, umass_string),1)
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


# for the verbosity output:
if (verbosity_out=='file') {
verbosity_file <- paste(fileOut, '.log', sep='')
}

# functions for the output

output_console <- function(output_string) {
cat(output_string)
}

output_file <- function(output_string) {
cat(output_string, file=verbosity_file, append=TRUE)
}

if (verbosity_out == 'file') {
cat_out <- output_file
} else {
cat_out <- output_console
}

cat_no_cat <- function(output_string, output_level) {
if (verbosity_level >= output_level) {
cat_out(output_string)
}
else {
cat_out('')
}
}

# this produces a csv file with the following fields:
# Roadway, Pollutant, Category, EF, unit
fileOut_csv <- paste(fileOut,'_EF.csv', sep='')
writeOutputTable('roadway', 'pollutant', 'category', 'EF', 'unit', 'init')


#######################################################################################

EF_preMain <- function(roadway_name,
		       speed_PC, speed_LCV, speed_LCat, speed_HDV, speed_Buses,
		       length_km, roadway_slope, load_HDV, driving_mode,
		       dist_fleet_light, dist_fleet_heavy)
	      {

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

EF_Group1_pre(roadway_name,
        c(speed_PC, speed_LCV, speed_LCat),
        length_km, NA, NA,
        c('CO', 'NOx', 'PM Exhaust', 'VOC', 'FC', 'CH4'),
        list(c('', '', driving_mode, '', '', driving_mode),
             c('', '', driving_mode, '', '', driving_mode),
             c(driving_mode, driving_mode, driving_mode, driving_mode, driving_mode, driving_mode)),
        dist_fleet_light,
        'write')

EF_Group1_pre(roadway_name,
        c(speed_HDV, speed_Buses),
        length_km, roadway_slope, load_HDV,
        c('CO', 'NOx', 'VOC', 'FC', 'CH4', 'NH3', 'N2O', 'PM Exhaust'),
        list(c('', '', '', '', driving_mode, driving_mode, driving_mode, ''),
             c('', '', '', '', driving_mode, driving_mode, driving_mode, '')),
        dist_fleet_heavy,
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

EF_perLength(roadway_name,
        c(speed_PC, speed_LCV, speed_LCat),
        length_km,
        c('benzo(a)pyrene', 'PCDD', 'PCDF', 'PM Brakes', 'PM Road paved', 'PM Tyres', 'CO2 lubricant', 'NH3 lightweight', 'N2O lightweight'),
        dist_fleet_light,
        'write')

EF_perLength(roadway_name,
        c(speed_HDV, speed_Buses),
        length_km,
        c('benzo(a)pyrene', 'PCDD', 'PCDF', 'PM Brakes', 'PM Road paved', 'PM Tyres', 'CO2 lubricant', 'NH3 lightweight', 'N2O lightweight'),
        dist_fleet_heavy,
        'write')


#######################################################################################

# FUNCTION FOR POLLUTANTS EF AS FUNCTION OF FUEL CONSUMED

# options 1, 2, 3, 4, 5 and 8 are the same as for the function EF_Group1_pre

# the sixth variable for the function are the pollutants
# Options are:
#   Pb, Cd, Cu, Cr, Ni, Se, Zn, Hg, As, SO2 and CO2 fuel
#   NH3 lightweight and N2O lightweight for Lightweight vehicles (Tier 1 calculation)

# the seventh variable for the function is to be left as one empty string
# for each category in the fleet distribution file, within a list

EF_perFuel_pre(roadway_name,
        c(speed_PC, speed_LCV, speed_LCat),
        length_km, NA, NA,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2', 'CO2 fuel'), #, 'NH3 lightweight', 'N2O lightweight'),
        list(c(''),c(''),c('')),
        dist_fleet_light,
        'write')

EF_perFuel_pre(roadway_name,
        c(speed_HDV, speed_Buses),
       	length_km, roadway_slope, load_HDV,
        c('Pb', 'As', 'Cd', 'Ni', 'SO2', 'CO2 fuel'), #, 'NH3 lightweight', 'N2O lightweight'),
        list(c(''),c('')),
        dist_fleet_heavy,
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

EF_perVOC_pre(roadway_name,
        c(speed_PC, speed_LCV, speed_LCat),
        length_km, NA, NA,
        c('toluene', 'mp-xylene', 'o-xylene', 'benzene'),
        list(c(''),c(''),c(''),c('')),
        c(driving_mode, driving_mode, driving_mode, driving_mode),
        dist_fleet_light,
        'write')

EF_perVOC_pre(roadway_name,
        c(speed_HDV, speed_Buses),
       	length_km, roadway_slope, load_HDV,
        c('toluene', 'mp-xylene', 'o-xylene', 'benzene'),
        list(c(''),c(''),c('')),
        c(driving_mode, driving_mode, driving_mode, driving_mode),
        dist_fleet_heavy,
        'write')


#######################################################################################

}

# read the roadways file
roadways <- read.table(roadways_file, header=TRUE, sep=',', stringsAsFactors=FALSE)

for (row in seq(1, nrow(roadways))) {
    EF_preMain(roadways[row,1], # the roadway name
	       roadways[row,2], roadways[row,3], roadways[row,4], roadways[row,5], roadways[row,6], # the speeds
	       roadways[row,7], roadways[row,8], roadways[row,9], roadways[row,10], # length, slope, load of HDV, mode
	       dist_fleet_light, dist_fleet_heavy # the fleet distribution files
               )
}


#######################################################################################

# PRODUCE THE FINAL TABLES

# this produces a csv file per roadway per pollutant per fleet
# the files have the following fields:
# Roadway, Fleet, Hour, activity, EF, unit

writeEmissionTables(fileOut_csv, activity_csv)

pollutantGroups <- c('PM10', 'xylene', 'Dioxins+Furans', 'CO2', 'NH3_all', 'N2O_all')
pollutantsInGroups <- list(c('PM Exhaust', 'PM Tyres', 'PM Brakes', 'PM Road paved'),
                           c('o-xylene', 'mp-xylene'),
                           c('PCDD', 'PCDF'),
                           c('CO2 fuel', 'CO2 lubricant'),
                           c('NH3', 'NH3 lightweight'),
                           c('N2O', 'N2O lightweight'))
writeEmissionTablesGroups()


cat_no_cat("\n",0)
