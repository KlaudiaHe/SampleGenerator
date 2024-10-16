%macro cluster_data;

    /* Clustering using PROC FASTCLUS based on values from variables: average amount of money spent, 
       total amount of money spent, customer present indicator and POS terminal attended */
    proc fastclus data=inter.card_level_data maxclusters=&K out=inter.cluster_out;
        var avg_spent total_spent common_terminal_attended common_presence;
    run;

    /* Duplicates removal */
    proc sort data=inter.cluster_out out=inter.clustered nodupkey dupout=inter.cluster_dups;
        by _all_;
    run;

    /*Simple scatter plot to visualize clusters*/
    proc sgplot data=inter.clustered;
        scatter x=avg_spent y=total_spent / group=cluster markerattrs=(symbol=CircleFilled) transparency=0.5;
        xaxis label="Average Amount Spent" grid;
        yaxis label="Total Amount Spent" grid;
        keylegend / title="Clusters";
        title "Distribution of Clusters Based on Average and Total Amount Spent";
        title2 "This scatter plot visualizes the distribution of card transactions based on two key variables: average amount spent per transaction (x-axis) and total amount spent (y-axis). Each point represents a card, and the points are colored according to the cluster they belong to.";
    run;

%mend cluster_data;






