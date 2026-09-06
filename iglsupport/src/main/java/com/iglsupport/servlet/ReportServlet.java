package com.iglsupport.servlet;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.iglsupport.dao.ReportDAO;
import com.iglsupport.model.ReportDTO;

@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("loginpage.jsp?msg=session_expired");
            return;
        }

        String userRole = (String) session.getAttribute("userRole");
        Integer userGid = (Integer) session.getAttribute("userGid");
        Integer userVid = (Integer) session.getAttribute("userVid");

        List<ReportDTO> reportList;
        
        // If Admin, or if Manager/IGL with gid == 0, treat like Admin (pass null GID but keep vendor restriction if needed, or pass null)
        if ("Admin".equalsIgnoreCase(userRole) || 
            (("Manager".equalsIgnoreCase(userRole) || "IGL".equalsIgnoreCase(userRole)) && userGid != null && userGid == 0)) {
            reportList = ReportDAO.getDailyReport(null, userVid, userRole);
        } else {
            reportList = ReportDAO.getDailyReport(userGid, userVid, userRole);
        }
        
        if (reportList != null && !reportList.isEmpty()) {
            request.setAttribute("reportList", reportList);
            request.setAttribute("hasData", true);
        } else {
            request.setAttribute("hasData", false);
            request.setAttribute("message", "No portions found matching your assigned area or inv_status = 1.");
        }
        
        request.getRequestDispatcher("report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}