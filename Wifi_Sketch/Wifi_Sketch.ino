#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "Suvanga’s iPhone (2)";
const char* password = "12345678";

// Replace with your computer's local IP where Node.js runs
String serverName = "http://192.168.56.1:4020/data";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  Serial.println("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    // Example JSON data
    String payload = "{\"temperature\": 25.5, \"humidity\": 60}";

    int httpResponseCode = http.POST(payload);

    if (httpResponseCode > 0) {
      Serial.print("Response code: ");
      Serial.println(httpResponseCode);
      String response = http.getString();
      Serial.println("Server reply: " + response);
    } else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  }

  delay(5000); // Send every 5 seconds
}
