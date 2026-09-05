<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard</title>
<style>
    /* body {
        font-family: Arial, sans-serif;
        background-color: #eef2f5;
        margin: 0;
        padding: 20px;
    }
    .navbar {
        background-color: #343a40;
        color: white;
        padding: 15px 25px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-radius: 6px;
    }
    .navbar h1 {
        margin: 0;
        font-size: 20px;
    }
    .nav-links {
        display: flex;
        align-items: center;
        gap: 15px;
    } */
    body {
            font-family: Arial, sans-serif;
            background-color: #eef2f5;
            margin: 0;
            padding: 15px;
            box-sizing: border-box;
        }
        .navbar {
            background-color: #343a40;
            color: white;
            padding: 12px 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 6px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .navbar h1 {
            margin: 0;
            font-size: 18px;
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            font-size: 13px;
        }
        .quick-actions {
            margin-top: 15px;
            display: flex;
            gap: 15px;
            flex-direction: column; /* Stack cards vertically on mobile by default */
        }
        @media (min-width: 600px) {
            .quick-actions {
                flex-direction: row; /* Place side-by-side on tablets/desktops */
            }
        }
        .action-card {
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 15px;
            background-color: #f8f9fa;
            text-decoration: none;
            color: #333;
            display: block;
            box-sizing: border-box;
        }
    .navbar a {
        text-decoration: none;
        font-weight: bold;
    }
    .nav-link {
        color: #ffffff;
        padding: 6px 12px;
        background-color: #1f4e78;
        border-radius: 4px;
        transition: background-color 0.2s;
    }
    .nav-link:hover {
        background-color: #163654;
    }
    .logout-link {
        color: #ffc107;
    }
    .content-card {
        background: white;
        margin-top: 20px;
        padding: 25px;
        border-radius: 6px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.08);
    }
    /* .quick-actions {
        margin-top: 20px;
        display: flex;
        gap: 15px;
        flex-wrap: wrap;
    }
    .action-card {
        border: 1px solid #dee2e6;
        border-radius: 6px;
        padding: 15px 20px;
        background-color: #f8f9fa;
        text-decoration: none;
        color: #333;
        display: inline-block;
        transition: box-shadow 0.2s, border-color 0.2s;
    } */
    .action-card:hover {
        border-color: #1f4e78;
        box-shadow: 0 2px 8px rgba(31, 78, 120, 0.15);
    }
    .action-card strong {
        color: #1f4e78;
        display: block;
        margin-bottom: 5px;
    }
</style>
</head>
<body>
<%
    // Session validation: Prevent unauthorized direct URL access
    String currentUser = (String) session.getAttribute("currentUser");
    String userRole = (String) session.getAttribute("userRole");
    
    if (currentUser == null || userRole == null) {
        response.sendRedirect("loginpage.jsp");
        return;
    }
    
    // Check if role is allowed
    boolean isAdmin = "Admin".equalsIgnoreCase(userRole);
    boolean isManagerOrIGL = "Manager".equalsIgnoreCase(userRole) || "IGL".equalsIgnoreCase(userRole);
    
    if (!isAdmin && !isManagerOrIGL) {
        response.sendRedirect("loginpage.jsp");
        return;
    }
%>
<div class="navbar">
    <h1>Application Dashboard (<%= userRole %>)</h1>
    <div class="nav-links">
        <% if (isAdmin || isManagerOrIGL) { %>
            <a href="ReportServlet" class="nav-link">Daily Progress Report</a>
        <% } %>
        <span>Welcome, <strong><%= currentUser %></strong></span> | 
        <a href="LogoutServlet" class="logout-link">Logout</a>
    </div>
</div>

<div class="content-card">
    <h2>Welcome to your workspace</h2>
    <p>You have successfully authenticated via MySQL database with role: <strong><%= userRole %></strong></p>
    
    <div class="quick-actions">
        <!-- Visible to Admin, Manager, and IGL -->
        <% if (isAdmin || isManagerOrIGL) { %>
            <a href="ReportServlet" class="action-card">
                <strong>Daily Progress Report &rarr;</strong>
                <span>View GA & portion reading and invoice reconciliation</span>
            </a>
        <% } %>

        <!-- Visible ONLY to Admin -->
        <% if (isAdmin) { %>
            <a href="PortionDetailsServlet" class="action-card">
                <strong>Portion Details &rarr;</strong>
                <span>Manage portion information and settings</span>
            </a>
        <% } %>
    </div>
</div>

</body>
</html>