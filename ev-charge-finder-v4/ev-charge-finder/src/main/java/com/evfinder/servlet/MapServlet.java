package com.evfinder.servlet;

import com.evfinder.dao.StationDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/map")
public class MapServlet extends HttpServlet {
    private final StationDAO stationDAO = new StationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("stations", stationDAO.getAll());
        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/map.jsp").forward(req, resp);
    }
}
