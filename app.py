"""
============================================================
AIRLINE RESERVATION SYSTEM - Flask Backend
B.Tech CSE-AIML | BCSC 0034: Database Technology
============================================================
"""

from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import mysql.connector
import mysql.connector
from mysql.connector import Error
from datetime import datetime, date
import json
import os
from urllib.parse import urlparse

# ── Flask App Configuration ──────────────────────────────────
app = Flask(__name__)
app.secret_key = 'airline_reservation_secret_key_2026'

# ── Database Configuration ───────────────────────────────────
# Railway provides DATABASE_URL in the format: mysql://user:pass@host:port/database
DATABASE_URL = os.environ.get('DATABASE_URL', 'mysql://root:root@localhost/airline_reservation')

def get_db():
    """Create and return a database connection, parsing URL if needed."""
    try:
        url = urlparse(DATABASE_URL)
        # Handle cases where url.path starts with '/'
        db_name = url.path[1:] if url.path.startswith('/') else url.path
        
        conn = mysql.connector.connect(
            user=url.username,
            password=url.password,
            host=url.hostname,
            port=url.port or 3306,
            database=db_name
        )
        return conn
    except Exception as e:
        print(f"Database Connection Error: {e}")
        return None


def query_db(sql, params=None, fetchone=False):
    """Execute a query and return results as list of dicts."""
    conn = get_db()
    if not conn:
        return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(sql, params or ())
        if sql.strip().upper().startswith('SELECT') or sql.strip().upper().startswith('SHOW'):
            results = cursor.fetchone() if fetchone else cursor.fetchall()
            return results if results else ([] if not fetchone else None)
        else:
            conn.commit()
            return cursor.lastrowid
    except Error as e:
        print(f"Query Error: {e}")
        return [] if not fetchone else None
    finally:
        cursor.close()
        conn.close()


# Custom JSON encoder for dates/decimals
class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        from decimal import Decimal
        if isinstance(obj, Decimal):
            return float(obj)
        return super().default(obj)


app.json_encoder = CustomEncoder


# ── Database Initialization (For Railway/Cloud) ──────────────
@app.route('/setup-db')
def setup_db():
    """Utility route to initialize the database schema and mock data on Railway."""
    try:
        conn = get_db()
        if not conn:
            return "Failed to connect to DB for setup.", 500
        
        # We need to execute queries one by one or use a specialized method
        # for our case study, we'll read database.sql and execute
        with open('database.sql', 'r', encoding='utf-8') as f:
            sql_script = f.read()
        
        cursor = conn.cursor()
        # mysql-connector-python execute() can only do one statement
        # but it has cmd_query_iter or we can just split by ';'
        for statement in sql_script.split(';'):
            if statement.strip():
                cursor.execute(statement)
        
        conn.commit()
        cursor.close()
        conn.close()
        return "<h1>Database Initialized Successfully!</h1><p>The schema and mock data have been loaded into your cloud database.</p><a href='/'>Go to Home</a>"
    except Exception as e:
        return f"<h1>Error Initializing Database</h1><p>{str(e)}</p>", 500


# ════════════════════════════════════════════════════════════
# ROUTES
# ════════════════════════════════════════════════════════════

# ── Login Page ───────────────────────────────────────────────
@app.route('/')
@app.route('/login')
def login():
    return render_template('login.html')


@app.route('/login', methods=['POST'])
def login_post():
    username = request.form.get('username', '')
    password = request.form.get('password', '')
    if username == 'admin' and password == 'admin':
        flash('Welcome to Airline Reservation System!', 'success')
        return redirect(url_for('dashboard'))
    else:
        flash('Invalid credentials. Use admin/admin.', 'danger')
        return redirect(url_for('login'))


