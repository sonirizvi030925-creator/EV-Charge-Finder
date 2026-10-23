package com.evfinder.servlet;

import com.evfinder.dao.StationDAO;
import com.evfinder.model.Station;
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
import java.util.TreeSet;

/** Stations list + connector filter + optional nearest-first sorting using Haversine. */
@WebServlet("/stations")
public class StationsServlet extends HttpServlet {
    private final StationDAO stationDAO = new StationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Station> all = stationDAO.getAll();

            // distinct connector types for the filter dropdown
            TreeSet<String> connectors = new TreeSet<>();
            for (Station s : all) {
                connectors.add(s.getConnectorType());
            }

            String connector = req.getParameter("connector");
            List<Station> result = new ArrayList<>();
            for (Station s : all) {
                if (connector == null || connector.isEmpty() || connector.equals(s.getConnectorType())) {
                    result.add(s);
                }
            }

            // if the user gave a location, sort nearest first
            String latStr = req.getParameter("lat");
            String lngStr = req.getParameter("lng");
            if (latStr != null && lngStr != null && !latStr.isEmpty() && !lngStr.isEmpty()) {
                try {
                    double lat = Double.parseDouble(latStr);
                    double lng = Double.parseDouble(lngStr);
                    for (Station s : result) {
                        s.setDistanceKm(DistanceUtil.km(lat, lng, s.getLatitude(), s.getLongitude()));
                    }
                    result.sort(Comparator.comparingDouble(Station::getDistanceKm));
                    req.setAttribute("showDistance", true);
                } catch (NumberFormatException e) {
                    req.setAttribute("error", "Latitude and longitude must be valid numbers.");
                }
            }

            req.setAttribute("stations", result);
            req.setAttribute("connectors", connectors);
        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/stations.jsp").forward(req, resp);
    }
}
