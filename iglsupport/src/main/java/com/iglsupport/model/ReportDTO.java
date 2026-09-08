package com.iglsupport.model;

import java.time.LocalDate;

public class ReportDTO {
    private String state;
    private String city;
    private String gaName;
    private int portionId;
    private Integer totalData;
    private String schedule;
    private LocalDate startDate;
    private LocalDate endDate;
    private int todayReading;
    private int todayInv;
    private int tillYdayRead;
    private int tillYdayInv;
    private int totalReading;
    private int totalInv;
    private int unbilled;
    private double billedPercent;
    private String status;
    private Integer perDayTarget;
    private Integer diff;
    
    private int yesterdayReading;
    private int yesterdayInv;

    // Added fields for Meter Reader Daily Report
    private String readingDate;
    private int readingCount;
    
 // Added fields for Maps
    private double lat;
    private double lon;

    public ReportDTO() {}

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getGaName() { return gaName; }
    public void setGaName(String gaName) { this.gaName = gaName; }

    public int getPortionId() { return portionId; }
    public void setPortionId(int portionId) { this.portionId = portionId; }

    public Integer getTotalData() { return totalData; }
    public void setTotalData(Integer totalData) { this.totalData = totalData; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public int getTodayReading() { return todayReading; }
    public void setTodayReading(int todayReading) { this.todayReading = todayReading; }

    public int getTodayInv() { return todayInv; }
    public void setTodayInv(int todayInv) { this.todayInv = todayInv; }

    public int getTillYdayRead() { return tillYdayRead; }
    public void setTillYdayRead(int tillYdayRead) { this.tillYdayRead = tillYdayRead; }

    public int getTillYdayInv() { return tillYdayInv; }
    public void setTillYdayInv(int tillYdayInv) { this.tillYdayInv = tillYdayInv; }

    public int getTotalReading() { return totalReading; }
    public void setTotalReading(int totalReading) { this.totalReading = totalReading; }

    public int getTotalInv() { return totalInv; }
    public void setTotalInv(int totalInv) { this.totalInv = totalInv; }

    public int getUnbilled() { return unbilled; }
    public void setUnbilled(int unbilled) { this.unbilled = unbilled; }

    public double getBilledPercent() { return billedPercent; }
    public void setBilledPercent(double billedPercent) { this.billedPercent = billedPercent; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getPerDayTarget() { return perDayTarget; }
    public void setPerDayTarget(Integer perDayTarget) { this.perDayTarget = perDayTarget; }

    public Integer getDiff() { return diff; }
    public void setDiff(Integer diff) { this.diff = diff; }
    
    public int getYesterdayReading() { return yesterdayReading; }
    public void setYesterdayReading(int yesterdayReading) { this.yesterdayReading = yesterdayReading; }

    public int getYesterdayInv() { return yesterdayInv; }
    public void setYesterdayInv(int yesterdayInv) { this.yesterdayInv = yesterdayInv; }

    // Getters and Setters for Daily Report fields
    public String getReadingDate() { return readingDate; }
    public void setReadingDate(String readingDate) { this.readingDate = readingDate; }

    public int getReadingCount() { return readingCount; }
    public void setReadingCount(int readingCount) { this.readingCount = readingCount; }
    
    
    // Getters and Setters for Maps fields
    public double getLat() { return lat; }
    public void setLat(double lat) { this.lat = lat; }

    public double getLon() { return lon; }
    public void setLon(double lon) { this.lon = lon; }
}