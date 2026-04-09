# 🚚 Delivery App

## 📌 Overview

A Flutter application for managing laundry service orders with SQLite database storage. Built for mobile platforms

---

## Features

### Core Requirements ✅
- Display list of laundry orders with Order ID, Customer Name, Phone Number, Service Type, Status, and Total Price
- Add new orders with form validation
- Automatic total price calculation (Number of Items × Price per Item)
- Update order status workflow: **Received → Washing → Ready → Delivered**
- Search functionality by Customer Name or Order ID
- SQLite local database storage

### Bonus Features ✅
- Filter orders by status (All, Received, Washing, Ready, Delivered)
- Dashboard showing Total Orders, Total Revenue (KWD), and Pending Orders
- Form validation for all inputs (name, phone, items, price)

## ▶️ How to Run the Project

### 1. Prerequisites

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Emulator or physical device

---

### 2. Clone the Repository

```bash
https://github.com/hamzahaseebb/FlutterApplciationDemo.git
```

---

### 3. Navigate to Project Folder

```bash
cd FlutterApplciationDemo
```

---

### 4. Install Dependencies

```bash
flutter pub get
```

---

### 5. Run the Application

```bash
flutter run
```

---

## 📱 Notes

* Ensure an emulator is running or a device is connected
* You can check connected devices using:

```bash
flutter devices
```

---

## 🛠️ Troubleshooting

If you face issues, run:

```bash
flutter doctor
```

and fix any reported problems.

---

## 👨‍💻 Author

Hamza Haseeb
