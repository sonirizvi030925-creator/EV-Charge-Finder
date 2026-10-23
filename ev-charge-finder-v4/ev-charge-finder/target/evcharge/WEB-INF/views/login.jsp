<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp"/>
<div class="row justify-content-center">
  <div class="col-md-5">
    <div class="card shadow-sm">
      <div class="card-body">
        <h4 class="mb-3">Login</h4>
        <c:if test="${param.registered == '1'}">
          <div class="alert alert-success">Registration successful. Please log in.</div>
        </c:if>
        <c:if test="${not empty error}">
          <div class="alert alert-danger"><c:out value="${error}"/></div>
        </c:if>
        <form method="post" action="${pageContext.request.contextPath}/login">
          <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control" required>
          </div>
          <button class="btn btn-success w-100">Login</button>
        </form>
        <p class="mt-3 mb-0 text-center">New user? <a href="${pageContext.request.contextPath}/register">Register</a></p>
      </div>
    </div>
  </div>
</div>
<jsp:include page="footer.jsp"/>
