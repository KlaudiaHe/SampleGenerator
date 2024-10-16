/*The purpose of this macro is to create card level dataset by summarizing information about the transactions.
In order to do that the most frequent values of currency, customer_present_indicator and pos_terminal_attended are determined.
This step prepares dataset for clustering. */

%macro summarize_card_data;
    
    /* Step 4: Create Frequency Tables and Derive Most Common Categories to create card level data */
    proc sql;
        /* Currency Code */
        create table freq_currency as
        select CARD_ID, CURRENCY_CODE_FOREIGN, count(*) as freq
        from inter.cleaned_data
        group by CARD_ID, CURRENCY_CODE_FOREIGN;

        create table max_freq_currency as
        select CARD_ID, max(freq) as max_freq
        from freq_currency
        group by CARD_ID;

        create table distinct_currency as
        select a.CARD_ID, min(a.CURRENCY_CODE_FOREIGN) as CURRENCY_CODE_FOREIGN
        from freq_currency a
        inner join max_freq_currency b on a.CARD_ID = b.CARD_ID and a.freq = b.max_freq
        group by a.CARD_ID;

        /* Customer Presence Indicator, using numeric conversion */
        create table freq_customer_present as
        select CARD_ID, CUSTOMER_PRESENT_INDICATOR, count(*) as freq
        from inter.cleaned_data
        group by CARD_ID, CUSTOMER_PRESENT_INDICATOR;

        create table max_freq_customer_present as
        select CARD_ID, max(freq) as max_freq
        from freq_customer_present
        group by CARD_ID;

        create table distinct_presence as
        select a.CARD_ID, min(a.CUSTOMER_PRESENT_INDICATOR) as CUSTOMER_PRESENT_INDICATOR
        from freq_customer_present a
        inner join max_freq_customer_present b on a.CARD_ID = b.CARD_ID and a.freq = b.max_freq
        group by a.CARD_ID;

        /* POS Terminal Attended, using numeric conversion */
        create table freq_terminal_attended as
        select CARD_ID, POS_TERMINAL_ATTENDED, count(*) as freq
        from inter.cleaned_data
        group by CARD_ID, POS_TERMINAL_ATTENDED;

        create table max_freq_terminal_attended as
        select CARD_ID, max(freq) as max_freq
        from freq_terminal_attended
        group by CARD_ID;

        create table distinct_terminal_attended as
        select a.CARD_ID, min(a.POS_TERMINAL_ATTENDED) as POS_TERMINAL_ATTENDED
        from freq_terminal_attended a
        inner join max_freq_terminal_attended b on a.CARD_ID = b.CARD_ID and a.freq = b.max_freq
        group by a.CARD_ID;

        /* Step 3: Process FRAUD data and add FRAUD flag */
        create table inter.fraud_data as
        select CARD_ID, max(FRAUD) as FRAUD
        from inter.cleaned_data
        group by CARD_ID;

        /* Final summary table, saved as card_level_data */
        create table inter.card_level_first as
        select a.CARD_ID,
            sum(a.AMOUNT_BASE) as total_spent,
            avg(a.AMOUNT_BASE) as avg_spent,
            b.CURRENCY_CODE_FOREIGN as common_currency,
            c.CUSTOMER_PRESENT_INDICATOR as common_presence,
            e.POS_TERMINAL_ATTENDED as common_terminal_attended,
            f.FRAUD
        from inter.cleaned_data a
        left join distinct_currency b on a.CARD_ID = b.CARD_ID
        left join distinct_presence c on a.CARD_ID = c.CARD_ID
        left join distinct_terminal_attended e on a.CARD_ID = e.CARD_ID
        left join inter.fraud_data f on a.CARD_ID = f.CARD_ID
        group by a.CARD_ID;
    quit;

    proc sort data=inter.card_level_first out=inter.card_level_data nodupkey dupout=inter.cleaned_dups;
        by _all_;
    run;

%mend summarize_card_data;