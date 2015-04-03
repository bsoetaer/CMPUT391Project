<HTML>
	<HEAD>
	<TITLE>Login</TITLE>
	</HEAD>

	<BODY>
	<!--Login page that prompts user for username/password until a valid pair is
		entered. Once a valid pair is entered, creates a new session for the user
		and redirects to the home page.
		@author  Braeden Soetaert
		This code was created based off code created by Hong-Yu Zhang at the University of Alberta.
	 -->
	<%@ page import="java.sql.*" %>
	<%@ page import="javax.sql.*" %>
	<%@ page import="javax.naming.*" %>
	<%@ page import="java.io.IOException" %>
	<%!	
		/**
		 * Display login form to get username and password.
		 */
		void loginForm(JspWriter out) throws IOException { 
			out.println("<form method=post action=login.jsp>");
			out.println("UserName: <input type=text name=USERID maxlength=24><br>");
			out.println("Password: <input type=password name=PASSWD maxlength=24><br>");
			out.println("<input type=submit name=bSubmit value=Submit>");
			out.println("</form>");
		}

		/**
		 * Display login form and also an error message that the last entered info
		 * was incorrect.
		 */
		void loginFailed(javax.servlet.jsp.JspWriter out) throws IOException {
			out.println("<hr><b>Either your username or your password was invalid!</b><hr>");
			loginForm(out);
		}

		/**
		 * Create session for user.
		 */
		void loginSuccess(
			Connection conn, String userName, HttpServletRequest request, 
			HttpServletResponse response, JspWriter out
		) throws SQLException, IOException {
			// Get the session (Create a new one if required)
			HttpSession session = request.getSession( true );
			// Set max inactive time to 30 mins
			session.setMaxInactiveInterval(30 * 60);

			Statement stmt = null;
			ResultSet rset = null;
			String sql = "SELECT users.person_id, first_name, last_name, class " +
				"FROM users, persons " +
				"WHERE user_name = '"+userName+"' " +
				"AND users.person_id = persons.person_id";
			try{
				stmt = conn.createStatement();
				rset = stmt.executeQuery(sql);
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}
			
			// Set session attributes and redirect if data retrieved correctly.
			if (rset != null && rset.next()) {
				session.setAttribute( "user_name", userName );
				session.setAttribute( "person_id", rset.getInt("person_id") );
				session.setAttribute( "first_name", rset.getString("first_name").trim() );
				session.setAttribute( "last_name", rset.getString("last_name").trim() );
				session.setAttribute( "class", rset.getString("class").trim() );
				response.sendRedirect("home.jsp");
			}
			else
				out.println("<hr>Error: User no longer exists.<hr>");
		}
	%>

	<% 
		// Redirect user to home page if they are already logged in.
		Integer person_id = (Integer) session.getAttribute("person_id");
		if(person_id != null) 
			response.sendRedirect("home.jsp");

		// If user submitted data.
		if(request.getParameter("bSubmit") != null) {

			//get the user input from the login page
			String userName = (request.getParameter("USERID")).trim();
			String passwd = (request.getParameter("PASSWD")).trim();

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
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}

			// select password for user from table
			Statement stmt = null;
			ResultSet rset = null;
			String sql = "select password from users where user_name = '"+userName+"'";
			try{
				stmt = conn.createStatement();
				rset = stmt.executeQuery(sql);
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}

			String truepwd = "";

			// Test if user exists
			if (rset != null && rset.next()) {
				// Test if password entered is correct.
				truepwd = (rset.getString(1)).trim();
				if(passwd.equals(truepwd)) 
					loginSuccess(conn, userName, request, response, out);
				else
					// Re-prompt login
					loginFailed(out);
			}
			else
				// Re-prompt login
				loginFailed(out);
		
			try{
				conn.close();
			}
			catch(Exception ex){
				out.println("<hr>" + ex.getMessage() + "<hr>");
			}
		}
		else {
			loginForm(out);
		}      
	%>
	</BODY>
</HTML>

