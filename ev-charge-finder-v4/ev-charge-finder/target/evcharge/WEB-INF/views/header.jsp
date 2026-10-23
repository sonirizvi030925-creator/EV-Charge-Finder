<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#050805">
  <title>EV Charge Finder</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Orbitron:wght@700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark mb-4">
  <div class="container">
    <a class="navbar-brand" href="${pageContext.request.contextPath}/">EV Charge Finder</a>
    <div class="navbar-nav ms-auto flex-row flex-wrap gap-3">
      <c:choose>
        <c:when test="${not empty sessionScope.user}">
          <a class="nav-link" href="${pageContext.request.contextPath}/find">Find Stations</a>
          <a class="nav-link" href="${pageContext.request.contextPath}/stations">All Stations</a>
          <a class="nav-link" href="${pageContext.request.contextPath}/map">Map</a>
          <a class="nav-link" href="${pageContext.request.contextPath}/planner">Range Planner</a>
          <span class="nav-link text-warning">Hi, <c:out value="${sessionScope.user.name}"/></span>
          <a class="nav-link" href="${pageContext.request.contextPath}/logout">Logout</a>
        </c:when>
        <c:otherwise>
          <a class="nav-link" href="${pageContext.request.contextPath}/login">Login</a>
          <a class="nav-link" href="${pageContext.request.contextPath}/register">Register</a>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</nav>
<div class="container">
