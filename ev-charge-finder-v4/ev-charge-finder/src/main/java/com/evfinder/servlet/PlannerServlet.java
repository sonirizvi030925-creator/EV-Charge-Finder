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

/**
 * Range + cost planner.
 * 1) range = full_range * battery% / 100
 * 2) road distance = straight-line distance (Haversine) x 1.3  (approximate)
 * 3) station reachable agar road distance <= range
 * 4) kWh = battery_kwh * (target% - current%) / 100
 * 5) cost = kWh x price_per_kwh,  time = kWh / charging_speed
 */
@WebServlet("/planner")
public class PlannerServlet extends HttpServlet {
    private static final double ROAD_FACTOR = 1.3;

    private final StationDAO stationDAO = new StationDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        loadVehicles(req);
        req.getRequestDispatcher("/WEB-INF/views/planner.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        loadVehicles(req);
        try {
            int vehicleId = Integer.parseInt(req.getParameter("vehicleId"));
            double battery = Double.parseDouble(req.getParameter("battery"));
            double target = Double.parseDouble(req.getParameter("target"));
            double lat = Double.parseDouble(req.getParameter("lat"));
            double lng = Double.parseDouble(req.getParameter("lng"));

            if (battery < 0 || battery > 100 || target < 0 || target > 100) {
                throw new IllegalArgumentException("Battery % must be between 0 and 100.");
            }
            if (target <= battery) {
                throw new IllegalArgumentException("Target % must be greater than the current battery %.");
            }

            Vehicle v = vehicleDAO.getById(vehicleId);
            if (v == null) {
                throw new IllegalArgumentException("Vehicle not found.");
            }

            double rangeKm = v.getFullRangeKm() * battery / 100.0;
            double needKwh = v.getBatteryKwh() * (target - battery) / 100.0;

            List<Station> reachable = new ArrayList<>();
            for (Station s : stationDAO.getAll()) {
                double straight = DistanceUtil.km(lat, lng, s.getLatitude(), s.getLongitude());
                double road = straight * ROAD_FACTOR;
                if (road <= rangeKm) {
                    s.setDistanceKm(straight);
                    s.setRoadKm(road);
                    s.setCost(needKwh * s.getPricePerKwh());
                    s.setTimeMin(s.getChargingSpeed() > 0 ? needKwh / s.getChargingSpeed() * 60 : 0);
                    reachable.add(s);
                }
            }
            reachable.sort(Comparator.comparingDouble(Station::getRoadKm));

            req.setAttribute("vehicle", v);
            req.setAttribute("rangeKm", rangeKm);
            req.setAttribute("needKwh", needKwh);
            req.setAttribute("reachable", reachable);
            req.setAttribute("calculated", true);
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Please enter valid numbers in all fields.");
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/planner.jsp").forward(req, resp);
    }

    private void loadVehicles(HttpServletRequest req) {
        try {
            req.setAttribute("vehicles", vehicleDAO.getAll());
        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
    }
}
