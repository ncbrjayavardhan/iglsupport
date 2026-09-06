package com.iglsupport.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.iglsupport.dao.UserDAO;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userId = request.getParameter("userId");
        String pwd = request.getParameter("pwd");

        if (userId == null || userId.trim().isEmpty() || pwd == null || pwd.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please enter both User ID and Password.");
            request.getRequestDispatcher("loginpage.jsp").forward(request, response);
            return;
        }

        HttpSession session2 = request.getSession();
        String userCaptchaStr = request.getParameter("captcha");
        Integer expectedCaptcha = (Integer) session2.getAttribute("expectedCaptcha");

        if (expectedCaptcha == null || userCaptchaStr == null || Integer.parseInt(userCaptchaStr) != expectedCaptcha) {
            request.setAttribute("errorMessage", "Invalid Math CAPTCHA answer. Please try again.");
            request.getRequestDispatcher("loginpage.jsp").forward(request, response);
            return;
        }

        session2.removeAttribute("expectedCaptcha");

        UserDAO.UserSessionInfo userInfo = UserDAO.getUserInfo(userId.trim(), pwd.trim());

        if (userInfo != null && userInfo.getRole() != null) {
            String trimmedRole = userInfo.getRole().trim();
            
            if (!"Admin".equalsIgnoreCase(trimmedRole) && 
                !"Manager".equalsIgnoreCase(trimmedRole) && 
                !"IGL".equalsIgnoreCase(trimmedRole)) {
                
                request.setAttribute("errorMessage", "Access Denied: Your role is not authorized to log in.");
                request.getRequestDispatcher("loginpage.jsp").forward(request, response);
                return;
            }

            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", userId.trim());
            session.setAttribute("userRole", trimmedRole);
            session.setAttribute("userGid", userInfo.getGid());
            session.setAttribute("userVid", userInfo.getVid());
            session.setMaxInactiveInterval(15 * 60);
            
            response.sendRedirect("dashboard.jsp");
        } else {
            request.setAttribute("errorMessage", "Invalid User ID, incorrect password, or inactive account.");
            request.getRequestDispatcher("loginpage.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("loginpage.jsp");
    }
}