<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.Arrays" %>
<%!
    // Guaranteed Indian Number Formatter (e.g., 94,82,226.00 and 94,82,226)
    public String formatIndianNumber(double value, int decimals) {
        String s = (decimals > 0) ? String.format("%." + decimals + "f", value) : String.format("%.0f", value);
        String intPart = s;
        String decPart = "";
        
        int dotIndex = s.indexOf('.');
        if (dotIndex != -1) {
            intPart = s.substring(0, dotIndex);
            decPart = s.substring(dotIndex);
        }

        if (intPart.length() <= 3) {
            return intPart + decPart;
        }

        String lastThree = intPart.substring(intPart.length() - 3);
        String remaining = intPart.substring(0, intPart.length() - 3);

        StringBuilder formatted = new StringBuilder();
        while (remaining.length() > 2) {
            formatted.insert(0, "," + remaining.substring(remaining.length() - 2));
            remaining = remaining.substring(0, remaining.length() - 2);
        }
        if (remaining.length() > 0) {
            formatted.insert(0, remaining);
        }

        return formatted.toString() + "," + lastThree + decPart;
    }
%>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pay Register Report - Vaibhutrans</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- SheetJS for Client-Side Excel Export -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
    <!-- JSZip for Multiple Excel Archive Download -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --icici-gradient: linear-gradient(135deg, #f97316 0%, #c2410c 100%);
            --bom-gradient: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
            --card-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
            --glass-bg: rgba(255, 255, 255, 0.96);
            --border-color: #cbd5e1;
        }

        * {
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            color: #1e293b;
            padding-bottom: 40px;
        }

        .report-card {
            padding: 20px 24px;
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-top: 14px;
        }

        .header-title-container {
            border-bottom: 2px dashed #e2e8f0;
        }

        .report-title {
            font-weight: 800;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
        }

        /* Metric Cards styling */
        .metric-card-1 {
            background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
            border: 1px solid #c7d2fe;
            border-radius: 10px;
        }

        .metric-card-status {
            background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
            border: 1px solid #fde68a;
            border-radius: 10px;
        }

        .metric-card-2 {
            background: linear-gradient(135deg, rgb(237, 222, 251) 0%, rgb(245, 247, 246) 100%);
            border: 1px solid #a7f3d0;
            border-radius: 10px;
        }

        .metric-label {
            font-size: 10.5px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            font-weight: 700;
            color: #475569;
        }

        .metric-val {
            font-size: 14px;
            font-weight: 800;
            color: #0f172a;
        }

        /* Filter Panel Single-Line Responsive Styling */
        .filters-panel {
            background: #f8fafc;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            padding: 8px 10px;
        }

        .filter-row-nowrap {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 6px;
        }

        .filter-item-cluster { flex: 1 1 110px; min-width: 100px; max-width: 130px; }
        .filter-item-multi   { flex: 1 1 120px; min-width: 110px; }
        .filter-item-month   { flex: 0 0 78px; min-width: 74px; }
        .filter-item-year    { flex: 0 0 78px; min-width: 74px; }
        .filter-item-actions { flex: 0 0 auto; display: flex; align-items: center; gap: 4px; }

        .filters-panel .form-select-sm, .bank-card .form-select-sm {
            height: 32px;
            font-size: 11px;
            padding: 3px 6px;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
        }

        /* Multi-Select Checkbox Dropdown Styling */
        .custom-multiselect-dropdown {
            max-height: 250px;
            overflow-y: auto;
            min-width: 200px;
            padding: 6px 8px;
            border-radius: 8px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        .multiselect-btn {
            height: 32px;
            font-size: 11px;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #1e293b;
            font-weight: 600;
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            text-align: left;
            padding: 3px 6px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .multiselect-btn:focus, .multiselect-btn:hover {
            background: #f8fafc;
            border-color: #6366f1;
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
        }

        .multiselect-option {
            font-size: 11.5px;
            cursor: pointer;
            padding: 3px 5px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            user-select: none;
        }

        .multiselect-option:hover {
            background: #f1f5f9;
        }

        .multiselect-actions {
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 4px;
            margin-bottom: 4px;
            display: flex;
            justify-content: space-between;
            font-size: 10.5px;
        }

        /* Bank Card styling */
        .bank-card {
            background: linear-gradient(135deg, #f0fdf4 0%, #e0f2fe 100%);
            border-radius: 10px;
            border: 1px solid #bae6fd;
        }

        /* Actions Bar */
        .actions-bar {
            background: #ffffff;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        /* Button styling */
        .btn {
            border-radius: 6px;
            font-weight: 600;
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            font-size: 11px;
            white-space: nowrap;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.15);
        }

        .btn-gradient-primary { background: var(--primary-gradient); color: white; }
        .btn-gradient-success { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; }
        .btn-gradient-info { background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); color: white; }
        .btn-gradient-icici { background: var(--icici-gradient); color: white; }
        .btn-gradient-bom { background: var(--bom-gradient); color: white; }
        .btn-dark { background: #0f172a; color: white; }
        .btn-light { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-light:hover { background: #e2e8f0; color: #0f172a; }

        /* Table styling */
        .table-responsive {
            margin-top: 10px;
            border-radius: 8px;
            overflow-x: auto;
            max-height: 560px;
            box-shadow: var(--card-shadow);
            border: 1.5px solid var(--border-color);
        }

        .table-bordered-custom {
            margin-bottom: 0;
            border-collapse: separate !important;
            border-spacing: 0;
            background: #ffffff;
            width: 100%;
        }

        .table-bordered-custom th,
        .table-bordered-custom td {
            border: 1px solid var(--border-color) !important;
            padding: 7px 10px;
            font-size: 12px;
            vertical-align: middle;
            white-space: nowrap;
        }

        .table-bordered-custom thead th {
            position: sticky;
            top: 0;
            z-index: 2;
            background: #0f172a;
            color: #f8fafc;
            border: 1px solid #334155 !important;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 10.5px;
            letter-spacing: 0.5px;
        }

        .table-bordered-custom tbody tr:hover {
            background-color: #f1f5f9;
        }

        tr.row-selected {
            background-color: #eff6ff !important;
        }

        /* Status Badges */
        .status-badge {
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 4px;
            font-size: 10.5px;
            display: inline-block;
        }
        .status-badge-allow { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        .status-badge-hold  { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .status-badge-paid  { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .status-badge-other { background: #fdf8f4; color: #9a3412; border: 1px solid #fed7aa; }

        .pagination-container {
            margin-top: 12px;
            padding: 10px 16px;
            background: #f8fafc;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .badge-total {
            background: var(--primary-gradient);
            padding: 5px 12px;
            font-weight: 700;
            border-radius: 20px;
            color: white;
            font-size: 11.5px;
        }

        .code-badge {
            background: #eef2ff;
            color: #4338ca;
            font-family: monospace;
            padding: 3px 8px;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            transition: all 0.15s ease;
        }
        .code-badge:hover {
            background: #e0e7ff;
            color: #312e81;
            text-decoration: underline;
        }

        /* Bulk Selection Banner */
        .bulk-selection-bar {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            padding: 6px 12px;
        }

        .filtered-banner {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 6px;
            padding: 4px 10px;
            font-size: 11.5px;
            color: #1e40af;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        /* Modern Action Button Styling */
        .btn-action-pill {
            background: linear-gradient(135deg, rgb(170, 121, 65) 0%, rgb(170, 121, 65) 100%);
            color: #ffffff !important;
            border-radius: 50rem;
            padding: 3px 10px;
            font-size: 11px;
            font-weight: 600;
            box-shadow: 0 2px 4px rgba(79, 70, 229, 0.25);
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .btn-action-pill:hover, 
        .btn-action-pill:focus {
            background: linear-gradient(135deg, #4338ca 0%, #4f46e5 100%);
            box-shadow: 0 4px 8px rgba(79, 70, 229, 0.35);
            transform: translateY(-1px);
            color: #ffffff;
        }

        .action-dropdown-menu {
            border-radius: 10px;
            padding: 6px;
            min-width: 140px;
            animation: dropdownFadeIn 0.15s ease-out;
        }

        .action-dropdown-menu .dropdown-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 11.5px;
            transition: background 0.15s ease, transform 0.1s ease;
        }

        .action-dropdown-menu .dropdown-item:hover {
            background-color: #f8fafc;
            transform: translateX(2px);
        }

        .action-item-allow:hover { color: #16a34a !important; }
        .action-item-hold:hover  { color: #dc2626 !important; }
        .action-item-paid:hover  { color: #2563eb !important; }

        .icon-circle {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            font-size: 9.5px;
        }

        @keyframes dropdownFadeIn {
            from { opacity: 0; transform: translateY(-4px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Modal Colored Section Cards */
        .modal-card-personal {
            background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
            border: 1px solid #bfdbfe !important;
            border-radius: 10px;
        }
        .modal-card-billing {
            background: linear-gradient(135deg, #fffbeb 0%, #fcd34d 100%);
            border: 1px solid rgb(254, 251, 0) !important;
            border-radius: 10px;
        }
        
        /* Salary Card Dynamic Themes */
        .modal-card-salary-paid {
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            border: 1px solid #86efac !important;
            border-radius: 10px;
        }
        .modal-card-salary-hold {
            background: linear-gradient(135deg, #fdf6ed 0%, #faedcd 100%);
            border: 1px solid #e9d8a6 !important;
            border-radius: 10px;
        }
        .modal-card-salary-allow {
            background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
            border: 1px solid #fca5a5 !important;
            border-radius: 10px;
        }

        .modal-section-title {
            font-size: 13px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
            padding-bottom: 5px;
            border-bottom: 2px solid rgba(0,0,0,0.08);
        }
    </style>
</head>
<body>

    <!-- Navbar -->
    <jsp:include page="navbar.jsp" />

    <div class="container-fluid px-4 mt-2">
        <div class="report-card">

            <!-- Header Section -->
            <div class="d-flex flex-wrap justify-content-between align-items-center header-title-container pb-2 mb-2 gap-2">
                <div class="d-flex align-items-center gap-2">
                    <div class="p-2 bg-light rounded-3 text-primary border">
                        <i class="fa fa-money-check-alt"></i>
                    </div>
                    <div>
                        <h4 class="report-title mb-0" style="font-size: 19px;">Pay Register Report</h4>
                        <p class="text-muted small mb-0" style="font-size: 11px;">Filter by Month, Year, Cluster, Zone, Circle, Division, Designation & DB Status</p>
                    </div>
                </div>

                <% if (request.getAttribute("message") != null) { %>
                    <div class="alert alert-success py-1 px-3 mb-0 small">
                        <i class="fa fa-check-circle me-1"></i> <%= request.getAttribute("message") %>
                    </div>
                <% } %>
            </div>

            <!-- Metric Summary Cards -->
            <%
                Map<String, Double> summary = (Map<String, Double>) request.getAttribute("summaryMap");
                double sumCtc1 = (summary != null && summary.get("SUM_CTC1_ACT") != null) ? summary.get("SUM_CTC1_ACT") : 0.0;
                double sumCtc = (summary != null && summary.get("SUM_CTC_ACT") != null) ? summary.get("SUM_CTC_ACT") : 0.0;
                double sumTcs = (summary != null && summary.get("SUM_TOTAL_TCS_ACT") != null) ? summary.get("SUM_TOTAL_TCS_ACT") : 0.0;
                double sumNet = (summary != null && summary.get("SUM_NET_AMT_PAYABLE") != null) ? summary.get("SUM_NET_AMT_PAYABLE") : 0.0;
                double sumTotalSalary = sumTcs + sumNet;

                double sumAllow = (summary != null && summary.get("SUM_ALLOW_AMT") != null) ? summary.get("SUM_ALLOW_AMT") : 0.0;
                double sumHold = (summary != null && summary.get("SUM_HOLD_AMT") != null) ? summary.get("SUM_HOLD_AMT") : 0.0;
                double sumPaid = (summary != null && summary.get("SUM_PAID_AMT") != null) ? summary.get("SUM_PAID_AMT") : 0.0;
                double sumAllowHold = sumAllow + sumHold;

                double sumTotBilled = (summary != null && summary.get("SUM_TOTAL_BILLED_ACT") != null) ? summary.get("SUM_TOTAL_BILLED_ACT") : 0.0;
                double sumManBilled = (summary != null && summary.get("SUM_MANNUAL_BILLED_ACT") != null) ? summary.get("SUM_MANNUAL_BILLED_ACT") : 0.0;
                double sumProbeBilled = (summary != null && summary.get("SUM_PROBE_BILLED_ACT") != null) ? summary.get("SUM_PROBE_BILLED_ACT") : 0.0;
                double sumAutoOcr = (summary != null && summary.get("SUM_AUTO_OCR_ACT") != null) ? summary.get("SUM_AUTO_OCR_ACT") : 0.0;
            %>

            <!-- First Card: Currency Figures in Indian Number Format -->
            <div class="metric-card-1 p-2 mb-2">
                <div class="row text-center g-1 align-items-center">
                    <div class="col border-end">
                        <div class="metric-label">CTC1 Act</div>
                        <div class="metric-val text-primary">&#8377;<%= formatIndianNumber(sumCtc1, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">CTC Act</div>
                        <div class="metric-val text-primary">&#8377;<%= formatIndianNumber(sumCtc, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">Total TCS Act</div>
                        <div class="metric-val text-danger">&#8377;<%= formatIndianNumber(sumTcs, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">Net Payable</div>
                        <div class="metric-val text-success">&#8377;<%= formatIndianNumber(sumNet, 2) %></div>
                    </div>
                    <div class="col">
                        <div class="metric-label">Total Salary Amount</div>
                        <div class="metric-val text-dark">&#8377;<%= formatIndianNumber(sumTotalSalary, 2) %></div>
                    </div>
                </div>
            </div>

            <!-- Middle Status Amount Card -->
            <div class="metric-card-status p-2 mb-2">
                <div class="row text-center g-1 align-items-center">
                    <div class="col border-end">
                        <div class="metric-label">Total Allow Amount</div>
                        <div class="metric-val text-success">&#8377;<%= formatIndianNumber(sumAllow, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">Total Hold Amount</div>
                        <div class="metric-val text-danger">&#8377;<%= formatIndianNumber(sumHold, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">Total Paid Amount</div>
                        <div class="metric-val text-primary">&#8377;<%= formatIndianNumber(sumPaid, 2) %></div>
                    </div>
                    <div class="col">
                        <div class="metric-label">Allow + Hold Total</div>
                        <div class="metric-val text-dark">&#8377;<%= formatIndianNumber(sumAllowHold, 2) %></div>
                    </div>
                </div>
            </div>

            <!-- Second Card: Quantity / Count Figures in Indian Number Format -->
            <div class="metric-card-2 p-2 mb-2">
                <div class="row text-center g-1 align-items-center">
                    <div class="col-3 border-end">
                        <div class="metric-label">Manual Billed</div>
                        <div class="metric-val text-secondary"><%= formatIndianNumber(sumManBilled, 0) %></div>
                    </div>
                    <div class="col-3 border-end">
                        <div class="metric-label">Probe Billed</div>
                        <div class="metric-val text-info"><%= formatIndianNumber(sumProbeBilled, 0) %></div>
                    </div>
                    <div class="col-3 border-end">
                        <div class="metric-label">Auto OCR Act</div>
                        <div class="metric-val text-success"><%= formatIndianNumber(sumAutoOcr, 0) %></div>
                    </div>
                    <div class="col-3">
                        <div class="metric-label">Total Billed Act</div>
                        <div class="metric-val text-dark"><%= formatIndianNumber(sumTotBilled, 0) %></div>
                    </div>
                </div>
            </div>

            <!-- Single-Line Compact Filter Form (Month & Year before Cluster) -->
            <%
                String selCluster = request.getAttribute("selectedCluster") != null ? String.valueOf(request.getAttribute("selectedCluster")) : "";
                List<String> selZones = (List<String>) request.getAttribute("selectedZones");
                List<String> selCircles = (List<String>) request.getAttribute("selectedCircles");
                List<String> selDivisions = (List<String>) request.getAttribute("selectedDivisions");
                List<String> selDesignations = (List<String>) request.getAttribute("selectedDesignations");
                List<String> selDbStatuses = (List<String>) request.getAttribute("selectedDbStatuses");
                String selMonth = request.getAttribute("selectedMonth") != null ? String.valueOf(request.getAttribute("selectedMonth")) : "";
                String selYear = request.getAttribute("selectedYear") != null ? String.valueOf(request.getAttribute("selectedYear")) : "";

                List<String> zoneList = (List<String>) request.getAttribute("zoneList");
                List<String> circleList = (List<String>) request.getAttribute("circleList");
                List<String> divisionList = (List<String>) request.getAttribute("divisionList");
                List<String> designationList = (List<String>) request.getAttribute("designationList");
                List<String> dbStatusList = (List<String>) request.getAttribute("dbStatusList");
                List<Map<String, String>> companyBankList = (List<Map<String, String>>) request.getAttribute("companyBankList");
            %>
            <div class="filters-panel mb-2">
                <form id="filterForm" action="pay-register" method="get">
                    <div class="filter-row-nowrap">
                        
                        <!-- 1) Month -->
                        <div class="filter-item-month">
                            <select name="month" id="filterMonth" class="form-select form-select-sm fw-semibold w-100">
                                <option value="">Month</option>
                                <%
                                    String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
                                    for (String m : months) {
                                %>
                                    <option value="<%=m%>" <%= m.equalsIgnoreCase(selMonth) ? "selected" : "" %>><%=m%></option>
                                <% } %>
                            </select>
                        </div>

                        <!-- 2) Year -->
                        <div class="filter-item-year">
                            <select name="year" id="filterYear" class="form-select form-select-sm fw-semibold w-100">
                                <option value="">Year</option>
                                <%
                                    int currYear = java.time.Year.now().getValue();
                                    for (int y = currYear; y >= currYear - 5; y--) {
                                %>
                                    <option value="<%=y%>" <%= String.valueOf(y).equals(selYear) ? "selected" : "" %>><%=y%></option>
                                <% } %>
                            </select>
                        </div>

                        <!-- 3) Cluster -->
                        <div class="filter-item-cluster">
                            <select name="cluster" id="filterCluster" class="form-select form-select-sm fw-semibold w-100">
                                <option value="" <%= "".equals(selCluster) ? "selected" : "" %>>3. All Clusters</option>
                                <option value="8" <%= "8".equals(selCluster) ? "selected" : "" %>>Cluster-8</option>
                                <option value="9" <%= "9".equals(selCluster) ? "selected" : "" %>>Cluster-9</option>
                                <option value="12" <%= "12".equals(selCluster) ? "selected" : "" %>>Cluster-12</option>
                                <option value="5" <%= "5".equals(selCluster) ? "selected" : "" %>>Cluster-5</option>
                            </select>
                        </div>

                        <!-- 4) Zone -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="zoneDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="zoneBtnLabel">4. All Zones</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="zoneDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('zoneCheckbox', true, 'zone')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('zoneCheckbox', false, 'zone')">Deselect</a>
                                    </div>
                                    <%
                                        if (zoneList != null && !zoneList.isEmpty()) {
                                            for (String z : zoneList) {
                                                boolean isChecked = (selZones != null && selZones.contains(z));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="zone" value="<%= z %>" class="form-check-input me-2 zoneCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('zone')">
                                            <span><%= z %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No zones available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 5) Circle -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="circleDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="circleBtnLabel">5. All Circles</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="circleDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('circleCheckbox', true, 'circle')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('circleCheckbox', false, 'circle')">Deselect</a>
                                    </div>
                                    <%
                                        if (circleList != null && !circleList.isEmpty()) {
                                            for (String c : circleList) {
                                                boolean isChecked = (selCircles != null && selCircles.contains(c));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="circle" value="<%= c %>" class="form-check-input me-2 circleCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('circle')">
                                            <span><%= c %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No circles available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 6) Division -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="divisionDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="divisionBtnLabel">6. All Divisions</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="divisionDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('divisionCheckbox', true, 'division')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('divisionCheckbox', false, 'division')">Deselect</a>
                                    </div>
                                    <%
                                        if (divisionList != null && !divisionList.isEmpty()) {
                                            for (String d : divisionList) {
                                                boolean isChecked = (selDivisions != null && selDivisions.contains(d));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="division" value="<%= d %>" class="form-check-input me-2 divisionCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('division')">
                                            <span><%= d %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No divisions available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 7) Designation -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="designationDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="designationBtnLabel">7. All Designations</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="designationDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('designationCheckbox', true, 'designation')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('designationCheckbox', false, 'designation')">Deselect</a>
                                    </div>
                                    <%
                                        if (designationList != null && !designationList.isEmpty()) {
                                            for (String desig : designationList) {
                                                boolean isChecked = (selDesignations != null && selDesignations.contains(desig));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="designation" value="<%= desig %>" class="form-check-input me-2 designationCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('designation')">
                                            <span><%= desig %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No designations available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 8) DB Status Dropdown -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="dbStatusDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="dbStatusBtnLabel">8. All DB Status</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="dbStatusDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('dbStatusCheckbox', true, 'dbStatus')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('dbStatusCheckbox', false, 'dbStatus')">Deselect</a>
                                    </div>
                                    <%
                                        if (dbStatusList != null && !dbStatusList.isEmpty()) {
                                            for (String status : dbStatusList) {
                                                boolean isChecked = (selDbStatuses != null && selDbStatuses.contains(status));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="dbStatus" value="<%= status %>" class="form-check-input me-2 dbStatusCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('dbStatus')">
                                            <span><%= status %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No status available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- Filter & Reset Buttons -->
                        <div class="filter-item-actions ms-auto">
                            <button type="submit" class="btn btn-gradient-primary btn-sm px-2" style="height: 32px;" title="Apply selected filters">
                                <i class="fa fa-filter"></i> Filter
                            </button>
                            <button type="button" class="btn btn-light btn-sm px-2 border" style="height: 32px;" onclick="clearAllFilters()" title="Reset all filters">
                                <i class="fa fa-rotate-right"></i> Reset
                            </button>
                        </div>

                    </div>
                </form>
            </div>

            <!-- Company Bank Details Filter Card -->
            <div class="bank-card p-2 mb-2">
                <div class="row g-2 align-items-center">
                    <div class="col-md-4">
                        <select id="companySelect" class="form-select form-select-sm fw-semibold" onchange="onCompanyChange()">
                            <option value="">-- Select Company --</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <select id="bankSelect" class="form-select form-select-sm fw-semibold" onchange="onBankChange()">
                            <option value="">-- Select Bank --</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <select id="accountNumberSelect" class="form-select form-select-sm fw-semibold">
                            <option value="">-- Select Account No --</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Quick Search & Bulk Paste Action Toolbar -->
            <div class="bulk-selection-bar d-flex flex-wrap align-items-center justify-content-between mb-2 gap-2">
                <div class="d-flex align-items-center gap-2 flex-grow-1" style="max-width: 420px;">
                    <div class="input-group input-group-sm w-100">
                        <span class="input-group-text bg-white border-end-0 py-1"><i class="fa fa-search text-muted"></i></span>
                        <input type="text" id="tableSearch" class="form-control border-start-0 py-1" placeholder="Search Code, Name, Account, Status..." onkeyup="filterTableSearch()">
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <span id="filteredModeBanner" class="filtered-banner" style="display: none;">
                        <i class="fa fa-filter"></i> Showing Selected Only (<span id="filteredSelectedCount">0</span>)
                    </span>
                    <button type="button" class="btn btn-gradient-primary btn-sm py-1 px-3" data-bs-toggle="modal" data-bs-target="#bulkPasteModal">
                        <i class="fa fa-clipboard-list me-1"></i> Paste Employee Codes
                    </button>
                    <button type="button" id="clearSelectionBtn" class="btn btn-light btn-sm py-1 px-2 border" style="display: none;" onclick="clearAllBulkSelection()">
                        <i class="fa fa-times-circle text-danger me-1"></i> Clear Selection (<span id="selectedCountBadge">0</span>)
                    </button>
                </div>
            </div>

            <!-- Export Toolbar -->
            <div class="actions-bar d-flex flex-wrap align-items-center justify-content-between mb-2 py-1 px-3 gap-2">
                <span class="text-muted small fw-semibold" style="font-size: 11.5px;"><i class="fa fa-download me-1"></i> Export Options</span>
                <div class="d-flex flex-wrap gap-2">
                    <button type="button" class="btn btn-gradient-primary btn-sm py-1 px-3" onclick="downloadMaster()">
                        <i class="fa fa-file-excel"></i> Download Master
                    </button>
                    <button type="button" class="btn btn-gradient-bom btn-sm py-1 px-3" onclick="exportBomTxtFormat()">
                        <i class="fa fa-university"></i> BOM Format
                    </button>
                    <button type="button" class="btn btn-gradient-icici btn-sm py-1 px-3" onclick="exportIciciFormat()">
                        <i class="fa fa-university"></i> ICICI Format
                    </button>
                    <button type="button" class="btn btn-gradient-success btn-sm py-1 px-3" onclick="exportExcel()">
                        <i class="fa fa-file-excel"></i> Excel
                    </button>
                    <button type="button" class="btn btn-gradient-info btn-sm py-1 px-3" onclick="exportCsv()">
                        <i class="fa fa-file-csv"></i> CSV
                    </button>
                    <button type="button" class="btn btn-dark btn-sm py-1 px-3" onclick="window.print()">
                        <i class="fa fa-print"></i> Print
                    </button>
                </div>
            </div>

            <!-- Main Data Table with Code Hyperlinks & Initial Load Guard -->
            <%
                List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
                
                String[][] displayColumns = {
                    {"DB_STATUS", "DB Status"},
                    {"CODE", "Code"},
                    {"EMP_NAME", "Name"},
                    {"DOJ", "DOJ"},
                    {"BANK_NAME", "Bank Name"},
                    {"BANK_BRANCH", "Bank Branch"},
                    {"IFSC", "IFSC"},
                    {"ACCOUNT_NO", "A/c No"},
                    {"AADHAAR", "Aadhaar"},
                    {"UAN", "UAN"},
                    {"ESI_NO", "ESI No"},
                    {"BRANCH", "Zone"},
                    {"CATEGORY", "Circle"},
                    {"DESIGNATION", "Designation"},
                    {"DEPARTMENT", "Division"},
                    {"MOBILE", "Mobile"},
                    {"FATHER_HUSBAND_NAME", "Father Name"},
                    {"TOTAL_DAYS", "Total Days"},
                    {"WK_OFF", "Wk Off"},
                    {"HOLIDAY", "Holiday"},
                    {"MAX_WORK_DAYS", "Max Work Days"},
                    {"MAX_PAYABLE_DAYS", "Max Payable Days"},
                    {"ABS_LWP", "Abs./LWP"},
                    {"NET_PAID_DAYS_ACT", "NET PAID DAYS [Actual]"},
                    {"BASIC_SALARY", "BASIC SALARY"},
                    {"CONVEYANCE", "CONVEYANCE ALLOWANCE"},
                    {"HRA", "HRA"},
                    {"GROSS_EARNING", "Gross Earning"},
                    {"PF", "PF"},
                    {"ESI", "ESI"},
                    {"PROFESSIONAL_TAX", "PROFESSIONAL TAX"},
                    {"GROSS_DEDUCTION", "Gross Deduction"},
                    {"NET_AMT_PAYABLE", "Net Amt Payable"},
                    {"TOTAL_TCS_ACT", "TOTAL TCS"},
                    {"GROSS_EARNING_2", "GROSS EARNING"},
                    {"PENSION_CONT", "PENSION CONT."},
                    {"EPF_DIFF", "EPF DIFF."},
                    {"EMPLOYER_PF_CONT", "TOTAL EMPLOYER'S PF CONT."},
                    {"EMPLOYER_ESI_CONT", "EMPLOYER'S ESI CONT."},
                    {"PF_EDLI_CHARGES", "PF EDLI CHARGES"},
                    {"TOTAL_CTC_SALARY", "TOTAL CTC SALARY"},
                    {"SIGNATURE", "Sign."},
                    {"REMARK", "Remark"},
                    {"CLUSTER_NAME", "Cluster name"},
                    {"PAY_MONTH", "pay month"},
                    {"PAY_YEAR", "pay year"}
                };
            %>
            <c:choose>
                <c:when test="${not empty records}">
                    <div class="table-responsive">
                        <table id="payRegisterTable" class="table table-bordered-custom table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th style="width: 40px;" class="text-center">
                                        <input type="checkbox" id="selectAllRows" class="form-check-input" onchange="toggleSelectAllRows(this)" title="Select all on current page">
                                    </th>
                                    <th style="width: 80px;" class="text-center">Action</th>
                                    <% for (String[] col : displayColumns) { %>
                                        <th data-col-name="<%= col[0] %>"><%= col[1] %></th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Map<String, Object> record : records) {
                                        String dbStatus = (record.get("DB_STATUS") != null) ? record.get("DB_STATUS").toString().trim() : "";
                                        String empCodeVal = (record.get("CODE") != null) ? record.get("CODE").toString().trim() : "";
                                %>
                                    <tr class="data-row"
                                        data-db-status="<%= dbStatus %>" 
                                        data-emp-code="<%= empCodeVal %>"
                                        data-emp-name="<%= record.get("EMP_NAME") != null ? record.get("EMP_NAME").toString() : "" %>"
                                        data-doj="<%= record.get("DOJ") != null ? record.get("DOJ").toString() : "" %>"
                                        data-uan="<%= record.get("UAN") != null ? record.get("UAN").toString() : "" %>"
                                        data-esi="<%= record.get("ESI_NO") != null ? record.get("ESI_NO").toString() : "" %>"
                                        data-branch="<%= record.get("BRANCH") != null ? record.get("BRANCH").toString() : "" %>"
                                        data-category="<%= record.get("CATEGORY") != null ? record.get("CATEGORY").toString() : "" %>"
                                        data-designation="<%= record.get("DESIGNATION") != null ? record.get("DESIGNATION").toString() : "" %>"
                                        data-department="<%= record.get("DEPARTMENT") != null ? record.get("DEPARTMENT").toString() : "" %>"
                                        data-mobile="<%= record.get("MOBILE") != null ? record.get("MOBILE").toString() : "" %>"
                                        data-ifsc="<%= record.get("IFSC") != null ? record.get("IFSC").toString() : "" %>"
                                        data-account="<%= record.get("ACCOUNT_NO") != null ? record.get("ACCOUNT_NO").toString() : "" %>"
                                        data-total-billed="<%= record.get("TOTAL_BILLED_ACT") != null ? record.get("TOTAL_BILLED_ACT").toString() : "0" %>"
                                        data-manual-billed="<%= record.get("MANNUAL_BILLED_ACT") != null ? record.get("MANNUAL_BILLED_ACT").toString() : "0" %>"
                                        data-probe-billed="<%= record.get("PROBE_BILLED_ACT") != null ? record.get("PROBE_BILLED_ACT").toString() : "0" %>"
                                        data-auto-ocr="<%= record.get("AUTO_OCR_ACT") != null ? record.get("AUTO_OCR_ACT").toString() : "0" %>"
                                        data-ctc1="<%= record.get("CTC1_ACT") != null ? record.get("CTC1_ACT").toString() : "0" %>"
                                        data-total-tcs="<%= record.get("TOTAL_TCS_ACT") != null ? record.get("TOTAL_TCS_ACT").toString() : "0" %>"
                                        data-ctc="<%= record.get("CTC_ACT") != null ? record.get("CTC_ACT").toString() : "0" %>"
                                        data-gross-earning="<%= record.get("GROSS_EARNING") != null ? record.get("GROSS_EARNING").toString() : "0" %>"
                                        data-pf="<%= record.get("PF") != null ? record.get("PF").toString() : "0" %>"
                                        data-esi-amt="<%= record.get("ESI") != null ? record.get("ESI").toString() : "0" %>"
                                        data-pt="<%= record.get("PROFESSIONAL_TAX") != null ? record.get("PROFESSIONAL_TAX").toString() : "0" %>"
                                        data-gross-deduction="<%= record.get("GROSS_DEDUCTION") != null ? record.get("GROSS_DEDUCTION").toString() : "0" %>"
                                        data-net-payable="<%= record.get("NET_AMT_PAYABLE") != null ? record.get("NET_AMT_PAYABLE").toString() : "0" %>"
                                        data-pension="<%= record.get("PENSION_CONT") != null ? record.get("PENSION_CONT").toString() : "0" %>"
                                        data-epf-diff="<%= record.get("EPF_DIFF") != null ? record.get("EPF_DIFF").toString() : "0" %>"
                                        data-emp-pf-cont="<%= record.get("EMPLOYER_PF_CONT") != null ? record.get("EMPLOYER_PF_CONT").toString() : "0" %>"
                                        data-emp-esi-cont="<%= record.get("EMPLOYER_ESI_CONT") != null ? record.get("EMPLOYER_ESI_CONT").toString() : "0" %>"
                                        data-pf-edli="<%= record.get("PF_EDLI_CHARGES") != null ? record.get("PF_EDLI_CHARGES").toString() : "0" %>"
                                        data-total-ctc-salary="<%= record.get("TOTAL_CTC_SALARY") != null ? record.get("TOTAL_CTC_SALARY").toString() : "0" %>"
                                        data-pay-month="<%= record.get("PAY_MONTH") != null ? record.get("PAY_MONTH").toString() : "" %>"
                                        data-pay-year="<%= record.get("PAY_YEAR") != null ? record.get("PAY_YEAR").toString() : "" %>">

                                        <td class="text-center">
                                            <input type="checkbox" class="form-check-input row-select-chk" value="<%= empCodeVal %>" onchange="onRowCheckboxChanged(this)">
                                        </td>
                                        <td class="text-center">
                                            <div class="dropdown">
                                                <button class="btn btn-action-pill dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    <i class="fa fa-sliders me-1"></i> Action
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end action-dropdown-menu shadow-lg border-0">
                                                    <li>
                                                        <a class="dropdown-item action-item-allow" href="javascript:void(0)" onclick="updateRecordStatus('<%= empCodeVal %>', 'Allow', this)">
                                                            <span class="icon-circle bg-success-subtle text-success"><i class="fa fa-check"></i></span>
                                                            <span class="fw-semibold">Allow</span>
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a class="dropdown-item action-item-hold" href="javascript:void(0)" onclick="updateRecordStatus('<%= empCodeVal %>', 'Hold', this)">
                                                            <span class="icon-circle bg-danger-subtle text-danger"><i class="fa fa-pause"></i></span>
                                                            <span class="fw-semibold">Hold</span>
                                                        </a>
                                                    </li>
                                                    <li><hr class="dropdown-divider my-1"></li>
                                                    <li>
                                                        <a class="dropdown-item action-item-paid" href="javascript:void(0)" onclick="updateRecordStatus('<%= empCodeVal %>', 'Paid', this)">
                                                            <span class="icon-circle bg-primary-subtle text-primary"><i class="fa-solid fa-indian-rupee-sign"></i></span>
                                                            <span class="fw-semibold">Mark Paid</span>
                                                        </a>
                                                    </li>
                                                </ul>
                                            </div>
                                        </td>
                                        <%
                                            for (String[] col : displayColumns) {
                                                String colKey = col[0];
                                                Object val = record.get(colKey);
                                                String strVal = (val != null) ? val.toString() : "";
                                                boolean isCode = "CODE".equalsIgnoreCase(colKey);
                                                boolean isStatus = "DB_STATUS".equalsIgnoreCase(colKey);
                                        %>
                                            <td>
                                                <% if (isCode) { %>
                                                    <a href="javascript:void(0);" class="code-badge text-decoration-none" onclick="openEmployeeDetailsModal(this)" title="Click to view full employee details">
                                                        <i class="fa fa-user-circle me-1 text-primary"></i><%= strVal %>
                                                    </a>
                                                <% } else if (isStatus) { 
                                                    String badgeClass = "status-badge-other";
                                                    if ("allow".equalsIgnoreCase(strVal)) badgeClass = "status-badge-allow";
                                                    else if ("left".equalsIgnoreCase(strVal) || "hold".equalsIgnoreCase(strVal)) badgeClass = "status-badge-hold";
                                                    else if ("paid".equalsIgnoreCase(strVal)) badgeClass = "status-badge-paid";
                                                %>
                                                    <span class="status-badge <%= badgeClass %>"><%= strVal.isEmpty() ? "-" : strVal %></span>
                                                <% } else { %>
                                                    <%= strVal %>
                                                <% } %>
                                            </td>
                                        <% } %>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination Section -->
                    <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-3">
                        <div class="d-flex align-items-center gap-2">
                            <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                            <span id="pageInfo" class="badge bg-white text-dark border px-3 py-1" style="font-size: 11px;">Page 1 of 1</span>
                            <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
                        </div>
                        <div>
                            <span id="totalBadge" class="badge-total">Total Records: <%= records != null ? records.size() : 0 %></span>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5 my-3 bg-white rounded-3 border">
                        <i class="fa fa-filter fa-3x text-primary opacity-50 mb-3"></i>
                        <h5 class="fw-bold text-dark">Please Select Filters to View Report</h5>
                        <p class="text-muted small mb-0">Use the filter panel above to select Month, Year, Cluster, and criteria, then click <strong>Filter</strong>.</p>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>

    <!-- Bulk Paste Modal Popup -->
    <div class="modal fade" id="bulkPasteModal" tabindex="-1" aria-labelledby="bulkPasteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg border-0" style="border-radius: 12px;">
                <div class="modal-header py-2 px-3 border-bottom">
                    <h5 class="modal-title fw-bold" id="bulkPasteModalLabel" style="font-size: 14px; color: #1e293b;">
                        <i class="fa fa-clipboard text-primary me-2"></i>Bulk Select by Employee Codes
                    </h5>
                    <button type="button" class="btn-close" data-bs-toggle="modal" data-bs-target="#bulkPasteModal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-3">
                    <label for="bulkEmployeeCodesInput" class="form-label text-muted small fw-semibold mb-1" style="font-size: 11.5px;">
                        Paste Employee Codes (separated by newlines, commas, tabs, or spaces):
                    </label>
                    <textarea id="bulkEmployeeCodesInput" class="form-control font-monospace" rows="7" placeholder="EMP001&#10;EMP002, EMP003&#10;EMP004	EMP005" style="font-size: 12px;"></textarea>
                    <div id="bulkPasteFeedback" class="small mt-2" style="font-size: 11px; display: none;"></div>
                </div>
                <div class="modal-footer py-2 px-3 border-top">
                    <button type="button" class="btn btn-light btn-sm border" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-gradient-primary btn-sm px-3" onclick="applyBulkPastedCodes()">
                        <i class="fa fa-check me-1"></i> Apply Selection
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Employee Detailed View Modal with Distinct Status Header & Colors -->
    <div class="modal fade" id="employeeDetailsModal" tabindex="-1" aria-labelledby="employeeDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content shadow-lg border-0" style="border-radius: 14px;">
                <div class="modal-header py-3 px-4 bg-dark text-white" style="border-top-left-radius: 14px; border-top-right-radius: 14px;">
                    <h5 class="modal-title fw-bold" id="employeeDetailsModalLabel" style="font-size: 16px;">
                        <i class="fa fa-id-card text-info me-2"></i> Employee Detailed Profile &mdash; <span id="modalMonthYearHeader" class="text-warning"></span>
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4 bg-light">
                    <div class="row g-3">
                        
                        <!-- 1) Personal Details Card (Blue Theme) -->
                        <div class="col-lg-4">
                            <div class="p-3 modal-card-personal h-100 shadow-sm">
                                <div class="modal-section-title text-primary"><i class="fa fa-user me-2"></i>Personal Details</div>
                                <div class="d-flex flex-column gap-2" id="personalContainer"></div>
                            </div>
                        </div>

                        <!-- 2) Billing Details Card (Green Theme) -->
                        <div class="col-lg-4">
                            <div class="p-3 modal-card-billing h-100 shadow-sm">
                                <div class="modal-section-title text-success"><i class="fa fa-file-invoice-dollar me-2"></i>Billing Details</div>
                                <div class="d-flex flex-column gap-2" id="billingContainer"></div>
                            </div>
                        </div>

                        <!-- 3) Salary Details Card (Dynamic Color Theme based on db_status) -->
                        <div class="col-lg-4">
                            <div class="p-3 h-100 shadow-sm" id="salaryCardWrapper">
                                <div class="modal-section-title" id="salaryTitleContainer"><i class="fa fa-wallet me-2"></i><span id="salaryTitleText">Salary Details</span></div>
                                <div class="d-flex flex-column gap-2" id="salaryContainer"></div>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="modal-footer py-2 px-4 border-top bg-white" style="border-bottom-left-radius: 14px; border-bottom-right-radius: 14px;">
                    <button type="button" class="btn btn-secondary btn-sm px-4" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Pass Data to JavaScript -->
    <script>
        var selectedCluster = "<%= selCluster %>";
        var selectedMonth = "<%= selMonth %>";
        var selectedYear = "<%= selYear %>";

        var rawBankDetails = [];
        <%
            if (companyBankList != null) {
                for (Map<String, String> b : companyBankList) {
        %>
            rawBankDetails.push({
                company: "<%= b.get("company_name").replace("\"", "\\\"") %>",
                bank: "<%= b.get("bank").replace("\"", "\\\"") %>",
                account: "<%= b.get("account_number").replace("\"", "\\\"") %>"
            });
        <%
                }
            }
        %>

        function openEmployeeDetailsModal(linkElem) {
            var row = linkElem.closest('tr');
            if (!row) return;

            var m = row.getAttribute('data-pay-month') || selectedMonth || '';
            var y = row.getAttribute('data-pay-year') || selectedYear || '';
            var monthYearStr = (m && y) ? (m + ' / ' + y) : (m || y || 'Selected Period');
            document.getElementById('modalMonthYearHeader').textContent = '[' + monthYearStr + ']';

            var dbStatus = (row.getAttribute('data-db-status') || '').trim().toUpperCase();
            if (!dbStatus) dbStatus = 'UNKNOWN';

            var salaryCardWrapper = document.getElementById('salaryCardWrapper');
            var salaryTitleText = document.getElementById('salaryTitleText');
            var salaryTitleContainer = document.getElementById('salaryTitleContainer');

            salaryTitleText.textContent = 'Salary Details (' + dbStatus + ')';

            if (dbStatus === 'PAID') {
                salaryCardWrapper.className = 'p-3 modal-card-salary-paid h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title text-success';
            } else if (dbStatus === 'ALLOW') {
                salaryCardWrapper.className = 'p-3 modal-card-salary-allow h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title text-danger'; // Red theme for Allow
            } else if (dbStatus === 'HOLD') {
                salaryCardWrapper.className = 'p-3 modal-card-salary-hold h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title';
                salaryTitleContainer.style.color = '#854d0e'; // Brown theme for Hold
            } else {
                salaryCardWrapper.className = 'p-3 modal-card-salary-hold h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title text-secondary';
            }

            var personalFields = [
                { label: 'Code', val: row.getAttribute('data-emp-code') },
                { label: 'Name', val: row.getAttribute('data-emp-name') },
                { label: 'DOJ', val: row.getAttribute('data-doj') },
                { label: 'UAN', val: row.getAttribute('data-uan') },
                { label: 'ESI No', val: row.getAttribute('data-esi') },
                { label: 'Branch', val: row.getAttribute('data-branch') },
                { label: 'Category', val: row.getAttribute('data-category') },
                { label: 'Designation', val: row.getAttribute('data-designation') },
                { label: 'Department', val: row.getAttribute('data-department') },
                { label: 'Mobile', val: row.getAttribute('data-mobile') },
                { label: 'IFSC', val: row.getAttribute('data-ifsc') },
                { label: 'A/c No', val: row.getAttribute('data-account') }
            ];

            var billingFields = [
                { label: 'Total Billed [Actual]', val: row.getAttribute('data-total-billed') },
                { label: 'Manual Billed [Actual]', val: row.getAttribute('data-manual-billed') },
                { label: 'Probe Billed [Actual]', val: row.getAttribute('data-probe-billed') },
                { label: 'Auto OCR [Actual]', val: row.getAttribute('data-auto-ocr') }
            ];

            var salaryFields = [
                { label: 'CTC-1 [Actual]', val: row.getAttribute('data-ctc1') },
                { label: 'Total TCS [Actual]', val: row.getAttribute('data-total-tcs') },
                { label: 'CTC [Actual]', val: row.getAttribute('data-ctc') },
                { label: 'Gross Earning', val: row.getAttribute('data-gross-earning') },
                { label: 'PF', val: row.getAttribute('data-pf') },
                { label: 'ESI', val: row.getAttribute('data-esi-amt') },
                { label: 'Professional Tax', val: row.getAttribute('data-pt') },
                { label: 'Gross Deduction', val: row.getAttribute('data-gross-deduction') },
                { label: 'Net Amt Payable', val: row.getAttribute('data-net-payable') },
                { label: 'Pension Cont.', val: row.getAttribute('data-pension') },
                { label: 'EPF Diff.', val: row.getAttribute('data-epf-diff') },
                { label: 'Total Employer\'s PF Cont.', val: row.getAttribute('data-emp-pf-cont') },
                { label: 'Employer\'s ESI Cont.', val: row.getAttribute('data-emp-esi-cont') },
                { label: 'PF EDLI Charges', val: row.getAttribute('data-pf-edli') },
                { label: 'Total CTC Salary', val: row.getAttribute('data-total-ctc-salary') }
            ];

            function populateSection(containerId, fields, isSalaryCard) {
                var container = document.getElementById(containerId);
                container.innerHTML = '';
                fields.forEach(function(item) {
                    var box = document.createElement('div');
                    box.className = 'p-2 bg-white border rounded shadow-xs d-flex justify-content-between align-items-center';

                    var labelSpan = document.createElement('span');
                    labelSpan.className = 'fw-bold small';
                    labelSpan.style.fontSize = '11px';
                    
                    var valSpan = document.createElement('span');
                    valSpan.className = 'fw-bold small';
                    valSpan.style.fontSize = '11.5px';

                    if (isSalaryCard) {
                        if (dbStatus === 'PAID') {
                            labelSpan.style.color = '#15803d';
                            valSpan.style.color = '#16a34a';
                        } else if (dbStatus === 'ALLOW') {
                            labelSpan.style.color = '#991b1b'; // Red label for Allow
                            valSpan.style.color = '#b91c1c';   // Red value for Allow
                        } else if (dbStatus === 'HOLD') {
                            labelSpan.style.color = '#854d0e'; // Brown label for Hold
                            valSpan.style.color = '#713f12';   // Brown value for Hold
                        } else {
                            labelSpan.className += ' text-muted';
                            valSpan.className += ' text-dark';
                        }
                    } else {
                        labelSpan.className += ' text-muted';
                        valSpan.className += ' text-dark';
                    }

                    labelSpan.textContent = item.label;
                    valSpan.textContent = (item.val && item.val !== 'null' && item.val !== '') ? item.val : '-';

                    box.appendChild(labelSpan);
                    box.appendChild(valSpan);
                    container.appendChild(box);
                });
            }

            populateSection('personalContainer', personalFields, false);
            populateSection('billingContainer', billingFields, false);
            populateSection('salaryContainer', salaryFields, true);

            var modal = new bootstrap.Modal(document.getElementById('employeeDetailsModal'));
            modal.show();
        }

        function toggleSelectAll(className, selectAll, type) {
            var checkboxes = document.querySelectorAll('.' + className);
            checkboxes.forEach(function(cb) {
                cb.checked = selectAll;
            });
            updateDropdownButtonLabel(type);
        }

        function onCheckboxSelectionChanged(type) {
            updateDropdownButtonLabel(type);
        }

        function updateDropdownButtonLabel(type) {
            var checkboxes = document.querySelectorAll('.' + type + 'Checkbox:checked');
            var labelSpan = document.getElementById(type + 'BtnLabel');
            if (!labelSpan) return;

            var defaultPrefix = type === 'zone' ? '4. All Zones' 
                              : (type === 'circle' ? '5. All Circles' 
                              : (type === 'division' ? '6. All Divisions' 
                              : (type === 'designation' ? '7. All Designations' 
                              : '8. All DB Status')));
            var pluralName = type === 'zone' ? 'Zones' 
                           : (type === 'circle' ? 'Circles' 
                           : (type === 'division' ? 'Divisions' 
                           : (type === 'designation' ? 'Designations' 
                           : 'Statuses')));

            if (checkboxes.length === 0) {
                labelSpan.textContent = defaultPrefix;
            } else if (checkboxes.length === 1) {
                labelSpan.textContent = checkboxes[0].value;
            } else {
                labelSpan.textContent = checkboxes.length + ' ' + pluralName + ' Selected';
            }
        }
    </script>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function initCompanyBankDropdowns() {
            var companySelect = document.getElementById('companySelect');
            if (!companySelect) return;

            var companies = Array.from(new Set(rawBankDetails.map(function(item) { return item.company; }))).filter(Boolean);
            companies.sort();

            companySelect.innerHTML = '<option value="">-- Select Company --</option>';
            companies.forEach(function(c) {
                var opt = document.createElement('option');
                opt.value = c;
                opt.textContent = c;
                companySelect.appendChild(opt);
            });

            if (companies.length > 0) {
                var defaultCompany = companies.find(function(c) {
                    return c.trim().toUpperCase() === "VIIPL" || c.trim().toUpperCase().includes("VIIPL");
                }) || companies[0];

                companySelect.value = defaultCompany;
                onCompanyChange();
            }
        }

        function onCompanyChange() {
            var selectedCompany = document.getElementById('companySelect').value;
            var bankSelect = document.getElementById('bankSelect');
            var accountSelect = document.getElementById('accountNumberSelect');

            bankSelect.innerHTML = '<option value="">-- Select Bank --</option>';
            accountSelect.innerHTML = '<option value="">-- Select Account No --</option>';

            if (!selectedCompany) return;

            var filtered = rawBankDetails.filter(function(item) { return item.company === selectedCompany; });
            var banks = Array.from(new Set(filtered.map(function(item) { return item.bank; }))).filter(Boolean);
            banks.sort();

            banks.forEach(function(b) {
                var opt = document.createElement('option');
                opt.value = b;
                opt.textContent = b;
                bankSelect.appendChild(opt);
            });

            if (banks.length > 0) {
                bankSelect.value = banks[0];
                onBankChange();
            }
        }

        function onBankChange() {
            var selectedCompany = document.getElementById('companySelect').value;
            var selectedBank = document.getElementById('bankSelect').value;
            var accountSelect = document.getElementById('accountNumberSelect');

            accountSelect.innerHTML = '<option value="">-- Select Account No --</option>';

            if (!selectedCompany || !selectedBank) return;

            var filtered = rawBankDetails.filter(function(item) {
                return item.company === selectedCompany && item.bank === selectedBank;
            });

            var accounts = Array.from(new Set(filtered.map(function(item) { return item.account; }))).filter(Boolean);
            accounts.sort();

            accounts.forEach(function(acc) {
                var opt = document.createElement('option');
                opt.value = acc;
                opt.textContent = acc;
                accountSelect.appendChild(opt);
            });

            if (accounts.length > 0) {
                accountSelect.value = accounts[0];
            }
        }

        function getValidatedDebitAccount(expectedBankKeyword, bankDisplayName) {
            var companySelect = document.getElementById('companySelect');
            var bankSelect = document.getElementById('bankSelect');
            var accountSelect = document.getElementById('accountNumberSelect');

            if (!companySelect || !companySelect.value) {
                alert("Please select a Company Name from the Company Debit Account card.");
                if (companySelect) companySelect.focus();
                return null;
            }

            if (!bankSelect || !bankSelect.value) {
                alert("Please select " + bankDisplayName + " from the Bank dropdown.");
                if (bankSelect) bankSelect.focus();
                return null;
            }

            if (expectedBankKeyword) {
                var selectedBankUpper = bankSelect.value.toUpperCase();
                var matchesExpected = false;

                if (expectedBankKeyword === "BOM") {
                    matchesExpected = selectedBankUpper.includes("BOM") || selectedBankUpper.includes("MAHARASHTRA");
                } else if (expectedBankKeyword === "ICICI") {
                    matchesExpected = selectedBankUpper.includes("ICICI");
                }

                if (!matchesExpected) {
                    alert("Please select a " + bankDisplayName + " account from the Company Debit Account card (currently selected: " + bankSelect.value + ").");
                    bankSelect.focus();
                    return null;
                }
            }

            if (!accountSelect || !accountSelect.value || accountSelect.value.trim() === '') {
                alert("Please select an Account Number for " + bankDisplayName + ".");
                if (accountSelect) accountSelect.focus();
                return null;
            }

            return accountSelect.value.trim();
        }

        function updateRecordStatus(empCode, newStatus, triggerElem) {
            if (!empCode) return;

            var row = triggerElem.closest('tr');
            var btn = row.querySelector('.dropdown-toggle');
            var originalBtnText = btn.innerHTML;
            
            btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i>';
            btn.disabled = true;

            var params = new URLSearchParams();
            params.append('action', 'updateRowStatus');
            params.append('empCode', empCode);
            params.append('newStatus', newStatus);
            params.append('cluster', selectedCluster || '');
            params.append('month', selectedMonth || '');
            params.append('year', selectedYear || '');

            fetch('pay-register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: params.toString()
            })
            .then(function(res) {
                if (!res.ok) throw new Error("HTTP error " + res.status);
                return res.json();
            })
            .then(function(data) {
                btn.innerHTML = originalBtnText;
                btn.disabled = false;

                if (data.success) {
                    row.setAttribute('data-db-status', newStatus);

                    var colIndexMap = {};
                    var ths = document.querySelectorAll('#payRegisterTable thead th');
                    for (var c = 0; c < ths.length; c++) {
                        var colName = ths[c].getAttribute('data-col-name');
                        if (colName) {
                            colIndexMap[colName.toUpperCase()] = c;
                        }
                    }

                    var dbStatusColIdx = colIndexMap['DB_STATUS'];
                    if (dbStatusColIdx !== undefined && row.cells[dbStatusColIdx]) {
                        var badgeClass = 'status-badge-other';
                        var stLower = newStatus.toLowerCase();
                        if (stLower === 'allow') badgeClass = 'status-badge-allow';
                        else if (stLower === 'hold' || stLower === 'left') badgeClass = 'status-badge-hold';
                        else if (stLower === 'paid') badgeClass = 'status-badge-paid';

                        row.cells[dbStatusColIdx].innerHTML = '<span class="status-badge ' + badgeClass + '">' + newStatus + '</span>';
                    }
                } else {
                    alert('Update failed: ' + (data.message || 'Unknown error'));
                }
            })
            .catch(function(err) {
                btn.innerHTML = originalBtnText;
                btn.disabled = false;
                console.error('Status update error:', err);
                alert('Failed to update status: ' + err.message);
            });
        }

        var selectedEmployeeCodesSet = new Set();

        function applyBulkPastedCodes() {
            var textarea = document.getElementById('bulkEmployeeCodesInput');
            var feedback = document.getElementById('bulkPasteFeedback');
            var rawText = (textarea ? textarea.value : '').trim();

            if (!rawText) {
                if (feedback) {
                    feedback.className = 'small text-danger mt-2';
                    feedback.textContent = 'Please paste at least one employee code.';
                    feedback.style.display = 'block';
                }
                return;
            }

            var parsedTokens = rawText
                .split(/[\r\n,\t\s]+/)
                .map(function(code) { return code.trim().toUpperCase(); })
                .filter(function(code) { return code.length > 0; });

            if (parsedTokens.length === 0) {
                if (feedback) {
                    feedback.className = 'small text-danger mt-2';
                    feedback.textContent = 'No valid employee codes found.';
                    feedback.style.display = 'block';
                }
                return;
            }

            var inputCodesSet = new Set(parsedTokens);
            var matchedCount = 0;
            var rows = document.querySelectorAll('#payRegisterTable tbody tr');

            selectedEmployeeCodesSet.clear();

            rows.forEach(function(row) {
                var empCode = (row.getAttribute('data-emp-code') || '').trim().toUpperCase();
                var chk = row.querySelector('.row-select-chk');

                if (empCode && inputCodesSet.has(empCode)) {
                    selectedEmployeeCodesSet.add(empCode);
                    if (chk) chk.checked = true;
                    row.classList.add('row-selected');
                    matchedCount++;
                } else {
                    if (chk) chk.checked = false;
                    row.classList.remove('row-selected');
                }
            });

            currentPage = 1;
            filterTableRows();

            var modalEl = document.getElementById('bulkPasteModal');
            var modalInstance = bootstrap.Modal.getInstance(modalEl);
            if (modalInstance) {
                modalInstance.hide();
            }

            var unmatchedCount = inputCodesSet.size - matchedCount;
            var summaryMsg = "Selected " + matchedCount + " of " + inputCodesSet.size + " pasted employee(s).";
            if (unmatchedCount > 0) {
                summaryMsg += " (" + unmatchedCount + " code(s) were not found in the currently loaded table).";
            }
            alert(summaryMsg);
        }

        function onRowCheckboxChanged(checkboxElem) {
            var row = checkboxElem.closest('tr');
            var empCode = (row.getAttribute('data-emp-code') || '').trim().toUpperCase();

            if (checkboxElem.checked) {
                if (empCode) selectedEmployeeCodesSet.add(empCode);
                row.classList.add('row-selected');
            } else {
                if (empCode) selectedEmployeeCodesSet.delete(empCode);
                row.classList.remove('row-selected');
            }

            filterTableRows();
        }

        function toggleSelectAllRows(masterCheckbox) {
            var rows = document.querySelectorAll('#payRegisterTable tbody tr');
            rows.forEach(function(row) {
                if (row.dataset.matched !== '0' && row.style.display !== 'none') {
                    var chk = row.querySelector('.row-select-chk');
                    var empCode = (row.getAttribute('data-emp-code') || '').trim().toUpperCase();
                    if (chk) {
                        chk.checked = masterCheckbox.checked;
                        if (masterCheckbox.checked) {
                            if (empCode) selectedEmployeeCodesSet.add(empCode);
                            row.classList.add('row-selected');
                        } else {
                            if (empCode) selectedEmployeeCodesSet.delete(empCode);
                            row.classList.remove('row-selected');
                        }
                    }
                }
            });
            filterTableRows();
        }

        function updateSelectAllState() {
            var visibleRows = Array.from(document.querySelectorAll('#payRegisterTable tbody tr')).filter(function(r) {
                return r.dataset.matched !== '0' && r.style.display !== 'none';
            });
            var activeCheckboxes = visibleRows.map(function(r) { return r.querySelector('.row-select-chk'); }).filter(Boolean);
            var checkedBoxes = activeCheckboxes.filter(function(chk) { return chk.checked; });
            var selectAll = document.getElementById('selectAllRows');
            
            if (selectAll && activeCheckboxes.length > 0) {
                selectAll.checked = activeCheckboxes.length === checkedBoxes.length;
                selectAll.indeterminate = checkedBoxes.length > 0 && checkedBoxes.length < activeCheckboxes.length;
            } else if (selectAll) {
                selectAll.checked = false;
                selectAll.indeterminate = false;
            }
        }

        function updateBulkSelectionUI() {
            var clearBtn = document.getElementById('clearSelectionBtn');
            var badge = document.getElementById('selectedCountBadge');
            var banner = document.getElementById('filteredModeBanner');
            var bannerCount = document.getElementById('filteredSelectedCount');
            var count = selectedEmployeeCodesSet.size;

            if (badge) badge.textContent = count;
            if (bannerCount) bannerCount.textContent = count;

            if (count > 0) {
                if (clearBtn) clearBtn.style.display = 'inline-flex';
                if (banner) banner.style.display = 'inline-flex';
            } else {
                if (clearBtn) clearBtn.style.display = 'none';
                if (banner) banner.style.display = 'none';
            }
        }

        function clearAllBulkSelection() {
            selectedEmployeeCodesSet.clear();
            var rows = document.querySelectorAll('#payRegisterTable tbody tr');
            rows.forEach(function(row) {
                var chk = row.querySelector('.row-select-chk');
                if (chk) chk.checked = false;
                row.classList.remove('row-selected');
            });
            var textarea = document.getElementById('bulkEmployeeCodesInput');
            if (textarea) textarea.value = '';
            var feedback = document.getElementById('bulkPasteFeedback');
            if (feedback) feedback.style.display = 'none';

            currentPage = 1;
            filterTableRows();
        }

        function filterTableRows() {
            var query = (document.getElementById('tableSearch') ? document.getElementById('tableSearch').value : '').toLowerCase().trim();
            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) return;

            var rows = table.tBodies[0].rows;
            var hasActiveSelection = selectedEmployeeCodesSet.size > 0;

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                var empCode = (r.getAttribute('data-emp-code') || '').trim().toUpperCase();
                var text = (r.innerText || r.textContent).toLowerCase();

                var matchesSearch = (query === '' || text.indexOf(query) > -1);
                var matchesSelection = (!hasActiveSelection || selectedEmployeeCodesSet.has(empCode));

                r.dataset.matched = (matchesSearch && matchesSelection) ? '1' : '0';
            }

            updateBulkSelectionUI();
            updatePagination();
        }

        function filterTableSearch() {
            currentPage = 1;
            filterTableRows();
        }

        function getSelectedOrVisibleRows() {
            var allRows = Array.from(document.querySelectorAll('#payRegisterTable tbody tr'));

            if (selectedEmployeeCodesSet.size > 0) {
                return allRows.filter(function(r) {
                    var empCode = (r.getAttribute('data-emp-code') || '').trim().toUpperCase();
                    return selectedEmployeeCodesSet.has(empCode) && r.dataset.matched !== '0';
                });
            }

            var checkedRows = allRows.filter(function(r) {
                var chk = r.querySelector('.row-select-chk');
                return chk && chk.checked && r.dataset.matched !== '0';
            });

            if (checkedRows.length > 0) {
                return checkedRows;
            }

            return allRows.filter(function(r) {
                return r.dataset.matched !== '0';
            });
        }

        var currentPage = 1;
        var pageSize = 50;
        var totalPages = 1;

        function updatePagination() {
            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) return;

            var rows = table.tBodies[0].rows;
            var matched = [];
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].dataset.matched !== '0') matched.push(rows[i]);
            }

            totalPages = Math.max(1, Math.ceil(matched.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            for (var i = 0; i < rows.length; i++) rows[i].style.display = 'none';

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(matched.length, start + pageSize);
            for (var j = start; j < end; j++) matched[j].style.display = '';

            var pageInfo = document.getElementById('pageInfo');
            var totalBadge = document.getElementById('totalBadge');
            if (pageInfo) pageInfo.textContent = 'Page ' + currentPage + ' of ' + totalPages;
            if (totalBadge) totalBadge.textContent = 'Total Records: ' + matched.length;

            updateSelectAllState();
        }

        function clearAllFilters() {
            window.location.href = 'pay-register';
        }

        function prevPage() {
            if (currentPage > 1) {
                currentPage--;
                updatePagination();
            }
        }

        function nextPage() {
            if (currentPage < totalPages) {
                currentPage++;
                updatePagination();
            }
        }

        function getExportData() {
            var table = document.getElementById('payRegisterTable');
            var data = [];
            var headerRow = [];
            var ths = table.tHead.rows[0].cells;
            
            for (var h = 2; h < ths.length; h++) {
                headerRow.push(ths[h].innerText.trim());
            }
            data.push(headerRow);

            var rows = getSelectedOrVisibleRows();
            for (var i = 0; i < rows.length; i++) {
                var rowData = [];
                for (var c = 2; c < rows[i].cells.length; c++) {
                    rowData.push((rows[i].cells[c].innerText || rows[i].cells[c].textContent).trim());
                }
                data.push(rowData);
            }
            return data;
        }

        function exportExcel() {
            var data = getExportData();
            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();

            var ws = XLSX.utils.aoa_to_sheet(data);
            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "PayRegister");
            XLSX.writeFile(wb, "PayRegister_Report_" + dd + "-" + mm + "-" + yyyy + ".xlsx");
        }

        function exportCsv() {
            var data = getExportData();
            var csv = data.map(function(row) {
                return row.map(function(cell) {
                    if (cell == null) return '';
                    var s = String(cell).replace(/"/g, '""');
                    if (s.search(/[,"\n]/) >= 0) s = '"' + s + '"';
                    return s;
                }).join(',');
            }).join('\n');

            var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'PayRegister_Report.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        function generateCompanionExcel(debitAccNo, pymtDate, formatName) {
            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) return;

            var rows = getSelectedOrVisibleRows();
            if (rows.length === 0) return;

            var colIndexMap = {};
            var ths = table.tHead.rows[0].cells;
            for (var c = 0; c < ths.length; c++) {
                var colName = ths[c].getAttribute('data-col-name');
                if (colName) {
                    colIndexMap[colName.toUpperCase()] = c;
                }
            }

            function getCellVal(row, colKey) {
                var idx = colIndexMap[colKey];
                if (idx !== undefined && row.cells[idx]) {
                    return (row.cells[idx].innerText || row.cells[idx].textContent).trim();
                }
                return "";
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();

            var companionHeaders = [
                'EMP_CODE', 'DOJ', 'Designation', 'AADHAR_NO', 'EMP_NAME', 'FATHER_NAME', 'MOBILE',
                'CLUSTER', 'ZONE', 'CIRCLE', 'DIV', 'ACCOUNT_NO', 'IFSC', 'BRANCH_NAME', 'BANK_NAME',
                'DB_STATUS', 'NET_PAY', 'TOTAL_TCS', 'SALARY_STATUS', 'TRANSFER_DATE', 'DEBIT_ACCOUNT'
            ];

            var summaryRows = [companionHeaders];

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                var dbStatus = (r.getAttribute('data-db-status') || '').trim().toLowerCase();
                if (dbStatus !== 'allow') continue;

                var empCode = getCellVal(r, 'CODE');
                var doj = getCellVal(r, 'DOJ');
                var designation = getCellVal(r, 'DESIGNATION');
                var aadhar = getCellVal(r, 'AADHAAR');
                var empName = getCellVal(r, 'EMP_NAME');
                var fatherName = getCellVal(r, 'FATHER_HUSBAND_NAME');
                var mobile = getCellVal(r, 'MOBILE');
                var cluster = getCellVal(r, 'CLUSTER_NAME') || selectedCluster;
                var zone = getCellVal(r, 'BRANCH');
                var circle = getCellVal(r, 'CATEGORY');
                var div = getCellVal(r, 'DEPARTMENT');
                var accNo = getCellVal(r, 'ACCOUNT_NO');
                var ifsc = getCellVal(r, 'IFSC');
                var branchName = getCellVal(r, 'BANK_BRANCH');
                var bankName = getCellVal(r, 'BANK_NAME');
                var rowStatus = (r.getAttribute('data-db-status') || '').trim();
                var netAmt = parseFloat(getCellVal(r, 'NET_AMT_PAYABLE').replace(/,/g, '')) || 0;
                var totalTcs = parseFloat(getCellVal(r, 'TOTAL_TCS_ACT').replace(/,/g, '')) || 0;

                summaryRows.push([
                    empCode, doj, designation, aadhar, empName, fatherName, mobile,
                    cluster, zone, circle, div, accNo, ifsc, branchName, bankName,
                    rowStatus, netAmt, totalTcs, "", "", ""
                ]);
            }

            var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
            var monthLabel = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "ALL";
            var yearYY = (selectedYear && selectedYear.length >= 2) ? selectedYear.substring(selectedYear.length - 2) : "";

            var ws = XLSX.utils.aoa_to_sheet(summaryRows);
            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Salary_Summary");
            var companionFileName = formatName + "_SUMMARY_DETAILS_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx";

            setTimeout(function() {
                XLSX.writeFile(wb, companionFileName);
            }, 600);
        }

        async function downloadMaster() {
            var bankSelect = document.getElementById('bankSelect');
            var selectedBank = bankSelect ? bankSelect.value.trim() : "";
            var debitAccNo = getValidatedDebitAccount(null, selectedBank ? selectedBank : "Selected Bank");
            if (!debitAccNo) return;

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();
            var pymtDate = dd + '-' + mm + '-' + yyyy;

            var companionHeaders = [
                'EMP_CODE', 'DOJ', 'Designation', 'AADHAR_NO', 'EMP_NAME', 'FATHER_NAME', 'MOBILE',
                'CLUSTER', 'ZONE', 'CIRCLE', 'DIV', 'ACCOUNT_NO', 'IFSC', 'BRANCH_NAME', 'BANK_NAME',
                'DB_STATUS', 'NET_PAY', 'TOTAL_TCS', 'SALARY_STATUS', 'TRANSFER_DATE', 'DEBIT_ACCOUNT'
            ];

            var masterRows = [companionHeaders];

            try {
                var fetchUrl = 'pay-register?action=getMasterData' +
                               '&cluster=' + encodeURIComponent(selectedCluster || '') +
                               '&month=' + encodeURIComponent(selectedMonth || '') +
                               '&year=' + encodeURIComponent(selectedYear || '');

                var response = await fetch(fetchUrl);
                if (!response.ok) throw new Error("HTTP error " + response.status);

                var allClusterRecords = await response.json();
                if (!allClusterRecords || allClusterRecords.length === 0) {
                    alert('No master records found for the selected Cluster.');
                    return;
                }

                for (var i = 0; i < allClusterRecords.length; i++) {
                    var r = allClusterRecords[i];
                    var empCode = r.CODE || r.EMP_CODE || '';
                    var doj = r.DOJ || '';
                    var designation = r.DESIGNATION || '';
                    var aadhar = r.AADHAAR || r.AADHAR || '';
                    var empName = r.EMP_NAME || '';
                    var fatherName = r.FATHER_HUSBAND_NAME || '';
                    var mobile = r.MOBILE || '';
                    var cluster = r.CLUSTER_NAME || selectedCluster || '';
                    var zone = r.BRANCH || r.ZONE || '';
                    var circle = r.CATEGORY || r.CIRCLE || '';
                    var div = r.DEPARTMENT || r.DIV || '';
                    var accNo = r.ACCOUNT_NO || '';
                    var ifsc = r.IFSC || '';
                    var branchName = r.BANK_BRANCH || r.BRANCH_NAME || '';
                    var bankName = r.BANK_NAME || '';
                    var dbStatus = r.DB_STATUS || '';
                    var netAmt = parseFloat(String(r.NET_AMT_PAYABLE || 0).replace(/,/g, '')) || 0;
                    var totalTcs = parseFloat(String(r.TOTAL_TCS_ACT || 0).replace(/,/g, '')) || 0;

                    masterRows.push([
                        empCode, doj, designation, aadhar, empName, fatherName, mobile,
                        cluster, zone, circle, div, accNo, ifsc, branchName, bankName,
                        dbStatus, netAmt, totalTcs, "", "", ""
                    ]);
                }

                var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
                var monthLabel = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "ALL";
                var yearYY = (selectedYear && selectedYear.length >= 2) ? selectedYear.substring(selectedYear.length - 2) : "";

                var ws = XLSX.utils.aoa_to_sheet(masterRows);
                var wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Master_Details");

                var bankPrefix = selectedBank ? selectedBank.replace(/[^a-zA-Z0-9_-]/g, '_') + "_" : "";
                var masterFileName = "MASTER_DETAILS_" + bankPrefix + clusterLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx";

                XLSX.writeFile(wb, masterFileName);

            } catch (err) {
                console.error("Error downloading master:", err);
                alert("Failed to download master data: " + err.message);
            }
        }

        async function exportIciciFormat() {
            var debitAccNo = getValidatedDebitAccount("ICICI", "ICICI Bank");
            if (!debitAccNo) return;

            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) {
                alert('No table data found.');
                return;
            }

            var rows = getSelectedOrVisibleRows();
            if (rows.length === 0) {
                alert('No records available to export for the selected filters.');
                return;
            }

            var colIndexMap = {};
            var ths = table.tHead.rows[0].cells;
            for (var c = 0; c < ths.length; c++) {
                var colName = ths[c].getAttribute('data-col-name');
                if (colName) colIndexMap[colName.toUpperCase()] = c;
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();
            var pymtDate = dd + '-' + mm + '-' + yyyy;

            var yearYY = (selectedYear && selectedYear.length >= 2) ? selectedYear.substring(selectedYear.length - 2) : String(yyyy).substring(2);
            var narrMonth = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "";
            var creditNarr = ("SALARY " + narrMonth + " " + yearYY).replace(/\s+/g, ' ').trim();

            var iciciHeaders = [
                'PYMT_PROD_TYPE_CODE', 'PYMT_MODE', 'DEBIT_ACC_NO', 'BNF_NAME', 'BENE_ACC_NO',
                'BENE_IFSC', 'AMOUNT', 'CREDIT_NARR', 'PYMT_DATE', 'MOBILE_NUM', 'EMAIL_ID', 'REMARK', 'REF_NO'
            ];

            var generatedRows = [];

            function getCellVal(row, colKey) {
                var idx = colIndexMap[colKey];
                if (idx !== undefined && row.cells[idx]) {
                    return (row.cells[idx].innerText || row.cells[idx].textContent).trim();
                }
                return "";
            }

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                var dbStatus = (r.getAttribute('data-db-status') || '').trim().toLowerCase();
                if (dbStatus !== 'allow') continue;

                var empName = getCellVal(r, 'EMP_NAME').replace(/\./g, ' ').replace(/[^a-zA-Z0-9\s]/g, '').replace(/\s+/g, ' ').trim();
                var ifsc = getCellVal(r, 'IFSC');
                var accNo = getCellVal(r, 'ACCOUNT_NO');
                var totalTcs = getCellVal(r, 'TOTAL_TCS_ACT');
                var netAmt = getCellVal(r, 'NET_AMT_PAYABLE');

                var pymtMode = (ifsc && ifsc.toUpperCase().startsWith("ICIC")) ? "FT" : "NEFT";

                var amt1 = parseFloat(totalTcs.replace(/,/g, '')) || 0;
                if (amt1 > 0) {
                    generatedRows.push(["PAB_VENDOR", pymtMode, debitAccNo, empName, accNo, ifsc, amt1, creditNarr, pymtDate, "", "", "", ""]);
                }

                var amt2 = parseFloat(netAmt.replace(/,/g, '')) || 0;
                if (amt2 > 0) {
                    generatedRows.push(["PAB_VENDOR", pymtMode, debitAccNo, empName, accNo, ifsc, amt2, creditNarr, pymtDate, "", "", "", ""]);
                }
            }

            if (generatedRows.length === 0) {
                alert('No valid records with DB_STATUS = "Allow" found in the selected rows.');
                return;
            }

            var maxRecordsPerSheet = 199;
            var totalFiles = Math.ceil(generatedRows.length / maxRecordsPerSheet);
            var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
            var monthLabel = narrMonth !== "" ? narrMonth : "ALL";

            if (totalFiles === 1) {
                var sheetData = [iciciHeaders].concat(generatedRows);
                var ws = XLSX.utils.aoa_to_sheet(sheetData);
                var wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Split 1");
                XLSX.writeFile(wb, "ICICI_SAL_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx");
            } else {
                var zip = new JSZip();
                for (var fileIdx = 0; fileIdx < totalFiles; fileIdx++) {
                    var start = fileIdx * maxRecordsPerSheet;
                    var end = Math.min(generatedRows.length, start + maxRecordsPerSheet);
                    var chunk = generatedRows.slice(start, end);
                    var sheetData = [iciciHeaders].concat(chunk);
                    var ws = XLSX.utils.aoa_to_sheet(sheetData);
                    var wb = XLSX.utils.book_new();
                    XLSX.utils.book_append_sheet(wb, ws, "Split " + (fileIdx + 1));
                    var wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
                    zip.file("ICICI_SAL_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_Part" + (fileIdx + 1) + "_of_" + totalFiles + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx", wbout);
                }
                var zipBlob = await zip.generateAsync({ type: "blob" });
                var link = document.createElement("a");
                link.href = URL.createObjectURL(zipBlob);
                link.download = "ICICI_SAL_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_AllParts_" + dd + "-" + mm + "-" + yyyy + ".zip";
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }

            generateCompanionExcel(debitAccNo, pymtDate, "ICICI");
        }

        function exportBomTxtFormat() {
            var debitAccNo = getValidatedDebitAccount("BOM", "Bank of Maharashtra (BOM)");
            if (!debitAccNo) return;

            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) {
                alert('No table data found.');
                return;
            }

            var rows = getSelectedOrVisibleRows();
            if (rows.length === 0) {
                alert('No records available to export for the selected filters.');
                return;
            }

            var colIndexMap = {};
            var ths = table.tHead.rows[0].cells;
            for (var c = 0; c < ths.length; c++) {
                var colName = ths[c].getAttribute('data-col-name');
                if (colName) colIndexMap[colName.toUpperCase()] = c;
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();
            var pymtDate = dd + '-' + mm + '-' + yyyy;

            var yearYY = (selectedYear && selectedYear.length >= 2) ? selectedYear.substring(selectedYear.length - 2) : String(yyyy).substring(2);
            var narrMonth = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "";
            var creditNarr = ("SALARY " + narrMonth + " " + yearYY).replace(/\s+/g, ' ').trim();

            var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
            var divisionLabel = (document.querySelectorAll('.divisionCheckbox:checked').length === 1)
                ? document.querySelector('.divisionCheckbox:checked').value.replace(/[^a-zA-Z0-9_-]/g, '_')
                : "ALL_DIVISIONS";
            var txtFileName = "BOM_SAL_" + clusterLabel + "_" + divisionLabel + "_" + narrMonth + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".txt";

            var bomHeaders = [
                'Debit Account No', 'Mode of Payment', 'Benf Account No', 'Benf Name', 'Amount',
                'Benf Add1', 'Benf Add2', 'Benf Add3', 'Benf PinCode', 'Benf Mobile No', 'Benf email ID',
                'DD Payable At', 'Benf IFSC', 'Branch Name', 'Bank Name', 'Benf Account Type',
                'Narration1', 'Narration2', 'Payment Ref No'
            ];

            var textLines = [];
            textLines.push(bomHeaders.join('|'));

            function getCellVal(row, colKey) {
                var idx = colIndexMap[colKey];
                if (idx !== undefined && row.cells[idx]) {
                    return (row.cells[idx].innerText || row.cells[idx].textContent).trim();
                }
                return "";
            }

            var recordCounter = 1;

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                var dbStatus = (r.getAttribute('data-db-status') || '').trim().toLowerCase();
                if (dbStatus !== 'allow') continue;

                var empName = getCellVal(r, 'EMP_NAME').replace(/\./g, ' ').replace(/[^a-zA-Z0-9\s]/g, '').replace(/\s+/g, ' ').trim();
                var ifsc = getCellVal(r, 'IFSC');
                var accNo = getCellVal(r, 'ACCOUNT_NO');
                var totalTcs = getCellVal(r, 'TOTAL_TCS_ACT');
                var netAmt = getCellVal(r, 'NET_AMT_PAYABLE');
                var bankName = getCellVal(r, 'BANK_NAME');
                var branchName = getCellVal(r, 'BANK_BRANCH');

                var pymtMode = (ifsc && ifsc.toUpperCase().startsWith("MAHB")) ? "I" : "N";

                var amt1 = parseFloat(totalTcs.replace(/,/g, '')) || 0;
                if (amt1 > 0) {
                    textLines.push([debitAccNo, pymtMode, accNo, empName, amt1, "", "", "", "", "", "", "", ifsc, branchName, bankName, "SA", creditNarr, "", clusterLabel + '/' + pymtDate + '/' + recordCounter++].join('|'));
                }

                var amt2 = parseFloat(netAmt.replace(/,/g, '')) || 0;
                if (amt2 > 0) {
                    textLines.push([debitAccNo, pymtMode, accNo, empName, amt2, "", "", "", "", "", "", "", ifsc, branchName, bankName, "SA", creditNarr, "", clusterLabel + '/' + pymtDate + '/' + recordCounter++].join('|'));
                }
            }

            if (textLines.length <= 1) {
                alert('No valid records with DB_STATUS = "Allow" found in the selected rows.');
                return;
            }

            var blob = new Blob([textLines.join('\r\n')], { type: 'text/plain;charset=utf-8;' });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = txtFileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(link.href);

            generateCompanionExcel(debitAccNo, pymtDate, "BOM");
        }

        document.addEventListener('DOMContentLoaded', function() {
            initCompanyBankDropdowns();
            updateDropdownButtonLabel('zone');
            updateDropdownButtonLabel('circle');
            updateDropdownButtonLabel('division');
            updateDropdownButtonLabel('designation');
            updateDropdownButtonLabel('dbStatus');
            updatePagination();
        });
    </script>
</body>
</html>