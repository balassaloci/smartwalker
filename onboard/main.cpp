#include <Arduino.h>

double bin2Voltage(int bin){
  double voltage = double(bin * 2)/1023;
  return voltage;
}

double voltage2Force(double voltage){
  double force = 7.757925 + (-0.0002484973 - 7.757925)/(1 + pow((voltage/7104.773),0.5384733));
  return force;
}

struct SensorData{
  double lGrip;
  double lLean;
  double rGrip;
  double rLean;
};

void serialize(const SensorData& data)
{
Serial.print("{\"lgrp\":");
    Serial.print(data.lGrip, DEC);

    Serial.print(",\"rgrp\":");
    Serial.print(data.rGrip, DEC);

    Serial.print(",\"llean\":");
    Serial.print(data.lLean, DEC);

    //rlean
    Serial.print(",\"rlean\":");
    Serial.print(data.rLean, DEC);

    Serial.println('}');
}

void setup() {
    // put your setup code here, to run once:
    Serial.begin(115200);
    while (!Serial) continue;
}

void loop() {
    // put your main code here, to run repeatedly:
   double lGrip1 = bin2Voltage(analogRead(0));
   double lGrip2 = bin2Voltage(analogRead(1));
   double lLean1 = bin2Voltage(analogRead(2));
   double lLean2 = bin2Voltage(analogRead(3));
   double rGrip1 = bin2Voltage(analogRead(4));
   double rGrip2 = bin2Voltage(analogRead(5));
   double rLean1 = bin2Voltage(analogRead(6));
   double rLean2 = bin2Voltage(analogRead(7));

   //Defective sensors: leftgrip2, rightlean2

   SensorData data;
   data.lLean = (lLean1 + lLean2)/2;
   data.rLean = (rLean1);
   data.lGrip = (lGrip1);
   data.rGrip = (rGrip1 + rGrip2)/2;
   serialize(data);
}
