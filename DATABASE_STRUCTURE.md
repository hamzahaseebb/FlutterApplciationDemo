# Database Structure Documentation

## Overview

The Laundry Order Management App uses **SQLite** as the local database. The database is created automatically when the app runs for the first time. It consists of a single table `orders` that stores all order information.

## Database File Location

| Platform | Path |
|----------|------|
| **Android** | `/data/data/com.example.laundry_app/databases/laundry.db` |
| **iOS** | App's Documents directory |
| **Emulator** | Accessible via Device File Explorer in Android Studio |

## Table Structure

### Orders Table

The `orders` table stores all laundry service orders with their details and status.

```sql
CREATE TABLE orders(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id TEXT NOT NULL UNIQUE,
  customer_name TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  service_type TEXT NOT NULL,
  number_of_items INTEGER NOT NULL,
  price_per_item REAL NOT NULL,
  total_price REAL NOT NULL,
  status TEXT NOT NULL
);

Column Details
Column	          Type	          Constraints	                  Description
id	              INTEGER	        PRIMARY KEY                   AUTOINCREMENT	Auto-incrementing unique identifier for each order
order_id	        TEXT	          NOT NULL,                     UNIQUE	Human-readable order ID (Format: ORD-{timestamp})
customer_name	    TEXT	          NOT NULL	                    Customer's full name
phone_number	    TEXT	          NOT NULL	                    Customer's contact number
service_type	    TEXT	          NOT NULL	                    Type of laundry service selected
number_of_items	  INTEGER	        NOT NULL	                    Quantity of laundry items
price_per_item	  REAL	          NOT NULL	                    Price per item in KWD
total_price	      REAL	          NOT NULL	                    Calculated total (items × price)
status	          TEXT	          NOT NULL	                    Current order status


Data Types Explanation
SQLite Type 	Dart Type	               Description
INTEGER	      int	Whole numbers        (IDs, counts)
TEXT	        String	Text values      (names, IDs, status)
REAL	        double-Decimal numbers   (prices, totals)

Sample Data
INSERT INTO orders (
  id, order_id, customer_name, phone_number, 
  service_type, number_of_items, price_per_item, 
  total_price, status
) VALUES (
  1, 'ORD-1712345678901', 'Ahmed Al-Rashid', '51234567',
  'Wash & Fold', 3, 2.500,
  7.500, 'Delivered'
);
