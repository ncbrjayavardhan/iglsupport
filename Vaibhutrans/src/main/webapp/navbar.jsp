<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!-- PWA Manifest Link -->
<link rel="manifest" href="${ctx}/manifest.json">
<!-- Tailwind CSS & Font Awesome -->
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    nav { box-sizing: border-box; }
    .container { max-width: 1200px; margin: 0 auto; padding: 0 1rem; }
    
    .bg-navbar-theme { background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%); }
    .hover-nav-item:hover { background-color: rgba(255, 255, 255, 0.12); }
    
    .bg-dropdown { 
        background-color: #1e293b; 
        border: 1px solid rgba(255, 255, 255, 0.1); 
    }
    .bg-dropdown-hover:hover { 
        background-color: #334155; 
    }
    .bg-flyout { 
        background-color: #0f172a; 
        border: 1px solid rgba(255, 255, 255, 0.15); 
    }

    .shadow-xl { box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5), 0 10px 10px -5px rgba(0, 0, 0, 0.04); }
    a { text-decoration: none; }
</style>

<nav class="bg-navbar-theme py-1 px-3 shadow-lg rounded-b-lg w-full font-sans">
    <div class="container mx-auto flex justify-between items-center flex-wrap">
        
        <!-- Brand -->
        <a href="${ctx}/dashboard.jsp" class="text-white text-xl font-bold tracking-wide rounded-md py-1 px-2 hover-nav-item transition duration-300 flex items-center">
            Vaibhutrans
        </a>

        <!-- Mobile Menu Button -->
        <div id="mobile-hamburger-wrapper" class="block lg:hidden">
            <button id="menu-button" class="menu-button text-white focus:outline-none py-1 px-2 rounded-md hover-nav-item transition duration-300">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7"></path>
                </svg>
            </button>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden lg:flex lg:items-center lg:w-auto w-full" id="navbar-links-desktop">
            <div class="text-base lg:flex-grow flex items-center">
                
                <!-- Home Link -->
                <a href="${ctx}/dashboard.jsp" class="block mt-2 lg:inline-block lg:mt-0 text-white hover:text-indigo-100 mr-6 py-1 px-2.5 rounded-md hover-nav-item transition duration-300">
                    Home
                </a>

                <!-- Dropdown: HR with Nested Flyout Dropdowns -->
                <div class="relative group inline-block mt-2 lg:mt-0 mr-6">
                    <button id="hr-dropdown-button-desktop" class="flex items-center text-white hover:text-indigo-100 py-1 px-2.5 rounded-md hover-nav-item transition duration-300 focus:outline-none">
                        HR <i class="fas fa-chevron-down ml-2 text-xs"></i>
                    </button>

                    <ul id="hr-submenu-desktop" class="absolute hidden group-hover:block bg-dropdown text-white py-1 rounded-lg shadow-xl min-w-[210px] z-10 top-full left-0">
                        
                        <!-- 1. Transactions Nested Dropdown -->
                        <li class="relative group/sub">
                            <a href="javascript:void(0)" class="flex items-center justify-between px-4 py-2 bg-dropdown-hover transition duration-200 whitespace-nowrap text-sm">
                                <span>Transactions</span>
                                <i class="fas fa-chevron-right text-xs ml-3 text-gray-400"></i>
                            </a>
                            <ul class="absolute left-full top-0 hidden group-hover/sub:block bg-flyout text-white py-1 rounded-lg shadow-xl min-w-[190px] z-20">
                                <li><a href="${ctx}/upload.jsp" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">Upload Excel</a></li>
                                <li><a href="${ctx}/addTransaction" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">Add Transaction</a></li>
                                <li><a href="${ctx}/report" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">View Report</a></li>
                                <li><a href="${ctx}/bankReport" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">View Bank Detail</a></li>
                            </ul>
                        </li>

                        <!-- 2. Pay Register Nested Dropdown -->
                        <li class="relative group/sub">
                            <a href="javascript:void(0)" class="flex items-center justify-between px-4 py-2 bg-dropdown-hover transition duration-200 whitespace-nowrap text-sm">
                                <span>Pay Register</span>
                                <i class="fas fa-chevron-right text-xs ml-3 text-gray-400"></i>
                            </a>
                            <ul class="absolute left-full top-0 hidden group-hover/sub:block bg-flyout text-white py-1 rounded-lg shadow-xl min-w-[200px] z-20">
                                <li><a href="${ctx}/payregister_upload.jsp" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">Upload Pay Register</a></li>
                                <li><a href="${ctx}/payment_status_update.jsp" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">Update Pay Status</a></li>
                                <li><a href="${ctx}/pay-register" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">View Pay Register</a></li>
                                <li><a href="${ctx}/employeeReport.jsp" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">Employee Master</a></li>
                            </ul>
                        </li>

                    </ul>
                </div>

                <!-- Dropdown: Accounts (Nested Flyout Menus) -->
                <div class="relative group inline-block mt-2 lg:mt-0 mr-6">
                    <button id="accounts-dropdown-button-desktop" class="flex items-center text-white hover:text-indigo-100 py-1 px-2.5 rounded-md hover-nav-item transition duration-300 focus:outline-none">
                        Accounts <i class="fas fa-chevron-down ml-2 text-xs"></i>
                    </button>

                    <ul id="accounts-submenu-desktop" class="absolute hidden group-hover:block bg-dropdown text-white py-1 rounded-lg shadow-xl min-w-[210px] z-10 top-full left-0">
                        
                        <!-- Upload Statement Submenu -->
                        <li class="relative group/sub">
                            <a href="#" class="flex items-center justify-between px-4 py-2 bg-dropdown-hover transition duration-200 whitespace-nowrap text-sm">
                                <span>Upload Statement</span>
                                <i class="fas fa-chevron-right text-xs ml-3 text-gray-400"></i>
                            </a>
                            <ul class="absolute left-full top-0 hidden group-hover/sub:block bg-flyout text-white py-1 rounded-lg shadow-xl min-w-[150px] z-20">
                                <li><a href="${ctx}/bom_upload.jsp" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">BOM</a></li>
                                <li><a href="${ctx}/sbi_upload.jsp" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">SBI</a></li>
                            </ul>
                        </li>

                        <!-- View Statement Submenu -->
                        <li class="relative group/sub">
                            <a href="#" class="flex items-center justify-between px-4 py-2 bg-dropdown-hover transition duration-200 whitespace-nowrap text-sm">
                                <span>View Statement</span>
                                <i class="fas fa-chevron-right text-xs ml-3 text-gray-400"></i>
                            </a>
                            <ul class="absolute left-full top-0 hidden group-hover/sub:block bg-flyout text-white py-1 rounded-lg shadow-xl min-w-[150px] z-20">
                                <li><a href="${ctx}/bomReport" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">BOM</a></li>
                                <li><a href="${ctx}/sbiReport" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">SBI</a></li>
                                <li><a href="${ctx}/AllbankreportServlet" class="block px-4 py-2 bg-dropdown-hover transition duration-200 text-sm">AllBank</a></li>
                            </ul>
                        </li>

                    </ul>
                </div>

                <!-- Logout -->
                <a href="${ctx}/logout" class="block mt-2 lg:inline-block lg:mt-0 text-white hover:text-indigo-100 py-1 px-2.5 rounded-md hover-nav-item transition duration-300">
                    Logout
                </a>
            </div>
        </div>
    </div>

    <!-- Mobile Drawer -->
    <div class="hidden lg:hidden w-full mt-2 bg-dropdown rounded-md py-2" id="navbar-links-mobile">
        <a href="${ctx}/dashboard.jsp" class="block px-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Home</a>

        <!-- Mobile HR -->
        <div class="relative">
            <button id="mobile-hr-button" class="w-full text-left px-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 focus:outline-none flex items-center justify-between text-sm">
                <span>HR</span>
                <svg class="w-4 h-4 transform transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
            </button>
            <ul id="mobile-hr-submenu" class="hidden pl-2 py-1 bg-dropdown rounded-md">
                <li class="font-bold text-indigo-300 px-4 py-1 text-xs uppercase tracking-wider">Transactions</li>
                <li><a href="${ctx}/upload.jsp" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Upload Excel</a></li>
                <li><a href="${ctx}/addTransaction" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Add Transaction</a></li>
                <li><a href="${ctx}/report" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">View Report</a></li>
                <li><a href="${ctx}/bankReport" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">View Bank Detail</a></li>

                <li class="font-bold text-indigo-300 px-4 py-1 text-xs uppercase tracking-wider mt-2">Pay Register</li>
                <li><a href="${ctx}/payregister_upload.jsp" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Upload Pay Register</a></li>
                <li><a href="${ctx}/payment_status_update.jsp" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Update Pay Status</a></li>
                <li><a href="${ctx}/pay-register" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">View Pay Register</a></li>
                <li><a href="${ctx}/employeeReport.jsp" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Employee Master</a></li>
            </ul>
        </div>

        <!-- Mobile Accounts -->
        <div class="relative">
            <button id="mobile-accounts-button" class="w-full text-left px-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 focus:outline-none flex items-center justify-between text-sm">
                <span>Accounts</span>
                <svg class="w-4 h-4 transform transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
            </button>
            <ul id="mobile-accounts-submenu" class="hidden pl-2 py-1 bg-dropdown rounded-md">
                <li class="font-bold text-indigo-300 px-4 py-1 text-xs uppercase tracking-wider">Upload Statement</li>
                <li><a href="${ctx}/bom_upload.jsp" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">BOM</a></li>
                <li><a href="${ctx}/sbi_upload.jsp" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">SBI</a></li>
                
                <li class="font-bold text-indigo-300 px-4 py-1 text-xs uppercase tracking-wider mt-2">View Statement</li>
                <li><a href="${ctx}/bomReport" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">BOM</a></li>
                <li><a href="${ctx}/sbiReport" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">SBI</a></li>
                <li><a href="${ctx}/AllbankreportServlet" class="block pl-6 pr-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">All Bank</a></li>
            </ul>
        </div>

        <a href="${ctx}/logout" class="block px-4 py-1.5 text-white bg-dropdown-hover rounded-md transition duration-300 text-sm">Logout</a>
    </div>
</nav>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const menuButton = document.getElementById('menu-button');
    const mobileMenu = document.getElementById('navbar-links-mobile');

    if (menuButton && mobileMenu) {
        menuButton.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
        });

        window.addEventListener('resize', () => {
            if (window.innerWidth >= 1024) {
                mobileMenu.classList.add('hidden');
            }
        });
    }

    function setupMobileToggle(buttonId, submenuId) {
        const btn = document.getElementById(buttonId);
        const menu = document.getElementById(submenuId);
        if (btn && menu) {
            btn.addEventListener('click', () => {
                menu.classList.toggle('hidden');
                const svg = btn.querySelector('svg');
                if (svg) {
                    svg.classList.toggle('rotate-180');
                }
            });
        }
    }

    setupMobileToggle('mobile-hr-button', 'mobile-hr-submenu');
    setupMobileToggle('mobile-accounts-button', 'mobile-accounts-submenu');
});
</script>