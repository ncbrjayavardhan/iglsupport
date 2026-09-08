<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meter Reader Daily Report</title>
    <style>
        :root {
            --primary: #1f4e78;
            --primary-hover: #16385c;
            --bg-light: #f4f6f9;
            --card-bg: #ffffff;
            --text-main: #2c3e50;
            --text-muted: #64748b;
            --border-color: #cbd5e1;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: var(--bg-light);
            color: var(--text-main);
        }

        .report-container {
            max-width: 800px;
            margin: 0 auto;
            background: var(--card-bg);
            padding: 24px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .report-header-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 12px;
            margin-bottom: 20px;
        }

        h2 {
            margin: 0;
            color: var(--primary);
            font-size: 22px;
        }

        .header-box {
            background: #f8fafc;
            padding: 16px 20px;
            border: 1px solid #e2e8f0;
            margin-bottom: 24px;
            border-radius: 6px;
            font-size: 14px;
            line-height: 1.6;
        }

        .header-box p {
            margin: 6px 0;
            color: #334155;
        }

        .header-box strong {
            color: #0f172a;
        }

        .table-responsive {
            overflow-x: auto;
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: center;
            background-color: #ffffff;
        }

        th, td {
            border: 1px solid #e2e8f0;
            padding: 10px 12px;
        }

        th {
            background-color: var(--primary);
            color: #ffffff;
            font-weight: 600;
            letter-spacing: 0.3px;
        }

        tbody tr:nth-child(even) {
            background-color: #f8fafc;
        }

        tbody tr:hover {
            background-color: #f1f5f9;
        }

        .total-row {
            font-weight: bold;
            background-color: #e2e8f0 !important;
            color: #0f172a;
        }

        .action-footer {
            margin-top: 20px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .btn {
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            border-radius: 4px;
            cursor: pointer;
            border: none;
            transition: background-color 0.2s;
        }

        .btn-close {
            background-color: #64748b;
            color: white;
        }

        .btn-close:hover {
            background-color: #475569;
        }

        .btn-print {
            background-color: var(--primary);
            color: white;
        }

        .btn-print:hover {
            background-color: var(--primary-hover);
        }

        /* Styling for date hyperlinks */
        .date-link {
            color: #2563eb;
            font-weight: bold;
            text-decoration: underline;
        }
        .date-link:hover {
            color: #1d4ed8;
        }

        @media print {
            body { background-color: #ffffff; padding: 0; }
            .report-container { box-shadow: none; padding: 0; }
            .action-footer { display: none; }
        }
    </style>
</head>
<body>

    <div class="report-container">
        <div class="report-header-title">
            <h2>Meter Reader Daily Performance Report</h2>
        </div>

        <div class="header-box">
            <p><strong>Meter Reader Name:</strong> ${userName}</p>
            <p><strong>GA Name:</strong> ${gaName} &nbsp;|&nbsp; <strong>Portion Number:</strong> ${portionNo}</p>
            <p><strong>Schedule Period:</strong> ${schedulePeriod} &nbsp;|&nbsp; <strong>Report Till Date:</strong> ${reportTillDate}</p>
        </div>

        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>Date (Click to View Map)</th>
                        <th>Readings Count</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty dailyReports}">
                            <c:set var="totalReadingsCount" value="0" />
                            
                            <c:forEach var="report" items="${dailyReports}">
                                <tr>
                                    <td>
                                        <!-- Hyperlink directing to map servlet with user id and target date -->
                                        <a href="MeterReaderMapServlet?userId=${userId}&date=${report.readingDate}" target="_blank" class="date-link">
                                            ${report.readingDate}
                                        </a>
                                    </td>
                                    <td><strong>${report.readingCount}</strong></td>
                                </tr>
                                <c:set var="totalReadingsCount" value="${totalReadingsCount + report.readingCount}" />
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="2" style="padding: 20px; color: var(--text-muted);">No readings found up to the current date for this schedule.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
                <c:if test="${not empty dailyReports}">
                    <tfoot>
                        <tr class="total-row">
                            <td style="text-align: right; padding-right: 15px;">Total Readings:</td>
                            <td>${totalReadingsCount}</td>
                        </tr>
                    </tfoot>
                </c:if>
            </table>
        </div>

        <div class="action-footer">
            <button class="btn btn-print" onclick="window.print()">Print Report</button>
            <button class="btn btn-close" onclick="window.close()">Close Window</button>
        </div>
    </div>

</body>
</html>