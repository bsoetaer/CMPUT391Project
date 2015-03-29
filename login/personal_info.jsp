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
	<!--Page where users can change their modifiable personal info. Form is
		populate with current data for personal info on load.
		@author  Braeden Soetaert
	 -->

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
		<%
			if(cls.equals("a")) {
				out.println("<li><a href=\"../user_management.jsp\">User Management</a></li>");
				out.println("<li><a href=\"../report_generator.jsp\">Generate Reports</a></li>");
				out.println("<li><a href=\"../data_analysis.jsp\">Data Analysis</a></li>");
			}
			else if(cls.equals("r")) {
				out.println("<li><a href=\"../upload.jsp\">Upload Images</a></li>");
			}
		%>
		<li><a href="logout.jsp">Logout</a></li>
	</ul>

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

		// Get old values for info as default values.
		Statement stmt = null;
		ResultSet rset = null;
		String pwd = "";
		String address = "";
		String email = "";
		String phone = "";
		String sql = "SELECT password, address, email, phone " +
			"FROM persons p, users u " +
			"WHERE p.person_id = " + person_id + " " +
			"AND u.user_name = '" + session.getAttribute("user_name") + "'";

		try{
			stmt = conn.createStatement();
			rset = stmt.executeQuery(sql);
		}
		catch(Exception ex){
			out.println("<hr>" + ex.getMessage() + "<hr>");
		}

		if (rset != null && rset.next()) {
			pwd = getStringData(rset, 1);
			address = getStringData(rset, 2);
			email = getStringData(rset, 3);
			phone = getStringData(rset, 4);
		}

		try{
			conn.close();
		}
		catch(Exception ex){
			out.println("<hr>" + ex.getMessage() + "<hr>");
		}	
	%>
	
	<br>
	<FORM method=post action=change_info.jsp>
	<TABLE border=2 cellpadding=10> 
		<TR>
			<th colspan="2"><b>Unchangeable Info</b></th>
		</TR>
		<TR>
			<TD> ID </TD>
			<TD> <%= person_id %> </TD>
		</TR>
		<TR>
			<TD> Username </TD>
			<TD> <%= session.getAttribute("user_name") %> </TD>
		</TR>
		<TR>
			<TD> Name </TD>
			<TD> <%= (session.getAttribute("first_name") + " " + session.getAttribute("last_name")) %> </TD>
		</TR>
		<TR>
			<th colspan="2"><b>Changeable Info</b></th>
		</TR>
		<TR>
			<TD> Password </TD>
			<TD> <input type=password name=PASSWD value="<%= pwd %>" maxlength=24><br> </TD>
		</TR>
		<TR>
			<TD> Address </TD>
			<TD> <input type=text name=ADDRESS value="<%= address %>" maxlength=128><br> </TD>
		</TR>
		<TR>
			<TD> Email </TD>
			<TD> <input type=text name=EMAIL value="<%= email %>" maxlength=128><br> </TD>
		</TR>
		<TR>
			<TD> Phone </TD>
			<TD> <input type=text name=PHONE value="<%= phone %>" maxlength=10><br> </TD>
		</TR>
	</TABLE>
	<br>
	<input type="button" name="cancel" value="Cancel" onClick="window.location='home.jsp';">
	<input type="reset" value="Reset">
	<input type=submit name=bSubmit value=Submit>
	</FORM>

    </BODY> 
</HTML> 
