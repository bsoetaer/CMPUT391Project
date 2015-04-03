<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
<title>Upload image</title> 
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

<!--Page to make upload images to record. Based on examples provided by
  Dr. Yuan
    @author  Vincent Phung
   -->

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


<h4>Images Uploaded to Record id ${param.rid}</h4>

<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%!

    void displayInfo(Integer record_id, Connection conn, JspWriter out) throws SQLException, IOException{
      // select person info for user from table
      Statement stmt = null;
      ResultSet rset = null;
      String sql = "SELECT image_id " +
        "FROM pacs_images " +
        "WHERE record_id = "+ record_id; //hard code for now
      try{
        stmt = conn.createStatement();
        rset = stmt.executeQuery(sql);
      }
      catch(Exception ex){
        out.println("<hr>" + ex.getMessage() + "<hr>");
      }

      // Display personal info in table
      if (rset != null) {
        out.println("<hr>");
        out.println("<h4>Images in Record</h4>");

        out.println("<table>");
        out.println("<table border=1>");
        out.println("<TR>");
        out.println("<th>Image Id</th>");
        out.println("<th>Thumbnail</th>");
        out.println("</TR>");

        // print the stuff now
        while(rset.next()) { 
          out.println("<tr>");
          out.println("<td>"); 
          out.print(rset.getInt(1));
          out.println("</td>");
          out.println("<td>"); 
          out.print("<a href=\"/CMPUT391Project/GetOnePic?");
          out.print("full");
          out.print(rset.getInt(1));
          out.print("\">");
          out.print("<img src=\"/CMPUT391Project/GetOnePic?thumbnail");
          out.print(rset.getInt(1));
          out.println("\"></a>");
          out.println(); 
          out.println("</td>");
          out.println("</tr>"); 
        } 

        out.println("</table>");
      } 
      else
      {
        out.println("No images uploaded to record .. ");
      }
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

    int record_id = Integer.parseInt(request.getParameter("rid"));
    displayInfo(record_id, conn, out);

    try{
      conn.close();
    }
    catch(Exception ex){
      out.println("<hr>" + ex.getMessage() + "<hr>");
    }
    
  %>


<h4>Upload Image!</h4>
<p>
</p><hr>
Please input or select the path of the image and the Record ID!
<!-- TODO: Might want to use url parameters instread of specifying recordid!-->
<form name="upload-image" method="POST" enctype="multipart/form-data" action="/CMPUT391Project/UploadImage?rid=${param.rid}">
<table>
  <tbody><tr>
    <th>File path: </th>
    <td><input name="image_path" type="file"></td>
  </tr>
  <tr>
    <td colspan="2" align="CENTER"><input name=".submit" value="Upload" type="submit"></td>
  </tr>
</tbody></table>
</form>
 
</body></html>
