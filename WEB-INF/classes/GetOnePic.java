import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import javax.naming.*;
import javax.sql.*;

/**
 *  This servlet sends one picture stored in the table below to the client 
 *  who requested the servlet.
 *
 *  
 *
 *  The request must come with a query string as follows:
 *    GetOnePic?full12:        sends the full picutre with photo_id = 12
 *    GetOnePic?regular 12: sends the regular sized picture  with photo_id = 12
 *    GetOnePic?thumbnail 12: sends the thumbnail   with photo_id = 12
 *
 *  @author  Li-Yan Yuan
 *  @Modified by Vincent Phung
 *
 */
public class GetOnePic extends HttpServlet 
    implements SingleThreadModel {

    /**
     *    This method first gets the query string indicating PHOTO_ID,
     *    and then executes the query 
     *          select image from yuan.photos where photo_id = PHOTO_ID   
     *    Finally, it sends the picture to the client
     */

    public void doGet(HttpServletRequest request,
		      HttpServletResponse response)
	throws ServletException, IOException {
	
	//  construct the query  from the client's QueryString
	String imageid  = request.getQueryString();
	String query;

	if ( imageid.startsWith("full") )  
	    query = "select full_size from pacs_images where image_id=" + imageid.substring(4);
	else if ( imageid.startsWith("regular") )  
	    query = "select regular_size from pacs_images where image_id=" + imageid.substring(7);
	else
		query = "select thumbnail from pacs_images where image_id=" + imageid.substring(9);

	ServletOutputStream out = response.getOutputStream();

	/*
	 *   to execute the given query
	 */
	Connection conn = null;
	try {
	    conn = getConnected();
	    Statement stmt = conn.createStatement();
	    ResultSet rset = stmt.executeQuery(query);
	    
	    if ( rset.next() ) {
			response.setContentType("image/jpg");
			InputStream input = rset.getBinaryStream(1);	    
			int imageByte;
			while((imageByte = input.read()) != -1) {
			    out.write(imageByte);
			}
			input.close();
	    }
	    else 
			out.println("no picture available");
		
	} catch( Exception ex ) {
	    out.println(ex.getMessage() );
	}
	// to close the connection
	finally {
	    try {
		conn.close();
	    } catch ( SQLException ex) {
		out.println( ex.getMessage() );
	    }
	}
    }

    /*
     *   Connect to the specified database
     */
    private Connection getConnected() throws Exception {

		Context initContext = new InitialContext();
		Context envContext  = (Context)initContext.lookup("java:/comp/env");
		DataSource ds = (DataSource)envContext.lookup("jdbc/myoracle");
		return( ds.getConnection());
	}
}
