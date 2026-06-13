# 🚛 **Cargo Guardian: Smart Food Cargo Monitoring System**
**Multi-Sensor Forensic Evidence & Integrity Scoring for Perishable Food Logistics**

---

## 📌 **Project Overview**
**Cargo Guardian** is a **low-cost, IoT-based embedded system** designed to monitor **perishable food cargo** (e.g., dairy, seafood, fresh produce, packaged goods) during transportation. It ensures **cold chain integrity** by continuously tracking:

- **Temperature** (DHT22)
- **Humidity** (DHT22)
- **Light** (LDR – detects container lid openings)
- **Motion** (PIR – intrusion detection)
- **Tilt** (SW-520D – mishandling/accident detection)

The system generates a **real-time Integrity Score (0–100)** and logs **timestamped forensic evidence** for post-incident analysis, liability resolution, and regulatory compliance.

---

## 🎯 **Problem Statement**

### **Challenges in Food Cargo Logistics**
1. **Incomplete Monitoring**: Existing systems focus only on **temperature/humidity** or **GPS tracking**, ignoring:
   - Unauthorized access (light/motion).
   - Physical mishandling (tilt/vibration).
2. **No Forensic Evidence**: Real-time alerts lack **historical data** for dispute resolution.
3. **No Integrity Quantification**: No standardized metric to assess **overall cargo condition**.
4. **High Costs**: Commercial solutions are **expensive** (proprietary hardware/cloud), unaffordable for **SMEs in developing countries** (e.g., Sri Lanka).
5. **Complexity**: Reliance on **machine learning/cloud AI** increases costs and deployment barriers.

---

## 💡 **Proposed Solution**
**Cargo Guardian** addresses these gaps with:
- **Multi-sensor monitoring** (5 parameters) for **holistic cargo safety**.
- **Rule-based Integrity Scoring** (0–100) with **transparent penalty system**.
- **Forensic Event Logging** (timestamped breaches stored in **Supabase**).
- **Low-cost hardware** (< **LKR 7,000** / ~$20 USD).
- **Flutter mobile app** for real-time monitoring (replaces fixed displays).
- **Open-source stack** (no proprietary dependencies).

---

---
## 🧠 **System Architecture**

### **1. Hardware Layer (ESP32)**
   **Component**       | **Parameter**           |
 |----------------------|------------------------|
 | ESP32                | Microcontroller + WiFi |
 | DHT22                | Temperature & Humidity |
 | LDR Sensor           | Light (Lid Status)     |
 | PIR Motion Sensor    | Intrusion Detection    |
 | SW-520D Tilt Sensor  | Container Orientation  |

---

### **2. Cloud Layer (Supabase)**
- **Tables**:
  - `cargo_readings`: Sensor data (temp, humidity, light, motion, tilt, score, status, events, timestamp).
  - `cargo_alerts`: Breach notifications (alert type, message, severity, read status).
- **Real-time streaming**: Pushes updates to Flutter app instantly.

---
### **3. Mobile App (Flutter)**
**Features**:
- **Dashboard**: Live score (color-coded), sensor values, breach alerts.
- **History**: Line graphs for temperature/integrity trends (last 20 readings).
- **Forensic Log**: Chronological breach records (event code, score, timestamp).
- **Driver Alerts**: Real-time pop-ups for new breaches (unread highlights).

---

---
## 📊 Integrity Scoring System

### Scoring Rules

The system starts at **100 points** and deducts penalties based on sensor violations.

| Sensor       | Safe Zone        | Warning Condition         | Critical Condition        | Warning Penalty | Critical Penalty |
|--------------|------------------|---------------------------|----------------------------|------------------|------------------|
| Temperature  | 2–8°C            | 8–15°C or 0–2°C           | >15°C or <0°C              | -15              | -40              |
| Humidity     | 45–65% RH        | 65–80% or 30–45% RH       | >80% or <30% RH            | -10              | -20              |
| Light (LDR)  | Dark (sealed)    | Brief light detected      | Light > 30 sec             | -20              | -20              |
| Motion (PIR) | No motion        | Motion detected           | Motion + lid open          | -15              | -15              |
| Tilt         | 0–15°            | 15–45°                    | >45° or inverted           | -15              | -15              |

