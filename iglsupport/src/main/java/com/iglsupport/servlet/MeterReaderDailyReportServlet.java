package com.iglsupport.servlet;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.iglsupport.dao.ReportDAO;
import com.iglsupport.model.ReportDTO;

@WebServlet("/MeterReaderDailyReportServlet")
public class MeterReaderDailyReportServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String userName = request.getParameter("userName");
        String gaName = request.getParameter("gaName");
        String portionNo = request.getParameter("portionNo");
        String scheduleStart = request.getParameter("scheduleStart");
        String scheduleEnd = request.getParameter("scheduleEnd");

        ReportDAO dao = new ReportDAO();
        List<ReportDTO> dailyReports = dao.getDailyReportForMeterReader(userId, scheduleStart, scheduleEnd);

        String reportTillDate = new SimpleDateFormat("dd-MM-yyyy").format(new Date());

        // Pass all fields back to JSP
        request.setAttribute("userId", userId != null ? userId : "");
        request.setAttribute("dailyReports", dailyReports);
        request.setAttribute("userName", userName != null ? userName : "N/A");
        request.setAttribute("gaName", gaName != null ? gaName : "N/A");
        request.setAttribute("portionNo", portionNo != null ? portionNo : "N/A");
        request.setAttribute("schedulePeriod", (scheduleStart != null && scheduleEnd != null) ? (scheduleStart + " to " + scheduleEnd) : "N/A");
        request.setAttribute("reportTillDate", reportTillDate);

        request.getRequestDispatcher("meterReaderDailyReport.jsp").forward(request, response);
    }
}