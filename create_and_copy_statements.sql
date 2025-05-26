/* Creating tables and importing recordings for all the tables */

/* Creating table for bankdata */
create table bankdata(
branchCodeNo INT,
STATE VARCHAR(225),
Address TEXT,
CITY VARCHAR(225)
);
/*importing records*/
COPY bankdata (branchCodeNo, STATE, Address, CITY)
FROM 'C:/Program Files/PostgreSQL/17/data/files/Final Data to import/bankdata.csv' -- change this path accordingly
DELIMITER ';'
CSV HEADER
ENCODING 'WIN1252';


/* creating table for bonddata*/
CREATE TABLE bonddata (
    Unique_key VARCHAR(50),
    Denominations INT
);
/* Importing recrods */
COPY bonddata (Unique_key, Denominations)
FROM 'C:/Program Files/PostgreSQL/17/data/files/Final Data to import/bonddata.csv'
DELIMITER ';'
CSV HEADER
ENCODING 'WIN1252';



/* Creating table for receiverdata */
CREATE TABLE receiverdata (
    DateEncashment DATE,
    PartyName VARCHAR(255),
    AccountNum VARCHAR(50),
    PayBranchCode INT,
    PayTeller INT,
    Unique_key VARCHAR(50)
);

/* Importing records into receiverdata table */
COPY receiverdata
FROM 'C:/Program Files/PostgreSQL/17/data/files/Final Data to import/receiverdata.csv'
DELIMITER ';'  
CSV HEADER     
ENCODING 'WIN1252';


/* Creating table for donordata */
CREATE TABLE donordata (
    Urn VARCHAR(50),
    JournalDate DATE,
    PurchaseDate DATE,
    ExpiryDate DATE,
    Purchaser VARCHAR(255),
    PayBranchCode INT,
    PayTeller INT,
    Unique_key VARCHAR(50)
);

/*Importing records into donordata table*/
COPY donordata
FROM 'C:/Program Files/PostgreSQL/17/data/files/Final Data to import/donordata.csv'
DELIMITER ';'
CSV HEADER
ENCODING 'UTF8';

