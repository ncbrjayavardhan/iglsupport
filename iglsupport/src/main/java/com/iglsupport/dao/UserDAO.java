package com.iglsupport.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.iglsupport.config.DBConnection;

public class UserDAO {

    public static class UserSessionInfo {
        private String role;
        private Integer gid;
        private Integer vid;

        public UserSessionInfo(String role, Integer gid, Integer vid) {
            this.role = role;
            this.gid = gid;
            this.vid = vid;
        }

        public String getRole() { return role; }
        public Integer getGid() { return gid; }
        public Integer getVid() { return vid; }
    }

    public static boolean validateUser(String userId, String pwd) {
        boolean status = false;
        String sql = "SELECT * FROM `user` WHERE userId = ? AND pwd = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, userId);
            pst.setString(2, pwd);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    status = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return status;
    }
    
    public static UserSessionInfo getUserInfo(String userId, String pwd) {
        UserSessionInfo userInfo = null;
        String sql = "SELECT role, gid, vid FROM `user` WHERE userId = ? AND pwd = ? AND status = 'Active'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, userId);
            pst.setString(2, pwd);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    int gid = rs.getInt("gid");
                    Integer gidObj = rs.wasNull() ? null : gid;
                    
                    int vid = rs.getInt("vid");
                    Integer vidObj = rs.wasNull() ? null : vid;

                    userInfo = new UserSessionInfo(role, gidObj, vidObj);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return userInfo;
    }
}