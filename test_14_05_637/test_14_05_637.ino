
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ESP8266HTTPClient.h>

HTTPClient http;

// Update these with values suitable for your network.
const char* ssid = "ppang";
const char* password = "ppang5532";

// Config MQTT Server
#define mqtt_server "34.87.101.146"
#define mqtt_port 1883
#define mqtt_user "test"
#define mqtt_password "test"

#define relay_pin1 14
#define relay_pin2 12
#define relay_pin3 13
#define relay_pin4 3

#define solenoid 3

String arr[4];
String tamp1 = "";
String tamp2 = "";
String tamp3 = "";
String tamp4 = "";
String tamp5 = "";

boolean checkStatusCon = true;
int countCon = 0;

boolean checkHigh1 = true;
boolean checkHigh2 = true;
boolean checkHigh3 = true;
boolean checkHigh4 = true;

boolean checkLow1 = false;
boolean checkLow2 = false;
boolean checkLow3 = false;
boolean checkLow4 = false;


WiFiClient espClient;
PubSubClient client(espClient);

void WIFI_Connect()
{
  countCon++;
  digitalWrite(2, 1);
  WiFi.disconnect();
  Serial.println("Booting Sketch...");
  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(ssid, password);
  // Wait for connection
  for (int i = 0; i < 25; i++)
  {
    if ( WiFi.status() != WL_CONNECTED ) {
      delay ( 250 );
      digitalWrite(2, 0);
      Serial.print ( "." );
      delay ( 250 );
      digitalWrite(2, 1);
    }
  }
  digitalWrite(2, 0);
}

void setup() {

  Serial.begin(115200);
  delay(10);
  ESP.wdtDisable();

  pinMode(relay_pin1, OUTPUT);
  pinMode(relay_pin2, OUTPUT);
  pinMode(relay_pin3, OUTPUT);
  pinMode(relay_pin4, OUTPUT);
  pinMode(solenoid, OUTPUT);

  pinMode(16, INPUT);
  pinMode(5, INPUT);
  pinMode(4, INPUT);
  pinMode(2, INPUT);

  digitalWrite(relay_pin1, LOW);
  digitalWrite(relay_pin2, LOW);
  digitalWrite(relay_pin3, LOW);
  digitalWrite(relay_pin4, LOW);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WIFI_Connect();

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED && countCon < 4)
  {
    digitalWrite(2, 1);
    WIFI_Connect();
  } else if (WiFi.status() == WL_CONNECTED) {
    digitalWrite(2, 0);
    countCon = 0;
    if (!client.connected()) {
      Serial.print("Attempting MQTT connection...");
      if (client.connect("ESP8266Client"
                         , mqtt_user, mqtt_password
                        )) {
        Serial.println("connected");
        countCon = 0;
        client.subscribe("/ESP/LED1");
        client.subscribe("/ESP/LED2");
        client.subscribe("/ESP/LED3");
        client.subscribe("/ESP/LED4");
        client.subscribe("/ESP/SLN");
        checkStatusCon = true;
      } else {
        Serial.print("failed, rc=");
        Serial.print(client.state());
        Serial.println(" try again in 5 seconds");
        delay(5000);
        checkStatusCon = false;
        return;
      }
    }
  }

  checkSwicth1(16, relay_pin1);
  checkSwicth2(5, relay_pin2);
  checkSwicth3(4, relay_pin3);
  checkSwicth4(2, relay_pin4);
  client.loop();
}