---
### **Status Classification**
 | **Score Range** | **Status** | **Meaning**               | **LED Color** |
 |-----------------|------------|---------------------------|---------------|
 | 80–100          | 🟢 GREEN   | Safe (all parameters OK)  | Green        |
 | 50–79           | 🟡 YELLOW  | Warning (minor breaches)  | Yellow       |
 | 0–49            | 🔴 RED     | Critical (immediate action)| Red         |

---

---
## ⚙️ **Technologies Used**
- **Hardware**: ESP32, DHT22, LDR, PIR, SW-520D Tilt
- **Firmware**: Arduino C++ (ESP32 libraries: `DHT.h`, `WiFi.h`, `HTTPClient.h`)
- **Cloud**: Supabase (PostgreSQL + Realtime API)
- **Mobile App**: Flutter (Dart), `fl_chart` for graphs
- **Protocols**: HTTP POST (WiFi), Real-time Streaming

---

---
## 📦 **Hardware Components**
- ESP32 Microcontroller
- DHT22 Sensor (Temperature & Humidity)
- LDR Sensor (Light/Lid Detection)
- PIR Motion Sensor (Intrusion Detection)
- SW-520D Tilt Sensor (Container Stability)
- Power Bank (10,000 mAh)

---

---
## 🔐 **Key Features**
✔ **Real-time Monitoring**: 3-second sensor updates.
✔ **Multi-Sensor Fusion**: Combines 5 parameters for **holistic cargo safety**.
✔ **Forensic Logging**: Timestamped breaches (e.g., `TEMP_CRITICAL`, `LID_OPEN`).
✔ **Integrity Scoring**: Transparent, rule-based (no ML).
✔ **Cloud Storage**: Supabase (free tier, real-time sync).
✔ **Mobile Alerts**: Flutter app with **pop-up notifications**.

---

---
## 📱 **Mobile App Features**
- **Dashboard**: Live score (color-coded), sensor values, last event.
- **History**: Line graphs for temperature/integrity trends (last 20 readings).
- **Forensic Log**: List of breaches (event code, score, timestamp, severity).
- **Driver Alerts**: Real-time pop-ups for new breaches (unread = highlighted).

---

---
## 🚀 **Future Improvements**
1. **GPS Integration**: Add **NEO-6M GPS module** for location-based forensic trails.
2. **Alternative Connectivity**:
   - **GSM (SIM800L)** for remote areas.
   - **LoRa (SX1276)** for long-range, low-power networks.
3. **Time-Weighted Scoring**: Penalize **longer breaches** more heavily.
4. **Push Notifications**: Firebase Cloud Messaging (FCM) for background alerts.
5. **Blockchain Logging**: Immutable forensic data storage (e.g., Ethereum hashes).
6. **Custom Enclosure**: Waterproof PCB for **commercial-grade durability**.
7. **Web Dashboard**: Multi-container monitoring for **fleet managers**.

---

---
## 👨‍💻 **Team Members**
 | **Name**               | **ID**                     |
 |------------------------|----------------------------|
 | AWF. Jahjan            | SEU/IS/20/ICT/031          |
 | AZ. Ahunah             | SEU/IS/20/ICT/042          |
 | NF. Nusrath            | SEU/IS/20/ICT/071          |
 | MNFH. Nifa             | SEU/IS/20/ICT/073          |

---

---
## 📚 **Conclusion**
Cargo Guardian proves that **low-cost, multi-sensor food cargo monitoring** with **forensic evidence** and **integrity scoring** is achievable using:
- **Open-source hardware/software** (ESP32, Supabase, Flutter).
- **Rule-based algorithms** (no ML/cloud dependencies).
- **Real-time cloud sync** for transparency.

**Impact**: Reduces **food spoilage losses** (40–50% in cold chains) and enables **liability resolution** for SMEs in developing regions like Sri Lanka.

---
---
## 📄 **License**
This project is for academic and educational purposes.
