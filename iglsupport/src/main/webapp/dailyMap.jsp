<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reading Locations & Path Map</title>
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        body { font-family: Arial, Helvetica, sans-serif; margin: 20px; background-color: #f4f6f9; }
        .map-container { max-width: 900px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        #map { height: 500px; width: 100%; border-radius: 6px; border: 1px solid #cbd5e1; margin-top: 15px; }
        .header-box { background: #f8fafc; padding: 15px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 14px; }
        .header-box p { margin: 5px 0; color: #334155; }
        .btn { padding: 8px 16px; background-color: #64748b; color: white; border: none; border-radius: 4px; cursor: pointer; margin-top: 15px; font-weight: 600; }
        .btn:hover { background-color: #475569; }
        .legend { margin-top: 10px; font-size: 13px; font-weight: bold; color: #334155; display: flex; gap: 20px; }
        .legend span { display: inline-block; width: 12px; height: 12px; border-radius: 50%; margin-right: 4px; }
        .dot-green { background-color: #22c55e; }
        .dot-red { background-color: #ef4444; }
        .dot-blue { background-color: #3b82f6; }
    </style>
</head>
<body>

    <div class="map-container">
        <h2>Meter Reader Route Map</h2>
        <br>
        <div class="header-box">
            <p><strong>Meter Reader ID:</strong> ${userId}</p>
            <p><strong>Selected Schedule Date:</strong> ${selectedDate}</p>
            <div class="legend">
                <div><span class="dot-green"></span> Start Point (First Reading)</div>
                <div><span class="dot-red"></span> End Point (Last Reading)</div>
                <div><span class="dot-blue"></span> Intermediate Stops</div>
            </div>
        </div>

        <div id="map"></div>

        <button class="btn" onclick="window.close()">Close Map</button>
    </div>

    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        var map = L.map('map').setView([20.5937, 78.9629], 5);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        // Load locations sorted by time from backend
        var locations = [
            <c:forEach var="loc" items="${locations}">
                { lat: ${loc.lat}, lon: ${loc.lon}, time: "${loc.readingDate}" },
            </c:forEach>
        ];

        var latLngs = [];
        var bounds = [];

        if (locations && locations.length > 0) {
            locations.forEach(function(loc, index) {
                if (loc.lat && loc.lon && loc.lat !== 0 && loc.lon !== 0) {
                    var point = [loc.lat, loc.lon];
                    latLngs.push(point);
                    bounds.push(point);

                    var marker;

                    // 1. First Reading (Start Point) -> Render as a Green Circle
                    if (index === 0) {
                        marker = L.circleMarker(point, {
                            radius: 9,
                            color: '#ffffff',      // White border
                            weight: 2,
                            fillColor: '#22c55e',  // Green fill
                            fillOpacity: 1
                        }).addTo(map);
                        
                        marker.bindPopup("<strong>🟢 START POINT (First Reading)</strong><br><strong>Time:</strong> " + loc.time + "<br><strong>Lat/Lon:</strong> " + loc.lat + ", " + loc.lon);
                    } 
                    // 2. Last Reading (End Point) -> Render as a Red Circle
                    else if (index === locations.length - 1) {
                        marker = L.circleMarker(point, {
                            radius: 9,
                            color: '#ffffff',      // White border
                            weight: 2,
                            fillColor: '#ef4444',  // Red fill
                            fillOpacity: 1
                        }).addTo(map);
                        
                        marker.bindPopup("<strong>🔴 END POINT (Last Reading)</strong><br><strong>Time:</strong> " + loc.time + "<br><strong>Lat/Lon:</strong> " + loc.lat + ", " + loc.lon);
                    } 
                    // 3. Intermediate Stops -> Render as standard Markers
                    else {
                        marker = L.marker(point).addTo(map);
                        marker.bindPopup("<strong>Stop #" + (index + 1) + "</strong><br><strong>Time:</strong> " + loc.time + "<br><strong>Lat/Lon:</strong> " + loc.lat + ", " + loc.lon);
                    }
                }
            });

            // Draw a chronological line connecting all the points path
            if (latLngs.length > 1) {
                var polyline = L.polyline(latLngs, {
                    color: '#2563eb', // Blue path line
                    weight: 4,
                    opacity: 0.7
                }).addTo(map);
            }

            if (bounds.length > 0) {
                map.fitBounds(bounds);
            }
        } else {
            alert("No GPS coordinates found for user " + "${userId}" + " on " + "${selectedDate}");
        }
    </script>