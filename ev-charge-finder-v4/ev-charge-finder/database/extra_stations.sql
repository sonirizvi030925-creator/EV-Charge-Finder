USE ev_charge_finder;

-- (Optional) purane 3 stations ko proper naam do
UPDATE stations SET name='EV Point Bandra',  address='Bandra West, Mumbai'        WHERE id=1;
UPDATE stations SET name='EV Point BKC',     address='Bandra Kurla Complex, Mumbai' WHERE id=2;
UPDATE stations SET name='EV Point Andheri', address='Andheri East, Mumbai'       WHERE id=3;

-- Naye demo stations (real nahi hain, demo data)
INSERT INTO stations (name, address, latitude, longitude, connector_type, charging_speed, price_per_kwh, available) VALUES
('EV Point Kanjurmarg', 'Kanjurmarg, Mumbai',      19.1308, 72.9285, 'CCS2',    30.00, 14.00, 1),
('EV Point Dadar',      'Dadar, Mumbai',           19.0178, 72.8478, 'Type 2',  22.00, 15.00, 1),
('EV Point Powai',      'Powai, Mumbai',           19.1176, 72.9060, 'CCS2',    60.00, 19.00, 0),
('EV Point Vikhroli',   'Vikhroli, Mumbai',        19.1110, 72.9275, 'CCS2',    30.00, 14.50, 1),
('EV Point Ghatkopar',  'Ghatkopar, Mumbai',       19.0860, 72.9090, 'CHAdeMO', 50.00, 17.00, 1),
('EV Point Borivali',   'Borivali West, Mumbai',   19.2307, 72.8567, 'CCS2',    30.00, 15.50, 1),
('EV Point Thane',      'Thane West',              19.2183, 72.9781, 'CCS2',    50.00, 16.00, 1),
('EV Point Worli',      'Worli, Mumbai',           19.0176, 72.8153, 'CCS2',    60.00, 20.00, 1),
('EV Point Colaba',     'Colaba, Mumbai',          18.9067, 72.8147, 'Type 2',  22.00, 16.50, 0),
('EV Point Vashi',      'Vashi, Navi Mumbai',      19.0771, 72.9986, 'CCS2',    30.00, 14.00, 1);
