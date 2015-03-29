<HTML> 
    <BODY> 
	<!--Logout user by invalidating current session.
		@author  Braeden Soetaert
	 -->
	<% 
		session.invalidate(); 
		response.sendRedirect("login.jsp");
	%>		
    </BODY> 
</HTML> 
