/*
SAMPLE DATASET CREATION

The purpose of this script is to generate a sample dataset consisting of transactions 
from fraudulent cards and X% non-fraudulent cards found in the most fraudulent clusters.

Process description:
Firstly, you specify the K-number of clusters in order to group cards from the initial dataset.
Then, you choose the N most-fraudulent clusters from all clusters (cluster is fraudulent 
if at least one card in the cluster has fraudulent transaction).
Next, you specify the X% of non-fraudulent cards from the most fraudulent clusters. 
Finally, the sample dataset is created using all of the transactions from fraudulent cards and the X% of non-fraudulent cards.

In order to gain more insight examine the following files:
2_Clean_data;
3_Summarize_data;
4_Cluster_data;
5_Create_sample;
6_Generate_reports.

To simply generate the sample dataset, execute the steps below in chronological order.
*/

/* 1.1. Set up the library where the data resides */
libname frauds '/home/u63782053/Frauds';

/* 1/2. Set up the library for intermediate tables */
libname inter '/home/u63782053/Frauds/Intermediate';

/* 2. Import XLSX file into a SAS dataset */
proc import datafile='/home/u63782053/Frauds/demodata.xlsx'
    out=frauds.demodata
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* 3. Include the macro files */
%include '/home/u63782053/Frauds/2_Clean_data.sas';
%include '/home/u63782053/Frauds/3_Summarize_data.sas';
%include '/home/u63782053/Frauds/4_Cluster_data.sas';
%include '/home/u63782053/Frauds/5_Create_sample.sas';
%include '/home/u63782053/Frauds/6_Generate_report.sas';

/* 4. Define macro variables */
%let K = 3; /* Number of clusters */
%let N = 3; /* Number of the most fraudulent clusters to be used for creating the sample dataset */
%let X = 20; /* Percentage of non-fraudulent cards from the most fraudulent clusters */

/* 5. Execute macro to prepare data for further manipulation */
%clean_data;

/* 6. Execute macro to prepare card level data */
%summarize_card_data;

/* 7. Execute macro to cluster cards */
%cluster_data;

/* 8. Execute macro to create a sample dataset */
%create_sample;

/* 9. Execute macro to generate reports */
%generate_reports;