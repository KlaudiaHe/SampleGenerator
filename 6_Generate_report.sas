/* The purpose of this macro is to generate the key statistics for the:
1. input dataset;
2. clusters;
3. final sample.

/* A. Stats about input dataset:
-Number of observations, variables, cards
-Number of fraudulent transactions
-Number of fraudulent cards.

B. Stats about clustered data:
-Number of clusters (K)
-Number of fraudulent clusters
-Number of transactions in each cluster

C. Stats about final sample:
- percent of non fraudulent cards added (X%) to the sample
-Number of non-fraudulent cards added;
-Number of non-fraudulent transactions added; 
-Total number of transactions.
*/


%macro generate_reports;
options locale=en_US;
ods noproctitle;
/* Add a large global title */
ods escapechar='^';
ods text="^S={font_size=11pt font_weight=bold just=center} Statistics for Input Dataset, Clusters and Final Sample^n^n";

/* 1. Number of observations and variables in the input dataset */ 
title "Number of Transactions in the Input Dataset";
proc sql;
    select count(*) as Number_of_Observations label='Number of all transactions'
    from inter.cleaned_data;
quit;

title "Number of Variables in the Input Dataset";
proc sql;
    select count(*) as Number_of_Variables label='Number of variables'
    from dictionary.columns
    where libname = 'FRAUDS' and memname = 'DEMODATA';
quit;

/* 2. Number of cards in the input dataset*/
title "Number of Cards in the Input Dataset";
proc sql;
    select count(distinct CARD_ID) as Number_of_Cards label='Number of all cards'
    from inter.cleaned_data;
quit;
 
/* 3. Number of fraudulent cards in the input dataset */ 
title "Number of Fraudulent Cards in the Input Dataset";
proc sql;
    select count(distinct CARD_ID) as Number_of_Fraudulent_Cards label='Number of fraudulent cards'
    from inter.cleaned_data
    where fraud = 1;
quit;
   
/* 4. Number of fraudulent transactions in the input dataset */
title "Number of Fraudulent Transactions in the Input Dataset";
proc freq data=inter.cleaned_data;
    tables fraud / nopercent;
run;
   

/* 5. General stats for &K clusters */
title "General Stats for all &K Clusters";
proc freq data=inter.clustered;
    tables cluster / nocum out=inter.transactions_per_cluster (rename=(count=num_transactions));
run;

/* 6. Clusters with fraudulent cards */
title "Number of Fraudulent Cards in &N Most Fraudulent Clusters";
proc sql;
    select cluster, count(distinct CARD_ID) as Fraudulent_Cards_in_Clusters label='Fraudulent cards'
    from inter.clustered
    where fraud = 1
    group by cluster;
quit;


/* 7. Number of cards in the final sample*/
title "Number of Cards in the Final Sample";
proc sql;
    select count(distinct CARD_ID) as Cards_in_the_Final_Sample label='All cards in final sample'
    from frauds.final_sample;
quit;

/* 8. Number of observations in the final sample */
title "Number of Transactions in the Final Sample";
proc sql;
    select count(*) as final_number_of_Observations label='All transactions in final sample'
    from frauds.final_sample;
quit; 
 

/* 9. Number of fraudulent and non-fraudulent transactions in the final sample */
title "Number of Fraudulent Transactions in the Final Sample";
proc freq data=frauds.final_sample;
    tables fraud / nopercent nocum;
run;

%mend generate_reports;



