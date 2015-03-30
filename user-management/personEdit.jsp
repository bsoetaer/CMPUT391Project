<HTML>

<HEAD>
	<TITLE>Edit Person Page</TITLE>
	<style>
		input[type=submit] {width: 15em;}
	</style>
</HEAD>

<BODY>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
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
	String sql = null;
	String result = null;
	
	if(request.getParameter("addPerson") != null ||
		request.getParameter("editPerson") != null ||
		request.getParameter("removePerson") != null) {
		
		String ID = (request.getParameter("ID")).trim();
		String[] newData = new String[5];
		newData[0] = (request.getParameter("FirstName")).trim();
		newData[1] = (request.getParameter("LastName")).trim();
		newData[2] = (request.getParameter("Address")).trim();
		newData[3] = (request.getParameter("Email")).trim();
		newData[4] = (request.getParameter("Phone")).trim();
		
		try {
			if(!newData[4].equals(""))
			{
				Long.parseLong(newData[4]);
				if(newData[4].length() != 7 && newData[4].length() != 10)
					result = "Failed: Phone needs to be of length 7 or 10";	
			}
		}
		catch (Exception e){ result = "Failed: Phone needs to be a whole number"; }
		
		for (int i = 0; i < newData.length; i++)
		{
			if (!newData[i].equals(""))
				break;
			if (i == 4)
				result = "Failed: No data entered.";
		}
		
		if(request.getParameter("addPerson") != null && result == null) {
			if(!ID.equals("")) {
				result = "Can not add person with specific ID. Please try again.";
			}
			else {
				sql = "INSERT INTO persons " +
					"VALUES(" + 
					"NULL, " +
					"'" + newData[0] + "', " +
					"'" + newData[1] + "', " +
					"'" + newData[2] + "', " +
					"'" + newData[3] + "', " +
					"'" + newData[4] + "')";

				try{
					stmt.executeUpdate(sql);
					conn.commit();
					result = "Insert Successful!";
				}
				catch(Exception ex){
					result = "Insert Failed: " + ex.getMessage();
				}
			}
		}
		else if(request.getParameter("editPerson") != null && result == null) {
			String[] person = new String[5];

			sql = "select * from persons where PERSON_ID = '" + ID + "'";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
		
			if(!rset.isBeforeFirst()) {
				result = "Update Failed: ID entered does not exist.";
			}
			else {
				rset.next();
				for(int i = 0; i < 5; i++)
				{
					if(newData[i].equals(""))
						person[i] = rset.getString(i+2);
					else
						person[i] = newData[i];
				}
			
				sql = "update persons " +
					"set FIRST_NAME = '" + person[0] + "', " +
					"LAST_NAME = '" + person[1] + "', " +
					"ADDRESS = '" + person[2] + "', " +
					"EMAIL = '" + person[3] + "', " +
					"PHONE = '" + person[4] + "' " +
					"where PERSON_ID = '" +
					ID + "'";
			
				try{
					stmt.executeUpdate(sql);
					conn.commit();
					result = "Update Successful!";
				}
				catch(Exception ex){
					result = "Update Failed: " + ex.getMessage();
				}
			}
		}
		else if(request.getParameter("removePerson") != null) {
			if(!ID.equals("")){
				sql = "select * from persons where PERSON_ID = " + ID;
				try{ rset = stmt.executeQuery(sql); }
				catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
				
				if(rset.isBeforeFirst()){
					sql = "select * from family_doctor where DOCTOR_ID = " + ID +
						" OR PATIENT_ID = " + ID;
					try{ rset = stmt.executeQuery(sql); }
					catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
					if(!rset.isBeforeFirst()){
						sql = "select * from users where person_id = " + ID;
						try{ rset = stmt.executeQuery(sql); }
						catch(Exception ex){
							out.println("<hr>" + ex.getMessage() + "<hr>");
						}
						if(!rset.isBeforeFirst()){
							sql = "DELETE FROM persons " +
								"WHERE person_id = " + ID;
							try{
								stmt.executeUpdate(sql);
								conn.commit();
								result = "Removal Successful!";
							}
							catch(Exception ex){
								result = "Removal Failed: " + ex.getMessage();
							}
						}
						else
							result = "Removal Failed: ID is in the Users Table." +
								" Please remove from Users table before deleting Person.";
					}
					else
						result = "Removal Failed: ID is in the Family Doctor Table." +
							" Please remove from Family Doctor table, " +
							"as well as Users table.";
				}
				else
					result = "Removal Failed: ID does not exist.";
			}
			else
				result = "Removal Failed: No ID entered.";
		}
	}
	
	sql = "select * from persons ORDER BY PERSON_ID";
	try{ rset = stmt.executeQuery(sql); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
	
%>
	
	<TABLE BORDER="1">
		<th colspan="6">persons Table:</th>
		<TR>
			<TH>ID</TH>
			<TH>First Name</TH>
			<TH>Last Name</TH>
			<TH>Address</TH>
			<TH>Email</TH>
			<TH>Phone</TH>
		</TR>
		<% while(rset.next()){ %>
		<TR>
			<TD> <%= rset.getString(1) %></td>
			<TD> <%= rset.getString(2) %></TD>
			<TD> <%= rset.getString(3) %></TD>
			<TD> <%= rset.getString(4) %></TD>
			<TD> <%= rset.getString(5) %></TD>
			<TD> <%= rset.getString(6) %></TD>
		</TR>
		<% } %>
	</TABLE>
	
	<br>
	<% if(result != null ) { %>
		<p><b><%= result %></b></p>
	<% } %>
	
	<form method=post action=personEdit.jsp>
		<input type=number name=ID maxlength=10 placeholder="ID"><br>
		<input type=text name=FirstName maxlength=24 placeholder="First Name"><br>
		<input type=text name=LastName maxlength=24 placeholder="Last Name"><br>
		<input type=text name=Address maxlength=128 placeholder="Address"><br>
		<input type=email name=Email maxlength=128 placeholder="Email"><br>
		<input type=text name=Phone maxlength=10 placeholder="Phone"><br>
		<input type=submit name=addPerson value= "Add New Person"><br>
		<input type=submit name=editPerson value="Edit Existing Person"><br>
		<input type=submit name=removePerson value="Remove Existing Person">
	</form>
	
	<form method=get action=userManagement.html>
		<input type=submit name=goBack value="Exit Person Edit">
	</form>

<%
	try{ stmt.close(); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
	
	try{ conn.close(); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
%>
</BODY>

</HTML>
