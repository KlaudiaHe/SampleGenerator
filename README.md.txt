SAMPLE DATASET CREATION WITH FRAUDULENT TRANSACTIONS

The purpose:

The purpose of this script is to generate a sample dataset consisting of transactions from fraudulent cards and X% non-fraudulent cards found in the most fraudulent clusters.
Creating this type of samples may help in focusing on high-risk transactions, balancing fraudulent and non-fraudulent data, improving fraud detection model training and increasing efficiency in model development.

Process description:

Firstly, you specify the K-number of clusters in order to group cards from the initial dataset.
Then, you choose the N most-fraudulent clusters from all clusters. Cluster is fraudulent if at least one card in the cluster has fraudulent transaction.
Next, you specify the X% of non-fraudulent cards from the most fraudulent clusters. 
Finally, the sample dataset is created using:
- all transactions made by fraudulent cards;
- X% of non-fraudulent cards from the most fraudulent cluster.


Code:

In order to gain more insight examine the following files:
2_Clean_data;
3_Summarize_data;
4_Cluster_data;
5_Create_sample;
6_Generate_reports.

Dataset used:

The dataset FRAUDS.DEMODATA consists of 60,599 records related to financial transactions. 
It contains detailed information about the transactions, including timestamps, merchant details, and fraud indicators. 
Below is a list of the variables along with short descriptions:

    CARD_ID: Unique identifier for the card used in the transaction.
    ACQUIRER_COUNTRY_CODE: Country code of the acquirer processing the transaction.
    AMOUNT_BASE: The base amount of the transaction.
    AMOUNT_CASH_BACK: The amount of cash back requested during the transaction.
    CURRENCY_CODE_FOREIGN: Currency code for transactions made in foreign currencies.
    CUSTOMER_PRESENT_INDICATOR: Indicator showing whether the customer was present at the point of transaction.
    DEVICE_ID: Identifier for the device used to process the transaction.
    FRAUD: Flag indicating whether the transaction is suspected of fraud.
    LOCAL_TIMESTAMP: The local time when the transaction was processed.
    MERCHANT_ADDRESS_LINE3: Additional details of the merchant’s address.
    MERCHANT_CATEGORY: The category of the merchant where the transaction took place.
    MERCHANT_COUNTRY_CODE: Country code of the merchant involved in the transaction.
    MERCHANT_POSTAL_CODE: Postal code of the merchant involved in the transaction.
    POS_CONDITION_CODE: Code indicating the condition of the point-of-sale (POS) terminal during the transaction.
    POS_TERMINAL_ATTENDED: Indicator showing whether the POS terminal was attended by a staff member.
    RUN_TIMESTAMP: Timestamp when the transaction was run or recorded.

