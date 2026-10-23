package com.evfinder.dao;

import com.evfinder.model.Vehicle;
import com.evfinder.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAO {

    private Vehicle map(ResultSet rs) throws SQLException {
        Vehicle v = new Vehicle();
        v.setId(rs.getInt("id"));
        v.setModel(rs.getString("model"));
        v.setBatteryKwh(rs.getDouble("battery_kwh"));
        v.setFullRangeKm(rs.getDouble("full_range_km"));
        return v;
    }

    public List<Vehicle> getAll() throws SQLException {
        List<Vehicle> list = new ArrayList<>();
        String sql = "SELECT id, model, battery_kwh, full_range_km FROM vehicles ORDER BY model";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    public Vehicle getById(int id) throws SQLException {
        String sql = "SELECT id, model, battery_kwh, full_range_km FROM vehicles WHERE id = ?";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }
}
