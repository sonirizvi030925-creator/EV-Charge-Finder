package com.evfinder.servlet;

import com.evfinder.dao.StationDAO;
import com.evfinder.dao.VehicleDAO;
import com.evfinder.model.Station;
import com.evfinder.model.Vehicle;
import com.evfinder.util.DistanceUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/**
 * JSON endpoint used by the Find Stations page (called with fetch() from JavaScript).
 * All the calculations are done here in Java:
 * 1) range = full_range * battery% / 100
 * 2) road distance = straight-line distance (Haversine) x 1.3 (approximate)
 * 3) a station is "reachable" if road distance <= range
 * 4) energy = battery_kwh * (target% - battery%) / 100
 * 5) cost = energy x price_per_kwh, time = energy / charging_speed
 */
@WebServlet("/api/find")
public class FindApiServlet extends HttpServlet {
    private static final double ROAD_FACTOR = 1.3;

    private final StationDAO stationDAO = new StationDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            double lat = Double.parseDouble(param(req, "lat"));
            double lng = Double.parseDouble(param(req, "lng"));
            int vehicleId = Integer.parseInt(param(req, "vehicleId"));
            double battery = Double.parseDouble(param(req, "battery"));
            double target = Double.parseDouble(param(req, "target"));
            boolean reachableOnly = "true".equals(req.getParameter("reachableOnly"));

            if (battery < 0 || battery > 100 || target < 0 || target > 100) {
                throw new IllegalArgumentException("Battery and target must be between 0 and 100.");
            }

            Vehicle v = vehicleDAO.getById(vehicleId);
            if (v == null) {
                throw new IllegalArgumentException("Vehicle not found.");
            }

            double rangeKm = v.getFullRangeKm() * battery / 100.0;
            double needKwh = Math.max(0, v.getBatteryKwh() * (target - battery) / 100.0);

            List<Station> list = new ArrayList<>();
            for (Station s : stationDAO.getAll()) {
                double straight = DistanceUtil.km(lat, lng, s.getLatitude(), s.getLongitude());
                double road = straight * ROAD_FACTOR;
                s.setDistanceKm(straight);
                s.setRoadKm(road);
                s.setCost(needKwh * s.getPricePerKwh());
                s.setTimeMin(s.getChargingSpeed() > 0 ? needKwh / s.getChargingSpeed() * 60 : 0);
                if (!reachableOnly || road <= rangeKm) {
                    list.add(s);
                }
            }
            list.sort(Comparator.comparingDouble(Station::getDistanceKm));

            StringBuilder sb = new StringBuilder();
            sb.append("{\"rangeKm\":").append(num(rangeKm));
            sb.append(",\"batteryPercent\":").append(num(battery));
            sb.append(",\"needKwh\":").append(num(needKwh));
            sb.append(",\"stations\":[");
            for (int i = 0; i < list.size(); i++) {
                Station s = list.get(i);
                if (i > 0) {
                    sb.append(",");
                }
                sb.append("{\"id\":").append(s.getId());
                sb.append(",\"name\":\"").append(esc(s.getName())).append("\"");
                sb.append(",\"address\":\"").append(esc(s.getAddress())).append("\"");
                sb.append(",\"connector\":\"").append(esc(s.getConnectorType())).append("\"");
                sb.append(",\"lat\":").append(s.getLatitude());
                sb.append(",\"lng\":").append(s.getLongitude());
                sb.append(",\"speedKw\":").append(num(s.getChargingSpeed()));
                sb.append(",\"pricePerKwh\":").append(num(s.getPricePerKwh()));
                sb.append(",\"available\":").append(s.isAvailable());
                sb.append(",\"straightKm\":").append(num(s.getDistanceKm()));
                sb.append(",\"roadKm\":").append(num(s.getRoadKm()));
                sb.append(",\"reachable\":").append(s.getRoadKm() <= rangeKm);
                sb.append(",\"cost\":").append(num(s.getCost()));
                sb.append(",\"timeMin\":").append(num(s.getTimeMin()));
                sb.append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());

        } catch (NumberFormatException e) {
            error(resp, 400, "Please enter valid numbers.");
        } catch (IllegalArgumentException e) {
            error(resp, 400, e.getMessage());
        } catch (Exception e) {
            error(resp, 500, "Database error: " + e.getMessage());
        }
    }

    private static String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.trim().isEmpty()) {
            throw new IllegalArgumentException("Missing value: " + name);
        }
        return v.trim();
    }

    private static void error(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        resp.getWriter().write("{\"error\":\"" + esc(message) + "\"}");
    }

    private static String num(double d) {
        return String.format(Locale.US, "%.2f", d);
    }

    /** Escapes a string so it is safe inside a JSON string value. */
    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        StringBuilder b = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"':  b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\n': b.append("\\n"); break;
                case '\r': b.append("\\r"); break;
                case '\t': b.append("\\t"); break;
                default:
                    if (c < 0x20) {
                        b.append(String.format("\\u%04x", (int) c));
                    } else {
                        b.append(c);
                    }
            }
        }
        return b.toString();
    }
}
