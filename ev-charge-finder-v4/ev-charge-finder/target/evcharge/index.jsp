<%
    if (session.getAttribute("user") != null) {
        response.sendRedirect(request.getContextPath() + "/find");
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>
