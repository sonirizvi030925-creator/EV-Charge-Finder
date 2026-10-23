<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>
<h4 class="mb-3">Charging Stations</h4>
<c:if test="${not empty error}">
  <div class="alert alert-danger"><c:out value="${error}"/></div>
</c:if>

<form method="get" action="${pageContext.request.contextPath}/stations" class="card card-body shadow-sm mb-4">
  <div class="row g-2 align-items-end">
    <div class="col-md-3">
      <label class="form-label">Connector type</label>
      <select name="connector" class="form-select">
        <option value="">All</option>
        <c:forEach var="c" items="${connectors}">
          <option value="${c}" ${param.connector == c ? 'selected' : ''}>${c}</option>
        </c:forEach>
      </select>
    </div>
    <div class="col-md-2">
      <label class="form-label">My latitude</label>
      <input type="text" id="lat" name="lat" value="${param.lat}" class="form-control" placeholder="19.1308">
    </div>
    <div class="col-md-2">
      <label class="form-label">My longitude</label>
      <input type="text" id="lng" name="lng" value="${param.lng}" class="form-control" placeholder="72.9285">
    </div>
    <div class="col-md-5">
      <button type="button" class="btn btn-outline-secondary" onclick="useMyLocation()">Use my location</button>
      <button class="btn btn-success">Search / Nearest first</button>
      <a class="btn btn-link" href="${pageContext.request.contextPath}/stations">Reset</a>
    </div>
  </div>
  <div class="form-text">Enter your location to sort stations by distance (Haversine formula).</div>
</form>

<div class="table-responsive">
<table class="table table-striped table-hover bg-white shadow-sm align-middle">
  <thead class="table-success">
    <tr>
      <th>Name</th><th>Address</th><th>Connector</th><th>Speed (kW)</th>
      <th>Price/kWh (Rs)</th><th>Status</th>
      <c:if test="${showDistance}"><th>Distance (km)</th></c:if>
      <th>Directions</th>
    </tr>
  </thead>
  <tbody>
    <c:forEach var="s" items="${stations}">
      <tr>
        <td><c:out value="${s.name}"/></td>
        <td><c:out value="${s.address}"/></td>
        <td><c:out value="${s.connectorType}"/></td>
        <td>${s.chargingSpeed}</td>
        <td>${s.pricePerKwh}</td>
        <td>
          <c:choose>
            <c:when test="${s.available}"><span class="badge bg-success">Available</span></c:when>
            <c:otherwise><span class="badge bg-danger">Busy</span></c:otherwise>
          </c:choose>
        </td>
        <c:if test="${showDistance}">
          <td><fmt:formatNumber value="${s.distanceKm}" maxFractionDigits="1"/></td>
        </c:if>
        <td>
          <a class="btn btn-sm btn-outline-success" target="_blank" rel="noopener"
             href="https://www.google.com/maps/dir/?api=1&amp;destination=${s.latitude},${s.longitude}">Directions</a>
        </td>
      </tr>
    </c:forEach>
    <c:if test="${empty stations}">
      <tr><td colspan="8" class="text-center text-muted">No stations found.</td></tr>
    </c:if>
  </tbody>
</table>
</div>

<script>
function useMyLocation() {
  if (!navigator.geolocation) { alert("Your browser does not support location."); return; }
  navigator.geolocation.getCurrentPosition(function (p) {
    document.getElementById("lat").value = p.coords.latitude.toFixed(5);
    document.getElementById("lng").value = p.coords.longitude.toFixed(5);
  }, function () { alert("Could not get your location. Please enter latitude and longitude manually."); });
}
</script>
<jsp:include page="footer.jsp"/>
