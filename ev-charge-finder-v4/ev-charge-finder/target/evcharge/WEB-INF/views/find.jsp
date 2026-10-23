<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
<link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.css">

<h4 class="mb-1">Find a charging station</h4>
<p class="text-muted">Pick your car and battery level, then click the map to set where you are. Stations you can reach are shown in green.</p>

<c:if test="${not empty error}">
  <div class="alert alert-danger"><c:out value="${error}"/></div>
</c:if>

<!-- 1. Controls -->
<div class="card mb-3">
  <div class="card-body">
    <div class="row g-3 align-items-end">
      <div class="col-md-4">
        <label class="form-label" for="vehicle">Your car</label>
        <select id="vehicle" class="form-select">
          <c:forEach var="v" items="${vehicles}">
            <option value="${v.id}"><c:out value="${v.model}"/></option>
          </c:forEach>
        </select>
      </div>
      <div class="col-md-4">
        <label class="form-label" for="battery">Battery now: <b id="batteryOut">30</b>%</label>
        <input type="range" id="battery" min="0" max="100" value="30" class="form-range">
      </div>
      <div class="col-md-4">
        <label class="form-label" for="target">Charge up to: <b id="targetOut">80</b>%</label>
        <input type="range" id="target" min="10" max="100" value="80" class="form-range">
      </div>
    </div>
    <div class="d-flex flex-wrap align-items-center gap-3 mt-3">
      <button type="button" class="btn btn-sm btn-outline-success" onclick="useGps()">Use my current location</button>
      <div class="form-check mb-0">
        <input class="form-check-input" type="checkbox" id="onlyReach">
        <label class="form-check-label" for="onlyReach">Show only stations in range</label>
      </div>
      <div id="summary" class="fw-semibold ms-md-auto"></div>
    </div>
  </div>
</div>

<!-- 2. Map in the middle -->
<div class="position-relative mb-2">
  <div id="routeBanner" class="route-banner d-none"></div>
  <div id="findMap" class="find-map"></div>
</div>
<p id="tip" class="small text-muted mb-1">Showing results from Kanjurmarg. Click the map or use your current location to change the start point.</p>
<p class="small text-muted">Green = in range, Grey = too far, Blue = you.</p>

