<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
<title>Regular Size Image</title> 
</head>
<body> 

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