# ✈️ SkyReserve — Airline Reservation System

> **B.Tech CSE-AIML | BCSC 0034: Database Technology | Case Study Project**

A full-stack Airline Reservation System built with Flask, MySQL, and Bootstrap 5. This project implements a central air-reservation database used by 12 booking offices across 6 countries, with complete CRUD operations, 10 required SQL query outcomes, interactive dashboard, and reports.

---

## 📸 Features

- 🔐 **Login Page** — Animated login with admin credentials
- 📊 **Dashboard** — Revenue cards, city-wise charts, occupancy doughnut, recent bookings
- 👥 **Customers** — Full CRUD with search, phones, emails, faxes
- ✈️ **Flights** — Manage flights with airline & airport data
- 📅 **Flight Availability** — View seat occupancy with progress bars
- 🎫 **Bookings** — Create, cancel, delete bookings with status filters
- 💱 **Currency Exchange** — View & add exchange rates between 6 currencies
- 📈 **Reports** — City-wise revenue, airline summaries, status distributions
- 🗄️ **SQL Queries** — All 10 required DBMS outcomes with live SQL display

---

## 🛠️ Tech Stack

| Layer      | Technology                         |
| ---------- | ---------------------------------- |
| Frontend   | HTML5, CSS3, JavaScript, Bootstrap 5 |
| Backend    | Python 3, Flask                    |
| Database   | MySQL                              |
| Charts     | Chart.js                           |
| Icons      | Bootstrap Icons                    |
| Typography | Google Fonts (Inter)               |

---

## 📁 Project Structure

```
AirlineReservation/
├── app.py                  # Flask backend (all routes + API)
├── database.sql            # MySQL schema + sample data
├── README.md               # This file
├── requirements.txt        # Python dependencies
├── static/
│   ├── style.css           # Complete CSS design system
│   └── script.js           # JavaScript (animations, interactions)
└── templates/
    ├── base.html           # Base layout template
    ├── login.html          # Login page
    ├── sidebar.html        # Sidebar navigation component
    ├── dashboard.html      # Dashboard with KPI cards + charts
    ├── customers.html      # Customers management
    ├── flights.html        # Flights management
    ├── availability.html   # Flight availability
    ├── bookings.html       # Bookings management
    ├── currency.html       # Currency exchange rates
    ├── reports.html        # Reports & analytics
    └── queries.html        # SQL query results (10 outcomes)
```

---

## 🚀 Setup Instructions

### Prerequisites
- Python 3.8+ installed
- MySQL 8.0+ installed and running
- pip (Python package manager)

### Step 1: Clone / Download the Project
Place the `AirlineReservation` folder on your machine.

### Step 2: Install Python Dependencies
```bash
cd AirlineReservation
pip install -r requirements.txt
```

### Step 3: Setup the Database
1. Open MySQL Workbench or MySQL CLI
2. Run the SQL file to create database, tables, and sample data:
```bash
mysql -u root -p < database.sql
```
Or copy-paste the contents of `database.sql` into MySQL Workbench and execute.

### Step 4: Configure Database Connection
Open `app.py` and update the `DB_CONFIG` dictionary with your MySQL credentials:
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'YOUR_PASSWORD_HERE',  # Change this!
    'database': 'airline_reservation',
    'autocommit': True
}
```

### Step 5: Run the Application
```bash
python app.py
```

### Step 6: Open in Browser
Navigate to: **http://127.0.0.1:5000**

Login credentials: **admin / admin**

---

## 📋 10 Required DBMS Outcomes

| # | Query Description | Route |
|---|-------------------|-------|
| 1 | Customers living in Canada (sorted by customer_id) | `/api/query/1` |
| 2 | Distinct customers who made bookings | `/api/query/2` |
| 3 | Currency exchange rate > 1 (sorted by from/to currency) | `/api/query/3` |
| 4 | Flight availability: Toronto (YYZ) → New York (JFK) | `/api/query/4` |
| 5 | Customers with no bookings | `/api/query/5` |
| 6 | Customer name, phone (formatted), email | `/api/query/6` |
| 7 | All cancelled bookings | `/api/query/7` |
| 8 | Total price, payment & balance per city (excl. cancelled) | `/api/query/8` |
| 9 | Recalculated total_price with airport tax changes | `/api/query/9` |
| 10 | Bookings, emails, phones & faxes per customer | `/api/query/10` |

---

## 🗃️ Database Schema (13 Tables)

1. **countries** — 6 countries with currency info
2. **airlines** — 6 airlines linked to countries
3. **cities** — 12 cities (2 per country)
4. **airports** — 12 airports with tax rates
5. **flights** — Flight routes with pricing
6. **flight_availability** — Seat tracking per flight per date
7. **customers** — Customer master with mailing address
8. **customer_phones** — Multiple phones per customer
9. **customer_faxes** — Multiple fax numbers per customer
10. **customer_emails** — Unique email per record
11. **currency_exchange** — Daily exchange rates
12. **bookings** — Reservation records
13. **payments** — Payment transactions

---

## 🔑 Key ER Relationships

- **Country** 1:N → Airlines, Cities
- **City** 1:1 → Airport
- **Airline** 1:N → Flights
- **Airport** 1:N → Flights (origin/destination)
- **Flight** 1:N → Flight Availability
- **Customer** 1:N → Phones, Faxes, Emails, Bookings
- **Flight** 1:N → Bookings
- **Booking** 1:N → Payments

---

## 👨‍💻 Author

Student Project — B.Tech CSE-AIML, Year I, Semester II
Subject: Database Technology (BCSC 0034)
