<HTML>

<HEAD>
	<TITLE>User Management Module</TITLE>
	<style>    
    ul {
		list-style-type: none;
		margin: 0;
		padding: 0;
	}

	li {
		display: inline;
	}
    </style>
</HEAD>

<BODY>
	<%@ page import="java.sql.*" %>
	<%@ page import="javax.sql.*" %>
	<%@ page import="javax.naming.*" %>

	<%
		// Return user to login page if session expired.
		Integer person_id = (Integer) session.getAttribute("person_id");
		String cls = "";
		if(person_id == null) 
			response.sendRedirect("login.jsp");
		else {
			cls = (String) session.getAttribute("class");
			if(!cls.equals("a"))
				response.sendRedirect("../login/home.jsp");
		}
	%>

	<!--Navigation Bar
		TODO: Update links.
	-->
	<ul>
		<li><a href="../login/home.jsp">Home</a></li>
		<li><a href="../login/personal_info.jsp">Change Personal Info</a></li>
		<li><a href="../search.jsp">Search Records</a></li>
		<% if(cls.equals("a")) { %>
			<li><a href="../user-management/userManagement.jsp">User Management</a></li>
			<li><a href="../report_generator.jsp">Generate Reports</a></li>
			<li><a href="dataAnalysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="../uplaod/upload.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="../login/logout.jsp">Logout</a></li>
	</ul>
	
	<br>
	<% int inputWidth = 150; %>
	<form method=post action=dataAnalysis.jsp>
		<input type=number name=PatientID maxlength=10 placeholder="Patient ID" style="width: <%= inputWidth %>px;"><br>
		<input type=text name=TestType maxlength=24 placeholder="Test Type" style="width: <%= inputWidth %>px;"><br>
		Start Date:<br>
			<input type=number name=startDateMM placeholder="mm" style="width: <%= inputWidth %>px;"><br>
			<input type=number name=startDateDD placeholder="dd" style="width: <%= inputWidth %>px;"><br>
			<input type=number name=startDateYYYY placeholder="yyyy" style="width: <%= inputWidth %>px;"><br>
		End Date:<br>
			<input type=number name=endDateMM placeholder="mm" style="width: <%= inputWidth %>px;"><br>
			<input type=number name=endDateDD placeholder="dd" style="width: <%= inputWidth %>px;"><br>
			<input type=number name=endDateYYYY placeholder="yyyy" style="width: <%= inputWidth %>px;"><br>
		<input type=submit name=runAnalytics value= "Run Analytics" style="width: <%= inputWidth %>px;"><br>
	</form>

</BODY>

</HTML>
