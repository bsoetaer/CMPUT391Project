<HTML>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css"> 
	<HEAD>
	<TITLE>Home</TITLE>
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
	<!--Home page that displays personal information and provides links to the rest of the site.
		@author  Braeden Soetaert
	 -->

	<%@ page import="java.sql.*" %>
	<%@ page import="javax.sql.*" %>
	<%@ page import="javax.naming.*" %>
	<%@ page import="java.io.IOException" %>
	
	<%!
		/**
		 * Get and display personal info as html table rows.
		 */
		void displayInfo(Integer person_id, Connection conn, JspWriter out) throws SQLException, IOException{
			// select person info for user from table
			Statement stmt = null;
			ResultSet rset = null;
			String sql = "SELECT first_name, last_name, address, email, phone " +
				"FROM persons " +
				"WHERE person_id = "+person_id;
			try{
				stmt = conn.createStatement();
				rset = stmt.executeQuery(sql);
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}

			// Display personal info in table
			if (rset != null && rset.next()) {
				out.println("<TR>");
				out.println("<TD> ID </TD>");
				out.println("<TD>" + person_id + "</TD>");
				out.println("</TR>");
				out.println("<TR>");
				out.println("<TD> First Name </TD>");
				out.println("<TD>" + (getStringData(rset, 1).isEmpty() ? "&nbsp;" : getStringData(rset, 1)) + "</TD>");
				out.println("</TR>");
				out.println("<TR>");
				out.println("<TD> Last Name </TD>");
				out.println("<TD>" + (getStringData(rset, 2).isEmpty() ? "&nbsp;" : getStringData(rset, 2)) + "</TD>");
				out.println("</TR>");
				out.println("<TR>");
				out.println("<TD> Address </TD>");
				out.println("<TD>" + (getStringData(rset, 3).isEmpty() ? "&nbsp;" : getStringData(rset, 3)) + "</TD>");
				out.println("</TR>");
				out.println("<TR>");
				out.println("<TD> Email </TD>");
				out.println("<TD>" + (getStringData(rset, 4).isEmpty() ? "&nbsp;" : getStringData(rset, 4)) + "</TD>");
				out.println("</TR>");
				out.println("<TR>");
				out.println("<TD> Phone </TD>");
				out.println("<TD>" + (getStringData(rset, 5).isEmpty() ? "&nbsp;" : getStringData(rset, 3)) + "</TD>");
				out.println("</TR>");
			}
		}
		
		/**
		 * Get and display family doctor names as an html tabl row.
		 */
		void getDoctor(Integer person_id, Connection conn, JspWriter out) throws SQLException, IOException {

			// Select family doctors from table
			Statement stmt = null;
			ResultSet rset = null;
			String sql = "SELECT first_name, last_name " +
				"FROM persons p, family_doctor f " +
				"WHERE f.patient_id = "+person_id+" " +
				"AND f.doctor_id = p.person_id";
			try{
				stmt = conn.createStatement();
				rset = stmt.executeQuery(sql);
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}

			if(rset.isBeforeFirst()) {
				out.println("<TR>");
				out.println("<TD>Family Doctor(s) </TD>");
				out.println("<TD>");
			}

			String doc_name = "";
			while (rset != null && rset.next()) {
				doc_name = getStringData(rset, 1) + " " + getStringData(rset, 2);
				out.println("Dr. "+doc_name+"<br>");
			}

			if( rset.isAfterLast() ) {
				out.println("</TD>");
				out.println("</TR>");
			}
		}

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
		else
			cls = (String) session.getAttribute("class");
	%>

	<!--Navigation Bar
		TODO: Update links.
	-->
	<ul>
		<li><a href="home.jsp">Home</a></li>
		<li><a href="personal_info.jsp">Change Personal Info</a></li>
		<li><a href="../search.jsp">Search Records</a></li>
		<% if(cls.equals("a")) { %>
			<li><a href="../user-management/userManagement.jsp">User Management</a></li>
			<li><a href="../generate_reports/generate_report.jsp">Generate Reports</a></li>
			<li><a href="../data_analysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="../upload/make_record.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="logout.jsp">Logout</a></li>
	</ul>

	<br>
	<TABLE class="table table-striped" border=2 cellpadding=10> 

	<%
		// Main point of execution
		// Display personal info for logged in user.
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

		getDoctor(person_id, conn, out);

		displayInfo(person_id, conn, out);

		try{
			conn.close();
		}
		catch(Exception ex){
			out.println("<hr>" + ex.getMessage() + "<hr>");
		}
		
	%>
	</TABLE>
    </BODY> 
</HTML> 
