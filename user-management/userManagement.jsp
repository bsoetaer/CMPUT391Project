<HTML>

<HEAD>
	<TITLE>User Management Module</TITLE>
	<style type="text/css">
    .container {
        width: 200px;
        clear: both;
    }
    .container input {
        width: 100%;
        clear: both;
    }
    
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
	
	<%!

		/**
		 * Get string data or empty string if data is null
		 */
		String getStringData(ResultSet rset, Integer colId) throws SQLException{
			String data = rset.getString(colId);
			if(data == null)
				return "";
			else
				return data.trim();
		}
	%>

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

	<!--Navigation Bar -->
	<ul>
		<li><a href="../login/home.jsp">Home</a></li>
		<li><a href="../login/personal_info.jsp">Change Personal Info</a></li>
		<li><a href="../search/search.jsp">Search Records</a></li>
		<% if(cls.equals("a")) { %>
			<li><a href="userManagement.jsp">User Management</a></li>
			<li><a href="../generate_reports/generate_report.jsp">Generate Reports</a></li>
			<li><a href="../data_analysis/dataAnalysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="../upload/make_record.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="../docs/user-manual/User-Management.html#User-Management">Help</a></li>
		<li><a href="../login/logout.jsp">Logout</a></li>
	</ul>
	
	<br>
	
	<div class="container">
		<form method=post action=personEdit.jsp>
			<input type=submit name=personEdit value="Edit Person">
		</form>
		
		<form method=post action=userEdit.jsp>
			<input type=submit name=userEdit value="Edit User">
		</form>
		
		<form method=post action=famDocEdit.jsp>
			<input type=submit name=famDocEdit value="Edit Family Doctor">
		</form>
	
		<form method=post action=../login/home.jsp>
			<input type=submit name=exitMangMod value="Exit Management Module">
		</form>
	</div>
</BODY>

</HTML>
