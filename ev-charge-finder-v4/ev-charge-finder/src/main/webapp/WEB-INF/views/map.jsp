<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.css">

<div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
  <h4 class="mb-0">Stations Map &amp; Directions</h4>
  <div>
    <span id="locStatus" class="small text-muted me-2">Detecting your location...</span>
    <button type="button" id="pickBtn" class="btn btn-sm btn-outline-success" onclick="togglePick()">Pick start point on map</button>
  </div>
</div>

<c:if test="${not empty error}">
  <div class="alert alert-danger"><c:out value="${error}"/></div>
</c:if>

<div class="row g-3">
  <div class="col-lg-8">
    <div id="map"></div>
    <p class="text-muted small mt-2 mb-0">
      Green = Available, Red = Busy, Blue = You. Click a station, then press <b>Directions</b>.
    </p>
  </div>
  <div class="col-lg-4">
    <div id="routePanel" class="card mb-3 d-none">
      <div class="card-body">
        <div class="d-flex justify-content-between align-items-start">
          <h6 class="mb-2">Route</h6>
          <button type="button" class="btn btn-sm btn-outline-secondary" onclick="clearRoute()">Clear</button>
        </div>
        <div id="routeInfo" class="mb-2"></div>
        <div id="routeSteps" class="route-steps"></div>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <h6 class="mb-3">Stations near you</h6>
        <div id="stationList" class="station-list"></div>
      </div>
    </div>
  </div>
