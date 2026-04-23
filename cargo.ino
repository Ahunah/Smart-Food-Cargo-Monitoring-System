// ============================================================
//  CARGO GUARDIAN — ESP32 with WiFi + Supabase
//  Multi-Sensor Forensic Evidence System with Integrity Scoring
// ============================================================

#include <DHT.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Arduino_JSON.h>

// -------- PIN DEFINITIONS --------
#define DHTPIN 18
#define DHTTYPE DHT22
#define LDR_PIN 19
#define PIR_PIN 5
#define TILT_PIN 4

// -------- WiFi CREDENTIALS --------
const char *WIFI_SSID = "Dialog 4G 563";
const char *WIFI_PASSWORD = "Aliyar3305";

// -------- SUPABASE CREDENTIALS --------
const char *SUPABASE_URL = "https://shotcrnrdeqzqhtehdvo.supabase.co";
const char *SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNob3Rjcm5yZGVxenFodGVoZHZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NDY5OTEsImV4cCI6MjA5MDUyMjk5MX0.HZkbGINSICYEu9jvr8C0CN_8mBdkuoZGTrybBF6VYsg";

// -------- PHARMA THRESHOLDS --------
#define TEMP_MIN_SAFE 2.0
#define TEMP_WARN_HIGH 8.0
#define TEMP_CRIT_HIGH 15.0
#define HUMID_MIN_SAFE 45.0
#define HUMID_MAX_SAFE 65.0
#define HUMID_MAX_WARN 80.0

// -------- PENALTIES --------
#define PENALTY_TEMP_CRITICAL 40
#define PENALTY_TEMP_WARNING 15
#define PENALTY_HUMID_CRITICAL 20
#define PENALTY_HUMID_WARNING 10
#define PENALTY_LID_OPEN 20
#define PENALTY_TILT 15
#define PENALTY_MOTION 15

DHT dht(DHTPIN, DHTTYPE);
unsigned long readingCount = 0;

// ============================================================
//  CONNECT TO WiFi
// ============================================================
void connectWiFi()
{
    Serial.print("[WiFi] Connecting to ");
    Serial.println(WIFI_SSID);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }
    Serial.println();
    Serial.print("[WiFi] Connected! IP: ");
    Serial.println(WiFi.localIP());
}

// ============================================================
//  SEND DATA TO SUPABASE
// ============================================================
void sendToSupabase(float temp, float humid,
                    bool lidOpen, bool motion, bool tilted,
                    int score, String status, String events)
{
    if (WiFi.status() != WL_CONNECTED)
    {
        Serial.println("[WiFi] Disconnected — reconnecting...");
        connectWiFi();
    }

    // ← FIXED: added /rest/v1/cargo_readings to the URL
    String url = String(SUPABASE_URL) + "/rest/v1/cargo_readings";

    HTTPClient http;
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("apikey", SUPABASE_KEY);
    http.addHeader("Authorization", String("Bearer ") + SUPABASE_KEY);
    http.addHeader("Prefer", "return=minimal");

    // ← FIXED: booleans written directly, not wrapped in String()
    String payload = "{";
    payload += "\"temperature\":" + String(temp, 1) + ",";
    payload += "\"humidity\":" + String(humid, 1) + ",";
    payload += "\"light\":" + String(lidOpen ? "true" : "false") + ",";
    payload += "\"motion\":" + String(motion ? "true" : "false") + ",";
    payload += "\"tilt\":" + String(tilted ? "true" : "false") + ",";
    payload += "\"score\":" + String(score) + ",";
    payload += "\"status\":\"" + status + "\",";
    payload += "\"events\":\"" + events + "\"";
    payload += "}";

    Serial.println("[Supabase] Sending: " + payload);

    int httpCode = http.POST(payload);

    if (httpCode == 201)
    {
        Serial.println("[Supabase] Data sent successfully!");
    }
    else
    {
        Serial.print("[Supabase] Error: HTTP ");
        Serial.print(httpCode);
        Serial.println(" — check URL and API key");
        Serial.println(http.getString()); // ← shows exact error from Supabase
    }
    http.end();
}
// Add this after your existing sendToSupabase function

void sendAlert(String alertType, String message, String severity)
{
    if (WiFi.status() != WL_CONNECTED)
        connectWiFi();

    String alertUrl = String(SUPABASE_URL) + "/rest/v1/cargo_alerts";

    HTTPClient http;
    http.begin(alertUrl);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("apikey", SUPABASE_KEY);
    http.addHeader("Authorization", String("Bearer ") + SUPABASE_KEY);
    http.addHeader("Prefer", "return=minimal");

    String payload = "{";
    payload += "\"alert_type\":\"" + alertType + "\",";
    payload += "\"message\":\"" + message + "\",";
    payload += "\"severity\":\"" + severity + "\"";
    payload += "}";

    int httpCode = http.POST(payload);
    if (httpCode == 201)
    {
        Serial.println("[Alert] Sent: " + alertType);
    }
    else
    {
        Serial.println("[Alert] Failed: " + String(httpCode));
    }
    http.end();
}
// ============================================================
//  INTEGRITY STATUS
// ============================================================
String integrityStatus(int score)
{
    if (score >= 80)
        return "GREEN";
    if (score >= 50)
        return "YELLOW";
    return "RED";
}

