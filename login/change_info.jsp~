<HTML> 
	<HEAD>
	<TITLE>Personal Information</TITLE>
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
	<!--Update personal info in database with data from personal_info page. Inform
		user about success/failure.
		@author  Braeden Soetaert
	 -->

	<%@ page import="java.sql.*" %>
	<%@ page import="javax.sql.*" %>
	<%@ page import="javax.naming.*" %>
	
	<%!
		/**
		 * Generate sql update statement for personal info so that we are not entering null
		 * or empty data.
		 */
		String getInfoSql(Integer person_id, String address, String email, String phone) {
			Boolean addressEmpty = (address == null || address.isEmpty());
			Boolean emailEmpty = (email == null || email.isEmpty());
			Boolean phoneEmpty = (phone == null || phone.isEmpty());
			Boolean needComma = false;

			if( addressEmpty && emailEmpty && phoneEmpty )
				return null;

			String sql = "UPDATE persons SET";
			
			if(!addressEmpty) {
				sql += " address = '" + address.trim() + "'";
				needComma = true;
			}
			
			if(!emailEmpty) {
				if( needComma )
					sql += ",";
				sql += " email = '" + email.trim() + "'";
				needComma = true;
			}

			if(!phoneEmpty) {
				if( needComma )
					sql += ",";
				sql += " phone = '" + phone.trim() + "'";
			}

			sql += " WHERE person_id = " + person_id;
			return sql;
		} 
	%>

	<%
		// Return user to login page if session expired.
		Integer person_id = (Integer) session.getAttribute("person_id");
		String cls = "";
		if(person_id == null) 
			response.sendRedirect("login.jsp");
		else
			cls = (String) session.getAttribute("class");
	%>

	<!--Display Menu -->
	<ul>
		<li><a href="home.jsp">Home</a></li>
		<li><a href="personal_info.jsp">Change Personal Info</a></li>
		<li><a href="../search.jsp">Search Records</a></li>
		<% if(cls.equals("a")) { %>
			<li><a href="../user-management/userManagement.jsp">User Management</a></li>
			<li><a href="../report_generator.jsp">Generate Reports</a></li>
			<li><a href="../data_analysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="../upload.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="logout.jsp">Logout</a></li>
	</ul>

	<%
		// Main point of execution. Only try to update database if data was submitted.
		if(request.getParameter("bSubmit") != null) {
			String pwd = request.getParameter("PASSWD");
			String address = request.getParameter("ADDRESS");
			String email = request.getParameter("EMAIL");
			String phone = request.getParameter("PHONE");

			String pwdSql = null;
			if( pwd != null && !pwd.isEmpty() ) {
				pwd = pwd.trim();
				pwdSql = "UPDATE users " +
					"SET password = '" + pwd + "' " +
					"WHERE user_name = '" + session.getAttribute("user_name") + "'";
			}

			String infoSql = getInfoSql(person_id, address, email, phone);

			// Only update database if there is some non-empty, non-null data.
			if( infoSql == null && pwdSql == null)
				out.println("<hr>NO INFO WAS CHANGED!<hr>");
			else {
				// Update personal info in database.
				Connection conn = null;

				try{
					//establish the connection 
					Context initContext = new InitialContext();
					Context envContext  = (Context)initContext.lookup("java:/comp/env");
					DataSource ds = (DataSource)envContext.lookup("jdbc/myoracle");
					conn = ds.getConnection();
					conn.setAutoCommit(false);
				}
				catch(Exception ex){
					out.println("<hr>" + ex.getMessage() + "<hr>");
				}		
		
				Statement stmt = null;
				ResultSet rset = null;
				try{
					stmt = conn.createStatement();
					if(pwdSql != null)
						stmt.executeUpdate(pwdSql);
					if(infoSql != null)
						stmt.executeUpdate(infoSql);
					conn.commit();
					out.println("<hr>Your Information was successfully updated.<hr>");
				}
				catch(Exception ex){
					out.println("<hr>" + ex.getMessage() + "<hr>");
				}

				try{
					conn.close();
				}
				catch(Exception ex){
					out.println("<hr>" + ex.getMessage() + "<hr>");
				}
			}
		}
		else {
			out.println("<hr>You have reached this page in error.<hr>");
		}		
	%>
	<a href="home.jsp">Back to Home</a>
    </BODY> 
</HTML> 
