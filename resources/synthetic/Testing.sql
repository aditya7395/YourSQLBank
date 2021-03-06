DROP DATABASE IF EXISTS YourSQLBank_DB;
CREATE DATABASE YourSQLBank_DB;
USE YourSQLBank_DB;

DROP TABLE IF EXISTS User_TB;
CREATE TABLE User_TB
(
    USERNAME VARCHAR(50) NOT NULL,
    CHECKING_ACC_ID INT NOT NULL,
    SAVING_ACC_ID INT NOT NULL,
    ADMIN BOOLEAN DEFAULT FALSE NOT NULL,
    ACTIVE BOOLEAN DEFAULT TRUE NOT NULL,
    F_NAME VARCHAR(30) NOT NULL,
    L_NAME VARCHAR(50) NOT NULL,
    PASS VARCHAR(50) NOT NULL,
    CREATED_ON DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(USERNAME)
);

DROP TABLE IF EXISTS Account_TB;
CREATE TABLE Account_TB
(
    ACC_ID INT AUTO_INCREMENT NOT NULL,
    USERNAME VARCHAR(50) NOT NULL,
    ACC_TYPE VARCHAR(4) NOT NULL,
    BALANCE FLOAT NOT NULL check(BALANCE >= 0),
    PRIMARY KEY(ACC_ID)
);

DROP TABLE IF EXISTS History_TB;
CREATE TABLE History_TB
(
    TRSN_ID INT AUTO_INCREMENT NOT NULL,
    TRSN_TYPE VARCHAR(4) NOT NULL,
    TRSN_AMT FLOAT NOT NULL,
    USERNAME VARCHAR(50) NOT NULL,
    ACC_ID INT NOT NULL,
    TRSN_DATE DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(TRSN_ID),
    FOREIGN KEY(USERNAME) REFERENCES User_TB(USERNAME)
);

DROP TABLE IF EXISTS Account_TB_Archive;
CREATE TABLE Account_TB_Archive
(
    ACC_ID INT AUTO_INCREMENT NOT NULL,
    USERNAME VARCHAR(50) NOT NULL,
    ACC_TYPE VARCHAR(4) NOT NULL,
    BALANCE FLOAT NOT NULL check(BALANCE >= 0),
    PRIMARY KEY(ACC_ID),
    FOREIGN KEY(USERNAME) REFERENCES USER_TB(USERNAME)
);

DROP TABLE IF EXISTS History_TB_Archive;
CREATE TABLE History_TB_Archive
(
    TRSN_ID INT AUTO_INCREMENT NOT NULL,
    TRSN_TYPE VARCHAR(4) NOT NULL,
    TRSN_AMT FLOAT NOT NULL,
    USERNAME VARCHAR(50) NOT NULL,
    ACC_ID INT NOT NULL,
    TRSN_DATE DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(TRSN_ID),
    FOREIGN KEY(USERNAME) REFERENCES User_TB(USERNAME)
);

DROP TRIGGER IF EXISTS Handle_Transactions;
DELIMITER //
CREATE TRIGGER Handle_Transactions
AFTER INSERT ON History_TB
FOR EACH ROW
BEGIN
	IF New.TRSN_TYPE = "WTDW" THEN
		UPDATE Account_TB set Balance = Balance - new.TRSN_AMT where Account_TB.ACC_ID = new.ACC_ID;
	ELSE IF New.TRSN_TYPE = "DPST" THEN
		UPDATE Account_TB set Balance = Balance + new.TRSN_AMT where Account_TB.ACC_ID = new.ACC_ID;
	END IF;
	END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS Account_Closing;
DELIMITER //
CREATE TRIGGER Account_Closing
AFTER UPDATE ON User_TB
FOR EACH ROW
BEGIN
IF New.Active = FALSE and Old.Active = TRUE THEN
    INSERT INTO Account_TB_Archive (SELECT * FROM Account_TB where Account_TB.USERNAME = NEW.USERNAME);
    DELETE FROM Account_TB where Account_TB.USERNAME = NEW.USERNAME;
    INSERT INTO History_TB_Archive (SELECT * FROM History_TB where History_TB.USERNAME = NEW.USERNAME);
    DELETE FROM History_TB where History_TB.USERNAME = NEW.USERNAME;
END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS Archive_History;
DELIMITER //
CREATE PROCEDURE Archive_History(IN Expected_Date timestamp)
BEGIN
	UPDATE History_TB_Archived SET TRSN_DATE=CURRENT_TIMESTAMP WHERE TRSN_DATE <= Expected_Date;
	DELETE FROM History_TB WHERE TRSN_DATE <= Expected_Date;
END//
DELIMITER ;

FLUSH PRIVILEGES;
SET SQL_SAFE_UPDATES = 0;

INSERT INTO Account_TB (USERNAME, ACC_TYPE, BALANCE) values ("groot", "CHKG", 100);
INSERT INTO Account_TB (USERNAME, ACC_TYPE, BALANCE) values ("groot", "SVNG", 100);
INSERT INTO User_TB (USERNAME, CHECKING_ACC_ID, SAVING_ACC_ID, ADMIN, ACTIVE, F_NAME, L_NAME, PASS) values ("groot", 1, 2, TRUE, TRUE, "I AM", "GROOT", "groot");

INSERT INTO Account_TB (USERNAME, ACC_TYPE, BALANCE) values ("soham", "CHKG", 100);
INSERT INTO Account_TB (USERNAME, ACC_TYPE, BALANCE) values ("soham", "SVNG", 100);
INSERT INTO User_TB (USERNAME, CHECKING_ACC_ID, SAVING_ACC_ID, ADMIN, ACTIVE, F_NAME, L_NAME, PASS) values ("soham", 3, 4, FALSE, TRUE, "Soham", "Shah", "pass");

INSERT INTO history_tb (TRSN_TYPE, TRSN_AMT, USERNAME, ACC_ID) VALUES ('WTDW', 10, "groot", 1);
INSERT INTO history_tb (TRSN_TYPE, TRSN_AMT, USERNAME, ACC_ID) VALUES ('DPST', 100, "groot", 2);

INSERT INTO history_tb (TRSN_TYPE, TRSN_AMT, USERNAME, ACC_ID) VALUES ('WTDW', 20, "soham", 3);
INSERT INTO history_tb (TRSN_TYPE, TRSN_AMT, USERNAME, ACC_ID) VALUES ('DPST', 200, "soham", 4);

SELECT * FROM Account_TB;
SELECT * FROM User_TB;
SELECT * FROM History_TB;
SELECT * FROM Account_TB_Archive;
SELECT * FROM History_TB_Archive;

SELECT * FROM User_TB join Account_TB ON User_TB.USERNAME = Account_TB.USERNAME;
SELECT * FROM User_TB JOIN Account_TB ON User_TB.USERNAME = Account_TB.USERNAME JOIN History_TB ON User_TB.USERNAME = History_TB.USERNAME;