// ============================================================
//  SETUP
// ============================================================
void setup()
{
    Serial.begin(115200);
    dht.begin();
    pinMode(LDR_PIN, INPUT);
    pinMode(PIR_PIN, INPUT);
    pinMode(TILT_PIN, INPUT_PULLUP);

    Serial.println("============================================");
    Serial.println("  CARGO GUARDIAN — SYSTEM INITIALISED      ");
    Serial.println("  Pharmaceutical Cold Chain Monitor         ");
    Serial.println("============================================");

    connectWiFi();
    delay(2000);
}

// ============================================================
//  MAIN LOOP
// ============================================================
void loop()
{
    readingCount++;
    int penalty = 0;
    String events = "";

    Serial.println();
    Serial.print("===== READING #");
    Serial.print(readingCount);
    Serial.print("  |  Uptime: ");
    Serial.print(millis() / 1000);
    Serial.println("s =====");

    // ── DHT22 ──
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    if (isnan(humidity) || isnan(temperature))
    {
        Serial.println("[DHT22]  ERROR!");
        penalty += 20;
        events += "SENSOR_ERROR;";
        sendAlert("SENSOR_ERROR",
                  "DHT22 sensor failed to read",
                  "HIGH");
        temperature = 0;
        humidity = 0;
    }
    else
    {
        if (temperature > TEMP_CRIT_HIGH || temperature < 0.0)
        {
            penalty += PENALTY_TEMP_CRITICAL;
            events += "TEMP_CRITICAL(" + String(temperature, 1) + "C);";
            sendAlert("TEMP_CRITICAL",
                      "URGENT: Temperature is " + String(temperature, 1) +
                          "C — Medicine may be destroyed!",
                      "CRITICAL");
        }
        else if (temperature > TEMP_WARN_HIGH || temperature < TEMP_MIN_SAFE)
        {
            penalty += PENALTY_TEMP_WARNING;
            events += "TEMP_WARNING(" + String(temperature, 1) + "C);";
            sendAlert("TEMP_WARNING",
                      "Warning: Temperature " + String(temperature, 1) +
                          "C is outside safe range (2-8C)",
                      "MEDIUM");
        }

        if (humidity > HUMID_MAX_WARN || humidity < 30.0)
        {
            penalty += PENALTY_HUMID_CRITICAL;
            events += "HUMID_CRITICAL(" + String(humidity, 1) + "%);";
            sendAlert("HUMID_CRITICAL",
                      "URGENT: Humidity " + String(humidity, 1) +
                          "% — Moisture damage risk!",
                      "HIGH");
        }
        else if (humidity > HUMID_MAX_SAFE || humidity < HUMID_MIN_SAFE)
        {
            penalty += PENALTY_HUMID_WARNING;
            events += "HUMID_WARNING(" + String(humidity, 1) + "%);";
            sendAlert("HUMID_WARNING",
                      "Warning: Humidity " + String(humidity, 1) +
                          "% is outside safe range",
                      "MEDIUM");
        }
    }

    // ── LDR ──
    bool lidOpen = (digitalRead(LDR_PIN) == LOW);
    if (lidOpen)
    {
        penalty += PENALTY_LID_OPEN;
        events += "LID_OPEN;";
        sendAlert("LID_OPEN",
                  "Alert: Container lid has been opened!",
                  "HIGH");
    }

    // ── PIR ──
    bool motion = (digitalRead(PIR_PIN) == HIGH);
    if (motion)
    {
        penalty += PENALTY_MOTION;
        events += "MOTION_DETECTED;";
        sendAlert("MOTION_DETECTED",
                  "Alert: Motion detected inside container — possible tampering!",
                  "HIGH");
    }

    // ── TILT ──
    bool tilted = (digitalRead(TILT_PIN) == LOW);
    if (tilted)
    {
        penalty += PENALTY_TILT;
        events += "TILT_ALERT;";
        sendAlert("TILT_ALERT",
                  "Alert: Container is tilted — vials and IV bags at risk!",
                  "MEDIUM");
    }

    // ── INTEGRITY SCORE ──
    int score = max(0, 100 - penalty);
    String status = integrityStatus(score);
    if (events == "")
        events = "ALL_OK";

    Serial.println();
    Serial.println("-------- INTEGRITY SCORE --------");
    Serial.print("  Score  : ");
    Serial.print(score);
    Serial.println(" / 100");
    Serial.print("  Status : ");
    Serial.println(status);
    Serial.print("  Events : ");
    Serial.println(events);
    Serial.println("---------------------------------");

    // ── SEND TO SUPABASE ──
    sendToSupabase(temperature, humidity,
                   lidOpen, motion, tilted,
                   score, status, events);

    delay(5000); // send every 5 seconds
}