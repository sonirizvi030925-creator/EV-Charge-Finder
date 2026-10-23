package com.evfinder.model;

public class Vehicle {
    private int id;
    private String model;
    private double batteryKwh;
    private double fullRangeKm;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public double getBatteryKwh() { return batteryKwh; }
    public void setBatteryKwh(double batteryKwh) { this.batteryKwh = batteryKwh; }
    public double getFullRangeKm() { return fullRangeKm; }
    public void setFullRangeKm(double fullRangeKm) { this.fullRangeKm = fullRangeKm; }
}
