package com.iglsupport.servlet;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.iglsupport.dao.ReportDAO;
import com.iglsupport.model.ReportDTO;

@WebServlet("/MeterReaderMapServlet")
public class MeterReaderMapServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String date = request.getParameter("date");
        
        System.out.println("=== MAP SERVLET DEBUG ===");
        System.out.println("Received userId: " + userId);
        System.out.println("Received date parameter: " + date);

        ReportDAO dao = new ReportDAO();
        List<ReportDTO> locations = dao.getReadingsMapForDate(userId, date);

        System.out.println("Locations retrieved from DAO: " + (locations != null ? locations.size() : "null"));

        request.setAttribute("locations", locations);
        request.setAttribute("selectedDate", date);
        request.setAttribute("userId", userId);

        request.getRequestDispatcher("dailyMap.jsp").forward(request, response);
    }
}