# ── Dashboard ────────────────────────────────────────────────
@app.route('/dashboard')
def dashboard():
    stats = {}
    stats['total_customers'] = query_db("SELECT COUNT(*) AS cnt FROM customers", fetchone=True)['cnt']
    stats['total_flights'] = query_db("SELECT COUNT(*) AS cnt FROM flights", fetchone=True)['cnt']
    stats['total_bookings'] = query_db("SELECT COUNT(*) AS cnt FROM bookings", fetchone=True)['cnt']
    stats['cancelled'] = query_db("SELECT COUNT(*) AS cnt FROM bookings WHERE status='Cancelled'", fetchone=True)['cnt']
    stats['total_revenue'] = query_db("SELECT COALESCE(SUM(total_price),0) AS rev FROM bookings WHERE status != 'Cancelled'", fetchone=True)['rev']
    stats['total_paid'] = query_db("SELECT COALESCE(SUM(amount_paid),0) AS paid FROM bookings WHERE status != 'Cancelled'", fetchone=True)['paid']

    # City-wise revenue for chart
    city_revenue = query_db("""
        SELECT booking_city, SUM(total_price) AS revenue
        FROM bookings WHERE status != 'Cancelled'
        GROUP BY booking_city ORDER BY booking_city
    """)

    # Flight occupancy for chart
    occupancy = query_db("""
        SELECT f.flight_no,
            SUM(fa.booked_business_seats + fa.booked_economy_seats) AS booked,
            SUM(fa.total_business_seats + fa.total_economy_seats) AS total
        FROM flight_availability fa
        JOIN flights f ON fa.flight_no = f.flight_no
        GROUP BY f.flight_no ORDER BY f.flight_no
        LIMIT 10
    """)

    # Recent bookings
    recent = query_db("""
        SELECT b.booking_no, b.booking_city, b.booking_date, b.flight_no,
               b.class_type, b.total_price, b.status,
               CONCAT(c.first_name, ' ', c.last_name) AS customer_name
        FROM bookings b JOIN customers c ON b.customer_id = c.customer_id
        ORDER BY b.booking_date DESC LIMIT 8
    """)

    return render_template('dashboard.html', stats=stats, city_revenue=city_revenue,
                           occupancy=occupancy, recent=recent)


# ── Customers Management ────────────────────────────────────
@app.route('/customers')
def customers():
    search = request.args.get('search', '')
    if search:
        sql = """SELECT * FROM customers
                 WHERE first_name LIKE %s OR last_name LIKE %s
                 OR city LIKE %s OR country LIKE %s
                 ORDER BY customer_id"""
        like = f'%{search}%'
        data = query_db(sql, (like, like, like, like))
    else:
        data = query_db("SELECT * FROM customers ORDER BY customer_id")
    return render_template('customers.html', customers=data, search=search)


@app.route('/customers/add', methods=['POST'])
def add_customer():
    fn = request.form['first_name']
    ln = request.form['last_name']
    st = request.form.get('street', '')
    ct = request.form.get('city', '')
    ps = request.form.get('province_state', '')
    pc = request.form.get('postal_code', '')
    co = request.form.get('country', '')
    query_db("""INSERT INTO customers (first_name, last_name, street, city, province_state, postal_code, country)
                VALUES (%s,%s,%s,%s,%s,%s,%s)""", (fn, ln, st, ct, ps, pc, co))

    # Get newly inserted customer_id
    cust = query_db("SELECT LAST_INSERT_ID() AS id", fetchone=True)
    cid = cust['id']

    # Add phone if provided
    phone = request.form.get('phone', '')
    if phone:
        parts = phone.replace('-', ' ').replace('(', '').replace(')', '').split()
        if len(parts) >= 3:
            query_db("INSERT INTO customer_phones (customer_id, country_code, area_code, local_number) VALUES (%s,%s,%s,%s)",
                     (cid, '1', parts[0], ''.join(parts[1:])))

    # Add email if provided
    email = request.form.get('email', '')
    if email:
        query_db("INSERT INTO customer_emails (customer_id, email) VALUES (%s,%s)", (cid, email))

    flash('Customer added successfully!', 'success')
    return redirect(url_for('customers'))


