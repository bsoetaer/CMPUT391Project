<HTML>
	<HEAD>
	<TITLE>Requested Report</TITLE>
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
	<!--Page to display report requested by the admin. If All Patients is chosen
		it will display data for all patients diagnosed with any problem during
		the time frame.
		@author  Braeden Soetaert
	 -->

	<%@ page import="java.util.Calendar" %>
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
		// Return user to login page if session expired. Return to home if not admin.
		Integer person_id = (Integer) session.getAttribute("person_id");
		String cls = "";
		if(person_id == null) 
			response.sendRedirect("../login/login.jsp");
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
			<li><a href="generate_report.jsp">Generate Reports</a></li>
			<li><a href="../data_analysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="../upload/make_record.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="logout.jsp">Logout</a></li>
	</ul>

	<br>

	<%
		// Main point of execution
		// Get types of diagnosis for display.

		// If user submitted data.
		if(request.getParameter("bSubmit") != null) {

			//get the user input from report gen page
			Calendar beginCal = Calendar.getInstance();
			Calendar endCal = Calendar.getInstance();
			beginCal.set(Integer.parseInt(request.getParameter("beginYear")),
						Integer.parseInt(request.getParameter("beginMonth")) - 1,
						Integer.parseInt(request.getParameter("beginDay")),
						Integer.parseInt(request.getParameter("beginHour")),
						Integer.parseInt(request.getParameter("beginMin")),
						Integer.parseInt(request.getParameter("beginSec")) );
			endCal.set(Integer.parseInt(request.getParameter("endYear")),
						Integer.parseInt(request.getParameter("endMonth")) - 1,
						Integer.parseInt(request.getParameter("endDay")),
						Integer.parseInt(request.getParameter("endHour")),
						Integer.parseInt(request.getParameter("endMin")),
						Integer.parseInt(request.getParameter("endSec")) );
			String diagnosis = (request.getParameter("diagnosis")).trim();
			
			// Convert calendar date to sql timestamp
			Timestamp beginTimestamp = new Timestamp(beginCal.getTimeInMillis());
			Timestamp endTimestamp = new Timestamp(endCal.getTimeInMillis());
			%>
			Begin Time: <%= beginTimestamp.toString() %><br>
			End Time: <%= endTimestamp.toString() %><br>
			Diagnosis: <%= diagnosis %><br>
			<%

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

			// Get data to display from database.
			Statement stmt = null;
			ResultSet rset = null;
			String sql = "SELECT first_name, last_name, address, phone, testDate " +
				"FROM persons p, " +
					"( SELECT patient_id, MIN(test_date) as testDate " +
					"FROM radiology_record ";
			if(diagnosis.equals("All Patients"))
				sql += "WHERE ";
			else
				sql += "WHERE diagnosis = '" + diagnosis + "' AND ";
			sql += "test_date BETWEEN timestamp '" + beginTimestamp + "' AND timestamp '" + endTimestamp + "' " +
				"GROUP BY patient_id ) r " +
				"WHERE p.person_id = r.patient_id";
			
			try{
				stmt = conn.createStatement();
				rset = stmt.executeQuery(sql);
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}

			// Display data for patients who match the report criteria in a table.
			if(rset != null && rset.isBeforeFirst()) { 
			%>
				<TABLE border=2 cellpadding=10>
					<TR>
						<TH><b>First Name</b></TH>
						<TH><b>Last Name</b></TH>
						<TH><b>Address</b></TH>
						<TH><b>Phone</b></TH>
						<TH><b>Date Diagnosed</b></TH>
					</TR>
			<%
				while (rset != null && rset.next()) { 
					String first_name = (getStringData(rset, 1).isEmpty() ? "&nbsp;" : getStringData(rset, 1));
					String last_name = (getStringData(rset, 2).isEmpty() ? "&nbsp;" : getStringData(rset, 2));
					String address = (getStringData(rset, 3).isEmpty() ? "&nbsp;" : getStringData(rset, 3));
					String email = (getStringData(rset, 4).isEmpty() ? "&nbsp;" : getStringData(rset, 4));
					Timestamp testDate = (rset.getTimestamp(5) == null ? new Timestamp(0) : rset.getTimestamp(5));
				%>
					<TR>
						<TD><%= first_name %></TD>
						<TD><%= last_name %></TD>
						<TD><%= address %></TD>
						<TD><%= email %></TD>
						<TD><%= testDate %></TD>
					</TR>
				<%
				}
			%>
				</TABLE>
			<%
			}
			else {
			%>
				<hr> There is no data available for the entered request. <hr>
			<%
			}

			try{
				conn.close();
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}
		}
		else {
			out.println("<hr>You have reached this page in error.<hr>");
		}
		
	%>

    </BODY> 
</HTML> 
