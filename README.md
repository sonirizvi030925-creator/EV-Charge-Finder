# EV Charge Finder

A Java full stack web application that helps electric vehicle (EV) owners find nearby charging stations, check whether they can reach them with their current battery, estimate the charging cost, and get directions on a map.

## Features

- **Register and Login** with BCrypt password hashing and session-based authentication
- **Find Stations page** with the controls on top, an interactive map in the middle and station cards below
  - Choose your car, current battery % and the % you want to charge up to
  - Shows how far you can drive (estimated range)
  - Marks each station as **in range** or **too far**
  - Estimates **charging cost and time** for every station
  - Results update instantly, without reloading the page (AJAX)
- **Nearest station search** using the Haversine formula
- **Directions on the map**: draws the road route from your location to the station with distance and travel time, plus an "Open in Google Maps" button
- **All Stations page** with connector type filter and nearest-first sorting
- **Map page** with a station list and turn-by-turn directions
- **Range Planner page** (form based version of the range and cost calculator)
- **Protected pages**: a servlet filter redirects users who are not logged in

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript, Bootstrap 5, JSP + JSTL |
| Backend | Java 17, Servlets, JDBC |
| Database | MySQL 8 |
| Maps | Leaflet, OpenStreetMap, Leaflet Routing Machine (OSRM) |
| Security | BCrypt (jBCrypt), PreparedStatement (prevents SQL injection) |
| Build and server | Maven, Apache Tomcat 10.1 |

## Architecture

```
Browser --> Servlet (controller) --> DAO (SQL queries) --> MySQL
               |
               +--> JSP page (view)   or   JSON response (AJAX)
```

- **Model**: `User`, `Station`, `Vehicle` (one object per database row)
- **DAO**: `UserDAO`, `StationDAO`, `VehicleDAO` (all SQL lives here)
- **Servlets**: handle requests and do the business logic
- **Util**: `DBUtil` (connection), `PasswordUtil` (BCrypt), `DistanceUtil` (Haversine)
- **Filter**: `AuthFilter` (login check)

## How the calculations work

| What | Formula |
|---|---|
| Remaining range | `full_range_km x battery% / 100` |
| Straight-line distance | Haversine formula (earth radius 6371 km) |
| Estimated road distance | `straight-line distance x 1.3` |
| Station reachable? | `road distance <= remaining range` |
| Energy needed | `battery_kwh x (target% - battery%) / 100` |
| Charging cost | `energy needed x price_per_kwh` |
| Charging time | `energy needed / charging_speed_kw x 60` (minutes) |

**Example:** Tata Nexon EV (40.5 kWh, 390 km range), battery 30%, charge to 80%
- Range = 390 x 30 / 100 = **117 km**
- Energy = 40.5 x (80 - 30) / 100 = **20.25 kWh**
- At Rs 14/kWh the cost is **Rs 283.5**, and at a 30 kW charger it takes about **40 minutes**

## Project structure

```
ev-charge-finder/
├── pom.xml
├── database/
│   └── extra_stations.sql
└── src/main/
    ├── java/com/evfinder/
    │   ├── dao/        UserDAO, StationDAO, VehicleDAO
    │   ├── filter/     AuthFilter
    │   ├── model/      User, Station, Vehicle
    │   ├── servlet/    Register, Login, Logout, Find, FindApi,
    │   │               Stations, Map, Planner
    │   └── util/       DBUtil, PasswordUtil, DistanceUtil
    ├── resources/      db.properties.example
    └── webapp/
        ├── index.jsp
        ├── css/style.css
        └── WEB-INF/views/