@app.route('/customers/delete/<int:cid>')
def delete_customer(cid):
    query_db("DELETE FROM bookings WHERE customer_id = %s", (cid,))
    query_db("DELETE FROM customers WHERE customer_id = %s", (cid,))
    flash('Customer deleted.', 'info')
    return redirect(url_for('customers'))


# ── Flights Management ───────────────────────────────────────
@app.route('/flights')
def flights():
    search = request.args.get('search', '')
    if search:
        like = f'%{search}%'
        data = query_db("""
            SELECT f.*, a1.airline_name, ap1.airport_name AS origin_name, ap2.airport_name AS dest_name
            FROM flights f
            JOIN airlines a1 ON f.airline_id = a1.airline_id
            JOIN airports ap1 ON f.origin = ap1.airport_code
            JOIN airports ap2 ON f.destination = ap2.airport_code
            WHERE f.flight_no LIKE %s OR a1.airline_name LIKE %s
               OR f.origin LIKE %s OR f.destination LIKE %s
            ORDER BY f.flight_no
        """, (like, like, like, like))
    else:
        data = query_db("""
            SELECT f.*, a1.airline_name, ap1.airport_name AS origin_name, ap2.airport_name AS dest_name
            FROM flights f
            JOIN airlines a1 ON f.airline_id = a1.airline_id
            JOIN airports ap1 ON f.origin = ap1.airport_code
            JOIN airports ap2 ON f.destination = ap2.airport_code
            ORDER BY f.flight_no
        """)
    airlines = query_db("SELECT * FROM airlines ORDER BY airline_name")
    airports = query_db("SELECT * FROM airports ORDER BY airport_code")
    return render_template('flights.html', flights=data, airlines=airlines, airports=airports, search=search)


@app.route('/flights/add', methods=['POST'])
def add_flight():
    query_db("""INSERT INTO flights (flight_no, airline_id, origin, destination, business_class, smoking_allowed, flight_price)
                VALUES (%s,%s,%s,%s,%s,%s,%s)""",
             (request.form['flight_no'], request.form['airline_id'],
              request.form['origin'], request.form['destination'],
              1 if request.form.get('business_class') else 0,
              1 if request.form.get('smoking_allowed') else 0,
              request.form['flight_price']))
    flash('Flight added successfully!', 'success')
    return redirect(url_for('flights'))


@app.route('/flights/delete/<flight_no>')
def delete_flight(flight_no):
    query_db("DELETE FROM flight_availability WHERE flight_no = %s", (flight_no,))
    query_db("DELETE FROM bookings WHERE flight_no = %s", (flight_no,))
    query_db("DELETE FROM flights WHERE flight_no = %s", (flight_no,))
    flash('Flight deleted.', 'info')
    return redirect(url_for('flights'))


# ── Flight Availability ──────────────────────────────────────
@app.route('/availability')
def availability():
    search = request.args.get('search', '')
    if search:
        like = f'%{search}%'
        data = query_db("""
            SELECT fa.*, f.origin, f.destination, a.airline_name
            FROM flight_availability fa
            JOIN flights f ON fa.flight_no = f.flight_no
            JOIN airlines a ON f.airline_id = a.airline_id
            WHERE fa.flight_no LIKE %s OR f.origin LIKE %s OR f.destination LIKE %s
            ORDER BY fa.departure_datetime
        """, (like, like, like))
    else:
        data = query_db("""
            SELECT fa.*, f.origin, f.destination, a.airline_name
            FROM flight_availability fa
            JOIN flights f ON fa.flight_no = f.flight_no
            JOIN airlines a ON f.airline_id = a.airline_id
            ORDER BY fa.departure_datetime
        """)
    return render_template('availability.html', availability=data, search=search)


