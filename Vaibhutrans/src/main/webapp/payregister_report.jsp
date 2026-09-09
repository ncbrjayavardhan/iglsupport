<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.Arrays" %>
<%!
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

        .bank-card {
            background: linear-gradient(135deg, #f0fdf4 0%, #e0f2fe 100%);
            border-radius: 10px;
            border: 1px solid #bae6fd;
        }

        .actions-bar {
            background: #ffffff;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

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
        }
        .code-badge:hover {
            background: #e0e7ff;
            color: #312e81;
            text-decoration: underline;
        }

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

        .action-dropdown-menu {
            border-radius: 10px;
            padding: 6px;
            min-width: 140px;
        }

        .action-dropdown-menu .dropdown-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 11.5px;
        }

        .icon-circle {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            font-size: 9.5px;
        }

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
        .modal-card-transaction {
            background: linear-gradient(135deg, #f3e8ff 0%, #e9d5ff 100%);
            border: 1px solid #d8b4fe !important;
            border-radius: 10px;
        }
        
        .modal-card-salary-paid {
            background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
            border: 1px solid #86efac !important;
            border-radius: 10px;
        }
        .modal-card-salary-hold {
            background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%); 
            border: 1px solid #fca5a5 !important; 
            border-radius: 10px;
        }
        .modal-card-salary-allow {
		    background: linear-gradient(135deg, #fefce8 0%, #fef08a 100%);
		    border: 1px solid #eab308 !important;
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

                        <div class="filter-item-cluster">
                            <select name="cluster" id="filterCluster" class="form-select form-select-sm fw-semibold w-100">
                                <option value="" <%= "".equals(selCluster) ? "selected" : "" %>>3. All Clusters</option>
                                <option value="8" <%= "8".equals(selCluster) ? "selected" : "" %>>Cluster-8</option>
                                <option value="9" <%= "9".equals(selCluster) ? "selected" : "" %>>Cluster-9</option>
                                <option value="12" <%= "12".equals(selCluster) ? "selected" : "" %>>Cluster-12</option>
                                <option value="5" <%= "5".equals(selCluster) ? "selected" : "" %>>Cluster-5</option>
                            </select>
                        </div>

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
                                        }
                                    %>
                                </div>
                            </div>
                        </div>

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
                                        }
                                    %>
                                </div>
                            </div>
                        </div>

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
                                        }
                                    %>
                                </div>
                            </div>
                        </div>

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
                                        }
                                    %>
                                </div>
                            </div>
                        </div>

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
                                        }
                                    %>
                                </div>
                            </div>
                        </div>

                        <div class="filter-item-actions ms-auto">
                            <button type="submit" class="btn btn-gradient-primary btn-sm px-2" style="height: 32px;">
                                <i class="fa fa-filter"></i> Filter
                            </button>
                            <button type="button" class="btn btn-light btn-sm px-2 border" style="height: 32px;" onclick="clearAllFilters()">
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

            <!-- Toolbar with Search Bar -->
            <div class="bulk-selection-bar d-flex flex-wrap align-items-center justify-content-between mb-2 gap-2">
                <div class="d-flex align-items-center gap-2 flex-grow-1" style="max-width: 420px;">
                    <div class="input-group input-group-sm w-100">
                        <span class="input-group-text bg-white border-end-0 py-1"><i class="fa fa-search text-muted"></i></span>
                        <input type="text" id="tableSearch" class="form-control border-start-0 py-1" placeholder="Search Code, Name, Account, Status..." onkeyup="filterTableSearch()">
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
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
                    <button type="button" class="btn btn-gradient-primary btn-sm py-1 px-3" onclick="downloadMaster()">Download Master</button>
                    <button type="button" class="btn btn-gradient-bom btn-sm py-1 px-3" onclick="exportBomTxtFormat()">BOM Format</button>
                    <button type="button" class="btn btn-gradient-icici btn-sm py-1 px-3" onclick="exportIciciFormat()">ICICI Format</button>
                    <button type="button" class="btn btn-gradient-success btn-sm py-1 px-3" onclick="exportExcel()">Excel</button>
                    <button type="button" class="btn btn-gradient-info btn-sm py-1 px-3" onclick="exportCsv()">CSV</button>
                </div>
            </div>

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
                                        <input type="checkbox" id="selectAllRows" class="form-check-input" onchange="toggleSelectAllRows(this)">
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
                                        String accountNoVal = (record.get("ACCOUNT_NO") != null) ? record.get("ACCOUNT_NO").toString().trim() : "";
                                %>
                                    <tr class="data-row"
                                        data-db-status="<%= dbStatus %>" 
                                        data-emp-code="<%= empCodeVal %>"
                                        data-account="<%= accountNoVal %>"
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

                    <!-- Pagination Section Restored -->
                    <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-3">
                        <div class="d-flex align-items-center gap-2">
                            <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                            <span id="pageInfo" class="badge bg-white text-dark border px-3 py-1" style="font-size: 11px;">Page 1 of 1</span>
                            <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <label for="gotoPage" class="small text-muted mb-0">Jump to:</label>
                            <input type="number" id="gotoPage" class="form-control form-control-sm text-center py-0" style="width:60px; height: 26px;" min="1" />
                            <button class="btn btn-dark btn-sm py-1" onclick="jumpToPage()">Go</button>
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
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Employee Detailed View Modal with 3-Column Layout (Billing + Transaction Stacked) -->
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
                        <!-- Column 1: Personal Details -->
                        <div class="col-lg-4">
                            <div class="p-3 modal-card-personal h-100 shadow-sm">
                                <div class="modal-section-title text-primary"><i class="fa fa-user me-2"></i>Personal Details</div>
                                <div class="d-flex flex-column gap-2" id="personalContainer"></div>
                            </div>
                        </div>

                        <!-- Column 2: Billing Details & Transaction Details Stacked -->
                        <div class="col-lg-4 d-flex flex-column gap-3">
                            <div class="p-3 modal-card-billing shadow-sm">
                                <div class="modal-section-title text-success"><i class="fa fa-file-invoice-dollar me-2"></i>Billing Details</div>
                                <div class="d-flex flex-column gap-2" id="billingContainer"></div>
                            </div>
                            <div class="p-3 modal-card-transaction shadow-sm">
                                <div class="modal-section-title" style="color: #6b21a8;"><i class="fa fa-exchange-alt me-2"></i>Transaction Details</div>
                                <div class="d-flex flex-column gap-2" id="transactionContainer"></div>
                            </div>
                        </div>

                        <!-- Column 3: Salary Details -->
                        <div class="col-lg-4">
                            <div class="p-3 h-100 shadow-sm" id="salaryCardWrapper">
                                <div class="modal-section-title" id="salaryTitleContainer"><i class="fa fa-wallet me-2"></i><span id="salaryTitleText">Salary Details</span></div>
                                <div class="d-flex flex-column gap-2" id="salaryContainer"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer py-2 px-4 border-top bg-white">
                    <button type="button" class="btn btn-secondary btn-sm px-4" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Script Handling Popup Population, Bank Dropdowns, Debounced Search, Pagination, & Asynchronous Transaction Fetching -->
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

        // Pagination variables
        var currentPage = 1;
        var pageSize = 50;
        var totalPages = 1;

        // Optimized Debounced Search & Pagination Handler
        var searchTimer;
        function filterTableSearch() {
            clearTimeout(searchTimer);
            searchTimer = setTimeout(function() {
                var query = document.getElementById('tableSearch').value.toLowerCase().trim();
                var rows = document.querySelectorAll('#payRegisterTable tbody tr');

                rows.forEach(function(row) {
                    var text = row.innerText.toLowerCase();
                    if (query === '' || text.indexOf(query) > -1) {
                        row.dataset.matched = '1';
                    } else {
                        row.dataset.matched = '0';
                    }
                });

                currentPage = 1;
                updatePagination();
            }, 300);
        }

        function updatePagination() {
            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) return;

            var rows = table.tBodies[0].rows;
            var matched = [];
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].dataset.matched !== '0') {
                    matched.push(rows[i]);
                } else {
                    rows[i].style.display = 'none';
                }
            }

            totalPages = Math.max(1, Math.ceil(matched.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            for (var i = 0; i < rows.length; i++) {
                if (rows[i].dataset.matched !== '0') {
                    rows[i].style.display = 'none';
                }
            }

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(matched.length, start + pageSize);
            for (var j = start; j < end; j++) {
                matched[j].style.display = '';
            }

            var pageInfo = document.getElementById('pageInfo');
            var totalBadge = document.getElementById('totalBadge');
            var gotoPage = document.getElementById('gotoPage');

            if (pageInfo) pageInfo.textContent = 'Page ' + currentPage + ' of ' + totalPages;
            if (totalBadge) totalBadge.textContent = 'Total Records: ' + matched.length;
            if (gotoPage) gotoPage.value = currentPage;
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

        function jumpToPage() {
            var v = parseInt(document.getElementById('gotoPage').value);
            if (!isNaN(v) && v >= 1 && v <= totalPages) {
                currentPage = v;
                updatePagination();
            }
        }

        /* function openEmployeeDetailsModal(linkElem) {
            var row = linkElem.closest('tr');
            if (!row) return;

            var m = row.getAttribute('data-pay-month') || selectedMonth || '';
            var y = row.getAttribute('data-pay-year') || selectedYear || '';
            var accountNo = row.getAttribute('data-account') || '';

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
                salaryTitleContainer.className = 'modal-section-title text-danger'; 
            } else if (dbStatus === 'HOLD') {
                salaryCardWrapper.className = 'p-3 modal-card-salary-hold h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title';
                salaryTitleContainer.style.color = '#854d0e'; 
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
                { label: 'A/c No', val: accountNo }
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

            function populateSection(containerId, fields) {
                var container = document.getElementById(containerId);
                container.innerHTML = '';
                fields.forEach(function(item) {
                    var box = document.createElement('div');
                    box.className = 'p-2 bg-white border rounded shadow-xs d-flex justify-content-between align-items-center';

                    var labelSpan = document.createElement('span');
                    labelSpan.className = 'fw-bold small text-muted';
                    labelSpan.style.fontSize = '11px';
                    
                    var valSpan = document.createElement('span');
                    valSpan.className = 'fw-bold small text-dark';
                    valSpan.style.fontSize = '11.5px';

                    labelSpan.textContent = item.label;
                    valSpan.textContent = (item.val && item.val !== 'null' && item.val !== '') ? item.val : '-';

                    box.appendChild(labelSpan);
                    box.appendChild(valSpan);
                    container.appendChild(box);
                });
            }

            populateSection('personalContainer', personalFields);
            populateSection('billingContainer', billingFields);
            populateSection('salaryContainer', salaryFields);

            // Show loading placeholder for transaction details
            document.getElementById('transactionContainer').innerHTML = 
                '<div class="p-2 bg-white border rounded small text-muted text-center"><i class="fa fa-spinner fa-spin me-1"></i> Loading transaction info...</div>';

            var modal = new bootstrap.Modal(document.getElementById('employeeDetailsModal'));
            modal.show();

            // Fetch UTR No & Transaction Date asynchronously on click
            fetch('pay-register?action=getTransactionDetails&accountNo=' + encodeURIComponent(accountNo) + '&payMonth=' + encodeURIComponent(m))
                .then(res => res.json())
                .then(data => {
                    var transactionFields = [
                        { label: 'UTR No', val: data.utr_no },
                        { label: 'Transaction Date', val: data.transaction_date }
                    ];
                    populateSection('transactionContainer', transactionFields);
                })
                .catch(err => {
                    document.getElementById('transactionContainer').innerHTML = 
                        '<div class="p-2 bg-white border rounded small text-danger text-center">Failed to load transaction data</div>';
                });
        }
        */
        
        function openEmployeeDetailsModal(linkElem) {
            var row = linkElem.closest('tr');
            if (!row) return;

            var empCode = row.getAttribute('data-emp-code') || '';
            var m = row.getAttribute('data-pay-month') || selectedMonth || '';
            var y = row.getAttribute('data-pay-year') || selectedYear || '';
            var accountNo = row.getAttribute('data-account') || '';

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
                salaryTitleContainer.className = 'modal-section-title text-danger'; 
            } else if (dbStatus === 'HOLD') {
                salaryCardWrapper.className = 'p-3 modal-card-salary-hold h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title';
                salaryTitleContainer.style.color = '#854d0e'; 
            } else {
                salaryCardWrapper.className = 'p-3 modal-card-salary-hold h-100 shadow-sm';
                salaryTitleContainer.className = 'modal-section-title text-secondary';
            }

            var personalFields = [
                { label: 'Code', val: empCode },
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
                { label: 'A/c No', val: accountNo }
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

            function populateSection(containerId, fields) {
                var container = document.getElementById(containerId);
                container.innerHTML = '';
                fields.forEach(function(item) {
                    var box = document.createElement('div');
                    box.className = 'p-2 bg-white border rounded shadow-xs d-flex justify-content-between align-items-center';

                    var labelSpan = document.createElement('span');
                    labelSpan.className = 'fw-bold small text-muted';
                    labelSpan.style.fontSize = '11px';
                    
                    var valSpan = document.createElement('span');
                    valSpan.className = 'fw-bold small text-dark';
                    valSpan.style.fontSize = '11.5px';

                    labelSpan.textContent = item.label;
                    valSpan.textContent = (item.val && item.val !== 'null' && item.val !== '') ? item.val : '-';

                    box.appendChild(labelSpan);
                    box.appendChild(valSpan);
                    container.appendChild(box);
                });
            }

            populateSection('personalContainer', personalFields);
            populateSection('billingContainer', billingFields);
            populateSection('salaryContainer', salaryFields);

            // Show loading placeholder for transaction details
            document.getElementById('transactionContainer').innerHTML = 
                '<div class="p-2 bg-white border rounded small text-muted text-center"><i class="fa fa-spinner fa-spin me-1"></i> Loading transaction info...</div>';

            var modal = new bootstrap.Modal(document.getElementById('employeeDetailsModal'));
            modal.show();

            // Fetch UTR No & Transaction Date asynchronously with unique employee code & year
            fetch('pay-register?action=getTransactionDetails&empCode=' + encodeURIComponent(empCode) + '&payMonth=' + encodeURIComponent(m) + '&payYear=' + encodeURIComponent(y))
                .then(res => res.json())
                .then(data => {
                    var transactionFields = [
                        { label: 'UTR No', val: data.utr_no },
                        { label: 'Transaction Date', val: data.transaction_date }
                    ];
                    populateSection('transactionContainer', transactionFields);
                })
                .catch(err => {
                    document.getElementById('transactionContainer').innerHTML = 
                        '<div class="p-2 bg-white border rounded small text-danger text-center">Failed to load transaction data</div>';
                });
        }
        function clearAllFilters() {
            window.location.href = 'pay-register';
        }

        document.addEventListener('DOMContentLoaded', function() {
            initCompanyBankDropdowns();
            // Initialize row matching flags for pagination on page load
            var rows = document.querySelectorAll('#payRegisterTable tbody tr');
            rows.forEach(function(r) { r.dataset.matched = '1'; });
            updatePagination();
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>