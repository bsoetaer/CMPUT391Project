<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
<title>Upload image</title> 
</head>
<body> 

<h4>Create Radiologist Record!
</h4>
<p>
</p><hr>
Enter relevant fields:
<form name="Create_rad_record" action="/CMPUT391Project/upload/make_record.jsp?rid=${param.rid}">
<table>
  <tbody><tr>
    <th>Patient id</th> 
    <td><input name="patient_id" type="number"></td>
  </tr>
  <tr>
    <th>Doctor Id</th>
    <td><input name="doctor_id" type="number"></td>
  </tr>
  <tr>
    <th>Test Type</th>
    <td><input name="test_type" type="text"></td>
  </tr>
  <tr>
    <th>Prescribing Date</th>
    <td><input name="prescribing_date" type="date"></td>
  </tr>
  <tr>
    <th>Test Date</th>
    <td><input name="test_date" type="date"></td>
  </tr>
  <tr>
    <th>Diagnosis</th>
    <td><input name="diagnosis" type="text"></td>
  </tr>
  <tr>
    <th>Description</th>
     <td><textarea name="description" cols=40 rows=6></textarea></td>
  </tr>
  <tr>
    <td colspan="2" align="CENTER"><input name="create_record" value="Create" type="submit"></td>
  </tr>
</tbody></table>
</form>

<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>


  
  <%!
    /**
     * Get and display personal info as html table rows.
     */
    void form(Integer person_id,HttpServletRequest request, Connection conn, JspWriter out) throws SQLException, IOException
    {
    
     if (request.getParameter("create_record") != null)
     {
     out.println("<hr> OKAY THEN I CAN ATLEAST CREATE RECORD<hr>");
      try{
        if(!
        (request.getParameter("patient_id").equals("") || 
        request.getParameter("doctor_id").equals("") || 
        request.getParameter("test_type").equals("") || 
        request.getParameter("prescribing_date").equals("") || 
        request.getParameter("test_date").equals("") || 
        request.getParameter("diagnosis").equals("") || 
        request.getParameter("description").equals(""))
        )
        {
            conn.setAutoCommit(false);
            Statement stmt2 = conn.createStatement();
            ResultSet rset2 = stmt2.executeQuery("select record_seq.NEXTVAL from dual");
            int nextItemId;
            if(rset2.next())
            {
              nextItemId = rset2.getInt(1);
            }
            else    
            {
                conn.close();
                out.println("<b>Error: item_seq does not exist</b>");
                return;       
            }

            // check the fields tho
            int patient_id = Integer.parseInt(request.getParameter("patient_id"));
            int doctor_id = Integer.parseInt(request.getParameter("doctor_id"));
            int rad_id = person_id;
            String test_type = request.getParameter("test_type");
            String sprescribing_date = request.getParameter("prescribing_date");
            String stest_date = request.getParameter("test_date");
            String diagnosis = request.getParameter("diagnosis");
            String description = request.getParameter("description");
            // date stuff
            DateFormat dateFormat = new SimpleDateFormat("MM-dd-yyyy");
            Date prescribing_date = dateFormat.parse(sprescribing_date);
            Date test_date = dateFormat.parse(stest_date);





            PreparedStatement addRecord = conn.prepareStatement("insert into radiology_record values(?, ?, ? , ? , ? , ? , ?, ? , ?)");
            addRecord.setInt(1, nextItemId);
            addRecord.setInt(2, patient_id);
            addRecord.setInt(3, doctor_id);
            addRecord.setInt(4, rad_id);
            addRecord.setString(5, test_type);
            

            addRecord.setDate(6, new java.sql.Date(prescribing_date.getTime()));
            addRecord.setDate(7,  new java.sql.Date(test_date.getTime()));
            addRecord.setString(8, diagnosis);
            addRecord.setString(9, description);

            addRecord.executeUpdate();
            stmt2.executeUpdate("commit");
            stmt2.close();
            addRecord.close();
            //enable the auto commit mode
            


        }
      }
      catch (Exception ex)
      {
        out.println("<hr>" + ex.getMessage() + "<hr>");
      }
     }
   out.println("<hr>It atleast comes here<hr>");
   }
  
    void displayInfo(Integer person_id, Connection conn, JspWriter out) throws SQLException, IOException{
      // select person info for user from table
      Statement stmt = null;
      ResultSet rset = null;
      String sql = "SELECT record_id, patient_id, doctor_id, test_type, prescribing_date ,test_date , diagnosis, description " +
        "FROM radiology_record " +
        "WHERE radiologist_id = "+person_id; //hard code for now
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
        out.println("<h4>Current Records</h4>");

        out.println("<table>");
          out.println("<table border=1>");
        out.println("<TR>");
        out.println("<th>Record Id (Click on Name to upload)</th>");
        out.println("<th>Patient Id</th>");
        out.println("<th>Doctor Id</th>");
        out.println("<th>Test Type</th>");
        out.println("<th>Prescribing Date</th>");
        out.println("<th>Test Date</th>");
        out.println("<th>Diagnosis</th>");
        out.println("<th>Description</th>");
        out.println("</TR>");

        // print the stuff now
        while(rset.next()) { 
          out.println("<tr>");
          out.println("<td>"); 
          out.print("<li><a href=\"../upload/upload_image.jsp");
          out.print("?rid=");
          out.print(rset.getInt(1));
          out.print("\">");
          out.print(rset.getInt(1));
          out.println("</a></li>");
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getInt(2)); 
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getInt(3)); 
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getString(4)); 
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getDate(5)); 
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getDate(6)); 
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getString(7)); 
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getString(8)); 
          out.println("</td>");
          out.println("</tr>"); 
        } 

        out.println("</table>");
      }
    }
    
    /**
     * Get and display family doctor names as an html tabl row.
     */
    void getDoctor(Integer person_id, Connection conn, JspWriter out) throws SQLException, IOException {

      // Select family doctors from table
      Statement stmt = null;
      ResultSet rset = null;
      String sql = "SELECT first_name, last_name " +
        "FROM persons p, family_doctor f " +
        "WHERE f.patient_id = "+person_id+" " +
        "AND f.doctor_id = p.person_id";
      try{
        stmt = conn.createStatement();
        rset = stmt.executeQuery(sql);
      }
      catch(Exception ex){
        out.println("<hr>" + ex.getMessage() + "<hr>");
      }

      if(rset.isBeforeFirst()) {
        out.println("<TR>");
        out.println("<TD>Family Doctor(s) </TD>");
        out.println("<TD>");
      }

      String doc_name = "";
      while (rset != null && rset.next()) {
        doc_name = getStringData(rset, 1) + " " + getStringData(rset, 2);
        out.println("Dr. "+doc_name+"<br>");
      }

      if( rset.isAfterLast() ) {
        out.println("</TD>");
        out.println("</TR>");
      }
    }

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


    displayInfo(person_id, conn, out);
    form(person_id,request , conn , out);

    try{
      conn.close();
    }
    catch(Exception ex){
      out.println("<hr>" + ex.getMessage() + "<hr>");
    }
    
  %>


</body></html>