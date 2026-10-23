package com.evfinder.servlet;

import com.evfinder.dao.VehicleDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Opens the "Find Stations" page (controls, map and station cards on one page). */
@WebServlet("/find")
public class FindServlet extends HttpServlet {
    private final VehicleDAO vehicleDAO = new VehicleDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("vehicles", vehicleDAO.getAll());
        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/find.jsp").forward(req, resp);
    }
}