# ── Bookings Management ─────────────────────────────────────
@app.route('/bookings')
def bookings():
    search = request.args.get('search', '')
    status_filter = request.args.get('status', '')
    sql = """
        SELECT b.*, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
               f.origin, f.destination
        FROM bookings b
        JOIN customers c ON b.customer_id = c.customer_id
        JOIN flights f ON b.flight_no = f.flight_no
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND (b.flight_no LIKE %s OR b.booking_city LIKE %s OR c.first_name LIKE %s OR c.last_name LIKE %s)"
        like = f'%{search}%'
        params.extend([like, like, like, like])
    if status_filter:
        sql += " AND b.status = %s"
        params.append(status_filter)
    sql += " ORDER BY b.booking_no DESC"
    data = query_db(sql, params)

    customers_list = query_db("SELECT customer_id, first_name, last_name FROM customers ORDER BY customer_id")
    flights_list = query_db("SELECT flight_no FROM flights ORDER BY flight_no")
    return render_template('bookings.html', bookings=data, customers=customers_list,
                           flights=flights_list, search=search, status_filter=status_filter)


@app.route('/bookings/add', methods=['POST'])
def add_booking():
    flight_no = request.form['flight_no']
    flight = query_db("SELECT * FROM flights WHERE flight_no = %s", (flight_no,), fetchone=True)
    if not flight:
        flash('Flight not found.', 'danger')
        return redirect(url_for('bookings'))

    origin_airport = query_db("SELECT * FROM airports WHERE airport_code = %s", (flight['origin'],), fetchone=True)
    dest_airport = query_db("SELECT * FROM airports WHERE airport_code = %s", (flight['destination'],), fetchone=True)

    class_type = request.form['class_type']
    price = float(flight['flight_price'])
    if class_type == 'Business':
        price = price * 1.5

    total = price + float(origin_airport['airport_tax']) + float(dest_airport['airport_tax'])

    cust = query_db("SELECT * FROM customers WHERE customer_id = %s", (request.form['customer_id'],), fetchone=True)

    query_db("""INSERT INTO bookings (booking_city, booking_date, flight_no, departure_datetime, arrival_datetime,
                class_type, total_price, status, customer_id, amount_paid, balance_due, ticket_first_name, ticket_last_name)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
             (request.form['booking_city'], datetime.now().strftime('%Y-%m-%d'),
              flight_no, request.form['departure_datetime'], request.form['arrival_datetime'],
              class_type, total, 'Booked', request.form['customer_id'],
              0, total, cust['first_name'], cust['last_name']))
    flash('Booking created successfully!', 'success')
    return redirect(url_for('bookings'))


@app.route('/bookings/cancel/<int:bid>')
def cancel_booking(bid):
    query_db("UPDATE bookings SET status = 'Cancelled' WHERE booking_no = %s", (bid,))
    flash('Booking cancelled.', 'warning')
    return redirect(url_for('bookings'))


@app.route('/bookings/delete/<int:bid>')
def delete_booking(bid):
    query_db("DELETE FROM payments WHERE booking_no = %s", (bid,))
    query_db("DELETE FROM bookings WHERE booking_no = %s", (bid,))
    flash('Booking deleted.', 'info')
    return redirect(url_for('bookings'))


# ── Currency Exchange ────────────────────────────────────────
@app.route('/currency')
def currency():
    data = query_db("SELECT * FROM currency_exchange ORDER BY from_currency, to_currency")
    return render_template('currency.html', rates=data)


@app.route('/currency/add', methods=['POST'])
def add_currency():
    query_db("""INSERT INTO currency_exchange (from_currency, to_currency, exchange_rate, rate_date)
                VALUES (%s,%s,%s,%s)""",
             (request.form['from_currency'], request.form['to_currency'],
              request.form['exchange_rate'], request.form['rate_date']))
    flash('Exchange rate added!', 'success')
    return redirect(url_for('currency'))


