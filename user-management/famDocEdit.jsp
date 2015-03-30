<HTML>

<HEAD>
	<TITLE>Edit User Page</TITLE>
	<style>
		input[type=submit] {width: 20em;}
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
	ResultSet docSet = null;
	String sql = null;
	String result = null;
	
	if(request.getParameter("addFamDoc") != null ||
		request.getParameter("removeFamDoc") != null) {
		
		String[] newData = new String[2];
		newData[0] = (request.getParameter("DocID")).trim();
		newData[1] = (request.getParameter("PatID")).trim();
		
		for (int i = 0; i < newData.length; i++)
		{
			if (newData[i].equals(""))
				result = "Failed: Missing data.";
		}
		
		if(request.getParameter("addFamDoc") != null && result == null) {
			sql = "select * from users where " + 
				"Person_ID = " + newData[0] + " AND " +
				"CLASS = 'd'";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}
			if(!rset.isBeforeFirst()) {
				result = "Update Failed: Doctor does not exist in DB.";
			}
			
			if(result == null) {
				sql = "select * from users where " + 
					"Person_ID = " + newData[1] + " AND " +
					"CLASS = 'p'";
				try{ rset = stmt.executeQuery(sql); }
				catch(Exception ex){
					out.println("<hr>" + ex.getMessage() + "<hr>");
				}
				if(!rset.isBeforeFirst()) {
					result = "Update Failed: Patient does not exist in DB.";
				}
			}
			
			if(result == null) {
				sql = "select * from FAMILY_DOCTOR where " + 
					"DOCTOR_ID = " + newData[0] + " AND " +
					"PATIENT_ID = " + newData[1];
				try{ rset = stmt.executeQuery(sql); }
				catch(Exception ex){
					out.println("<hr>" + ex.getMessage() + "<hr>");
				}
				if(rset.isBeforeFirst()) {
					result = "Update Failed: Entry already exists.";
				}
			}
			
			if(result == null) {
				sql = "INSERT INTO FAMILY_DOCTOR " +
					"VALUES(" +
					newData[0] + ", " +
					newData[1] + ")";

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
		else if(request.getParameter("removeFamDoc") != null && result == null) {
			sql = "select * from FAMILY_DOCTOR where " + 
				"DOCTOR_ID = " + newData[0] + " AND " +
				"PATIENT_ID = " + newData[1];
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}
			if(!rset.isBeforeFirst()) {
				result = "Deletion Failed: Entry does not exist.";
			}
			if(result == null) {
				sql = "DELETE FROM FAMILY_DOCTOR " +
					"WHERE DOCTOR_ID = " + newData[0] + " AND " +
					"PATIENT_ID = " + newData[1];

				try{
					stmt.executeUpdate(sql);
					conn.commit();
					result = "Deletion Successful!";
				}
				catch(Exception ex){
					result = "Deletion Failed: " + ex.getMessage();
				}
			}
		}
	}
	
	sql = "select * from family_doctor ORDER BY DOCTOR_ID, PATIENT_ID";
	try{ docSet = stmt.executeQuery(sql); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
%>
	<TABLE BORDER="1">
		<th colspan="2">Family Doctor Table:</th>
		<TR>
			<TH>Doctor ID</TH>
			<TH>Patient ID</TH>
		</TR>
		<% while(docSet.next()){ %>
		<TR>
			<TD> <%= docSet.getString(1) %></td>
			<TD> <%= docSet.getString(2) %></TD>
		</TR>
		<% } %>
	</TABLE>
	
	<br>
	<% if(result != null ) { %>
		<p><b><%= result %></b></p>
	<% } %>

	<form method=post action=famDocEdit.jsp>
		<input type=number name=DocID maxlength=24 placeholder="Doctor ID"><br>
		<input type=number name=PatID maxlength=24 placeholder="Patient ID"><br>
		<input type=submit name=addFamDoc value="Add New Family Doctor"><br>
		<input type=submit name=removeFamDoc value="Remove Existing Family Doctor">
	</form>
	
	<form method=get action=userManagement.html>
		<input type=submit name=goBack value="Exit Family Doctor Edit">
	</form>
	
<%
	try{ stmt.close(); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
	
	try{ conn.close(); }
	catch(Exception ex){ out.println("<hr>" + ex.getMessage() + "<hr>"); }
%>
</BODY>

</HTML>
