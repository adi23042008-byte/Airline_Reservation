-- ============================================================
-- AIRLINE RESERVATION SYSTEM - DATABASE SCHEMA
-- B.Tech CSE-AIML | BCSC 0034: Database Technology
-- ============================================================

-- Create database
DROP DATABASE IF EXISTS airline_reservation;
CREATE DATABASE airline_reservation;
USE airline_reservation;

-- ============================================================
-- TABLE 1: COUNTRIES
-- Stores the 6 countries involved in the airline system
-- ============================================================
CREATE TABLE countries (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country_name VARCHAR(50) NOT NULL UNIQUE,
    currency_name VARCHAR(30) NOT NULL,
    currency_code VARCHAR(5) NOT NULL
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 2: AIRLINES
-- 6 airlines, one per country
-- ============================================================
CREATE TABLE airlines (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_code VARCHAR(10) NOT NULL UNIQUE,
    airline_name VARCHAR(50) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 3: CITIES
-- 12 cities across 6 countries (2 per country)
-- ============================================================
CREATE TABLE cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(50) NOT NULL,
    country_id INT NOT NULL,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 4: AIRPORTS
-- One airport per city, each with a unique airport code
-- ============================================================
CREATE TABLE airports (
    airport_code VARCHAR(5) PRIMARY KEY,
    airport_name VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    airport_tax DECIMAL(10,4) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 5: FLIGHTS
-- Flight master table with unique flight numbers
-- ============================================================
CREATE TABLE flights (
    flight_no VARCHAR(10) PRIMARY KEY,
    airline_id INT NOT NULL,
    origin VARCHAR(5) NOT NULL,
    destination VARCHAR(5) NOT NULL,
    business_class BOOLEAN NOT NULL DEFAULT TRUE,
    smoking_allowed BOOLEAN NOT NULL DEFAULT FALSE,
    flight_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (origin) REFERENCES airports(airport_code),
    FOREIGN KEY (destination) REFERENCES airports(airport_code)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 6: FLIGHT AVAILABILITY
-- Tracks seat availability for each flight on each date
-- ============================================================
CREATE TABLE flight_availability (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_no VARCHAR(10) NOT NULL,
    departure_datetime DATETIME NOT NULL,
    arrival_datetime DATETIME NOT NULL,
    total_business_seats INT NOT NULL DEFAULT 0,
    booked_business_seats INT NOT NULL DEFAULT 0,
    total_economy_seats INT NOT NULL DEFAULT 0,
    booked_economy_seats INT NOT NULL DEFAULT 0,
    FOREIGN KEY (flight_no) REFERENCES flights(flight_no),
    UNIQUE KEY uk_flight_departure (flight_no, departure_datetime)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 7: CUSTOMERS
-- Customer master table
-- ============================================================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    street VARCHAR(100),
    city VARCHAR(50),
    province_state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 8: CUSTOMER PHONES
-- Zero or more phone numbers per customer
-- ============================================================
CREATE TABLE customer_phones (
    phone_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    country_code VARCHAR(5) NOT NULL,
    area_code VARCHAR(5) NOT NULL,
    local_number VARCHAR(15) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 9: CUSTOMER FAXES
-- Zero or more fax numbers per customer
-- ============================================================
CREATE TABLE customer_faxes (
    fax_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    country_code VARCHAR(5) NOT NULL,
    area_code VARCHAR(5) NOT NULL,
    local_number VARCHAR(15) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 10: CUSTOMER EMAILS
-- Zero or more email addresses per customer (each unique)
-- ============================================================
CREATE TABLE customer_emails (
    email_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 11: CURRENCY EXCHANGE
-- Daily exchange rates between currencies
-- ============================================================
CREATE TABLE currency_exchange (
    exchange_id INT PRIMARY KEY AUTO_INCREMENT,
    from_currency VARCHAR(5) NOT NULL,
    to_currency VARCHAR(5) NOT NULL,
    exchange_rate DECIMAL(12,6) NOT NULL,
    rate_date DATE NOT NULL,
    UNIQUE KEY uk_exchange (from_currency, to_currency, rate_date)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 12: BOOKINGS
-- Reservation records for customers
-- ============================================================
CREATE TABLE bookings (
    booking_no INT PRIMARY KEY AUTO_INCREMENT,
    booking_city VARCHAR(50) NOT NULL,
    booking_date DATE NOT NULL,
    flight_no VARCHAR(10) NOT NULL,
    departure_datetime DATETIME NOT NULL,
    arrival_datetime DATETIME NOT NULL,
    class_type ENUM('Business', 'Economy') NOT NULL DEFAULT 'Economy',
    total_price DECIMAL(12,2) NOT NULL,
    status ENUM('Booked', 'Cancelled', 'Scratched') NOT NULL DEFAULT 'Booked',
    customer_id INT NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    balance_due DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    ticket_first_name VARCHAR(50) NOT NULL,
    ticket_last_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (flight_no) REFERENCES flights(flight_no),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 13: PAYMENTS
-- Payment records against bookings
-- ============================================================
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_no INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(30) DEFAULT 'Credit Card',
    currency_code VARCHAR(5) NOT NULL,
    FOREIGN KEY (booking_no) REFERENCES bookings(booking_no)
) ENGINE=InnoDB;


-- ============================================================
-- SAMPLE DATA INSERTS
-- ============================================================

-- Countries
INSERT INTO countries (country_name, currency_name, currency_code) VALUES
('Canada', 'Canadian Dollar', 'CAD'),
('USA', 'US Dollar', 'USD'),
('UK', 'British Pound', 'GBP'),
('France', 'French Franc', 'FRF'),
('Germany', 'German Mark', 'DEM'),
('Italy', 'Italian Lira', 'ITL');

-- Airlines
INSERT INTO airlines (airline_code, airline_name, country_id) VALUES
('AC', 'AirCan', 1),
('US', 'USAir', 2),
('BA', 'BritAir', 3),
('AF', 'AirFrance', 4),
('LH', 'LuftAir', 5),
('IT', 'ItalAir', 6);

-- Cities (2 per country)
INSERT INTO cities (city_name, country_id) VALUES
('Toronto', 1), ('Montreal', 1),
('New York', 2), ('Chicago', 2),
('London', 3), ('Edinburgh', 3),
('Paris', 4), ('Nice', 4),
('Bonn', 5), ('Berlin', 5),
('Rome', 6), ('Naples', 6);

-- Airports (1 per city)
INSERT INTO airports (airport_code, airport_name, city_id, airport_tax) VALUES
('YYZ', 'Toronto Pearson Intl', 1, 25.00),
('YUL', 'Montreal Trudeau Intl', 2, 22.50),
('JFK', 'John F. Kennedy Intl', 3, 30.00),
('ORD', 'Chicago O\'Hare Intl', 4, 28.00),
('LHR', 'London Heathrow', 5, 35.00),
('EDI', 'Edinburgh Airport', 6, 20.00),
('CDG', 'Paris Charles de Gaulle', 7, 32.00),
('NCE', 'Nice Cote d\'Azur', 8, 18.00),
('BNJ', 'Bonn Airport', 9, 15.00),
('TXL', 'Berlin Tegel', 10, 17.00),
('FCO', 'Rome Fiumicino', 11, 22.00),
('NAP', 'Naples Intl', 12, 16.00);

-- Flights
INSERT INTO flights (flight_no, airline_id, origin, destination, business_class, smoking_allowed, flight_price) VALUES
('AC101', 1, 'YYZ', 'JFK', TRUE, FALSE, 350.00),
('AC102', 1, 'JFK', 'YYZ', TRUE, FALSE, 350.00),
('AC201', 1, 'YYZ', 'YUL', TRUE, FALSE, 180.00),
('AC202', 1, 'YUL', 'YYZ', TRUE, FALSE, 180.00),
('AC301', 1, 'YYZ', 'LHR', TRUE, FALSE, 850.00),
('US101', 2, 'JFK', 'ORD', TRUE, FALSE, 220.00),
('US201', 2, 'JFK', 'LHR', TRUE, FALSE, 780.00),
('US301', 2, 'ORD', 'CDG', TRUE, FALSE, 920.00),
('BA101', 3, 'LHR', 'EDI', TRUE, FALSE, 150.00),
('BA201', 3, 'LHR', 'CDG', TRUE, FALSE, 320.00),
('BA301', 3, 'LHR', 'FCO', TRUE, FALSE, 480.00),
('AF101', 4, 'CDG', 'NCE', TRUE, TRUE, 200.00),
('AF201', 4, 'CDG', 'TXL', TRUE, FALSE, 380.00),
('AF301', 4, 'CDG', 'FCO', TRUE, TRUE, 420.00),
('LH101', 5, 'TXL', 'BNJ', TRUE, FALSE, 160.00),
('LH201', 5, 'TXL', 'FCO', TRUE, FALSE, 350.00),
('LH301', 5, 'BNJ', 'LHR', TRUE, FALSE, 400.00),
('IT101', 6, 'FCO', 'NAP', TRUE, TRUE, 120.00),
('IT201', 6, 'FCO', 'CDG', TRUE, FALSE, 410.00),
('IT301', 6, 'NAP', 'NCE', TRUE, TRUE, 280.00);

-- Flight Availability
INSERT INTO flight_availability (flight_no, departure_datetime, arrival_datetime, total_business_seats, booked_business_seats, total_economy_seats, booked_economy_seats) VALUES
('AC101', '2026-05-01 08:00:00', '2026-05-01 10:30:00', 20, 12, 150, 98),
('AC101', '2026-05-02 08:00:00', '2026-05-02 10:30:00', 20, 8, 150, 110),
('AC101', '2026-05-03 08:00:00', '2026-05-03 10:30:00', 20, 15, 150, 140),
('AC102', '2026-05-01 14:00:00', '2026-05-01 16:30:00', 20, 10, 150, 85),
('AC102', '2026-05-02 14:00:00', '2026-05-02 16:30:00', 20, 5, 150, 72),
('AC201', '2026-05-01 07:00:00', '2026-05-01 08:15:00', 15, 10, 120, 90),
('AC202', '2026-05-01 18:00:00', '2026-05-01 19:15:00', 15, 7, 120, 65),
('AC301', '2026-05-01 22:00:00', '2026-05-02 10:00:00', 30, 25, 250, 210),
('US101', '2026-05-01 09:00:00', '2026-05-01 12:00:00', 20, 14, 160, 120),
('US201', '2026-05-01 20:00:00', '2026-05-02 08:00:00', 30, 22, 250, 195),
('US301', '2026-05-02 10:00:00', '2026-05-02 18:30:00', 25, 18, 200, 170),
('BA101', '2026-05-01 06:30:00', '2026-05-01 07:45:00', 10, 6, 100, 75),
('BA201', '2026-05-01 11:00:00', '2026-05-01 12:30:00', 20, 15, 180, 140),
('BA301', '2026-05-01 14:00:00', '2026-05-01 17:30:00', 25, 20, 220, 180),
('AF101', '2026-05-01 09:00:00', '2026-05-01 10:30:00', 15, 10, 130, 100),
('AF201', '2026-05-01 13:00:00', '2026-05-01 15:00:00', 20, 12, 160, 130),
('AF301', '2026-05-02 08:00:00', '2026-05-02 10:30:00', 20, 16, 180, 150),
('LH101', '2026-05-01 07:00:00', '2026-05-01 08:00:00', 10, 5, 80, 55),
('LH201', '2026-05-01 12:00:00', '2026-05-01 14:30:00', 20, 14, 160, 120),
('LH301', '2026-05-02 09:00:00', '2026-05-02 11:30:00', 15, 10, 140, 110),
('IT101', '2026-05-01 10:00:00', '2026-05-01 11:00:00', 10, 8, 100, 80),
('IT201', '2026-05-01 15:00:00', '2026-05-01 17:30:00', 20, 15, 170, 140),
('IT301', '2026-05-02 11:00:00', '2026-05-02 12:30:00', 12, 9, 110, 85);

-- Customers (15 customers from various countries)
INSERT INTO customers (first_name, last_name, street, city, province_state, postal_code, country) VALUES
('James', 'Smith', '123 Maple St', 'Toronto', 'Ontario', 'M5V 2T6', 'Canada'),
('Marie', 'Dubois', '456 Oak Ave', 'Montreal', 'Quebec', 'H3B 1A7', 'Canada'),
('John', 'Williams', '789 Broadway', 'New York', 'New York', '10001', 'USA'),
('Sarah', 'Johnson', '321 Michigan Ave', 'Chicago', 'Illinois', '60601', 'USA'),
('William', 'Brown', '15 Baker Street', 'London', 'England', 'W1U 8EW', 'UK'),
('Emily', 'Taylor', '42 Royal Mile', 'Edinburgh', 'Scotland', 'EH1 1RE', 'UK'),
('Pierre', 'Martin', '8 Rue de Rivoli', 'Paris', 'Ile-de-France', '75001', 'France'),
('Sophie', 'Laurent', '25 Promenade', 'Nice', 'PACA', '06000', 'France'),
('Hans', 'Mueller', '10 Berliner Str', 'Berlin', 'Berlin', '10115', 'Germany'),
('Klaus', 'Schmidt', '5 Bonner Platz', 'Bonn', 'NRW', '53111', 'Germany'),
('Marco', 'Rossi', '12 Via Roma', 'Rome', 'Lazio', '00100', 'Italy'),
('Lucia', 'Bianchi', '7 Via Toledo', 'Naples', 'Campania', '80100', 'Italy'),
('Raj', 'Patel', '55 MG Road', 'Mumbai', 'Maharashtra', '400001', 'India'),
('Chen', 'Wei', '88 Nanjing Rd', 'Shanghai', 'Shanghai', '200001', 'China'),
('Anna', 'Kowalski', '30 Elm Drive', 'Toronto', 'Ontario', 'M4B 1B3', 'Canada');

-- Customer Phones
INSERT INTO customer_phones (customer_id, country_code, area_code, local_number) VALUES
(1, '1', '416', '5551234'),
(1, '1', '416', '5555678'),
(2, '1', '514', '5552345'),
(3, '1', '212', '5553456'),
(4, '1', '312', '5554567'),
(5, '44', '20', '55512345'),
(6, '44', '131', '5556789'),
(7, '33', '1', '55567890'),
(8, '33', '4', '55578901'),
(9, '49', '30', '55589012'),
(10, '49', '228', '5551111'),
(11, '39', '6', '55590123'),
(12, '39', '81', '5552222'),
(13, '91', '22', '55501234'),
(15, '1', '416', '5559999');

-- Customer Faxes
INSERT INTO customer_faxes (customer_id, country_code, area_code, local_number) VALUES
(1, '1', '416', '5551111'),
(3, '1', '212', '5553333'),
(5, '44', '20', '55555555'),
(7, '33', '1', '55577777'),
(9, '49', '30', '55599999'),
(11, '39', '6', '55511111');

-- Customer Emails
INSERT INTO customer_emails (customer_id, email) VALUES
(1, 'james.smith@email.ca'),
(2, 'marie.dubois@email.ca'),
(3, 'john.williams@email.com'),
(4, 'sarah.johnson@email.com'),
(5, 'william.brown@email.co.uk'),
(6, 'emily.taylor@email.co.uk'),
(7, 'pierre.martin@email.fr'),
(8, 'sophie.laurent@email.fr'),
(9, 'hans.mueller@email.de'),
(10, 'klaus.schmidt@email.de'),
(11, 'marco.rossi@email.it'),
(12, 'lucia.bianchi@email.it'),
(13, 'raj.patel@email.in'),
(14, 'chen.wei@email.cn'),
(15, 'anna.kowalski@email.ca');

-- Currency Exchange Rates
INSERT INTO currency_exchange (from_currency, to_currency, exchange_rate, rate_date) VALUES
('CAD', 'USD', 0.7500, '2026-05-01'),
('CAD', 'GBP', 0.5800, '2026-05-01'),
('CAD', 'FRF', 4.2500, '2026-05-01'),
('CAD', 'DEM', 1.2700, '2026-05-01'),
('CAD', 'ITL', 1256.00, '2026-05-01'),
('USD', 'CAD', 1.3300, '2026-05-01'),
('USD', 'GBP', 0.7700, '2026-05-01'),
('USD', 'FRF', 5.6600, '2026-05-01'),
('USD', 'DEM', 1.6900, '2026-05-01'),
('USD', 'ITL', 1674.00, '2026-05-01'),
('GBP', 'CAD', 1.7200, '2026-05-01'),
('GBP', 'USD', 1.3000, '2026-05-01'),
('GBP', 'FRF', 7.3400, '2026-05-01'),
('GBP', 'DEM', 2.1900, '2026-05-01'),
('GBP', 'ITL', 2172.00, '2026-05-01'),
('FRF', 'CAD', 0.2350, '2026-05-01'),
('FRF', 'USD', 0.1770, '2026-05-01'),
('FRF', 'GBP', 0.1360, '2026-05-01'),
('FRF', 'DEM', 0.2990, '2026-05-01'),
('FRF', 'ITL', 296.00, '2026-05-01'),
('DEM', 'CAD', 0.7870, '2026-05-01'),
('DEM', 'USD', 0.5920, '2026-05-01'),
('DEM', 'GBP', 0.4560, '2026-05-01'),
('DEM', 'FRF', 3.3500, '2026-05-01'),
('DEM', 'ITL', 989.00, '2026-05-01'),
('ITL', 'CAD', 0.000796, '2026-05-01'),
('ITL', 'USD', 0.000597, '2026-05-01'),
('ITL', 'GBP', 0.000460, '2026-05-01'),
('ITL', 'FRF', 0.003380, '2026-05-01'),
('ITL', 'DEM', 0.001011, '2026-05-01');

-- Bookings
INSERT INTO bookings (booking_city, booking_date, flight_no, departure_datetime, arrival_datetime, class_type, total_price, status, customer_id, amount_paid, balance_due, ticket_first_name, ticket_last_name) VALUES
('Toronto', '2026-04-15', 'AC101', '2026-05-01 08:00:00', '2026-05-01 10:30:00', 'Business', 580.00, 'Booked', 1, 400.00, 180.00, 'James', 'Smith'),
('Toronto', '2026-04-15', 'AC301', '2026-05-01 22:00:00', '2026-05-02 10:00:00', 'Economy', 910.00, 'Booked', 1, 910.00, 0.00, 'James', 'Smith'),
('Montreal', '2026-04-16', 'AC201', '2026-05-01 07:00:00', '2026-05-01 08:15:00', 'Economy', 227.50, 'Booked', 2, 227.50, 0.00, 'Marie', 'Dubois'),
('New York', '2026-04-17', 'US101', '2026-05-01 09:00:00', '2026-05-01 12:00:00', 'Business', 388.00, 'Booked', 3, 200.00, 188.00, 'John', 'Williams'),
('New York', '2026-04-17', 'AC102', '2026-05-01 14:00:00', '2026-05-01 16:30:00', 'Economy', 405.00, 'Cancelled', 3, 100.00, 305.00, 'John', 'Williams'),
('Chicago', '2026-04-18', 'US301', '2026-05-02 10:00:00', '2026-05-02 18:30:00', 'Economy', 980.00, 'Booked', 4, 500.00, 480.00, 'Sarah', 'Johnson'),
('London', '2026-04-18', 'BA101', '2026-05-01 06:30:00', '2026-05-01 07:45:00', 'Economy', 205.00, 'Booked', 5, 205.00, 0.00, 'William', 'Brown'),
('London', '2026-04-19', 'BA201', '2026-05-01 11:00:00', '2026-05-01 12:30:00', 'Business', 547.00, 'Cancelled', 5, 200.00, 347.00, 'William', 'Brown'),
('Edinburgh', '2026-04-19', 'BA101', '2026-05-01 06:30:00', '2026-05-01 07:45:00', 'Economy', 205.00, 'Booked', 6, 205.00, 0.00, 'Emily', 'Taylor'),
('Paris', '2026-04-20', 'AF101', '2026-05-01 09:00:00', '2026-05-01 10:30:00', 'Economy', 250.00, 'Booked', 7, 250.00, 0.00, 'Pierre', 'Martin'),
('Paris', '2026-04-20', 'AF201', '2026-05-01 13:00:00', '2026-05-01 15:00:00', 'Business', 619.00, 'Booked', 7, 300.00, 319.00, 'Pierre', 'Martin'),
('Nice', '2026-04-21', 'AF301', '2026-05-02 08:00:00', '2026-05-02 10:30:00', 'Economy', 470.00, 'Scratched', 8, 100.00, 370.00, 'Sophie', 'Laurent'),
('Berlin', '2026-04-21', 'LH101', '2026-05-01 07:00:00', '2026-05-01 08:00:00', 'Economy', 192.00, 'Booked', 9, 192.00, 0.00, 'Hans', 'Mueller'),
('Bonn', '2026-04-22', 'LH301', '2026-05-02 09:00:00', '2026-05-02 11:30:00', 'Business', 647.50, 'Booked', 10, 400.00, 247.50, 'Klaus', 'Schmidt'),
('Rome', '2026-04-22', 'IT101', '2026-05-01 10:00:00', '2026-05-01 11:00:00', 'Economy', 158.00, 'Booked', 11, 158.00, 0.00, 'Marco', 'Rossi'),
('Rome', '2026-04-23', 'IT201', '2026-05-01 15:00:00', '2026-05-01 17:30:00', 'Economy', 464.00, 'Cancelled', 11, 200.00, 264.00, 'Marco', 'Rossi'),
('Naples', '2026-04-23', 'IT301', '2026-05-02 11:00:00', '2026-05-02 12:30:00', 'Business', 454.00, 'Booked', 12, 454.00, 0.00, 'Lucia', 'Bianchi'),
('Toronto', '2026-04-24', 'AC101', '2026-05-02 08:00:00', '2026-05-02 10:30:00', 'Economy', 405.00, 'Booked', 13, 200.00, 205.00, 'Raj', 'Patel'),
('Toronto', '2026-04-25', 'AC101', '2026-05-03 08:00:00', '2026-05-03 10:30:00', 'Business', 580.00, 'Booked', 15, 580.00, 0.00, 'Anna', 'Kowalski');

-- Payments
INSERT INTO payments (booking_no, payment_date, amount, payment_method, currency_code) VALUES
(1, '2026-04-15', 400.00, 'Credit Card', 'CAD'),
(2, '2026-04-15', 910.00, 'Credit Card', 'CAD'),
(3, '2026-04-16', 227.50, 'Debit Card', 'CAD'),
(4, '2026-04-17', 200.00, 'Credit Card', 'USD'),
(5, '2026-04-17', 100.00, 'Credit Card', 'USD'),
(6, '2026-04-18', 500.00, 'Credit Card', 'USD'),
(7, '2026-04-18', 205.00, 'Debit Card', 'GBP'),
(8, '2026-04-19', 200.00, 'Credit Card', 'GBP'),
(9, '2026-04-19', 205.00, 'Debit Card', 'GBP'),
(10, '2026-04-20', 250.00, 'Credit Card', 'FRF'),
(11, '2026-04-20', 300.00, 'Credit Card', 'FRF'),
(12, '2026-04-21', 100.00, 'Cash', 'FRF'),
(13, '2026-04-21', 192.00, 'Debit Card', 'DEM'),
(14, '2026-04-22', 400.00, 'Credit Card', 'DEM'),
(15, '2026-04-22', 158.00, 'Cash', 'ITL'),
(16, '2026-04-23', 200.00, 'Credit Card', 'ITL'),
(17, '2026-04-23', 454.00, 'Debit Card', 'ITL'),
(18, '2026-04-24', 200.00, 'Credit Card', 'CAD'),
(19, '2026-04-25', 580.00, 'Credit Card', 'CAD');


-- ============================================================
-- 10 REQUIRED SQL QUERIES (for reference)
-- ============================================================

-- QUERY 1: All customers who live in Canada, sorted by customer_id
-- SELECT * FROM customers WHERE country = 'Canada' ORDER BY customer_id;

-- QUERY 2: List all different customers who made bookings
-- SELECT DISTINCT c.* FROM customers c INNER JOIN bookings b ON c.customer_id = b.customer_id;

-- QUERY 3: Currency exchange rate > 1, sorted by from_currency and to_currency
-- SELECT * FROM currency_exchange WHERE exchange_rate > 1 ORDER BY from_currency, to_currency;

-- QUERY 4: Flight availabilities between Toronto (YYZ) and New York (JFK)
-- SELECT fa.flight_no, f.origin, f.destination, fa.departure_datetime, fa.arrival_datetime
-- FROM flight_availability fa
-- JOIN flights f ON fa.flight_no = f.flight_no
-- WHERE f.origin = 'YYZ' AND f.destination = 'JFK'
-- ORDER BY fa.flight_no;

-- QUERY 5: Customers who did not place any booking
-- SELECT c.customer_id FROM customers c
-- LEFT JOIN bookings b ON c.customer_id = b.customer_id
-- WHERE b.booking_no IS NULL ORDER BY c.customer_id;

-- QUERY 6: Customer first_name, last_name, phone_no, email
-- SELECT c.customer_id, c.first_name, c.last_name,
--   CONCAT(cp.area_code, '-', SUBSTRING(cp.local_number,1,3), '-', SUBSTRING(cp.local_number,4)) AS phone_no,
--   ce.email
-- FROM customers c
-- LEFT JOIN customer_phones cp ON c.customer_id = cp.customer_id
-- LEFT JOIN customer_emails ce ON c.customer_id = ce.customer_id
-- ORDER BY c.customer_id;

-- QUERY 7: All cancelled bookings
-- SELECT b.booking_no, b.customer_id, b.flight_no, f.origin, f.destination, b.class_type, b.status, b.booking_city
-- FROM bookings b JOIN flights f ON b.flight_no = f.flight_no
-- WHERE b.status = 'Cancelled' ORDER BY b.booking_no, b.customer_id, b.flight_no;

-- QUERY 8: Total_price, total_payment, total_balance per city (exclude cancelled)
-- SELECT b.booking_city AS city_name, SUM(b.total_price) AS total_price, SUM(b.amount_paid) AS total_payment, SUM(b.balance_due) AS total_balance
-- FROM bookings b WHERE b.status != 'Cancelled'
-- GROUP BY b.booking_city ORDER BY b.booking_city;

-- QUERY 9: Recalculate total_price with airport tax changes
-- SELECT b.booking_no, f.origin, f.destination, f.flight_price,
--   b.total_price AS previous_total_price,
--   CASE WHEN b.class_type = 'Business'
--     THEN (f.flight_price * 1.5) + (ao.airport_tax + 0.01) + (ad.airport_tax - 0.005)
--     ELSE f.flight_price + (ao.airport_tax + 0.01) + (ad.airport_tax - 0.005)
--   END AS new_total_price
-- FROM bookings b
-- JOIN flights f ON b.flight_no = f.flight_no
-- JOIN airports ao ON f.origin = ao.airport_code
-- JOIN airports ad ON f.destination = ad.airport_code;

-- QUERY 10: Number of bookings, emails, phones, faxes per customer
-- SELECT c.customer_id, c.first_name, c.last_name,
--   COUNT(DISTINCT b.booking_no) AS number_of_bookings,
--   COUNT(DISTINCT ce.email_id) AS number_of_emails,
--   COUNT(DISTINCT cp.phone_id) AS number_of_phones,
--   COUNT(DISTINCT cf.fax_id) AS number_of_faxes
-- FROM customers c
-- LEFT JOIN bookings b ON c.customer_id = b.customer_id
-- LEFT JOIN customer_emails ce ON c.customer_id = ce.customer_id
-- LEFT JOIN customer_phones cp ON c.customer_id = cp.customer_id
-- LEFT JOIN customer_faxes cf ON c.customer_id = cf.customer_id
-- GROUP BY c.customer_id, c.first_name, c.last_name;