<!-- 3. Station cards below the map -->
<h5 class="mt-4 mb-3" id="listTitle">Stations</h5>
<div id="list" class="row g-3"></div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.min.js"></script>
<script>
(function () {
  'use strict';

  var API = '${pageContext.request.contextPath}/api/find';
  var DEFAULT_LOC = [19.1308, 72.9285];                       // Kanjurmarg
  var MUMBAI_BOUNDS = L.latLngBounds([18.85, 72.70], [19.40, 73.10]);
  var me = { lat: DEFAULT_LOC[0], lng: DEFAULT_LOC[1] };
  var timer = null;
  var routeControl = null;
  var lastStations = [];
  var pins = {};

  function $(id) { return document.getElementById(id); }

  function esc(v) {
    var d = document.createElement('div');
    d.textContent = (v == null) ? '' : String(v);
    return d.innerHTML;
  }

  function fmtTime(minutes) {
    var m = Math.round(minutes);
    if (m < 60) { return m + ' min'; }
    return Math.floor(m / 60) + ' h ' + (m % 60) + ' min';
  }

  function googleLink(s) {
    return 'https://www.google.com/maps/dir/?api=1&origin=' + me.lat + ',' + me.lng +
           '&destination=' + s.lat + ',' + s.lng + '&travelmode=driving';
  }

  // ---------- map ----------
  var map = L.map('findMap').setView(DEFAULT_LOC, 11);
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map);
  var pinLayer = L.layerGroup().addTo(map);
  var youPin = null;

  function placeYou() {
    if (youPin) { map.removeLayer(youPin); }
    youPin = L.circleMarker([me.lat, me.lng], {
      radius: 9, color: '#001018', weight: 3, fillColor: '#00b3ff', fillOpacity: 1
    }).addTo(map).bindTooltip('You are here');
  }

  function setMe(lat, lng, tip) {
    me.lat = lat;
    me.lng = lng;
    $('tip').textContent = tip;
    clearRoute();
    placeYou();
    search();
  }

  map.on('click', function (e) {
    if (!MUMBAI_BOUNDS.contains(e.latlng)) {
      $('tip').textContent = 'This demo covers Mumbai only. Click a spot inside Mumbai.';
      return;
    }
    setMe(e.latlng.lat, e.latlng.lng, 'Location set. Click the map again to move it.');
  });

  window.useGps = function () {
    if (!navigator.geolocation) {
      $('tip').textContent = 'Your browser does not support location. Click the map instead.';
      return;
    }
    $('tip').textContent = 'Getting your location...';
    navigator.geolocation.getCurrentPosition(function (p) {
      var ll = L.latLng(p.coords.latitude, p.coords.longitude);
      if (!MUMBAI_BOUNDS.contains(ll)) {
        $('tip').textContent = 'You seem to be outside Mumbai. Click a spot on the map instead.';
        return;
      }
      setMe(ll.lat, ll.lng, 'Using your current location.');
      map.setView(ll, 12);
    }, function () {
      $('tip').textContent = 'Could not get your location. Click the map instead.';
    }, { enableHighAccuracy: true, timeout: 8000 });
  };

  // ---------- data (Java servlet /api/find does the calculations) ----------
  function readJson(res) {
    return res.json().then(function (data) {
      if (!res.ok) { throw new Error((data && data.error) || ('HTTP ' + res.status)); }
      return data;
    });
  }

  function search() {
    var q = 'lat=' + me.lat + '&lng=' + me.lng +
            '&vehicleId=' + encodeURIComponent($('vehicle').value) +
            '&battery=' + $('battery').value +
            '&target=' + $('target').value +
            '&reachableOnly=' + $('onlyReach').checked;
    fetch(API + '?' + q).then(readJson).then(show).catch(function (e) {
      $('list').innerHTML = '<div class="col-12"><div class="alert alert-danger">Search failed: ' +
                            esc(e.message) + '</div></div>';
    });
  }

  function popupHtml(i) {
    var s = lastStations[i];
    return '<b>' + esc(s.name) + '</b><br>' + s.straightKm + ' km away<br>' +
           esc(s.connector) + ' | ' + s.speedKw + ' kW<br>' +
           '<button class="btn btn-sm btn-success mt-2" onclick="routeTo(' + i + ')">Route on map</button>';
  }

  function show(data) {
    lastStations = data.stations;
    pinLayer.clearLayers();
    pins = {};

    $('summary').textContent = 'You can drive about ' + Math.round(data.rangeKm) +
                               ' km on ' + Math.round(data.batteryPercent) + '% battery.';

    if (!data.stations.length) {
      $('listTitle').textContent = 'Stations';
      $('list').innerHTML = '<div class="col-12"><div class="alert alert-warning mb-0">' +
        'No stations in range. Try a higher battery level or untick "Show only stations in range".</div></div>';
      return;
    }

    $('listTitle').textContent = 'Stations near you (' + data.stations.length + ')';
    var target = $('target').value;
    var html = '';

    data.stations.forEach(function (s, i) {
      var tag = s.reachable ? '<span class="tag yes">In range</span>' : '<span class="tag no">Too far</span>';
      var cost = data.needKwh > 0
        ? 'Cost to reach ' + target + '%: <b>Rs ' + Math.round(s.cost) + '</b> | about ' + fmtTime(s.timeMin)
        : 'Battery is already at or above the target.';
      var avail = s.available
        ? '<span class="badge bg-success">Available</span>'
        : '<span class="badge bg-danger">Busy</span>';

      html += '<div class="col-md-6"><div class="res-card" data-i="' + i + '">' +
        '<div class="d-flex justify-content-between align-items-start gap-2"><b>' + esc(s.name) + '</b>' + tag + '</div>' +
        '<div class="line">' + esc(s.address) + '</div>' +
        '<div class="line"><b>' + s.straightKm + ' km</b> away (about ' + s.roadKm + ' km by road)</div>' +
        '<div class="line">' + esc(s.connector) + ' | ' + s.speedKw + ' kW | Rs ' + s.pricePerKwh + '/kWh</div>' +
        '<div class="line">' + cost + '</div>' +
        '<div class="line">' + avail + ' <span class="text-muted">(sample data)</span></div>' +
        '<div class="mt-2 d-flex gap-2">' +
          '<button class="btn btn-sm btn-success" onclick="routeTo(' + i + ')">Route on map</button>' +
          '<a class="btn btn-sm btn-outline-secondary" target="_blank" rel="noopener" href="' + googleLink(s) + '">Google Maps</a>' +
        '</div></div></div>';

      var pin = L.circleMarker([s.lat, s.lng], {
        radius: 9, color: '#001a0d', weight: 2,
        fillColor: s.reachable ? '#00ff88' : '#5c6b63', fillOpacity: 1
      }).bindPopup(function () { return popupHtml(i); });
      pinLayer.addLayer(pin);
      pins[i] = pin;
    });

    $('list').innerHTML = html;
  }

  window.focusStation = function (i) {
    var s = lastStations[i];
    if (!s) { return; }
    $('findMap').scrollIntoView({ behavior: 'smooth', block: 'center' });
    map.setView([s.lat, s.lng], 14);
    pins[i].openPopup();
  };

  $('list').addEventListener('click', function (e) {
    if (e.target.closest('a') || e.target.closest('button')) { return; }
    var card = e.target.closest('.res-card');
    if (card) { window.focusStation(Number(card.getAttribute('data-i'))); }
  });

  // ---------- directions on the map ----------
  window.routeTo = function (i) {
    var s = lastStations[i];
    if (!s) { return; }
    map.closePopup();
    removeRouteControl();

    var banner = $('routeBanner');
    banner.classList.remove('d-none');
    banner.innerHTML = 'Finding the best route to <b>' + esc(s.name) + '</b>...';
    $('findMap').scrollIntoView({ behavior: 'smooth', block: 'center' });

    routeControl = L.Routing.control({
      waypoints: [L.latLng(me.lat, me.lng), L.latLng(s.lat, s.lng)],
      show: false,
      addWaypoints: false,
      draggableWaypoints: false,
      routeWhileDragging: false,
      fitSelectedRoutes: true,
      lineOptions: { styles: [{ color: '#00ff88', weight: 5, opacity: 0.95 }] },
      createMarker: function () { return null; }
    }).addTo(map);

    routeControl.on('routesfound', function (e) {
      var r = e.routes[0];
      banner.innerHTML = '<b>' + esc(s.name) + '</b>: ' + fmtTime(r.summary.totalTime / 60) +
        ' (' + (r.summary.totalDistance / 1000).toFixed(1) + ' km) ' +
        '<button class="btn btn-sm btn-light ms-2" onclick="clearRoute()">Clear</button>';
    });

    routeControl.on('routingerror', function () {
      banner.innerHTML = 'Could not load the route. Check your internet connection. ' +
        '<button class="btn btn-sm btn-light ms-2" onclick="clearRoute()">Close</button>';
    });
  };

  function removeRouteControl() {
    if (routeControl) {
      map.removeControl(routeControl);
      routeControl = null;
    }
  }

  window.clearRoute = function () {
    removeRouteControl();
    $('routeBanner').classList.add('d-none');
  };

  // ---------- controls ----------
  function soon() {
    clearTimeout(timer);
    timer = setTimeout(search, 250);
  }
  $('vehicle').addEventListener('change', soon);
  $('onlyReach').addEventListener('change', soon);
  $('battery').addEventListener('input', function () { $('batteryOut').textContent = this.value; soon(); });
  $('target').addEventListener('input', function () { $('targetOut').textContent = this.value; soon(); });

  placeYou();
  search();
})();
</script>
<jsp:include page="footer.jsp"/>
