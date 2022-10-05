---
title: 'EFcalculatoR: an easy-to-use R function to compute roadway-specific vehicular emission factors from the EMEP/EEA air pollutant emission inventory guidebook'
tags:
  - R
  - Air pollution
  - EMEP/EEA
  - Road traffic
  - Air pollutants emission factors
authors:
  - name: Alexandre Caseiro
    orcid: 0000-0003-3188-3371
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
    corresponding: true
  - name: Cristina Monteiro
    affiliation: 2
affiliations:
  - name: Institute for Advanced Sustainability Studies
    index: 1
  - name: UVW - Centro de Modelação de Sistemas Ambientais
    index: 2
date: 5 October 2022
bibliography: paper.bib
---

# Summary
Air pollution dispertion modelling is fundamental to many environmental impact assessment studies.
It is common, in the industry of environmental impact assessments, that the available activity data does not have the same resolution as the emissions data and the data to be input to the model.
In particular, common dispersion models used in the industry require roadways to be characterized as line sources, with an emission factor that relates to all the passing traffic, whereas emission factors are described in terms of vehicles differentiated by characteristics such as type of fuel, technology, emission standard, technology, among others.
The tool presented in the present paper allows simplify the process and to derive the emission factor at the roadway level based on the EMEP/EEA air pollutant emission inventory guidebook and taking as input a description of the circulating material (e.g. taken from the national distribution) and the estimation of the number of passing vehicles differentiated, e.g., at the level of light and heavy vehicles.


# Statement of need

In a world where the most prominent risks are all environmental [@wef2021a], air pollution stands out for being the main global health impacting environmental issue [@hei2020a].
Air pollution is deemed to be responsible for 8.8 million premature deaths worldwide and 12 \% of the world's cities have air quality measures that meet WHO standards.
In Europe, the number of premature deaths is estimated at 790000, associated with an average reduction of 2.2 years in life expectancy, 2.9 years at the global level [@unep2019a, @lelieveld2020a].
The problematic also has a social dimension in its effects, as it is not evenly distributed among the population [@wang2016a @fairburn2019a].
In cities, vehicular traffic is a very strong source of air pollution, with 8 % of the european (EU-28) urban population exposed to fine particulates levels above the Eropean Union (EU) legal standard, and 77% exposed to levels above the World Health Organisation (WHO) standard [@eea2019a].

Air quality modelling (AQM) is primordial to any strategy to improve air quality.
It is used to support policies when administrative bodies (e.g. municipalities or regions) plan for better air [@eea2018a].
It is also used by the industry in the scope of environmental impact assessments in order to assess the impact of new or renewed infrastructure.
The use of AQM is particularly relevant in a world where traffic patterns are likely to shift in the near future due to the effects of global crisis both on the supply and the demand sides [@weo2021a], and particularly in the EU where the air quality standards are subject to debate [@ec2019a, @ec2019b, @ec2020a].
The inputs of AQM are emission factors (EF), activity (A) and meteorology, the output, after processing the dispersion of pollutants, are the ambient pollutant concentrations.

In the case of vehicular road traffic, the EMEP/EEA air pollutant emission inventory guidebook can be used as reference for EF.
However, the EF are listed in the document as a function of single vehicle type (and possibly driving mode and roadway characteristics).
Oftentimes, what the operator has at disposal is a characterization of the roadways within the domain and a representation (characterization) of the vehicular fleet within the domain (usually country specific).
What the operator needs, as input to the model, is a roadway (or roadway-chunk) specific EF.

The discrepancy implies lengthy, roadway-specific, calculations which the EFcalculatoR R function can simplify, turning the whole AQM process faster.

# References
