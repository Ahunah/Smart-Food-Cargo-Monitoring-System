# 🚛 Smart Food Cargo Monitoring System  
### (Cargo Guardian – Multi-Sensor Forensic Evidence System)

---

## 📌 Project Overview
Smart Food Cargo Monitoring System (Cargo Guardian) is an IoT-based embedded system designed to monitor **pharmaceutical cold chain cargo** such as vaccines and medicines.

It continuously tracks:
- Temperature
- Humidity
- Light (door open detection)
- Motion (intrusion detection)
- Tilt (container safety)

The system generates a **real-time integrity score (0–100)** and provides **forensic evidence logging** for every incident.

---

## 🎯 Problem Statement
Pharmaceutical cargo requires strict cold chain conditions (2°C–8°C). Existing systems:
- Only monitor basic parameters
- Lack forensic tracking
- Do not provide integrity scoring
- Are expensive for small healthcare providers

---

## 💡 Proposed Solution
Cargo Guardian solves these issues using:
- ESP32 microcontroller
- Multi-sensor monitoring system
- Integrity scoring algorithm
- Supabase cloud database
- Flutter mobile application

---

## 🧠 System Architecture

### 1. Hardware Layer (ESP32)
Sensors used:
- DHT22 → Temperature & Humidity
- LDR → Light detection (door open)
- PIR → Motion detection
- Tilt Sensor → Container stability

---

### 2. Cloud Layer (Supabase)
Stores:
- `cargo_readings` (sensor data)
- `cargo_alerts` (forensic events)

Provides real-time data streaming.

---

### 3. Mobile App (Flutter)
Features:
- Dashboard (live monitoring)
- History graphs
- Forensic logs
- Driver alerts

---

## 📊 Integrity Scoring System

Score starts at **100** and decreases based on sensor violations:

| Status | Range | Meaning |
|--------|------|--------|
| 🟢 Green | 80–100 | Safe condition |
| 🟡 Yellow | 50–79 | Warning |
| 🔴 Red | 0–49 | Critical |

---

## ⚙️ Technologies Used
- ESP32 (Arduino C++)
- Flutter (Dart)
- Supabase (PostgreSQL)
- Firebase concepts (future extension)
- IoT Sensors

---

## 📦 Hardware Components
- ESP32 Microcontroller
- DHT22 Sensor
- LDR Sensor
- PIR Motion Sensor
- Tilt Sensor (SW-520D)
- Power Bank (10,000 mAh)

---

## 🔐 Key Features
- Real-time cargo monitoring
- Multi-sensor integration
- Integrity scoring algorithm
- Forensic event logging
- Cloud-based storage
- Mobile app monitoring

---

## 📱 Mobile App Features
- Live dashboard
- Temperature & humidity tracking
- Alert notifications
- Historical graphs
- Forensic evidence logs

---

## 🚀 Future Improvements
- GPS tracking integration
- Firebase push notifications
- LoRa / GSM communication
- Blockchain-based logging
- AI anomaly detection
- Web dashboard for fleet monitoring

---

## 👨‍💻 Team Members
- SEU/IS/20/ICT/031  
- SEU/IS/20/ICT/042  
- SEU/IS/20/ICT/071  
- SEU/IS/20/ICT/073  

---

## 📚 Conclusion
This project demonstrates a low-cost, scalable IoT solution for pharmaceutical cold chain monitoring with forensic-level tracking capability.

---

## 📄 License
This project is for academic and educational purposes.