void updateDataToServer(String topic, String msg) {

  String path = "/api/card/update?topic=" + topic + "&msg=" + msg;      //ชุด Directory ที่เก็บไฟล์ และตัวแปรที่ต้องการจะฝาก

  // Your Domain name with URL path or IP address with path
  http.begin("http://34.87.101.146:8080" + path);

  // Prepare your HTTP POST request data
  String httpRequestData = "topic=" + topic + "&msg=" + msg;

  Serial.print("httpRequestData: ");
  Serial.println(httpRequestData);

  // Send HTTP POST request
  int httpResponseCode = http.GET();

  if (httpResponseCode > 0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.println("] ");

  String msg = "";
  String str1 = topic;
  String str2 = topic;
  String str3 = topic;
  String str4 = topic;
  String str5 = topic;

  int i = 0;

  while (i < length) {
    msg += (char)payload[i++];
  }
  if (str1 == "/ESP/LED1" && msg == "led1on" || msg == "led1off") {
    tamp1 = msg;
    digitalWrite(relay_pin1, (tamp1 == "led1on" ? LOW : HIGH));
    Serial.println("relay_pin1: ");
    Serial.println(tamp1);
    //    updateDataToServer(str1, tamp1);
  }
  else if (str2 == "/ESP/LED2" && msg == "led2on" || msg == "led2off") {
    tamp2 = msg;
    digitalWrite(relay_pin2, (tamp2 == "led2on" ? LOW : HIGH));
    Serial.println("relay_pin2: ");
    Serial.println(tamp2);
    //    updateDataToServer(str2, tamp2);
  }
  else if (str3 == "/ESP/LED3" && msg == "led3on" || msg == "led3off") {
    tamp3 = msg;
    digitalWrite(relay_pin3, (tamp3 == "led3on" ? LOW : HIGH));
    Serial.println("relay_pin3: ");
    Serial.println(tamp3);
    //    updateDataToServer(str3, tamp3);
  }
  else if (str4 == "/ESP/LED4" && msg == "led4on" || msg == "led4off") {
    tamp4 = msg;
    digitalWrite(relay_pin4, (tamp4 == "led4on" ? LOW : HIGH));
    Serial.println("relay_pin4: ");
    Serial.println(tamp4);
    //    updateDataToServer(str4, tamp4);
  }
  else if (str5 == "/ESP/SLN" && msg == "slnon" || msg == "slnoff") {
    tamp5 = msg;
    digitalWrite(solenoid, (tamp5 == "slnon" ? LOW : HIGH));
    Serial.println("solenoid: ");
    Serial.println(tamp5);
    //    updateDataToServer(str5, tamp5);
  }

}

void checkSwicth1(int pinSw, int pinRelay) {
  if (digitalRead(pinSw) == HIGH && checkHigh1) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh1 = false;
    checkLow1 = true;
    if (checkStatusCon) {
      client.publish("/ESP/LED1", (digitalRead(pinRelay) == LOW ? "on" : "off"));
      updateDataToServer("/ESP/LED1", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }

  }
  else if (digitalRead(pinSw) == LOW && checkLow1) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh1 = true;
    checkLow1 = false;
    if (checkStatusCon) {
      client.publish("/ESP/LED1", (digitalRead(pinRelay) == LOW ? "on" : "off"));
      updateDataToServer("/ESP/LED1", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
}

void checkSwicth2(int pinSw, int pinRelay) {
  if (digitalRead(pinSw) == HIGH && checkHigh2) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh2 = false;
    checkLow2 = true;
    if (checkStatusCon) {
      checkStatusCon ? client.publish("/ESP/LED2", (digitalRead(pinRelay) == LOW ? "on" : "off")) : Serial.print("");
      updateDataToServer("/ESP/LED2", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
  else if (digitalRead(pinSw) == LOW && checkLow2) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh2 = true;
    checkLow2 = false;
    if (checkStatusCon) {
      checkStatusCon ? client.publish("/ESP/LED2", (digitalRead(pinRelay) == LOW ? "on" : "off")) : Serial.print("");
      updateDataToServer("/ESP/LED2", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
}

void checkSwicth3(int pinSw, int pinRelay) {
  if (digitalRead(pinSw) == HIGH && checkHigh3) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh3 = false;
    checkLow3 = true;
    if (checkStatusCon) {
      checkStatusCon ? client.publish("/ESP/LED3", (digitalRead(pinRelay) == LOW ? "on" : "off")) : Serial.print("");
      updateDataToServer("/ESP/LED3", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
  else if (digitalRead(pinSw) == LOW && checkLow3) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh3 = true;
    checkLow3 = false;
    if (checkStatusCon) {
      checkStatusCon ? client.publish("/ESP/LED3", (digitalRead(pinRelay) == LOW ? "on" : "off")) : Serial.print("");
      updateDataToServer("/ESP/LED3", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
}

void checkSwicth4(int pinSw, int pinRelay) {
  if (digitalRead(pinSw) == HIGH && checkHigh4) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh4 = false;
    checkLow4 = true;
    if (checkStatusCon) {
      checkStatusCon ? client.publish("/ESP/LED4", (digitalRead(pinRelay) == LOW ? "on" : "off")) : Serial.print("");
      updateDataToServer("/ESP/LED4", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
  else if (digitalRead(pinSw) == LOW && checkLow4) {
    if (digitalRead(pinRelay) == LOW) {
      digitalWrite(pinRelay, HIGH);
    } else {
      digitalWrite(pinRelay, LOW);
    }
    checkHigh4 = true;
    checkLow4 = false;
    if (checkStatusCon) {
      checkStatusCon ? client.publish("/ESP/LED4", (digitalRead(pinRelay) == LOW ? "on" : "off")) : Serial.print("");
      updateDataToServer("/ESP/LED4", (digitalRead(pinRelay) == LOW ? "on" : "off"));
    }
  }
}
