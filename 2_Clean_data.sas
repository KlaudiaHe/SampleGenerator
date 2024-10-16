/* The purpose of this macro is to prepare data for creation of card level dataset. */


%macro clean_data;
    %LET source_dataset = frauds.demodata;
    
    /* 1. Remove duplicate rows from the initial dataset */
    proc sort data=&source_dataset out=inter.cleaned_data nodupkey dupout=inter.dup_dataset;
        by _all_;
    run;

    /* 2. Convert AMOUNT_BASE into numeric values */
    data inter.cleaned_data;
        set inter.cleaned_data;
        AMOUNT_BASE_num = input(AMOUNT_BASE, comma12.);
        drop AMOUNT_BASE;
        rename AMOUNT_BASE_num = AMOUNT_BASE;
    run;

    /* 3. Remove transactions with missing time and amount */
    data inter.cleaned_data;
        set inter.cleaned_data;
        where AMOUNT_BASE ^= . and RUN_TIMESTAMP ^= ' ' and LOCAL_TIMESTAMP ^= ' ';
    run;

    /* 4. Remove transactions with missing time and amount */
    data inter.cleaned_data;
        set inter.cleaned_data;
        where AMOUNT_BASE ^= . and RUN_TIMESTAMP ^= ' ' and LOCAL_TIMESTAMP ^= ' ';
    run;

    /* 6. Convert 'Y'/'N' to 1/0 for relevant variables */
data inter.cleaned_data;
        set inter.cleaned_data;
        POS_TERMINAL_ATTENDED_NUM = (POS_TERMINAL_ATTENDED = 'Y');
        CUSTOMER_PRESENT_NUM = (CUSTOMER_PRESENT_INDICATOR = 'Y');
    run;

    data inter.cleaned_data;
        set inter.cleaned_data;
        drop POS_TERMINAL_ATTENDED CUSTOMER_PRESENT_INDICATOR;
        rename POS_TERMINAL_ATTENDED_NUM = POS_TERMINAL_ATTENDED
               CUSTOMER_PRESENT_NUM = CUSTOMER_PRESENT_INDICATOR;
    run;

    /* 5. Impute missing: POS_TERMINAL_ATTENDED, CUSTOMER_PRESENT_INDICATOR, and CURRENCY_CODE_FOREIGN with the most frequent values */
    %impute_most_freq(var=POS_TERMINAL_ATTENDED);
    %impute_most_freq(var=CUSTOMER_PRESENT_INDICATOR);
    %impute_most_freq(var=CURRENCY_CODE_FOREIGN);

%mend clean_data;

%macro impute_most_freq(var=);
    /* Step 1: Calculate frequency of each value */
    proc freq data=inter.cleaned_data noprint;
        tables &var / missing out=freq_&var;
    run;

    /* Step 2: Sort the frequency table by descending count */
    proc sort data=freq_&var;
        by descending count;
    run;

    /* Step 3: Retrieve the most frequent value */
    data _null_;
        set freq_&var;
        if _N_ = 1 then call symputx('most_freq', &var);
    run;

    /* Step 4: Impute missing values */
    data inter.cleaned_data;
        set inter.cleaned_data;
        if &var = '' then &var = symget('most_freq');
    run;
%mend impute_most_freq;


/* proc freq data=inter.cleaned_data; */
/* tables POS_TERMINAL_ATTENDED CUSTOMER_PRESENT_INDICATOR CURRENCY_CODE_FOREIGN / missing; */
/* run; */
