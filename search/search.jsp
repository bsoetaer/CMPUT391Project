<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
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
<title>Search</title> 
</head>
<body> 


<!--Page to search records . Based on examples provided by
  Dr. Yuan
    @author  Vincent Phung
   -->

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
    <li><a href="../search/search.jsp">Search Records</a></li>
    <% if(cls.equals("a")) { %>
      <li><a href="../user-management/userManagement.jsp">User Management</a></li>
      <li><a href="../generate_reports/generate_report.jsp">Generate Reports</a></li>
      <li><a href="../data_analysis/dataAnalysis.jsp">Data Analysis</a></li>
    <% } else if(cls.equals("r")) { %>
      <li><a href="../upload/make_record.jsp">Upload Images</a></li>
    <% } %>
    <li><a href="../docs/user-manual/Home.html#Home">Help</a></li>
    <li><a href="../login/logout.jsp">Logout</a></li>
  </ul>




<h4>Record Search
</h4>
<p>
</p><hr>
Search Parameters:
<form name="search_records" action="/CMPUT391Project/search/search.jsp">
<table>
  <tbody><tr>
    <th>Sort by:</th> 
    <td>
    <input type="radio" name="sort_by" value="recent_first">Test Date: Most Recent First<br>
    <input type="radio" name="sort_by" value="recent_last">Test Date: Most Recent Last<br>
    <input type="radio" name="sort_by" value="rank" checked="checked">Rankings<br>
    </td>
  </tr>
  <tr>
    <th>From Date</th>
    <td><input name="from_date" type="date"></td>
  </tr>
  <tr>
    <th>To</th>
    <td><input name="to_date" type="date"></td>
  </tr>
  <tr>
    <th>Keyword(s)</th>
     <td><textarea name="keywords" cols=40 rows=6></textarea></td>
  </tr>
  <tr>
    <td colspan="2" align="CENTER"><input name="search_records" value="Search!" type="submit"></td>
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
     * Get and display search records as html table rows.
     */
    void form(Integer person_id,String cls , HttpServletRequest request, Connection conn, JspWriter out) throws SQLException, IOException
    {
    
     if (request.getParameter("search_records") != null)
     {
      try{
        if(!(request.getParameter("sort_by").equals("") ))
        {   
          String sort_by  = request.getParameter("sort_by");
          String from_date = "";
          String to_date = "";

          String selectQuery = " SELECT ";
          String containsQuery = " AND  (";
          String whereClause = " WHERE ";
          String orderClause = " ORDER BY ";

          // form checking ..
          if ((sort_by.equals("recent_first") || sort_by.equals("recent_last")) && 
          (request.getParameter("from_date").equals("") && request.getParameter("to_date").equals("")))
          {
            out.println("<hr> You need atleast one date entered if you are sorting by date.. <hr>");
            return;
          }
          if (sort_by.equals("rank") && request.getParameter("keywords").equals(""))
          {
            out.println("<hr> You need atleast one keyword if you are sorting by ranking.. <hr>");
            return;
          } // done form checking .. 

          

          //okay figure out what kind of user i am!
          if (cls.equals("a")){
          }else if (cls.equals("p")){
            whereClause = whereClause + " r.patient_id = " + person_id;
          }else if (cls.equals("d")){
            whereClause = whereClause + " r.doctor_id = " + person_id+ " AND r.patient_id = p.person_id" ;
          }else if (cls.equals("r")){
            whereClause = whereClause + " r.radiologist_id = " + person_id+ " AND r.patient_id = p.person_id";
          }else {
            out.println("<hr> You are not a real class dude...  <hr>");
            return;
          }

          whereClause = whereClause + " AND ";

          // figure out dates!
          if (request.getParameter("from_date").equals("")){
            from_date = "1900-01-01";
          }
          if (request.getParameter("to_date").equals("")){
            to_date = "9999-12-12";
          } else{
            from_date ="TO_DATE('"+request.getParameter("from_date")+"'  , 'yyyy-MM-dd' )" ;
            to_date ="TO_DATE('"+request.getParameter("to_date")+"'  , 'yyyy-MM-dd' )" ;
          }
          if (request.getParameter("sort_by").equals("recent_first")){
            whereClause = whereClause + " r.test_date > " + from_date +" and r.test_date < " + to_date;
            orderClause = orderClause + " r.test_date DESC";
          }else if (request.getParameter("sort_by").equals("recent_last")){
             whereClause = whereClause + " r.test_date > " + from_date +" and r.test_date < " + to_date; 
              orderClause = orderClause + " r.test_date ASC";
          }else if (request.getParameter("sort_by").equals("rank")){
              whereClause = whereClause + " r.test_date > " + from_date +" and r.test_date < " + to_date; 
              orderClause = orderClause + " rank DESC";
          }else {
            out.println("<hr> We cant sort by that ..   <hr>");
            return;
          }


          // now we gotta make our search query huh ...
          // alright so the idea is to get the rank of each keyword, add em up
          // and that will be the total rank.. like if keywords were [mega cool] 
          // then we would go do rank of mega then add to rank of cool etc for total

          // so first we gotta split the words by ... space
          String[] myKeywords = request.getParameter("keywords").split(" ");
          out.println(" <br> " ) ;

          int scoreLabel = 1;
          for(String keyword: myKeywords){
            containsQuery = containsQuery + "(contains(p.first_name,'" + keyword +"',"+scoreLabel + ") > 0  OR " +
              "contains(p.last_name,'" + keyword +"',"+ (scoreLabel+1) +") > 0 OR " + 
              "contains(r.diagnosis,'" + keyword +"',"+ (scoreLabel+2) +") > 0 OR " +
              "contains(r.description,'" + keyword +"',"+ (scoreLabel+3) +") > 0 )";

            containsQuery = containsQuery + "OR ";

            selectQuery =  selectQuery + " ( 6*(score("+scoreLabel +") + score("+ (scoreLabel+1) +")) + 3*score(" + (scoreLabel+2) +") + score ("+ (scoreLabel+3) + ") )";
            selectQuery = selectQuery + " + ";
            scoreLabel +=4;
          }

          // now remove the last instance of "or " or "+"
          int lastIndex = containsQuery.lastIndexOf("OR ");
          containsQuery = containsQuery.substring(0 , lastIndex);
          containsQuery = containsQuery + " )";
          lastIndex = selectQuery.lastIndexOf(" + ");
          selectQuery = selectQuery.substring(0,lastIndex);

          selectQuery = selectQuery + " as rank , p.first_name , p.last_name, r.record_id, r.patient_id , r.radiologist_id , r.test_type , r.prescribing_date , r.test_date , "+
            "diagnosis , description ";

          // get that from clause!
          selectQuery = selectQuery + "FROM radiology_record r , persons p ";
          String sql = selectQuery + whereClause + containsQuery + orderClause;
          

          Statement stmt = null;
          ResultSet rset = null;
          try{
              stmt = conn.createStatement();
              rset = stmt.executeQuery(sql);
          }
          catch(Exception ex){
            out.println("<hr>" + ex.getMessage() + "<hr>");
          }

          if (rset != null ){

            
            out.println("<hr>");
            out.println("<h4>Search Results</h4>");
            // table definition!
            out.println("<table>");
            out.println("<table border=1>");
            out.println("<TR>");
            out.println("<th>Rank</th>");
            out.println("<th>Patient First Name</th>");
            out.println("<th>Patient Last Name</th>");
            out.println("<th>Record ID</th>");
            out.println("<th>Patient ID</th>");
            out.println("<th>Radiologist ID</th>");
            out.println("<th>Test Type</th>");
            out.println("<th>Prescribing Date</th>");
            out.println("<th>Test Date</th>");
            out.println("<th>Diagnosis</th>");
            out.println("<th>Description</th>");
            out.println("<th> IMAGE STUFF</th>");
            out.println("</TR>");
            // print the stuff now

            while(rset.next()) { 
              out.println("<tr>");
              out.println("<td>"); 
              out.print(rset.getInt(1)); //rank
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getString(2));  //p.fname
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getString(3));  //p.lname
              out.println("</td>");
              out.println("<td>"); 
              int record_id = rset.getInt(4); 
              out.println(record_id);  //record_id 
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getInt(5));  //patient_id 
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getInt(6));  //radio_id
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getString(7)); //test_type 
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getDate(8)); //presc_date
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getDate(9)); //test_date
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getString(10)); //diagnosis
              out.println("</td>");
              out.println("<td>"); 
              out.println(rset.getString(11)); //description
              out.println("</td>");
              out.println("<td>");

              // get the images for each record dude ..
              Statement innerStmt = null;
              ResultSet innerRset = null;
              String getImageSql = "SELECT image_id " +
                "FROM pacs_images " +
                "WHERE record_id = "+ record_id; 
              try{
                innerStmt = conn.createStatement();
                innerRset = stmt.executeQuery(getImageSql);
              }
              catch(Exception ex){
                out.println("<hr>" + ex.getMessage() + "<hr>");
                return;
              }

              if (innerRset != null) {
                out.println("<table>");
                out.println("<table border=1>");
                out.println("<TR>");
                out.println("<th>Image Id</th>");
                out.println("<th>Thumbnail</th>");
                out.println("</TR>");

                // print the image thumbnails now
                while(innerRset.next()) { 
                  out.println("<tr>");
                  out.println("<td>"); 
                  out.print(innerRset.getInt(1));
                  out.println("</td>");
                  out.println("<td>"); 
                  out.print("<a href=\"/CMPUT391Project/upload/view_image.jsp?");
                  out.print("regular=");
                  out.print(innerRset.getInt(1));
                  out.print("\">");
                  out.print("<img src=\"/CMPUT391Project/GetOnePic?thumbnail");
                  out.print(innerRset.getInt(1));
                  out.println("\"></a>");
                  out.println(); 
                  out.println("</td>");
                  out.println("</tr>"); 
                } 

                out.println("</table>");
              } 

              out.println("</td>"); // end image stuff 
              out.println("</tr>"); 
            }

            out.println("</table>"); 
          }
          

        }
      }
      catch (Exception ex)
      {
        out.println("<hr>" + ex.getMessage() + " haha ? <hr>");
      }
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


    //displayInfo(person_id, conn, out);
    form(person_id,cls, request , conn , out);

    try{
      conn.close();
    }
    catch(Exception ex){
      out.println("<hr>" + ex.getMessage() + "<hr>");
    }
    
  %>


</body></html>