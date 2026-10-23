package com.evfinder.servlet;

import com.evfinder.dao.UserDAO;
import com.evfinder.model.User;
import com.evfinder.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String error = null;

        try {
            User user = (email == null) ? null : userDAO.findByEmail(email.trim());
            if (user != null && password != null && PasswordUtil.check(password, user.getPasswordHash())) {
                req.getSession().setAttribute("user", user);
                resp.sendRedirect(req.getContextPath() + "/find");
                return;
            }
            error = "Incorrect email or password.";
        } catch (Exception e) {
            error = "Database error: " + e.getMessage();
        }
        req.setAttribute("error", error);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
}
