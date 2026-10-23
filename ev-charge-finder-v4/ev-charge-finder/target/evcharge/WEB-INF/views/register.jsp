<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp"/>
<div class="row justify-content-center">
  <div class="col-md-5">
    <div class="card shadow-sm">
      <div class="card-body">
        <h4 class="mb-3">Register</h4>
        <c:if test="${not empty error}">
          <div class="alert alert-danger"><c:out value="${error}"/></div>
        </c:if>
        <form method="post" action="${pageContext.request.contextPath}/register">
          <div class="mb-3">
            <label class="form-label">Name</label>
            <input type="text" name="name" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Password (min 6 characters)</label>
            <input type="password" name="password" class="form-control" minlength="6" required>
          </div>
          <button class="btn btn-success w-100">Register</button>
        </form>
        <p class="mt-3 mb-0 text-center">Already have an account? <a href="${pageContext.request.contextPath}/login">Login</a></p>
      </div>
    </div>
  </div>
</div>
<jsp:include page="footer.jsp"/>
