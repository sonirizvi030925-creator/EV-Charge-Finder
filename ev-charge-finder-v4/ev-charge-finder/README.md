# EV Charge Finder

Java (Servlet/JSP + JDBC) + MySQL web app: login, charging stations list with filter and nearest search
(Haversine), Leaflet/OpenStreetMap map, and a range + charging cost planner.

## Setup
1. MySQL database `ev_charge_finder` (tables: stations, users, vehicles).
2. In `src/main/resources/db.properties`, set your MySQL password (this file is not pushed to GitHub).
3. `mvn clean package` -> `target/evcharge.war`
4. copy the war into Tomcat 10.1 `webapps` (or run it with the VS Code Community Server Connector).
5. Browser: http://localhost:8080/evcharge/

## Architecture
Browser -> Servlet (controller) -> DAO (SQL, PreparedStatement) -> MySQL -> model -> JSP (view)

## Note
Station data is demo data. Real-time availability needs a live data source.
