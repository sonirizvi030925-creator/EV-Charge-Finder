<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="header.jsp"/>
<h4 class="mb-3">Range &amp; Cost Planner</h4>
<c:if test="${not empty error}">
  <div class="alert alert-danger"><c:out value="${error}"/></div>
</c:if>

<form method="post" action="${pageContext.request.contextPath}/planner" class="card card-body shadow-sm mb-4">
  <div class="row g-3">
    <div class="col-md-4">
      <label class="form-label">Vehicle</label>
      <select name="vehicleId" class="form-select" required>
        <c:forEach var="v" items="${vehicles}">
          <option value="${v.id}" ${param.vehicleId == v.id ? 'selected' : ''}>
            <c:out value="${v.model}"/> (${v.batteryKwh} kWh, ${v.fullRangeKm} km)
          </option>
        </c:forEach>
      </select>
    </div>
    <div class="col-md-2">
      <label class="form-label">Current battery %</label>
      <input type="number" name="battery" min="0" max="100" step="any"
             value="${empty param.battery ? '30' : param.battery}" class="form-control" required>
    </div>
    <div class="col-md-2">
      <label class="form-label">Charge up to %</label>
      <input type="number" name="target" min="1" max="100" step="any"
             value="${empty param.target ? '80' : param.target}" class="form-control" required>
    </div>
    <div class="col-md-2">
      <label class="form-label">My latitude</label>
      <input type="text" id="lat" name="lat" value="${empty param.lat ? '19.1308' : param.lat}" class="form-control" required>
    </div>
    <div class="col-md-2">
      <label class="form-label">My longitude</label>
      <input type="text" id="lng" name="lng" value="${empty param.lng ? '72.9285' : param.lng}" class="form-control" required>
    </div>
  </div>
  <div class="mt-3">
    <button type="button" class="btn btn-outline-secondary" onclick="useMyLocation()">Use my location</button>
    <button class="btn btn-success">Calculate</button>
  </div>
  <div class="form-text">Default location is Kanjurmarg. Road distance is estimated as straight-line distance x 1.3.</div>
</form>

<c:if test="${calculated}">
  <div class="row mb-3">
    <div class="col-md-4">
      <div class="card text-center shadow-sm"><div class="card-body">
        <div class="text-muted">Estimated remaining range</div>
        <div class="fs-3 fw-bold"><fmt:formatNumber value="${rangeKm}" maxFractionDigits="0"/> km</div>
      </div></div>
    </div>
    <div class="col-md-4">
      <div class="card text-center shadow-sm"><div class="card-body">
        <div class="text-muted">Energy needed</div>
        <div class="fs-3 fw-bold"><fmt:formatNumber value="${needKwh}" maxFractionDigits="1"/> kWh</div>
      </div></div>
    </div>
    <div class="col-md-4">
      <div class="card text-center shadow-sm"><div class="card-body">
        <div class="text-muted">Reachable stations</div>
        <div class="fs-3 fw-bold">${reachable.size()}</div>
      </div></div>
    </div>
  </div>

  <div class="table-responsive">
  <table class="table table-striped bg-white shadow-sm align-middle">
    <thead class="table-success">
      <tr><th>Station</th><th>Connector</th><th>Road dist (km)</th><th>Price/kWh</th>
          <th>Est. cost (Rs)</th><th>Est. time (min)</th><th>Status</th></tr>
    </thead>
    <tbody>
      <c:forEach var="s" items="${reachable}">
        <tr>
          <td><c:out value="${s.name}"/></td>
          <td><c:out value="${s.connectorType}"/></td>
          <td><fmt:formatNumber value="${s.roadKm}" maxFractionDigits="1"/></td>
          <td>${s.pricePerKwh}</td>
          <td><fmt:formatNumber value="${s.cost}" maxFractionDigits="0"/></td>
          <td><fmt:formatNumber value="${s.timeMin}" maxFractionDigits="0"/></td>
          <td>
            <c:choose>
              <c:when test="${s.available}"><span class="badge bg-success">Available</span></c:when>
              <c:otherwise><span class="badge bg-danger">Busy</span></c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty reachable}">
        <tr><td colspan="7" class="text-center text-danger">No station is within range at this battery level.</td></tr>
      </c:if>
    </tbody>
  </table>
  </div>
</c:if>

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
