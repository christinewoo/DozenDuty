CREATE database dozenduty_new;

use dozenduty_new;

CREATE TABLE dozenDuty_app_member(
	memberID 	INT unsigned AUTO_INCREMENT, 
	memberName	VARCHAR(20),
	PRIMARY KEY (memberID)
);

CREATE TABLE dozenDuty_app_money(
    moneyID     INT unsigned AUTO_INCREMENT,
    borrowerID  INT unsigned NOT NULL,
    lenderID    INT unsigned NOT NULL,
    amount      REAL NOT NULL DEFAULT 0,
    PRIMARY KEY (moneyID),
    FOREIGN KEY (borrowerID) REFERENCES dozenDuty_app_member(memberID),
    FOREIGN KEY (lenderID) REFERENCES dozenDuty_app_member(memberID)
);

CREATE TABLE dozenDuty_app_home(
	homeID 		INT unsigned AUTO_INCREMENT, 
	memberID 	INT unsigned,
	homeName	VARCHAR(20) NOT NULL,
	PRIMARY KEY (homeID, memberID),
	FOREIGN KEY (memberID) REFERENCES dozenDuty_app_member(memberID)
);

CREATE TABLE dozenDuty_app_grocery(
	groceryID 	INT unsigned AUTO_INCREMENT, 
    groceryName VARCHAR(40),
	memberID	INT unsigned, 
	unitPrice	REAL unsigned, 
	quantity	REAL unsigned DEFAULT 0, 
	purchaseDate	DATE NOT NULL, 
	ExpirationDate	DATE, 
	ItemType	VARCHAR(20),
    ItemUnit    VARCHAR(10),
	PRIMARY KEY (groceryID),
	FOREIGN KEY (memberID) REFERENCES dozenDuty_app_member(memberID)
);

CREATE TABLE dozenDuty_app_chore(
	choreID		INT unsigned AUTO_INCREMENT, 
	memberID	INT unsigned, 
	name		VARCHAR(20), 
	assignDate	DATE NOT NULL,
	dueDate		DATE NOT NULL, 
	status		VARCHAR(15) DEFAULT 'NOT STARTED', 
	weight		INT  DEFAULT 3,
	PRIMARY KEY  (choreID),
	FOREIGN KEY  (memberID) REFERENCES dozenDuty_app_member(memberID)
);

CREATE TABLE dozenDuty_app_contain(
	memberID 	INT unsigned AUTO_INCREMENT,
	homeID 	INT unsigned, 
	PRIMARY KEY (memberID,homeID),
	FOREIGN KEY (memberID) REFERENCES dozenDuty_app_member(memberID),
	FOREIGN KEY (homeID) REFERENCES dozenDuty_app_home(homeID)
);

CREATE TABLE dozenDuty_app_shop(
	groceryID	INT unsigned AUTO_INCREMENT,
	homeID	INT unsigned,
	PRIMARY KEY(groceryID, homeID),
	FOREIGN KEY (groceryID) REFERENCES dozenDuty_app_grocery(groceryID),
	FOREIGN KEY (homeID) REFERENCES dozenDuty_app_home(homeID)
);

CREATE TABLE dozenDuty_app_does(
	choreID	INT unsigned AUTO_INCREMENT,
	homeID	INT unsigned,
	PRIMARY KEY(choreID, homeID),
	FOREIGN KEY (choreID) REFERENCES dozenDuty_app_chore(choreID),
	FOREIGN KEY (homeID) REFERENCES dozenDuty_app_home(homeID)
);

DELIMITER //
CREATE TRIGGER create_debts
    AFTER INSERT ON dozenduty_app_member
    FOR EACH ROW
    BEGIN
        Declare done int default 0;
        Declare new_id INT;
        Declare cur cursor for SELECT DISTINCT memberID FROM dozenDuty_app_member;
        Declare CONTINUE HANDLER FOR NOT FOUND SET done = 1;
        
        Open cur;
        
        Repeat
            FETCH cur into new_id;
            IF new_id<>new.memberID AND new_id IS NOT NULL THEN
                INSERT INTO dozenDuty_app_money (borrowerID,lenderID)
                VALUES(new.memberID,new_id);
                INSERT INTO dozenDuty_app_money (borrowerID,lenderID)
                VALUES(new_id,new.memberID);
            END IF;
            UNTIL done
        END Repeat;
    END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER delete_debts
    BEFORE DELETE ON dozenduty_app_member
    FOR EACH ROW
    BEGIN
        Declare done int default 0;
        Declare delete_id INT;
        Declare cur cursor for SELECT DISTINCT memberID FROM dozenDuty_app_member;
        Declare CONTINUE HANDLER FOR NOT FOUND SET done = 1;
        
        Open cur;
        
        Repeat
            FETCH cur into delete_id;
            IF delete_id=old.memberID THEN
                DELETE FROM dozenDuty_app_money WHERE borrowerID=delete_id or lenderID=delete_id;
            END IF;
            UNTIL done
        END Repeat;
    END //
DELIMITER ;


GRANT ALL ON dozenDuty_new.* TO 'djangouser'@'%';
FLUSH PRIVILEGES;