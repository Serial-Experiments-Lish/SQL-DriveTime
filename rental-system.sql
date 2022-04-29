CREATE DATABASE rental_db;
USE rental_db;

CREATE TABLE vehicles (
	veh_reg_no VARCHAR(8) NOT NULL,
    category ENUM('car', 'truck') NOT NULL DEFAULT 'car',
    -- Enumeration of one of the items in the list
    brand VARCHAR(30) NOT NULL DEFAULT '',
    `desc` VARCHAR(256) NOT NULL DEFAULT '',
    photo BLOB          NULL,
    -- binary large object of 64KB to be implemented later
    daily_rate DECIMAL(6,2)  NOT NULL DEFAULT 9999.99,
    -- Set default to max value
    PRIMARY KEY (veh_reg_no),
    INDEX (category)
) ENGINE=InnoDB;
DESC vehicles;
SHOW CREATE TABLE vehicles;
SHOW INDEX FROM vehicles;

CREATE TABLE customers (
	customer_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(30)  NOT NULL DEFAULT '',
    address VARCHAR(80)  NOT NULL DEFAULT '',
    phone VARCHAR(15)  NOT NULL DEFAULT '',
    discount DOUBLE  NOT NULL DEFAULT 0.0,
    PRIMARY KEY (customer_id),
    UNIQUE INDEX (phone),
    INDEX (`name`)
) ENGINE=InnoDB;
DESC customers;
SHOW CREATE TABLE customers;
SHOW INDEX FROM customers;

CREATE TABLE rental_records (
	rental_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	veh_reg_no 	VARCHAR(8)  NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    start_date DATE          NOT NULL DEFAULT('0000-00-00'),
    end_date DATE          NOT NULL DEFAULT('0000-00-00'),
    lastUpdated TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (rental_id),
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
		ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (veh_reg_no) REFERENCES vehicles (veh_reg_no)
		ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
DESC rental_records;
SHOW CREATE TABLE rental_records;
SHOW INDEX FROM rental_records;

INSERT INTO vehicles VALUES
   ('SBA1111A', 'car', 'NISSAN SUNNY 1.6L', '4 Door Saloon, Automatic', NULL, 99.99),
   ('SBB2222B', 'car', 'TOYOTA ALTIS 1.6L', '4 Door Saloon, Automatic', NULL, 99.99),
   ('SBC3333C', 'car', 'HONDA CIVIC 1.8L',  '4 Door Saloon, Automatic', NULL, 119.99),
   ('GA5555E', 'truck', 'NISSAN CABSTAR 3.0L',  'Lorry, Manual ', NULL, 89.99),
   ('GA6666F', 'truck', 'OPEL COMBO 1.6L',  'Van, Manual', NULL, 69.99);
SELECT * FROM vehicles;

INSERT INTO customers VALUES
   (1001, 'Angel', '8 Happy Ave', '88888888', 0.1),
   (NULL, 'Mohammed Ali', '1 Kg Java', '99999999', 0.15),
   (NULL, 'Kumar', '5 Serangoon Road', '55555555', 0),
   (NULL, 'Kevin Jones', '2 Sunset boulevard', '22222222', 0.2);
SELECT * FROM customers;

INSERT INTO rental_records VALUES
  (NULL, 'SBA1111A', 1001, '2012-01-01', '2012-01-21', NULL),
  (NULL, 'SBA1111A', 1001, '2012-02-01', '2012-02-05', NULL),
  (NULL, 'GA5555E',  1003, '2012-01-05', '2012-01-31', NULL),
  (NULL, 'GA6666F',  1004, '2012-01-20', '2012-02-20', NULL);
SELECT * FROM rental_records;

-- First query, to update 'Angel' renting SBA1111A for 10 days, starting today. 
INSERT INTO rental_records (veh_reg_no, customer_id, start_date, end_date)
VALUES ('SBA1111A', '1001', NOW(), DATE_ADD(CURDATE(), INTERVAL(10) DAY));

-- Second query, to register Kumar for rental starting tomorrow for next 3 months.
INSERT INTO rental_records (veh_reg_no, customer_id, start_date, end_date)
VALUES ('GA5555E', '1003', DATE_ADD(CURDATE(), INTERVAL(1) DAY), DATE_ADD(CURDATE(), INTERVAL(3) MONTH));

-- Third query, to list rental records with registration number, brand, and customer name.
SELECT category, start_date, veh_reg_no, brand, `name`, end_date FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
INNER JOIN customers USING (customer_id)
ORDER BY category, start_date;

-- Fourth query, to list expired rental records.
SELECT * FROM rental_records 
WHERE end_date < CURDATE();

-- Fifth query, to list vehicles rented out on '2012-01-10'.
SELECT veh_reg_no, `name`, start_date, end_date FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
INNER JOIN customers USING (customer_id)
WHERE ('2012-01-10' BETWEEN start_date AND end_date);

-- Sixth query, to list vehicles rented out today.
SELECT veh_reg_no, `name`, start_date, end_date FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
INNER JOIN customers USING (customer_id)
WHERE (NOW() BETWEEN start_date AND end_date);

-- Seventh query, to list vehicles rented out from '2012-01-03' to '2012-01-18'.
SELECT veh_reg_no, category, brand, `desc`, start_date, end_date FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
WHERE (start_date BETWEEN '2012-01-03' AND '2012-01-18' AND end_date >= '2012-01-18');

-- Eight query, to list vehicles available for rental on '2012-01-10'.
SELECT veh_reg_no, brand, `desc` FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
WHERE ('2012-01-10' NOT BETWEEN start_date AND end_date);

-- Ninth query, to list vehicles available for rental between '2012-01-03' to '2012-01-18'.
SELECT veh_reg_no, brand, `desc` FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
WHERE (end_date < '2012-01-03' OR start_date > '2012-01-18');

-- Tenth query, to list vehicles available for rental 10 days from today.
SELECT veh_reg_no, brand, `desc`, start_date FROM vehicles
INNER JOIN rental_records USING (veh_reg_no)
WHERE (start_date < CURDATE() AND end_date > DATE_ADD(CURDATE(), INTERVAL(10) DAY));