<HTML>

<HEAD>
	<TITLE>Data Analysis Module</TITLE>
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
		String userName = (String) session.getAttribute("user_name");
		String cls = "";
		if(person_id == null) 
			response.sendRedirect("../login/login.jsp");
		else {
			cls = (String) session.getAttribute("class");
			if(!cls.equals("a"))
				response.sendRedirect("../login/home.jsp");
		}
	%>
	
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
	%>
	
	<!--Navigation Bar -->
	<ul>
		<li><a href="../login/home.jsp">Home</a></li>
		<li><a href="../login/personal_info.jsp">Change Personal Info</a></li>
		<li><a href="../search/search.jsp">Search Records</a></li>
		<% if(cls.equals("a")) { %>
			<li><a href="../user-management/userManagement.jsp">User Management</a></li>
			<li><a href="../generate_reports/generate_report.jsp">Generate Reports</a></li>
			<li><a href="dataAnalysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="../upload/make_record.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="../docs/user-manual/Data-Analysis.html#Data-Analysis">Help</a></li>
		<li><a href="../login/logout.jsp">Logout</a></li>
	</ul>
	
	<br>
	
	<%
	String firstName = "", lastName = "", testType = "";
	String startMM = "", startDD = "", startYYYY = "";
	String endMM = "", endDD = "", endYYYY = "";
	
	boolean error = false;
	String message = null;
	
	if(request.getParameter("runAnalytics") != null ||
		request.getParameter("weeks") != null ||
		request.getParameter("months") != null ||
		request.getParameter("years") != null) {		
		
		firstName = (request.getParameter("FirstName")).trim();
		lastName = (request.getParameter("LastName")).trim();
		testType = (request.getParameter("TestType")).trim();
		
		startMM = (request.getParameter("startDateMM")).trim();
		startDD = (request.getParameter("startDateDD")).trim();
		startYYYY = (request.getParameter("startDateYYYY")).trim();
		
		endMM = (request.getParameter("endDateMM")).trim();
		endDD = (request.getParameter("endDateDD")).trim();
		endYYYY = (request.getParameter("endDateYYYY")).trim();
	}
	
	if(request.getParameter("runAnalytics") != null) {		
		if(!((firstName.equals("") && lastName.equals("")) ||
			(!firstName.equals("") && !lastName.equals("")))) {
				error = true;
				message = "First and Last name required.";
			}
		
		if(!((startMM.equals("") && startDD.equals("") && startYYYY.equals("")) ||
			(!startMM.equals("") && !startDD.equals("") && !startYYYY.equals(""))) && !error) {
				error = true;
				message = "Start Date requires all 3 or no fields filled in.";
			}
			
		if(!((endMM.equals("") && endDD.equals("") && endYYYY.equals("")) ||
			(!endMM.equals("") && !endDD.equals("") && !endYYYY.equals(""))) && !error) {
				error = true;
				message = "End Date requires all 3 or no fields filled in.";
			}
		if(!error) {
			String create, select, from, where, sortBy;
			String tableName = userName + "Analysis";
			
			create = "Create Table " + tableName + " AS ";
		
			select = "SELECT ";
			if(!firstName.equals(""))
				select = select +
					"persons.first_name||' '||persons.last_name \"full_name\", ";
			if(!testType.equals(""))
				select = select+"radiology_record.test_type, ";
			select = select+"to_Char(radiology_record.test_date,'YYYY') \"Year\", ";
			select = select+"to_Char(radiology_record.test_date,'mm') \"Month\", ";
			select = select+"to_Char(radiology_record.test_date,'WW') \"Week\" ";
			
			from = "FROM radiology_record INNER JOIN persons " +
				"ON persons.person_id = Radiology_record.patient_id ";
			
			where = "WHERE ";
			boolean whereEntry = false;
			
			if(!firstName.equals("")){
				where = where + "first_name = '" + firstName +
					"' AND last_name = '" + lastName + "' ";
				whereEntry = true;
				}
			if(!testType.equals("")){
				if(whereEntry)
					where = where + "AND ";
				where = where + "radiology_record.test_type = '" + testType + "' ";
				whereEntry = true;
				}
			if(!startMM.equals("")){
				if(whereEntry)
					where = where + "AND ";
				where = where + "radiology_record.test_date > " +
					"to_date('"+startMM+"-"+startDD+"-"+startYYYY+"','mm-dd-yyyy') ";
				whereEntry = true;
				}
			if(!endMM.equals("")){
				if(whereEntry)
					where = where + "AND ";
				where = where + "radiology_record.test_date < " +
					"to_date('"+endMM+"-"+
					(Integer.parseInt(endDD)+1)+"-"+
					endYYYY+"','mm-dd-yyyy') ";
				whereEntry = true;
				}
			if(firstName.equals("") && 
				testType.equals("") && 
				startMM.equals("") &&
				endMM.equals(""))
					where = "";
			
			sortBy = "ORDER BY \"Year\", \"Week\"";
			
			String sql = create + select + from + where + sortBy;
			
			try{
				stmt.executeUpdate("DROP TABLE " + tableName);
				conn.commit();
			}
			catch(Exception ex){ }
			
			try{
				stmt.executeUpdate(sql);
				conn.commit();
			}
			catch(Exception ex){
				error = true;
				message = ex.getMessage();
			}
			
			sql = "select count(\"Year\") from " + tableName;
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){
				message = ex.getMessage();
				error = true;
			}
			rset.next();
			%>
			
			<TABLE BORDER="1">
				<th colspan="2"><%= tableName %> Table:</th>
				<TR>
					<TD>Record Count</TD>
					<TD> <%= rset.getString(1) %></td>
				</TR>
			</TABLE><br>
		<%
		}
	}
	else if(request.getParameter("weeks") != null){
		String tableName = userName + "Analysis";
		String sql = "select \"Year\", \"Week\", count(\"Week\") from " + tableName +
			" Group By \"Year\", \"Week\"";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){
				message = ex.getMessage();
				error = true;
			}
		%>
		<TABLE BORDER="1">
			<th colspan="3"><%= tableName %> Table:</th>
			<TR>
				<TH>Year</TH>
				<TH>Week Number</TH>
				<TH>Record Count</TH>
			</TR>
			<% while(rset.next()){ %>
			<TR>
				<TD> <%= rset.getString(1) %></TD>
				<TD> <%= rset.getString(2) %></TD>
				<TD> <%= rset.getString(3) %></TD>
			</TR>
			<% } %>
		</TABLE><br>
		<%
	}
	else if(request.getParameter("months") != null){
		String tableName = userName + "Analysis";
		String sql = "select \"Year\", \"Month\", count(\"Month\") from " + tableName +
			" Group By \"Year\", \"Month\" Order By \"Year\", \"Month\"";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){
				message = ex.getMessage();
				error = true;
			}
		%>
		<TABLE BORDER="1">
			<th colspan="3"><%= tableName %> Table:</th>
			<TR>
				<TH>Year</TH>
				<TH>Month</TH>
				<TH>Record Count</TH>
			</TR>
			<% while(rset.next()){ %>
			<TR>
				<TD> <%= rset.getString(1) %></TD>
				<TD> <%= rset.getString(2) %></TD>
				<TD> <%= rset.getString(3) %></TD>
			</TR>
			<% } %>
		</TABLE><br>
		<%
	}
	else if(request.getParameter("years") != null){
		String tableName = userName + "Analysis";
		String sql = "select \"Year\", count(\"Year\") from " + tableName +
			" Group By \"Year\" Order By \"Year\"";
			try{ rset = stmt.executeQuery(sql); }
			catch(Exception ex){
				message = ex.getMessage();
				error = true;
			}
		%>
		<TABLE BORDER="1">
			<th colspan="2"><%= tableName %> Table:</th>
			<TR>
				<TH>Year</TH>
				<TH>Record Count</TH>
			</TR>
			<% while(rset.next()){ %>
			<TR>
				<TD> <%= rset.getString(1) %></TD>
				<TD> <%= rset.getString(2) %></TD>
			</TR>
			<% } %>
		</TABLE><br>
		<%
	}
	
	try{
		conn.close();
	}
	catch(Exception ex){
		out.println("<hr>" + ex.getMessage() + "<hr>");
	}
	%>
	
	<% if(message != null ) { %>
		<p><b><%= message %></b></p>
	<% } %>
	
	<% int inputWidth = 200; %>
	<form method=post action=dataAnalysis.jsp>
		<input type=text
			   name=FirstName
			   <% if(!lastName.equals("")) { %>
			       value="<%= firstName %>"
			   <% } %>
			   maxlength = 24
			   placeholder="First Name"
			   style="width: <%= inputWidth %>px;"><br>
			   
		<input type=text
			   name=LastName
			   <% if(!lastName.equals("")) { %>
			       value="<%= lastName %>"
			   <% } %>
			   maxlength = 24
			   placeholder="Last Name"
			   style="width: <%= inputWidth %>px;"><br>
		
		<input type=text
			   name=TestType
			   <% if(!testType.equals("")) { %>
			       value="<%= testType %>"
			   <% } %>
			   maxlength=24
			   placeholder="Test Type"
			   style="width: <%= inputWidth %>px;"><br>
		
		Start Date:<br>
			<input type=number
				   name=startDateMM
				   <% if(!startMM.equals("")) { %>
			           value=<%= Long.parseLong(startMM) %>
			       <% } %>
			       max=12
			       min=1
				   placeholder="mm"
				   style="width: <%= inputWidth %>px;"><br>
			<input type=number
				   name=startDateDD
				   <% if(!startDD.equals("")) { %>
			           value=<%= Long.parseLong(startDD) %>
			       <% } %>
			       max=31
			       min=1
				   placeholder="dd"
				   style="width: <%= inputWidth %>px;"><br>
			<input type=number
				   name=startDateYYYY
				   <% if(!startYYYY.equals("")) { %>
			           value=<%= Long.parseLong(startYYYY) %>
			       <% } %>
			       max=3000
			       min=0
				   placeholder="yyyy"
				   style="width: <%= inputWidth %>px;"><br>
		
		End Date:<br>
			<input type=number
				   name=endDateMM
				   <% if(!endMM.equals("")) { %>
			           value=<%= Long.parseLong(endMM) %>
			       <% } %>
			       max=12
			       min=1
				   placeholder="mm"
				   style="width: <%= inputWidth %>px;"><br>
			<input type=number
				   name=endDateDD
				   <% if(!endDD.equals("")) { %>
			           value=<%= Long.parseLong(endDD) %>
			       <% } %>
			       max=31
			       min=1
				   placeholder="dd"
				   style="width: <%= inputWidth %>px;"><br>
			<input type=number
				   name=endDateYYYY
				   <% if(!endYYYY.equals("")) { %>
			           value=<%= Long.parseLong(endYYYY) %>
			       <% } %>
			       max=3000
			       min=0
				   placeholder="yyyy"
				   style="width: <%= inputWidth %>px;"><br>
		
		<input type=submit
			   name=runAnalytics
			   value="Run Analytics"
			   style="width: <%= inputWidth %>px;"><br>
		<input type=submit
			   name=clearData
			   value="Clear Entry"
			   style="width: <%= inputWidth %>px;"><br>
		<% if(request.getParameter("runAnalytics") != null ||
			request.getParameter("weeks") != null ||
			request.getParameter("months") != null ||
			request.getParameter("years") != null) { %>
				<input type=submit name=weeks value="Weeks">
				<input type=submit name=months value="Months">
				<input type=submit name=years value="Years">
		<% } %>
	</form>

</BODY>

</HTML>
