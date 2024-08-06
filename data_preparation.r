# DOWNLOAD Two clinical files from cbioportal, and transform them into a clinical csv file which at least contains three columns: slide_id, case_id, label
# This file may be used for Deep Learning modeling and other statistical analysis for predicting prognosis of TCGA-PAAD
# Author: Zhang Zhao, email: zhangfide@hotmail.com, date: 2024-08-06

# Firstly, DOWNLOAD Two clinical files named as data_clinical_patient.txt and data_clinical_sample.txt respectively from cbioportal 
# Then, Prepare a dataframe for storing clinical informaion of TCGA-PAAD

paad_patient_clin <- read.table("data_clinical_patient.txt", sep='\t', header = TRUE, na.strings = c("[Not Available]","[Not Applicable]"), stringsAsFactors = TRUE, skip=4)
paad_sample_clin <- read.table("data_clinical_sample.txt", sep='\t', header = TRUE, na.strings = c("[Not Available]"), stringsAsFactors = TRUE, skip=4)
paad_clin <- merge(paad_sample_clin,paad_patient_clin,by=c('PATIENT_ID'))

# Define a new column to give labels to samples
paad_clin <- within(paad_clin, {
    response <- NA
    response[TREATMENT_OUTCOME_FIRST_COURSE %in% c('Complete Remission/Response', 'Partial Remission/Response')] <- "responsive"
    response[TREATMENT_OUTCOME_FIRST_COURSE %in% c('Progressive Disease')] <- 'non-responsive' })

# Select samples which had a specific response evaluation
paad_clin_not_evaled <- subset(paad_clin, 
                           response %in% c(NA), 
                           select = c("SAMPLE_ID","PATIENT_ID","response","SEX","AGE","TUMOR_RESECTED_MAX_DIMENSION","GRADE",
                                    "AJCC_PATHOLOGIC_TUMOR_STAGE","DIABETES_DIAGNOSIS_INDICATOR","HISTORY_CHRONIC_PANCREATITIS",
                                    "FAMILY_HISTORY_OF_CANCER","RADIATION_TREATMENT_ADJUVANT","PRIMARY_SITE_PATIENT",
                                    "TARGETED_MOLECULAR_THERAPY","OS_STATUS","OS_MONTHS","DFS_STATUS","DFS_MONTHS"))
paad_clin_evaled <- subset(paad_clin, 
                           response %in% c("responsive", "non-responsive"), 
                           select = c("SAMPLE_ID","PATIENT_ID","response","SEX","AGE","TUMOR_RESECTED_MAX_DIMENSION","GRADE",
                                    "AJCC_PATHOLOGIC_TUMOR_STAGE","DIABETES_DIAGNOSIS_INDICATOR","HISTORY_CHRONIC_PANCREATITIS",
                                    "FAMILY_HISTORY_OF_CANCER","RADIATION_TREATMENT_ADJUVANT","PRIMARY_SITE_PATIENT",
                                    "TARGETED_MOLECULAR_THERAPY","OS_STATUS","OS_MONTHS","DFS_STATUS","DFS_MONTHS"))

# Rename columns which will be used for following Deep Learning Modelling
out_df_not_evaled <- rename(paad_clin_not_evaled , c(SAMPLE_ID="slide_id", PATIENT_ID="case_id", response="label"))
out_df <- rename(paad_clin_evaled , c(SAMPLE_ID="slide_id", PATIENT_ID="case_id", response="label"))
write.csv(out_df_not_evaled, "D:/计算病理学研究/项目/胰腺癌预后模型/分析过程/tcga_paad_clin.NA.csv", row.names=FALSE)
write.csv(out_df, "D:/计算病理学研究/项目/胰腺癌预后模型/分析过程/tcga_paad_clin.csv", row.names=FALSE)
