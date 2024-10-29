#  MHC-HLO
This repository provides program files for replication of Harmonized Learning Outcomes (HLOs) – a core component of Human Capital Index. The repository also provides program files for the analysis for the paper Measuring Human Capital Using Global Learning Data (https://www.nature.com/articles/s41586-021-03323-7). 

# <h1 id="my-custom-anchor-name">
 HLO
</h1>

Harmonized Learning outcomes are developed in a two step process. 
1) Exchange rates are developed between all assessments. Technical details on construction of exchange rates are provided in [HLO (Harmonized Learning Outcomes)](https://www.nature.com/articles/s41586-021-03323-7)| Angrist, N., S. Djankov, P.K. Goldberg and H.A. Patrinos. 2021. Measuring Human Capital using Global Learning Data. Nature 592: 403-408 | Summary in [VoxEU](https://voxeu.org/article/measuring-human-capital-learning-matters-more-schooling) | [Data](https://datacatalog.worldbank.org/int/search/dataset/0038001). The do files for developing exchange rates are available at [exchangerate](https://github.com/worldbank/MHC-HLO-Production/blob/main/02_exchangerate/exchange_rates.do). (Mean learning outcomes are obtained from all the assessment data available. For information on the assessments available, please see  [Assessments included in Harmonized Learning Outcomes](#--assessments-included-in-harmonized-learning-outcomes). Detailed list of country-year-assessment is available [here](https://github.com/worldbank/MHC-HLO/blob/main/00_Documentation/country-year-assessment.csv). The raw data and published report for these assessments (if needed) can be obtained from datalibweb. Please see [Guidelines to retrieve raw data from datalibweb](#--guidelines-to-retrieve-raw-data-from-datalibweb). The final compiled data on mean learning outcomes is available [here](https://github.com/worldbank/MHC-HLO-Production/blob/3f99ebba4ed5047625984389fe4b808399217a04/1_input/WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta))
2) Mean learning outcomes are multiplied with exchange rates to develop Harmonized Learning Outcomes. The do files for developing HLOs are available at [03_HLO](https://github.com/worldbank/MHC-HLO-Production/tree/main/03_HLO)

For inclusion into Human Capital Index, Harmonized Learning Outcomes are averaged across primary and secondary levels and across subjects. The do files for obtaining HLOs for HCI are available at 04_HLO-HCI(https://github.com/worldbank/MHC-HLO-Production/tree/main/04_HLO_HCI)

We also document here do files used for the paper [Measuring Human Capital Using Global Learning Data](https://www.nature.com/articles/s41586-021-03323-7). The do files for the analysis as presented in the paper are available at [05_MHC](https://github.com/worldbank/MHC-HLO-Production/tree/main/05_MHC). The Harmonized Learning Outcomes used for Measuring Human Capita Paper were developed using a number of approaches including the use of exchange rates. For details on the methods used and the final numbers on Harmonized Learning Outcomes used for MHC paper, please go [here](https://github.com/worldbank/MHC-HLO/edit/main/51_MHC/Readme). 

<h2 id="my-custom-anchor-name">
  Assessments included in Harmonized Learning Outcomes:
</h2>

1. International Standardized Assessments (ISATs).

TIMSS. The Trends in International Mathematics and Science Study (TIMSS) is one of the main survey series conducted by the IEA. Five TIMSS rounds have been held to date in Math and Science subjects covering grades 4 and 8. The first, conducted in 1995, covered 45 national educational systems and three groups of students. The second round covered 38 educational systems in 1999, examining pupils from secondary education (grade 8). The third round covered 50 educational systems in 2003, focusing on both primary and secondary education (grades 4 and 8). In 2007, the fourth survey covered grades 4 and 8 and more than 66 educational systems. In 2011, the survey covered 77 educational systems across grades 4 and 8. The 2015 round covered 63 countries/areas, while the latest 2019 round covered 64 countries and eight benchmarking systems. The precise content of the questionnaires varies but remains systematic across countries.

PIRLS. The other dominant IEA survey is the Progress in International Reading Literacy Study (PIRLS). Four rounds of PIRLS have been held to date: in 2001, 2006 and 2011 and 2016. The PIRLS tests pupils from primary schools in grade 4 in reading proficiency. In 2006, PIRLS included 41 countries/areas, two of which were African countries (Morocco and South Africa), 4 lower-middle-income countries (Georgia, Indonesia, Moldova, Morocco) and 8 upper-middle-income countries (Bulgaria, Islamic Republic of Iran, Lithuania, Macedonia, Federal Yugoslavian Republic, Romania, Russian Federation, South Africa). The third round of PIRLS was carried out with TIMSS in 2011 and included 60 countries/areas. The latest round of PIRLS was conducted in 2016 and included 62 countries/areas. In our database, we use all recent IEA studies across two subjects (mathematics and reading/literacy).  We use results from official reports (Harmon et al., 1997; Martin et al., 2000; Mullis et al., 2000; Mullis et al., 2003; Mullis et al., 2004; Martin et al., 2007; Mullis et al., 2008; Mullis et al., 2009; Martin et al., 2016; Mullis et al., 2016).

PISA. The Organization for Economic Co-operation and Development (OECD) launched the Programme for International Student Assessment (PISA) in 1997 to provide comparable data on student performance. PISA emphasizes an extended concept of “literacy” and an emphasis on lifelong learning – with the aim of measuring pupils’ capacity to apply learned knowledge to new settings. Since 2000, PISA has assessed the skills of 15-year-old pupils every three years. PISA concentrates on three subjects: mathematics, science and literacy. In 2000, PISA had a focus, in the form of extensive domain items, on literacy; in 2003, on mathematical skills; and in 2006 on scientific skills. The framework for evaluation remains the same across time to ensure comparability.6 In 2009, 75 countries/areas participated; in 2012, 65 countries/areas participated and in 2015, 72 countries/areas participated and in 2018, 79 countries/areas participated. A main distinction between PISA and IEA surveys is that PISA assesses 15-year-old pupils, regardless of grade level, while IEA assessments assess grade 4 and 8.

2.	Regional Standardized Assessments (RSATs).

The Southern and Eastern Africa Consortium for Monitoring Educational Quality (SACMEQ). SACMEQ grew out of a national investigation into the quality of primary education in Zimbabwe in 1991. It was supported by the UNESCO International Institute for Educational Planning (IIEP) (Ross and Postlethwaite, 1991). Several education ministers in Southern and Eastern African countries expressed an interest in a similar study. Planners from seven countries met in Paris in July 2004 and established SACMEQ. The current 15 SACMEQ-member education members are: Botswana, Kenya, Lesotho, Malawi, Mauritius, Mozambique, Namibia, Seychelles, the Republic of South Africa, Swaziland, the United Republic of Tanzania, United Republic of Tanzania (Zanzibar), Uganda, Zambia and Zimbabwe.

The first SACMEQ round took place between 1995 and 1999. SACMEQ I covered seven different countries and assessed performance in reading at grade 6. The participating countries were Kenya, Malawi, Mauritius, Namibia, United Republic of Tanzania (Zanzibar), Zambia and Zimbabwe. The studies shared common features (research issues, instruments, target populations, sampling and analytical procedures). A separate report was prepared for each country.

SACMEQ II surveyed grade 6 pupils from 2000-2004 in 14 countries: Botswana, Kenya, Lesotho, Mauritius, Malawi, Mozambique, Namibia, Seychelles, South Africa, Swaziland, Tanzania (Mainland), Tanzania (Zanzibar), Uganda, and Zambia. Notably, SACMEQ II also collected information on pupils’ socioeconomic status as well as educational inputs, the educational environment and issues relating to equitable allocation of human and material resources. SACMEQ II also included overlapping items with a series of other surveys for international comparison, namely the Indicators of the Quality of Education (Zimbabwe) study, TIMSS and the 1985-94 IEA Reading Literacy Study.

The third SACMEQ round (SACMEQ III) spans 2006-2011 and covers the same countries as SACMEQ II plus Zimbabwe. SACMEQ III also assess the achievement of grade 6 pupils. The latest round of SACMEQ (SACMEQ IV) was conducted in 2013 in 15 countries.

LLECE. The network of national education systems in Latin American and Caribbean countries, known as the Latin American Laboratory for Assessment of the Quality of Education (LLECE), was formed in 1994 and is coordinated by the UNESCO Regional Bureau for Education in Latin America and the Caribbean. Assessments conducted by the LLECE focus on achievement in reading and mathematics. The first round was conducted in 1998 across grades 3 and 4 in 13 countries (Casassus et al., 1998, 2002). These countries include: Argentina, Bolivia, Brazil, Chile, Colombia, Costa Rica, Cuba, Dominican Republic, Honduras, Mexico, Paraguay, Peru and the República Bolivariana de Venezuela (Casassus et al., 1998). The second round of the LLECE survey was initiated in 2006 in the same countries as LLECE I. In round two, called the Second Regional Comparative and Explanatory Study (SERCE), pupils were tested in grade 3 and grade 6. The Third Regional Comparative and Explanatory Study (TERCE), was done in 2013 across grades 3 and 6 and included 15 Latin American and Caribbean countries. Our analysis will include both SERCE and TERCE results, since these assessments are most similar and cover comparable grades.

PASEC. The “Programme d’Analyse des Systemes Educatifs” (PASEC, or Programme of Analysis of Education Systems”) was launched by the Conference of Ministers of Education of French-Speaking Countries (CONFEMEN). These surveys are conducted in French-speaking countries in Sub-Saharan Africa in primary school (grade 2 and 5) for skills in language of instruction and mathematics. Altinok, Angrist and Patrinos (2018) included PASEC I (1996 to 2003) and PASEC II (2004 to 2010). The current database also includes PASEC III which was conducted in 2014 in 10 countries . PASEC was improved and modified significantly in 2014. Unlike earlier PASEC assessments, PASEC 2014 used new tests and used Item Response Model to implement tests and analyze results. PASEC 2019 covered 14 countries and the results are temporally comparable to PASEC 2014.

3.	International/Regional Non-IRT Assessments.

Early Grade Reading Assessment (EGRA). Early Grade Reading Assessment (EGRA) is a basic literacy assessment conducted in early grades, mainly between grades 1 and 4. By 2015, EGRA had been administered in more than 70 countries and in more than 120 languages. The assessment consists of a range of sub-tasks and individual EGRAs differ in the sub-tasks used. Despite the differences, there are certain sub-tasks specifically oral reading fluency and reading comprehension that are captured almost universally in EGRAs and are relatively comparable across countries. Specifically, reading comprehension on EGRA maps directly into one of the levels in Levels 1-8 on SACMEQ, the RSAT for East and Southern Africa and is identified by Abadzi(2009) as a likely proficiency link between EGRA and ISATs/RSATs. We therefore use scores on reading comprehension to link learning outcomes on EGRAs to learning outcomes on PIRLS. Using EGRA allows us to cover new countries in our database, namely, Afghanistan, Cambodia, Guyana, Kiribati, Rwanda, Nepal, Sierra Leone, Sudan, Timor-Leste, Tonga, Tuvalu and Vanuatu. Similarly, using EGRA also allows us to add recent data on learning outcomes for countries like Democratic Republic of Congo, Gambia, Ghana, Kyrgyzstan, Tanzania and Zambia. EGRAs also allow us to include into the database ‘better than nothing’ estimates where we do not have data on learning outcomes from the other assessments but have results from non-nationally representative EGRAs. Non-nationally representative EGRAs allow us to include ‘better than nothing’ estimates on learning outcomes for some countries namely Bangladesh, Haiti, Iraq, Lao PDR, Myanmar and Tajikistan. 

Pacific Islands Literacy and Numeracy Assessment (PILNA).PILNA is a regional assessment covering 15 Pacific Island Nations in 2018. The first round of PILNA was administered in 2012 in 14 Pacific Island countries. Since 2012, PILNA has been carried out after every three years, in 2015 and 2018, and the next round of PILNA is planned for the year 2021. PILNA assesses literacy and numeracy for students after four and six years of formal schooling counting from the first year of International Standard Classification of Education (ISCED) Level 1. For literacy, the assessment is divided into two major domains: Reading and Writing. For Reading domain, students are provided with three types of text, narrative, procedural and informative and student competencies are assessed in identifying information, interpreting and critically analyzing the provided text.

The Multiple Indicator Cluster Surveys, MICS. MICS is one of the largest global sources of statistically sound and internationally comparable data on children and women. MICS data are gathered during face-to-face interviews in representative samples of households. The surveys are typically carried out by government organizations, with technical support from UNICEF. Since the mid-1990s, MICS has supported more than 100 countries to produce data on a range of indicators in areas such as health, education, child protection and HIV/AIDS. MICS data can be disaggregated by numerous geographic, social and demographic characteristics. As of 2019, five rounds of surveys have been conducted: MICS1 (1995-1999), MICS2 (1999-2004), MICS3 (2004–2009), MICS4 (2009–2012) and MICS5 (2012-2015). The sixth round of MICS (MICS6) is scheduled to take place in 2016–2019. Survey results, tools, reports, microdata, and information on the MICS programme are available at <mics.unicef.org>.

MICS 6 includes a module on Foundational Learning Skills (FLS) measuring learning outcomes expected for grades 2 and 3 in reading and numeracy. This module is administered to one randomly selected child aged 7 to 14 years in each surveyed household. The FLS Module of MICS6 covers reading and mathematics skills. We use the reading component of the instrument which includes two subtasks – oral reading accuracy and reading comprehension. As of April 2021, 51 countries have already participated in MICS6. Of these, for 34 countries, the survey has been completed and data and survey findings are publicly available on UNICEF’s website. Of these, eight countries did not include foundational learning module. 




<h2 id="my-custom-anchor-name">
  Guidelines to Retrieve Raw Data from datalibweb:
</h2>

Installation of datalibweb

a) Directly from Stata: In order to get install to Datalibweb command in Stata, type the following code, and click on the datalibweb (hyperlink) to install in your computer.
1. Close all Stata sessions
2. Enter this line in Stata “net from http://eca/povdata/datalibweb/_ado” 

 b) Manual installation: In addition, users can install the package the manual way.

1. Get the file from this link: http://eca/povdata/datalibweb/_ado/datalibweb.zip 
2. Copy with replacement all the files into c:/ado, without changing the folder structure.

Retrieving data

datalibweb, parameters [options]
Parameters
    Required                     Description
    --------------------------------------------------------------------------------------------------------
    country(string)              three digits country code (WDI standards). More than one country is
                                               allowed, i.e "ALB VNM".

    years(numlist)               years for which the data is requested (one or many years: i.e. 2005 or
                                              2005/2008 or 2005 2008).

    type(string)                   type of ONE collection requested -EDURAW

For example: the code below is used to query the file “ALB_2015_CM2_STU_QQQ.dta” from the ALB 2015 PISA survey.

datalibweb, country(ALB) year(2015) type(EDURAW) surveyid(ALB_2015_PISA_v01_M) filename(ALB_2015_CM2_STU_QQQ.dta)
