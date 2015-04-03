<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
<title>Regular Size Image</title> 
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
</head>
<body> 

 <%
		// Return user to login page if session expired. Return to home if not admin.
		Integer person_id = (Integer) session.getAttribute("person_id");
		String cls = "";
		if(person_id == null) 
			response.sendRedirect("../login/login.jsp");
		else {
			cls = (String) session.getAttribute("class");
			if(!cls.equals("r"))
				response.sendRedirect("../login/home.jsp");
		}
	%>


  <!--Navigation Bar -->
	<ul>
		<li><a href="../login/home.jsp">Home</a></li>
		<li><a href="../login/personal_info.jsp">Change Personal Info</a></li>
		<li><a href="../search/search.jsp">Search Records</a></li>
		<% if(cls.equals("a")) { %>
			<li><a href="../user-management/userManagement.jsp">User Management</a></li>
			<li><a href="../generate_reports/generate_report.jsp">Generate Reports</a></li>
			<li><a href="../data_analysis/dataAnalysis.jsp">Data Analysis</a></li>
		<% } else if(cls.equals("r")) { %>
			<li><a href="make_record.jsp">Upload Images</a></li>
		<% } %>
		<li><a href="../docs/user-manual/Uploading-Images.html#Uploading-Images">Help</a></li>
		<li><a href="../login/logout.jsp">Logout</a></li>
	</ul>
  

<h4>Regular image for id ${param.rid}</h4>

<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%!

    void displayInfo(Integer image_id, Connection conn, JspWriter out) throws SQLException, IOException{
      // select person info for user from table

        out.println("<hr>");
        out.println("<h4>Regular Image</h4>");
        out.print("<img src=\"/CMPUT391Project/GetOnePic?regular");
        out.print(image_id);
        out.println("\">");
        out.println("<br>");
        out.print("<a href=\"/CMPUT391Project/GetOnePic?");
        out.print("full");
        out.print(image_id);
        out.print("\">");
        out.print("Click Here for Full Size");
        out.println("</a>");
      } 

    
    

  %>

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

    int image_id = Integer.parseInt(request.getParameter("regular"));
    displayInfo(image_id, conn, out);

    try{
      conn.close();
    }
    catch(Exception ex){
      out.println("<hr>" + ex.getMessage() + "<hr>");
    }
    
  %>



 
</body></html>