# ── Reports Page ─────────────────────────────────────────────
@app.route('/reports')
def reports():
    # City-wise summary
    city_summary = query_db("""
        SELECT booking_city, COUNT(*) AS total_bookings,
               SUM(total_price) AS revenue, SUM(amount_paid) AS collected
        FROM bookings WHERE status != 'Cancelled'
        GROUP BY booking_city ORDER BY booking_city
    """)
    # Airline-wise
    airline_summary = query_db("""
        SELECT a.airline_name, COUNT(b.booking_no) AS bookings,
               SUM(b.total_price) AS revenue
        FROM bookings b
        JOIN flights f ON b.flight_no = f.flight_no
        JOIN airlines a ON f.airline_id = a.airline_id
        WHERE b.status != 'Cancelled'
        GROUP BY a.airline_name ORDER BY a.airline_name
    """)
    # Status summary
    status_summary = query_db("""
        SELECT status, COUNT(*) AS cnt, SUM(total_price) AS total
        FROM bookings GROUP BY status
    """)
    return render_template('reports.html', city_summary=city_summary,
                           airline_summary=airline_summary, status_summary=status_summary)


# ════════════════════════════════════════════════════════════
# SQL QUERY RESULTS – 10 REQUIRED OUTCOMES
# ════════════════════════════════════════════════════════════
@app.route('/queries')
def queries():
    return render_template('queries.html')


