package com.evfinder.servlet;

import com.evfinder.dao.UserDAO;
import com.evfinder.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        String error = null;
        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            error = "All fields are required.";
        } else if (password.length() < 6) {
            error = "Password must be at least 6 characters long.";
        }

        try {
            if (error == null && userDAO.findByEmail(email.trim()) != null) {
                error = "This email is already registered.";
            }
            if (error == null) {
                userDAO.register(name.trim(), email.trim(), PasswordUtil.hash(password));
                resp.sendRedirect(req.getContextPath() + "/login?registered=1");
                return;
            }
        } catch (Exception e) {
            error = "Database error: " + e.getMessage();
        }
        req.setAttribute("error", error);
        req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
    }
}
