package com.evfinder.model;

public class Station {
    private int id;
    private String name;
    private String address;
    private double latitude;
    private double longitude;
    private String connectorType;
    private double chargingSpeed;
    private double pricePerKwh;
    private boolean available;

    // Not stored in the database; set after calculation
    private double distanceKm;
    private double roadKm;
    private double cost;
    private double timeMin;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    public String getConnectorType() { return connectorType; }
    public void setConnectorType(String connectorType) { this.connectorType = connectorType; }
    public double getChargingSpeed() { return chargingSpeed; }
    public void setChargingSpeed(double chargingSpeed) { this.chargingSpeed = chargingSpeed; }
    public double getPricePerKwh() { return pricePerKwh; }
    public void setPricePerKwh(double pricePerKwh) { this.pricePerKwh = pricePerKwh; }
    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
    public double getDistanceKm() { return distanceKm; }
    public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }
    public double getRoadKm() { return roadKm; }
    public void setRoadKm(double roadKm) { this.roadKm = roadKm; }
    public double getCost() { return cost; }
    public void setCost(double cost) { this.cost = cost; }
    public double getTimeMin() { return timeMin; }
    public void setTimeMin(double timeMin) { this.timeMin = timeMin; }
}
