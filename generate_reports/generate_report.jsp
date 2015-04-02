<HTML>
	<HEAD>
	<TITLE>Generate Report</TITLE>
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
	<!--Page to request a report is generated of all patients with a specific diagnosis
		for a specific time period.
		@author  Braeden Soetaert
	 -->

	<%@ page import="java.util.Calendar" %>
	<%@ page import="java.sql.*" %>
	<%@ page import="javax.sql.*" %>
	<%@ page import="javax.naming.*" %>
		
	<%
		// Return user to login page if session expired.
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

	<%
		Calendar now = Calendar.getInstance();
		int year = now.get(Calendar.YEAR);
	%>
	<br>
	<Form name="report_gen" action="report.jsp" method="POST">
	<TABLE border=2 cellpadding=10>
		<TR>
			<th colspan="12"><b>Begin</b></th>
		</TR>
		<TR>
			<TD> Year </TD>
			<TD> <select name="beginYear">
					<% for(int i = year; i >= 1900; i--) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Month </TD>
			<TD> <select name="beginMonth">
					<% for(int i = 1; i <= 12; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Day </TD>
			<TD> <select name="beginDay">
					<% for(int i = 1; i <= 31; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Hour </TD>
			<TD> <select name="beginHour">
					<% for(int i = 0; i < 24; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Min </TD>
			<TD> <select name="beginMin">
					<% for(int i = 0; i < 60; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Sec </TD>
			<TD> <select name="beginSec">
					<% for(int i = 0; i < 60; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			
		</TR>
		<TR>
			<th colspan="12"><b>End</b></th>
		</TR>
		<TR>
			<TD> Year </TD>
			<TD> <select name="endYear">
					<% for(int i = year; i >= 1900; i--) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Month </TD>
			<TD> <select name="endMonth">
					<% for(int i = 1; i <= 12; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Day </TD>
			<TD> <select name="endDay">
					<% for(int i = 1; i <= 31; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Hour </TD>
			<TD> <select name="endHour">
					<% for(int i = 0; i < 24; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Min </TD>
			<TD> <select name="endMin">
					<% for(int i = 0; i < 60; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			<TD> Sec </TD>
			<TD> <select name="endSec">
					<% for(int i = 0; i < 60; i++) { %>
						<option><%= i %></option> 
					<% } %>
				</select>
			</TD>
			
		</TR>
		<TR>
			<TH colspan="6"><b> Diagnosis <b></TH>
			<TD colspan="6"> <select name="diagnosis">
					<option>All Patients</option>

	<%
		// Main point of execution
		// Get types of diagnosis for display.
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

		// Get old values for info as default values.
		Statement stmt = null;
		ResultSet rset = null;
		String sql = "SELECT DISTINCT diagnosis " +
			"FROM radiology_record";

		try{
			stmt = conn.createStatement();
			rset = stmt.executeQuery(sql);
		}
		catch(Exception ex){
			out.println("<hr>" + ex.getMessage() + "<hr>");
		}
		
		while (rset != null && rset.next()) { 
			String diagnosis = rset.getString(1);
			if(diagnosis == null)
				diagnosis = "NULL";
			out.println("<option>" + diagnosis + "</option>");
		}

		try{
			conn.close();
		}
		catch(Exception ex){
			out.println("<hr>" + ex.getMessage() + "<hr>");
		}
		
	%>
				</select>
			</TD>
		</TR>
	</TABLE>
	<br>
	<input type="button" name="cancel" value="Cancel" onClick="window.location='../login/home.jsp';">
	<input type="reset" value="Reset">
	<input type=submit name=bSubmit value=Submit>
	</FORM>

    </BODY> 
</HTML> 