@app.route('/api/query/<int:qnum>')
def run_query(qnum):
    """API endpoint that returns JSON results for each of the 10 required queries."""
    results = []
    title = ""
    sql = ""

    if qnum == 1:
        title = "Q1: Customers who live in Canada (sorted by customer_id)"
        sql = "SELECT * FROM customers WHERE country = 'Canada' ORDER BY customer_id"
        results = query_db(sql)

    elif qnum == 2:
        title = "Q2: Distinct customers who made bookings"
        sql = """SELECT DISTINCT c.customer_id, c.first_name, c.last_name, c.city, c.country
                 FROM customers c INNER JOIN bookings b ON c.customer_id = b.customer_id
                 ORDER BY c.customer_id"""
        results = query_db(sql)

    elif qnum == 3:
        title = "Q3: Currency exchange rates > 1 (sorted by from_currency, to_currency)"
        sql = """SELECT * FROM currency_exchange
                 WHERE exchange_rate > 1
                 ORDER BY from_currency, to_currency"""
        results = query_db(sql)

    elif qnum == 4:
        title = "Q4: Flight availabilities between Toronto (YYZ) and New York (JFK)"
        sql = """SELECT fa.flight_no, f.origin, f.destination,
                        fa.departure_datetime AS departure_time,
                        fa.arrival_datetime AS arrival_time
                 FROM flight_availability fa
                 JOIN flights f ON fa.flight_no = f.flight_no
                 WHERE f.origin = 'YYZ' AND f.destination = 'JFK'
                 ORDER BY fa.flight_no"""
        results = query_db(sql)

    elif qnum == 5:
        title = "Q5: Customers who did not place any booking (customer_id only)"
        sql = """SELECT c.customer_id FROM customers c
                 LEFT JOIN bookings b ON c.customer_id = b.customer_id
                 WHERE b.booking_no IS NULL
                 ORDER BY c.customer_id"""
        results = query_db(sql)

    elif qnum == 6:
        title = "Q6: Customer first_name, last_name, phone_no (formatted) and email"
        sql = """SELECT c.customer_id, c.first_name, c.last_name,
                    CONCAT(cp.area_code, '-', SUBSTRING(cp.local_number,1,3), '-', SUBSTRING(cp.local_number,4)) AS phone_no,
                    ce.email
                 FROM customers c
                 LEFT JOIN customer_phones cp ON c.customer_id = cp.customer_id
                 LEFT JOIN customer_emails ce ON c.customer_id = ce.customer_id
                 ORDER BY c.customer_id"""
        results = query_db(sql)

    elif qnum == 7:
        title = "Q7: All cancelled bookings"
        sql = """SELECT b.booking_no, b.customer_id, b.flight_no,
                        f.origin, f.destination, b.class_type AS class,
                        b.status, b.booking_city
                 FROM bookings b
                 JOIN flights f ON b.flight_no = f.flight_no
                 WHERE b.status = 'Cancelled'
                 ORDER BY b.booking_no, b.customer_id, b.flight_no"""
        results = query_db(sql)

    elif qnum == 8:
        title = "Q8: Total price, payment & balance per city (excl. cancelled)"
        sql = """SELECT b.booking_city AS city_name,
                        SUM(b.total_price) AS total_price,
                        SUM(b.amount_paid) AS total_payment,
                        SUM(b.balance_due) AS total_balance
                 FROM bookings b
                 WHERE b.status != 'Cancelled'
                 GROUP BY b.booking_city
                 ORDER BY b.booking_city"""
        results = query_db(sql)

    elif qnum == 9:
        title = "Q9: Recalculated total_price (origin tax +0.01, dest tax -0.005)"
        sql = """SELECT b.booking_no, f.origin, f.destination, f.flight_price,
                    b.total_price AS previous_total_price,
                    CASE WHEN b.class_type = 'Business'
                        THEN (f.flight_price * 1.5) + (ao.airport_tax + 0.01) + (ad.airport_tax - 0.005)
                        ELSE f.flight_price + (ao.airport_tax + 0.01) + (ad.airport_tax - 0.005)
                    END AS new_total_price
                 FROM bookings b
                 JOIN flights f ON b.flight_no = f.flight_no
                 JOIN airports ao ON f.origin = ao.airport_code
                 JOIN airports ad ON f.destination = ad.airport_code
                 ORDER BY b.booking_no"""
        results = query_db(sql)

    elif qnum == 10:
        title = "Q10: Number of bookings, emails, phones, faxes per customer"
        sql = """SELECT c.customer_id, c.first_name, c.last_name,
                    COUNT(DISTINCT b.booking_no) AS number_of_bookings,
                    COUNT(DISTINCT ce.email_id) AS number_of_emails,
                    COUNT(DISTINCT cp.phone_id) AS number_of_phones,
                    COUNT(DISTINCT cf.fax_id) AS number_of_faxes
                 FROM customers c
                 LEFT JOIN bookings b ON c.customer_id = b.customer_id
                 LEFT JOIN customer_emails ce ON c.customer_id = ce.customer_id
                 LEFT JOIN customer_phones cp ON c.customer_id = cp.customer_id
                 LEFT JOIN customer_faxes cf ON c.customer_id = cf.customer_id
                 GROUP BY c.customer_id, c.first_name, c.last_name
                 ORDER BY c.customer_id"""
        results = query_db(sql)

    else:
        return jsonify({'error': 'Invalid query number'}), 400

    # Serialize for JSON
    serialized = json.loads(json.dumps(results, cls=CustomEncoder))
    return jsonify({'title': title, 'sql': sql, 'data': serialized})


# ════════════════════════════════════════════════════════════
# API endpoints for charts/dashboard
# ════════════════════════════════════════════════════════════
@app.route('/api/stats')
def api_stats():
    stats = {
        'customers': query_db("SELECT COUNT(*) AS c FROM customers", fetchone=True)['c'],
        'flights': query_db("SELECT COUNT(*) AS c FROM flights", fetchone=True)['c'],
        'bookings': query_db("SELECT COUNT(*) AS c FROM bookings", fetchone=True)['c'],
        'cancelled': query_db("SELECT COUNT(*) AS c FROM bookings WHERE status='Cancelled'", fetchone=True)['c'],
    }
    return jsonify(stats)


# ════════════════════════════════════════════════════════════
if __name__ == '__main__':
    print("=" * 60)
    print("  AIRLINE RESERVATION SYSTEM")
    print("  Open http://127.0.0.1:5000 in your browser")
    print("  Login: admin / admin")
    print("=" * 60)
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
