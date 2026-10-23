package com.evfinder.dao;

import com.evfinder.model.Station;
import com.evfinder.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StationDAO {

    public List<Station> getAll() throws SQLException {
        List<Station> list = new ArrayList<>();
        String sql = "SELECT id, name, address, latitude, longitude, connector_type, "
                + "charging_speed, price_per_kwh, available FROM stations ORDER BY name";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Station s = new Station();
                s.setId(rs.getInt("id"));
                s.setName(rs.getString("name"));
                s.setAddress(rs.getString("address"));
                s.setLatitude(rs.getDouble("latitude"));
                s.setLongitude(rs.getDouble("longitude"));
                s.setConnectorType(rs.getString("connector_type"));
                s.setChargingSpeed(rs.getDouble("charging_speed"));
                s.setPricePerKwh(rs.getDouble("price_per_kwh"));
                s.setAvailable(rs.getBoolean("available"));
                list.add(s);
            }
        }
        return list;
    }
}
