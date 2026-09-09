<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.vaibhutrans.model.Transaction" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Activity Report - Vaibhutrans</title>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- SheetJS Library for Client-Side Export -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
    <!-- jsPDF Library & AutoTable Plugin for PDF Export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
    <!-- PWA Manifest Link -->
    <link rel="manifest" href="${pageContext.request.contextPath}/manifest.json">
    <meta name="theme-color" content="#007bff">
    <!-- CSS Styling -->
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --card-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
            --glass-bg: rgba(255, 255, 255, 0.95);
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
            padding-bottom: 15px;
        }

        /* Compact Report Card */
        .report-card { 
            padding: 12px 16px; 
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 14px; 
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-top: 8px;
        }

        /* Compact Header */
        .header-title-container {
            border-bottom: 1px dashed #e2e8f0;
            padding-bottom: 8px;
            margin-bottom: 8px;
        }

        .report-title { 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 20px;
            letter-spacing: -0.5px;
        }

        /* Compact KPI Visual Summaries */
        .kpi-card {
            background: #ffffff;
            border-radius: 8px;
            padding: 6px 12px;
            border: 1px solid var(--border-color);
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }
        
        .kpi-title {
            font-size: 9.5px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.5px;
        }

        .kpi-value {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
        }

        /* ULTRA COMPACT FILTERS STYLING */
        .filters-panel { 
            background: #f8fafc;
            padding: 8px 10px;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
        }

        .form-floating > .form-control,
        .form-floating > .form-select {
            height: calc(2.1rem + 2px) !important;
            min-height: calc(2.1rem + 2px) !important;
            padding: 0.35rem 0.5rem !important;
            font-size: 11.5px !important;
            font-weight: 500;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
        }

        .form-floating > label {
            padding: 0.35rem 0.5rem !important;
            font-size: 10px !important;
            color: #64748b;
            transform: scale(0.85) translateY(-0.5rem) translateX(0.1rem);
        }

        .form-floating > .form-control:focus ~ label,
        .form-floating > .form-control:not(:placeholder-shown) ~ label,
        .form-floating > .form-select ~ label {
            transform: scale(0.75) translateY(-0.75rem) translateX(0.15rem);
            opacity: 0.85;
        }

        .form-control:focus, .form-select:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
        }

        /* Actions Bar */
        .actions-bar {
            background: #ffffff;
            padding: 6px 12px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        /* Button styling */
        .btn { 
            border-radius: 6px; 
            font-weight: 600; 
            border: none; 
            padding: 4px 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            font-size: 11.5px;
        }
        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        
        .btn-gradient-primary { background: var(--primary-gradient); color: white; }
        .btn-gradient-success { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; }
        .btn-gradient-danger { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; }
        .btn-gradient-info { background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); color: white; }
        .btn-dark { background: #0f172a; color: white; }
        .btn-light { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-light:hover { background: #e2e8f0; }

        .btn-edit { 
            background-color: #0284c7; 
            color: white; 
            padding: 2px 6px; 
            font-size: 10.5px; 
            border-radius: 4px; 
            text-decoration: none;
        }
        .btn-edit:hover { background-color: #0369a1; color: white; }

        /* INCREASED TABLE HEIGHT & STICKY HEADER */
        .table-responsive { 
            margin-top: 6px;
            border-radius: 8px;
            overflow-x: auto; 
            overflow-y: auto;
            max-height: 72vh;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
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
            padding: 5px 8px !important;
            font-size: 11.5px;
            vertical-align: middle;
            white-space: nowrap;
        }

        /* Sticky Table Header */
        .table-bordered-custom thead th { 
            position: sticky;
            top: 0;
            z-index: 10;
            background: #1e293b;
            color: #f8fafc;
            border: 1px solid #334155 !important;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 10px;
            letter-spacing: 0.5px;
            text-align: left;
        }

        .table-bordered-custom tbody tr:hover {
            background-color: #f1f5f9;
        }

        .utr-badge {
            background: #e0e7ff;
            color: #3730a3;
            font-family: monospace;
            padding: 2px 5px;
            border-radius: 4px;
            font-size: 10.5px;
            font-weight: 600;
            border: 1px solid #c7d2fe;
        }

        .pagination-container {
            margin-top: 8px;
            padding: 6px 12px;
            background: #f8fafc;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .badge-total {
            background: var(--primary-gradient);
            padding: 4px 10px;
            font-weight: 700;
            border-radius: 16px;
            color: white;
            font-size: 11px;
        }

        .modal-content {
            border-radius: 12px;
            border: none;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .modal-header {
            background: var(--primary-gradient);
            color: white;
            border-bottom: none;
            padding: 12px 16px;
        }

        .list-group-item {
            border: 1px solid #e2e8f0;
            border-radius: 6px !important;
            margin-bottom: 4px;
            background: #ffffff;
            padding: 6px 10px;
            user-select: none;
            transition: transform 0.15s ease, background-color 0.15s ease, box-shadow 0.15s ease;
        }

        .drag-handle {
            cursor: grab;
            color: #94a3b8;
            margin-right: 8px;
            padding: 2px 4px;
        }

        .drag-handle:active { cursor: grabbing; }

        .list-group-item.dragging {
            opacity: 0.5;
            background-color: #e0e7ff;
            border: 2px dashed #4f46e5;
        }

        @media print {
            body { background: white !important; color: black !important; }
            .navbar, .filters-panel, .actions-bar, .pagination-container, .action-col { display: none !important; }
            .report-card { border: none !important; box-shadow: none !important; padding: 0 !important; }
            .table-responsive { overflow: visible !important; border: none !important; max-height: none !important; }
            .table-bordered-custom th, .table-bordered-custom td { border: 1px solid #000 !important; }
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp"/>

<div class="container-fluid px-3 mt-1">
    <div class="report-card">
        
        <!-- Header section -->
        <div class="d-flex flex-wrap justify-content-between align-items-center header-title-container gap-2">
            <div class="d-flex align-items-center gap-2">
                <div class="p-1 px-2 bg-light rounded-3 text-primary border">
                    <i class="fa fa-list-check"></i>
                </div>
                <div>
                    <h3 class="report-title mb-0">Transaction Activity Report</h3>
                </div>
            </div>
        </div>

        <!-- KPI Summary Cards -->
        <div class="row g-2 mb-2">
            <div class="col-6 col-md-3 col-lg-2">
                <div class="kpi-card">
                    <div class="kpi-title">Total Records</div>
                    <div class="kpi-value text-primary" id="kpi-total-records">0</div>
                </div>
            </div>
            <div class="col-6 col-md-3 col-lg-2">
                <div class="kpi-card">
                    <div class="kpi-title">Total Amount</div>
                    <div class="kpi-value text-success" id="kpi-total-amount">₹0.00</div>
                </div>
            </div>
        </div>

        <!-- Filter Control Panel -->
        <div class="filters-panel mb-2">
            <div class="row g-1 align-items-center">
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="text" id="filter-utr" class="form-control" oninput="debouncedApplyFilters()" placeholder="Search Reference..." />
                        <label for="filter-utr"><i class="fa fa-search me-1"></i> UTR No</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="text" id="filter-benf-acc" class="form-control" oninput="debouncedApplyFilters()" placeholder="Search Benf Acc..." />
                        <label for="filter-benf-acc"><i class="fa fa-wallet me-1"></i> Benf Acc No</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="text" id="filter-beneficiary" class="form-control" oninput="debouncedApplyFilters()" placeholder="Search Beneficiary..." />
                        <label for="filter-beneficiary"><i class="fa fa-user me-1"></i> Beneficiary</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="date" id="filter-from-date" class="form-control" onchange="applyFilters()" />
                        <label for="filter-from-date">From Date</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="date" id="filter-to-date" class="form-control" onchange="applyFilters()" />
                        <label for="filter-to-date">To Date</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="number" id="filter-min-amt" class="form-control" oninput="debouncedApplyFilters()" placeholder="0.00" step="0.01" />
                        <label for="filter-min-amt">Min Amt (₹)</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="number" id="filter-max-amt" class="form-control" oninput="debouncedApplyFilters()" placeholder="Max..." step="0.01" />
                        <label for="filter-max-amt">Max Amt (₹)</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="text" id="filter-narration" class="form-control" oninput="debouncedApplyFilters()" placeholder="Search Narration..." />
                        <label for="filter-narration">Narration</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="text" id="filter-tallyledger" class="form-control" oninput="debouncedApplyFilters()" placeholder="Search Tally Ledger..." />
                        <label for="filter-tallyledger">Tally Ledger</label>
                    </div>
                </div>
                <div class="col-6 col-sm-4 col-md-3 col-lg-3 col-xl-2">
                    <div class="form-floating">
                        <input type="text" id="filter-project" class="form-control" oninput="debouncedApplyFilters()" placeholder="Search Project..." />
                        <label for="filter-project">Project</label>
                    </div>
                </div>

                <div class="col-12 col-sm-4 col-md-3 col-lg-3 col-xl-2 ms-auto">
                    <button type="button" class="btn btn-light py-1 px-2 w-100 h-100" style="height: calc(2.1rem + 2px) !important;" onclick="clearFilters()">
                        <i class="fa fa-rotate-right me-1"></i> Reset Filters
                    </button>
                </div>
            </div>
        </div>

        <!-- Data Export Toolbar -->
        <div class="actions-bar d-flex flex-wrap align-items-center justify-content-between mb-2 gap-2">
            <span class="text-muted small fw-semibold" style="font-size: 11px;"><i class="fa fa-download me-1"></i> Quick Export Options</span>
            <div class="d-flex gap-1">
                <button type="button" class="btn btn-warning btn-sm text-dark fw-bold" onclick="exportTallyHeader()">
            		<i class="fa fa-file-invoice me-1"></i> Tally Header
        		</button>
                <button type="button" class="btn btn-gradient-primary btn-sm" data-bs-toggle="modal" data-bs-target="#customExportModal">
                    <i class="fa fa-sliders"></i> Custom Export
                </button>
                <button type="button" class="btn btn-gradient-success btn-sm" onclick="exportExcel()">
                    <i class="fa fa-file-excel"></i> Excel
                </button>
                <button type="button" class="btn btn-gradient-info btn-sm" onclick="exportCsv()">
                    <i class="fa fa-file-csv"></i> CSV
                </button>
                <button type="button" class="btn btn-gradient-danger btn-sm" onclick="exportPdf()">
                    <i class="fa fa-file-pdf"></i> PDF
                </button>
                <button type="button" class="btn btn-dark btn-sm" onclick="printReport()">
                    <i class="fa fa-print"></i> Print
                </button>
            </div>
        </div>

        <!-- Main Data Table with Sticky Header -->
        <div class="table-responsive">
            <table class="table table-bordered-custom table-hover align-middle mb-0" id="reportTable">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Debit Acc</th>
                        <th>Benf Acc</th>
                        <th>Benf Name</th>
                        <th>Benf IFSC</th>
                        <th>Bank & Branch</th>
                        <th class="text-end">Amount</th>
                        <th>Mode</th>
                        <th>UTR No</th>
                        <th>Status</th>
                        <th>Narration</th>
                        <th>Tally Ledger</th>
                        <th>Project</th>
                        <th class="text-center action-col">Action</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <% 
                        List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
                        if (transactions != null && !transactions.isEmpty()) {
                            // DESCENDING ORDER SORT: Newest dates on top, null dates at bottom
                            Collections.sort(transactions, new Comparator<Transaction>() {
                                @Override
                                public int compare(Transaction t1, Transaction t2) {
                                    if (t1.getTransactionDate() == null && t2.getTransactionDate() == null) return 0;
                                    if (t1.getTransactionDate() == null) return 1;
                                    if (t2.getTransactionDate() == null) return -1;
                                    return t2.getTransactionDate().compareTo(t1.getTransactionDate());
                                }
                            });

                            for (Transaction tx : transactions) {
                                String date = (tx.getTransactionDate() != null) ? tx.getTransactionDate().toString() : "";
                                String debitAcc = (tx.getDebitAccount() != null) ? tx.getDebitAccount() : "";
                                String benfAcc = (tx.getBenfAccount() != null) ? tx.getBenfAccount() : "";
                                String benfName = (tx.getBenfName() != null) ? tx.getBenfName() : "";
                                String benfIfsc = (tx.getBenfIfsc() != null) ? tx.getBenfIfsc() : "";
                                
                                String bank = (tx.getBenfBank() != null) ? tx.getBenfBank() : "";
                                String branch = (tx.getBenfBranch() != null) ? tx.getBenfBranch() : "";
                                String bankAndBranch = bank + (!branch.isEmpty() ? " - " + branch : "");

                                double amount = tx.getAmount();
                                String mode = (tx.getPaymentMode() != null) ? tx.getPaymentMode() : "";
                                String utr = (tx.getUtrNo() != null) ? tx.getUtrNo() : "";
                                String status = (tx.getStatus() != null) ? tx.getStatus() : "";
                                String narration = (tx.getNarration() != null) ? tx.getNarration() : "";
                                String tallyLedger = (tx.getTallyledger() != null) ? tx.getTallyledger() : "";
                                String project = (tx.getProject() != null) ? tx.getProject() : "";

                                String encodedUtr = URLEncoder.encode(utr, "UTF-8");

                                boolean isPaid = "Successful/Paid".equalsIgnoreCase(status.trim());
                                String statusBadgeClass = isPaid ? "bg-success-subtle text-success border border-success-subtle" 
                                                                 : "bg-danger-subtle text-danger border border-danger-subtle";
                    %>
                    <tr data-utr="<%= utr %>"
                        data-benfacc="<%= benfAcc %>"
                        data-beneficiary="<%= benfName %>"
                        data-date="<%= date %>"
                        data-amount="<%= amount %>"
                        data-status="<%= status %>"
                        data-narration="<%= narration %>"
                        data-tallyledger="<%= tallyLedger %>"
                        data-project="<%= project %>">
                        <td class="fw-medium text-nowrap"><%= date %></td>
                        <td><%= debitAcc %></td>
                        <td><%= benfAcc %></td>
                        <td class="fw-semibold"><%= benfName %></td>
                        <td><code class="text-secondary"><%= benfIfsc %></code></td>
                        <td><%= bankAndBranch %></td>
                        <td class="text-end fw-bold"><%= String.format("%.2f", amount) %></td>
                        <td><span class="badge bg-light text-dark border"><%= mode %></span></td>
                        <td>
                            <% if(!utr.trim().isEmpty()) { %>
                                <span class="utr-badge"><%= utr %></span>
                            <% } %>
                        </td>
                        <td><span class="badge <%= statusBadgeClass %>"><%= status %></span></td>
                        <td><%= narration %></td>
                        <td><%= tallyLedger %></td>
                        <td><%= project %></td>
                        <td class="text-center action-col">
                            <a href="editTransaction?utr=<%= encodedUtr %>" class="btn btn-edit"><i class="fa fa-pen me-1"></i>Edit</a>
                        </td>
                    </tr>
                    <% 
                            }
                        } else {
                    %>
                    <tr id="noDataRow">
                        <td colspan="14" class="text-center py-4 text-muted">
                            <i class="fa fa-folder-open fa-2x mb-2 text-secondary opacity-50 d-block"></i>
                            No transaction data available.
                        </td>
                    </tr>
                    <% 
                        }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Pagination Controls -->
        <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-2">
            <div class="d-flex align-items-center gap-1">
                <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                <span id="pageInfo" class="badge bg-white text-dark border px-2 py-1">Page 1 of 1</span>
                <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
            </div>

            <div class="d-flex align-items-center gap-1">
                <label for="gotoPage" class="small text-muted mb-0">Jump to:</label>
                <input type="number" id="gotoPage" class="form-control form-control-sm text-center py-0" style="width:60px; height: 24px;" min="1" />
                <button class="btn btn-dark btn-sm py-1" onclick="jumpToPage()">Go</button>
            </div>

            <div>
                <span id="totalBadge" class="badge-total">Total Records: 0</span>
            </div>
        </div>

    </div>
</div>

<!-- Custom Export Modal -->
<div class="modal fade" id="customExportModal" tabindex="-1" aria-labelledby="customExportModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title text-white fw-bold fs-6" id="customExportModalLabel"><i class="fa fa-sliders me-2"></i>Custom Export Configuration</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-3">
                <p class="text-muted small mb-2" style="font-size: 11px;">Select columns to include in your export and drag items to reorder them.</p>
                
                <div class="mb-2">
                    <label class="form-label fw-bold small text-muted mb-1" style="font-size: 11px;">Export Format</label>
                    <select id="customExportFormat" class="form-select form-select-sm">
                        <option value="xlsx">Excel (.xlsx)</option>
                        <option value="pdf">PDF (.pdf)</option>
                    </select>
                </div>

                <label class="form-label fw-bold small text-muted mb-1" style="font-size: 11px;">Select & Reorder Columns</label>
                <ul class="list-group" id="columnList">
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="0">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="0" checked id="col_0">
                        <label class="form-check-label w-100 small" for="col_0">Date</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="1">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="1" checked id="col_1">
                        <label class="form-check-label w-100 small" for="col_1">Debit Acc</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="2">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="2" checked id="col_2">
                        <label class="form-check-label w-100 small" for="col_2">Benf Acc</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="3">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="3" checked id="col_3">
                        <label class="form-check-label w-100 small" for="col_3">Benf Name</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="4">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="4" checked id="col_4">
                        <label class="form-check-label w-100 small" for="col_4">Benf IFSC</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="5">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="5" checked id="col_5">
                        <label class="form-check-label w-100 small" for="col_5">Bank & Branch</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="6">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="6" checked id="col_6">
                        <label class="form-check-label w-100 small" for="col_6">Amount</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="7">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="7" checked id="col_7">
                        <label class="form-check-label w-100 small" for="col_7">Mode</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="8">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="8" checked id="col_8">
                        <label class="form-check-label w-100 small" for="col_8">UTR No</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="9">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="9" checked id="col_9">
                        <label class="form-check-label w-100 small" for="col_9">Status</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="10">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="10" checked id="col_10">
                        <label class="form-check-label w-100 small" for="col_10">Narration</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="11">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="11" checked id="col_11">
                        <label class="form-check-label w-100 small" for="col_11">Tally Ledger</label>
                    </li>
                    <li class="list-group-item d-flex align-items-center" draggable="true" data-index="12">
                        <i class="fa fa-grip-vertical drag-handle"></i>
                        <input class="form-check-input me-2 column-checkbox" type="checkbox" value="12" checked id="col_12">
                        <label class="form-check-label w-100 small" for="col_12">Project</label>
                    </li>
                </ul>
            </div>
            <div class="modal-footer bg-light p-2">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-gradient-primary btn-sm" onclick="exportCustom()">Export Now</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentPage = 1;
    const pageSize = 50;
    let totalPages = 1;
    let visibleRows = [];
    let debounceTimer;

    document.addEventListener("DOMContentLoaded", function() {
        applyFilters();
        initDragAndDrop();
    });

    function debouncedApplyFilters(delay = 300) {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            applyFilters();
        }, delay);
    }

    function applyFilters() {
        const utr = document.getElementById("filter-utr").value.trim().toLowerCase();
        const benfAcc = document.getElementById("filter-benf-acc").value.trim().toLowerCase();
        const bene = document.getElementById("filter-beneficiary").value.trim().toLowerCase();
        const fromDate = document.getElementById("filter-from-date").value;
        const toDate = document.getElementById("filter-to-date").value;
        const minAmt = parseFloat(document.getElementById("filter-min-amt").value) || null;
        const maxAmt = parseFloat(document.getElementById("filter-max-amt").value) || null;
        const narration = document.getElementById("filter-narration").value.trim().toLowerCase();
        const tallyledger = document.getElementById("filter-tallyledger").value.trim().toLowerCase();
        const project = document.getElementById("filter-project").value.trim().toLowerCase();

        const rows = Array.from(document.querySelectorAll("#tableBody tr[data-utr]"));
        visibleRows = [];

        rows.forEach(row => {
            const rowUtr = row.getAttribute("data-utr").toLowerCase();
            const rowBenfAcc = row.getAttribute("data-benfacc").toLowerCase();
            const rowBene = row.getAttribute("data-beneficiary").toLowerCase();
            const rowDate = row.getAttribute("data-date");
            const rowAmt = parseFloat(row.getAttribute("data-amount"));
            const rowNarration = row.getAttribute("data-narration").toLowerCase();
            const rowTallyLedger = row.getAttribute("data-tallyledger").toLowerCase();
            const rowProject = row.getAttribute("data-project").toLowerCase();

            let matches = true;

            if (utr && !rowUtr.includes(utr)) matches = false;
            if (benfAcc && !rowBenfAcc.includes(benfAcc)) matches = false;
            if (bene && !rowBene.includes(bene)) matches = false;
            if (fromDate && rowDate < fromDate) matches = false;
            if (toDate && rowDate > toDate) matches = false;
            if (minAmt !== null && rowAmt < minAmt) matches = false;
            if (maxAmt !== null && rowAmt > maxAmt) matches = false;
            if (narration && !rowNarration.includes(narration)) matches = false;
            if (tallyledger && !rowTallyLedger.includes(tallyledger)) matches = false;
            if (project && !rowProject.includes(project)) matches = false;

            if (matches) {
                row.dataset.matched = "1";
                visibleRows.push(row);
            } else {
                row.dataset.matched = "0";
                row.style.display = "none";
            }
        });

        currentPage = 1;
        updateKPIMetrics();
        renderPagination();
    }

    function clearFilters() {
        document.getElementById("filter-utr").value = "";
        document.getElementById("filter-benf-acc").value = "";
        document.getElementById("filter-beneficiary").value = "";
        document.getElementById("filter-from-date").value = "";
        document.getElementById("filter-to-date").value = "";
        document.getElementById("filter-min-amt").value = "";
        document.getElementById("filter-max-amt").value = "";
        document.getElementById("filter-narration").value = "";
        document.getElementById("filter-tallyledger").value = "";
        document.getElementById("filter-project").value = "";
        applyFilters();
    }

    function updateKPIMetrics() {
        const totalRecords = visibleRows.length;
        
        // Sum only records whose status is "Successful/Paid"
        const totalAmount = visibleRows.reduce((sum, row) => {
            const status = (row.getAttribute("data-status") || "").trim().toLowerCase();
            if (status === "successful/paid") {
                return sum + parseFloat(row.getAttribute("data-amount") || 0);
            }
            return sum;
        }, 0);

        document.getElementById("kpi-total-records").innerText = totalRecords;
        document.getElementById("kpi-total-amount").innerText = '₹' + totalAmount.toLocaleString('en-IN', {minimumFractionDigits: 2});
        
        const totalBadge = document.getElementById("totalBadge");
        if (totalBadge) totalBadge.innerText = "Total Records: " + totalRecords;
    }

    function renderPagination() {
        totalPages = Math.max(1, Math.ceil(visibleRows.length / pageSize));
        if (currentPage > totalPages) currentPage = totalPages;

        const table = document.querySelector('table');
        const rows = table.tBodies[0].rows;
        for (let i = 0; i < rows.length; i++) rows[i].style.display = 'none';

        const start = (currentPage - 1) * pageSize;
        const end = Math.min(visibleRows.length, start + pageSize);
        for (let j = start; j < end; j++) visibleRows[j].style.display = '';

        document.getElementById("pageInfo").innerText = "Page " + currentPage + " of " + totalPages;
        const goto = document.getElementById("gotoPage");
        if (goto) goto.value = currentPage;
    }

    function prevPage() { if (currentPage > 1) { currentPage--; renderPagination(); } }
    function nextPage() { if (currentPage < totalPages) { currentPage++; renderPagination(); } }
    function jumpToPage() {
        const v = parseInt(document.getElementById('gotoPage').value);
        if (!isNaN(v) && v >= 1 && v <= totalPages) { currentPage = v; renderPagination(); }
    }

    /* EXPORT & PRINT IMPLEMENTATION */
    function getExportData(selectedIndices = [0,1,2,3,4,5,6,7,8,9,10,11,12]) {
        const headers = [];
        const ths = document.querySelectorAll("#reportTable thead th");
        selectedIndices.forEach(idx => {
            if (ths[idx]) headers.push(ths[idx].innerText.trim());
        });

        const rowsData = [];
        visibleRows.forEach(row => {
            const rowData = [];
            const cells = row.querySelectorAll("td");
            selectedIndices.forEach(idx => {
                if (cells[idx]) {
                    rowData.push(cells[idx].innerText.trim());
                }
            });
            rowsData.push(rowData);
        });

        return { headers, data: rowsData };
    }

    function exportExcel() {
        if (visibleRows.length === 0) { alert("No data available to export!"); return; }
        const { headers, data } = getExportData();
        const ws = XLSX.utils.aoa_to_sheet([headers, ...data]);
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Transactions");
        XLSX.writeFile(wb, "Transaction_Report.xlsx");
    }

    function exportCsv() {
        if (visibleRows.length === 0) { alert("No data available to export!"); return; }
        const { headers, data } = getExportData();
        const ws = XLSX.utils.aoa_to_sheet([headers, ...data]);
        const csvOutput = XLSX.utils.sheet_to_csv(ws);
        
        const blob = new Blob([csvOutput], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement("a");
        const url = URL.createObjectURL(blob);
        link.setAttribute("href", url);
        link.setAttribute("download", "Transaction_Report.csv");
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    function exportPdf() {
        if (visibleRows.length === 0) { alert("No data available to export!"); return; }
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({ orientation: "landscape" });

        const { headers, data } = getExportData();

        doc.setFontSize(16);
        doc.text("Transaction Activity Report", 14, 15);

        doc.autoTable({
            head: [headers],
            body: data,
            startY: 22,
            styles: { fontSize: 8 },
            headStyles: { fillColor: [30, 41, 59] }
        });

        doc.save("Transaction_Report.pdf");
    }

    function printReport() {
        window.print();
    }

    /* CUSTOM EXPORT DRAG & DROP & FUNCTIONALITY */
    function initDragAndDrop() {
        const columnList = document.getElementById("columnList");
        let draggedItem = null;

        columnList.addEventListener("dragstart", (e) => {
            draggedItem = e.target.closest("li");
            e.target.classList.add("dragging");
        });

        columnList.addEventListener("dragend", (e) => {
            e.target.classList.remove("dragging");
            draggedItem = null;
        });

        columnList.addEventListener("dragover", (e) => {
            e.preventDefault();
            const afterElement = getDragAfterElement(columnList, e.clientY);
            if (afterElement == null) {
                columnList.appendChild(draggedItem);
            } else {
                columnList.insertBefore(draggedItem, afterElement);
            }
        });
    }

    function getDragAfterElement(container, y) {
        const draggableElements = [...container.querySelectorAll(".list-group-item:not(.dragging)")];
        return draggableElements.reduce((closest, child) => {
            const box = child.getBoundingClientRect();
            const offset = y - box.top - box.height / 2;
            if (offset < 0 && offset > closest.offset) {
                return { offset: offset, element: child };
            } else {
                return closest;
            }
        }, { offset: Number.NEGATIVE_INFINITY }).element;
    }

    function exportCustom() {
        if (visibleRows.length === 0) { alert("No data available to export!"); return; }

        const columnItems = document.querySelectorAll("#columnList li");
        const selectedIndices = [];

        columnItems.forEach(item => {
            const checkbox = item.querySelector(".column-checkbox");
            if (checkbox && checkbox.checked) {
                selectedIndices.push(parseInt(checkbox.value));
            }
        });

        if (selectedIndices.length === 0) {
            alert("Please select at least one column to export.");
            return;
        }

        const format = document.getElementById("customExportFormat").value;
        const { headers, data } = getExportData(selectedIndices);

        if (format === "pdf") {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({ orientation: "landscape" });

            doc.setFontSize(16);
            doc.text("Custom Transaction Activity Report", 14, 15);

            doc.autoTable({
                head: [headers],
                body: data,
                startY: 22,
                styles: { fontSize: 8 },
                headStyles: { fillColor: [30, 41, 59] }
            });

            doc.save("Custom_Transaction_Report.pdf");
        } else {
            const ws = XLSX.utils.aoa_to_sheet([headers, ...data]);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Transactions");
            XLSX.writeFile(wb, "Custom_Transaction_Report.xlsx");
        }

        const modalEl = document.getElementById('customExportModal');
        const modal = bootstrap.Modal.getInstance(modalEl);
        if (modal) modal.hide();
    }
    
    function exportTallyHeader() {
        fetch('report?action=tallyheader')
            .then(response => {
                if (!response.ok) throw new Error("Failed to fetch tally header data.");
                return response.json();
            })
            .then(data => {
                if (!data || data.length === 0) {
                    alert("No data found for Tally Header.");
                    return;
                }

                // Prepare rows for SheetJS: Headers + Data mapping
                const headers = ["Benf Account", "Tally Ledger","Project"];
                const rows = data.map(item => [item.benf_account, item.tallyledger, item.project]);

                const ws = XLSX.utils.aoa_to_sheet([headers, ...rows]);
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "TallyHeader");

                // Explicitly pull date components safely
                var now = new Date();
                var yyyy = now.getFullYear();
                var mm = String(now.getMonth() + 1).padStart(2, '0');
                var dd = String(now.getDate()).padStart(2, '0');
                var hh = String(now.getHours()).padStart(2, '0');
                var min = String(now.getMinutes()).padStart(2, '0');
                var ss = String(now.getSeconds()).padStart(2, '0');

                // Build filename safely using standard string concatenation to prevent template literal scoping issues
                var fileName = "tallyheader_" + yyyy + "-" + mm + "-" + dd + "_" + hh + "-" + min + "-" + ss + ".xlsx";

                XLSX.writeFile(wb, fileName);
            })
            .catch(error => {
                console.error("Error exporting Tally Header:", error);
                alert("Error generating Tally Header export.");
            });
    }

    
</script>
</body>
</html>