/*The purpose of this macro is to create sample dataset which consists of all transactions from:
-fraudulent cards (at least one fraudulent transaction);
-X% non-fraudulent cards from the N most fraudulent clusters. */

%macro create_sample;

    /* Step 1: Identify all card IDs that have at least one fraudulent transaction */
    proc sql;
        create table inter.fraudulent_cards as
        select distinct CARD_ID
        from inter.cleaned_data
        where FRAUD = 1;
    quit;

    /* Step 2: Retrieve all transactions from these card IDs */
    proc sql;
        create table inter.all_fraud_cards as
        select a.*
        from inter.cleaned_data a
        where a.CARD_ID in (select CARD_ID from inter.fraudulent_cards);
    quit;

    /* Step 3: Identify top N most-fraudulent clusters based on the count of fraudulent transactions */
    proc sql;
        create table inter.top_clusters as
        select cluster, count(FRAUD) as fraud_count
        from inter.clustered
        where FRAUD = 1
        group by cluster
        having fraud_count > 0
        order by fraud_count desc;
    quit;

    /* Step 3a: Limit to top N clusters */
    proc sql noprint;
        select cluster into :top_n_clusters separated by ','
        from inter.top_clusters
        (obs=&N);
    quit;

    /* Step 4: Create a temporary dataset of non-fraudulent cards from these top clusters */
    proc sql;
        create table inter.non_fraud_cards_temp as
        select distinct CARD_ID
        from inter.clustered
        where cluster in (&top_n_clusters) and FRAUD = 0;
    quit;

    /* Step 5: Calculate the sample size based on X macro value */
    proc sql noprint;
        select count(*) into :total_non_fraud_cards
        from inter.non_fraud_cards_temp;
    quit;

    %let sample_size = %sysevalf(&total_non_fraud_cards * &X / 100, ceil);

    /* Step 6: Sample X% of non-fraudulent cards */
    proc surveyselect data=inter.non_fraud_cards_temp out=inter.sampled_non_fraud_cards
        sampsize=&sample_size method=srs;
    run;

    /* Step 7: Retrieve all transactions for the sampled non-fraudulent cards */
    proc sql;
        create table inter.all_sampled_non_fraud as
        select *
        from inter.cleaned_data
        where CARD_ID in (select CARD_ID from inter.sampled_non_fraud_cards);
    quit;

    /* Step 8: Combine all fraudulent transactions and all transactions from sampled non-fraudulent cards */
    data inter.combined;
        set inter.all_fraud_cards inter.all_sampled_non_fraud;
    run;

    /* Step 9: Ensure that each transaction has the cluster value assigned to it */
    proc sql;
        create table inter.sample_data as
        select 
            a.*,
            b.cluster
        from inter.combined a
        left join inter.clustered b
        on a.CARD_ID = b.CARD_ID;
    quit;

    /* Step 10: Remove any duplicate records */
    proc sort data=inter.sample_data out=frauds.final_sample nodupkey dupout=inter.sample_data_dups;
        by _all_;
    run;

%mend create_sample;
