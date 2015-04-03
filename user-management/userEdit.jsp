<HTML>

<HEAD>
	<TITLE>Edit User Page</TITLE>
	<style>
		input[type=submit] {width: 15em;}
		
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
<%@ page import="java.util.Date" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

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
		<li><a href="../docs/user-manual/Edit-User.html#Edit-User">Help</a></li>
		<li><a href="../login/logout.jsp">Logout</a></li>
	</ul>
	
	<br>

<%
	//establish the connection to the underlying database
	Connection conn = null;
	try{
		//establish the connection 
		Context initContext = new InitialContext();
		Context envContext  = (Context)initContext.lookup("java:/comp/env");
		DataSource ds = (DataSource)envContext.lookup("jdbc/myoracle");
		conn = ds.getConnection();
		conn.setAutoCommit(false);
	}
	catch(Exception ex){ out.println("<hr> " + ex.getMessage() + "<hr>"); }
	
	Statement stmt = null;
	stmt = conn.createStatement();
	ResultSet rset = null;
	ResultSet usersSet = null;
	String sql = null;
	String result = null;
	
	if(request.getParameter("addUser") != null ||
		request.getParameter("editUser") != null ||
		request.getParameter("removeUser") != null) {
		
		String userName = (request.getParameter("UserName")).trim();
		String[] newData = new String[6];
		newData[0] = (request.getParameter("Password")).trim();
		newData[1] = (request.getParameter("UserClass")).trim();
		newData[2] = (request.getParameter("ID")).trim();
		newData[3] = (request.getParameter("dateMM")).trim();
		newData[4] = (request.getParameter("dateDD")).trim();
		newData[5] = (request.getParameter("dateYYYY")).trim();
		
		for (int i = 0; i < newData.length; i++)
		{
			if (!newData[i].equals(""))
				break;
			if (i == newData.length - 1)
				result = "Failed: No data entered.";
		}
		
		if(userName.equals(""))
			result = "Failed: No User Name entered.";
		
		if(request.getParameter("addUser") != null && result == null) {
			String date;
			for (int i = 0; i < 3; i++)
			{
				if (newData[i].equals(""))
					result = "Insert Failed: All non-date fields required.";
			}
			
			if(!(newData[3].equals("") &&
				newData[4].equals("") &&
				newData[5].equals(""))
				&& !(!newData[3].equals("") &&
				!newData[4].equals("") &&
				!newData[5].equals("")))
					result = "Insert Failed: Incomplete date entered.";
			
			Format formatter = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
			if (!newData[3].equals("") &&
				!newData[4].equals("") &&
				!newData[5].equals(""))
			{
				Calendar cal = Calendar.getInstance();
				cal.setTimeInMillis(0);
				cal.set(Integer.parseInt(newData[5]),
					Integer.parseInt(newData[3]) - 1,
					Integer.parseInt(newData[4]), 0, 0, 0);
				date = formatter.format(cal.getTime());
			}
			else
				date = formatter.format(new Date());
			
			sql = "select * from persons where PERSON_ID = '" + newData[2] + "'";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
			if(!rset.isBeforeFirst())
				result = "Insert Failed: ID entered does not exist in persons.";
				
			sql = "select * from users where USER_NAME = '" + newData[0] + "'";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
			if(rset.isBeforeFirst())
				result = "Insert Failed: User Name already in use.";
			
			if(result == null) {
				sql = "INSERT INTO users " +
					"VALUES(" +
					"'" + userName + "', " +
					"'" + newData[0] + "', " +
					"'" + newData[1] + "', " +
					"" + newData[2] + ", " +
					"TO_DATE('" + date + "', 'yyyy/mm/dd hh24:mi:ss'))";

				try{
					stmt.executeUpdate(sql);
					conn.commit();
					result = "Insert Successful!";
				}
				catch(Exception ex){ result = "Insert Failed: "+ex.getMessage(); }
			}
		}
		else if(request.getParameter("editUser") != null && result == null) {
			String[] user = new String[4];

			sql = "select * from users where USER_NAME = '" + userName + "'";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){ out.println("<hr>"+ex.getMessage()+"<hr>"); }
		
			if(!rset.isBeforeFirst()) {
				result = "Update Failed: User Name enterted does not exist.";
			}
			else {
				rset.next();
				
				boolean update = true;
				String oldClass = rset.getString(3);
				String oldID = rset.getString(4);
				
				for(int i = 0; i < 4; i++)
				{
					if(newData[i].equals(""))
						user[i] = rset.getString(i+2);
					else
						user[i] = newData[i];
				}
				
				if(!newData[3].equals(""))
				{
					Format formatter = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
					Calendar cal = Calendar.getInstance();
					cal.setTimeInMillis(0);
					cal.set(Integer.parseInt(newData[5]),
						Integer.parseInt(newData[3]) - 1,
						Integer.parseInt(newData[4]), 0, 0, 0);
					user[3] = formatter.format(cal.getTime());
				}
				
				if(oldClass.equals("p") || oldClass.equals("d")) {
					sql = "select * from family_doctor where " +
						"doctor_id = " + oldID + " OR " +
						"patient_id = " + oldID;
					try{ rset = stmt.executeQuery(sql); }
					catch(Exception ex){ out.println("<hr>"+ex.getMessage()+"<hr>"); }
					
					if(rset.isBeforeFirst()) {
						int userCount = 0;
						sql = "select * from users where Person_id = " + oldID +
							" AND class = '" + oldClass + "'";
						try{ rset = stmt.executeQuery(sql); }
						catch(Exception ex){ out.println("<hr>"+ex.getMessage()+"<hr>"); }
						
						while(rset.next()) { userCount++; }
						
						if(userCount == 1) {
							update = false;
							result = "Insert Failed: ID is in Family Doctor Table.";
						}
					}
				}
			
				if(update) {
					sql = "update users " +
						"set PASSWORD = '" + user[0] + "', " +
						"CLASS = '" + user[1] + "', " +
						"PERSON_ID = '" + user[2] + "', " +
						"DATE_REGISTERED = TO_DATE('" + 
							user[3] + "', 'yyyy/mm/dd hh24:mi:ss') " +
						"where USER_NAME = '" + userName + "'";
			
					try{
						stmt.executeUpdate(sql);
						conn.commit();
						result = "Update Successful!";
					}
					catch(Exception ex){ result = "Update Failed: "+ex.getMessage(); }
				}
			}
		}
		else if(request.getParameter("removeUser") != null && !userName.equals("")) {
			boolean remove = false;
			sql = "select * from users where USER_NAME = '" + userName + "'";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
		
			if(rset.isBeforeFirst()) {
				rset.next();
				
				String userClass = rset.getString(3);
				String ID = rset.getString(4);
		
				if(rset.getString(3).equals("d") || rset.getString(3).equals("p")) {
					sql = "select * from family_doctor " +
						"where DOCTOR_ID = " + ID +
						" OR PATIENT_ID = " + ID;
					try{ rset = stmt.executeQuery(sql); }
					catch(Exception ex){ out.println("<hr>"+ex.getMessage()+"<hr>"); }
					if(!rset.isBeforeFirst())
						remove = true;
					else {
						int userCount = 0;
						sql = "select * from users where Person_id = " + ID +
							" AND class = '" + userClass + "'";
						try{ rset = stmt.executeQuery(sql); }
						catch(Exception ex){ out.println("<hr>"+ex.getMessage()+"<hr>"); }
						
						while(rset.next()) { userCount++; }
						
						if(userCount > 1)
							remove = true;
					}
				}
				else
					remove = true;
		
				if(remove) {
					sql = "DELETE FROM users " +
						"WHERE user_name = '" + userName + "'";
					try{
						stmt.executeUpdate(sql);
						conn.commit();
						result = "Removal Successful!";
					}
					catch(Exception ex){ result = "Removal Failed: " + ex.getMessage(); }
				}
				else
					result = "Removal Failed: " +
						"User exists as a patient or doctor in the family doctor table.";
			}
			else
				result = "Removal Failed: User Name does not exist.";
		}
	}
	
	sql = "select * from users ORDER BY USER_NAME";
	try{ usersSet = stmt.executeQuery(sql); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
%>

	<TABLE BORDER="1">
		<th colspan="5">users Table:</th>
		<TR>
			<TH>User Name</TH>
			<TH>Password</TH>
			<TH>User Class</TH>
			<TH>ID</TH>
			<TH>Date Registered</TH>
		</TR>
		<% while(usersSet.next()){ %>
		<TR>
			<TD> <%= usersSet.getString(1) %></td>
			<TD> <%= usersSet.getString(2) %></TD>
			<TD> <%= usersSet.getString(3) %></TD>
			<TD> <%= usersSet.getString(4) %></TD>
			<TD> <%= usersSet.getString(5) %></TD>
		</TR>
		<% } %>
	</TABLE>
	
	<br>
	<% if(result != null ) { %>
		<p><b><%= result %></b></p>
	<% } %>

	<form method=post action=userEdit.jsp>
		<input type=text name=UserName maxlength=24 placeholder="User Name"><br>
		<input type=text name=Password maxlength=24 placeholder="Password"><br>
		User Class: <select size="1" name=UserClass>
    		<option>a</option>
    		<option>p</option>
    		<option>d</option>
    		<option>r</option>
		</select><br>
		<input type=number
			   name=ID
			   max=<%= Long.MAX_VALUE %>
			   min=0
			   placeholder="ID"><br>
		Date Registered:<br>
			<input type=number
				   name=dateMM
				   max=12
			       min=1
				   placeholder="mm"><br>
			<input type=number
				   name=dateDD
				   max=31
			       min=1
				   placeholder="dd"><br>
			<input type=number
				   name=dateYYYY
				   max=3000
			       min=0
				   placeholder="yyyy"><br>
		<input type=submit name=addUser value="Add New User"><br>
		<input type=submit name=editUser value="Edit Existing User"><br>
		<input type=submit name=removeUser value="Remove Existing User">
	</form>

	<form method=post action=userManagement.jsp>
		<input type=submit name=goBack value="Exit User Edit">
	</form>
	
<%
	try{ stmt.close(); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
	
	try{ conn.close(); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
%>
</BODY>

</HTML>