</div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.min.js"></script>
<script>
  // Used when the browser cannot give the real location (Kanjurmarg, Mumbai)
  var DEFAULT_LOC = [19.1308, 72.9285];

  // Stations loaded from the database (MapServlet -> StationDAO)
  var stations = [
  <c:forEach var="s" items="${stations}" varStatus="st">
    { name: "<c:out value='${s.name}'/>",
      address: "<c:out value='${s.address}'/>",
      connector: "<c:out value='${s.connectorType}'/>",
      lat: ${s.latitude}, lng: ${s.longitude},
      speed: ${s.chargingSpeed}, price: ${s.pricePerKwh},
      available: ${s.available} }${st.last ? '' : ','}
  </c:forEach>
  ];

  var map = L.map('map').setView([19.09, 72.88], 11);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map);

  var userLatLng = L.latLng(DEFAULT_LOC[0], DEFAULT_LOC[1]);
  var userMarker = null;
  var routeControl = null;
  var markers = [];
  var pickMode = false;

  function dot(color) {
    return L.divIcon({
      className: '',
      html: '<div style="width:18px;height:18px;border-radius:50%;background:' + color +
            ';border:2px solid #001a0d;box-shadow:0 0 10px ' + color + ',0 0 20px ' + color + '"></div>',
      iconSize: [18, 18], iconAnchor: [9, 9]
    });
  }

  function googleMapsLink(i) {
    var s = stations[i];
    return 'https://www.google.com/maps/dir/?api=1&origin=' + userLatLng.lat + ',' + userLatLng.lng +
           '&destination=' + s.lat + ',' + s.lng + '&travelmode=driving';
  }

  function popupHtml(i) {
    var s = stations[i];
    return '<div><b>' + s.name + '</b><br>' + s.address + '<br>' +
           'Connector: ' + s.connector + '<br>' +
           'Speed: ' + s.speed + ' kW<br>' +
           'Price: Rs ' + s.price + '/kWh<br>' +
           'Status: ' + (s.available ? 'Available' : 'Busy') +
           '<div class="mt-2 d-flex gap-2">' +
           '<button class="btn btn-sm btn-success" onclick="navigateTo(' + i + ')">Directions</button>' +
           '<a class="btn btn-sm btn-outline-secondary" target="_blank" rel="noopener" href="' +
           googleMapsLink(i) + '">Google Maps</a></div></div>';
  }

  // ----- station markers -----
  var bounds = [];
  stations.forEach(function (s, i) {
    bounds.push([s.lat, s.lng]);
    markers[i] = L.marker([s.lat, s.lng], { icon: dot(s.available ? '#00ff88' : '#ff3b5c') })
      .addTo(map)
      .bindPopup(function () { return popupHtml(i); });
  });
  if (bounds.length > 0) { map.fitBounds(bounds, { padding: [30, 30] }); }

  // ----- station list (nearest first) -----
  function renderList() {
    var order = stations.map(function (s, i) {
      return { i: i, d: userLatLng.distanceTo(L.latLng(s.lat, s.lng)) / 1000 };
    });
    order.sort(function (a, b) { return a.d - b.d; });

    var html = '';
    order.forEach(function (o) {
      var s = stations[o.i];
      html += '<div class="station-item" onclick="focusStation(' + o.i + ')">' +
              '<div class="d-flex justify-content-between"><b>' + s.name + '</b>' +
              '<span class="badge ' + (s.available ? 'bg-success' : 'bg-danger') + '">' +
              (s.available ? 'Available' : 'Busy') + '</span></div>' +
              '<div class="small text-muted">' + s.connector + ' | ' + s.speed + ' kW | Rs ' + s.price + '/kWh</div>' +
              '<div class="small">' + o.d.toFixed(1) + ' km away (straight line)</div>' +
              '<button class="btn btn-sm btn-success mt-1" onclick="event.stopPropagation(); navigateTo(' + o.i + ')">Directions</button>' +
              '</div>';
    });
    if (html === '') { html = '<div class="text-muted">No stations found.</div>'; }
    document.getElementById('stationList').innerHTML = html;
  }

  function focusStation(i) {
    map.setView([stations[i].lat, stations[i].lng], 15);
    markers[i].openPopup();
  }

  // ----- user location -----
  function setUserLocation(lat, lng, message) {
    userLatLng = L.latLng(lat, lng);
    if (userMarker) { map.removeLayer(userMarker); }
    userMarker = L.marker(userLatLng, {
      icon: L.divIcon({ className: '', html: '<div class="user-dot"></div>', iconSize: [16, 16], iconAnchor: [8, 8] })
    }).addTo(map).bindTooltip('Start point');
    document.getElementById('locStatus').textContent = message;
    renderList();
  }

  function useDefaultLocation() {
    setUserLocation(DEFAULT_LOC[0], DEFAULT_LOC[1],
      'Using default start point (Kanjurmarg). You can pick another on the map.');
  }

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (p) {
      setUserLocation(p.coords.latitude, p.coords.longitude, 'Using your current location.');
    }, useDefaultLocation, { enableHighAccuracy: true, timeout: 8000 });
  } else {
    useDefaultLocation();
  }

  // ----- pick a start point by clicking on the map -----
  function togglePick() {
    pickMode = !pickMode;
    var btn = document.getElementById('pickBtn');
    btn.textContent = pickMode ? 'Click on the map now...' : 'Pick start point on map';
    btn.classList.toggle('active', pickMode);
  }
  map.on('click', function (e) {
    if (!pickMode) { return; }
    setUserLocation(e.latlng.lat, e.latlng.lng, 'Using the start point you picked.');
    togglePick();
  });

  // ----- directions -----
  function navigateTo(i) {
    var s = stations[i];
    map.closePopup();
    removeRouteControl();

    document.getElementById('routePanel').classList.remove('d-none');
    document.getElementById('routeInfo').innerHTML = 'Finding the best route to <b>' + s.name + '</b>...';

    routeControl = L.Routing.control({
      waypoints: [userLatLng, L.latLng(s.lat, s.lng)],
      routeWhileDragging: false,
      addWaypoints: false,
      draggableWaypoints: false,
      showAlternatives: false,
      fitSelectedRoutes: true,
      lineOptions: { styles: [{ color: '#00ff88', weight: 5, opacity: 0.95 }] },
      createMarker: function () { return null; }
    }).addTo(map);

    // show the turn-by-turn steps inside the side panel
    document.getElementById('routeSteps').innerHTML = '';
    document.getElementById('routeSteps').appendChild(routeControl.getContainer());

    routeControl.on('routesfound', function (e) {
      var r = e.routes[0];
      var km = (r.summary.totalDistance / 1000).toFixed(1);
      var min = Math.round(r.summary.totalTime / 60);
      document.getElementById('routeInfo').innerHTML =
        '<div class="fs-5 fw-bold text-success">' + min + ' min (' + km + ' km)</div>' +
        '<div>To <b>' + s.name + '</b></div>' +
        '<a class="btn btn-sm btn-outline-success mt-2" target="_blank" rel="noopener" href="' +
        googleMapsLink(i) + '">Open in Google Maps</a>';
    });

    routeControl.on('routingerror', function () {
      document.getElementById('routeInfo').innerHTML =
        '<div class="text-danger">Could not load the route. Check your internet connection.</div>' +
        '<a class="btn btn-sm btn-outline-success mt-2" target="_blank" rel="noopener" href="' +
        googleMapsLink(i) + '">Open in Google Maps</a>';
    });
  }

  function removeRouteControl() {
    if (routeControl) {
      map.removeControl(routeControl);
      routeControl = null;
    }
  }

  function clearRoute() {
    removeRouteControl();
    document.getElementById('routePanel').classList.add('d-none');
    document.getElementById('routeSteps').innerHTML = '';
  }
</script>
<jsp:include page="footer.jsp"/>
