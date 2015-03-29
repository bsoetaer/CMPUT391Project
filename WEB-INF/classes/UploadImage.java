/***
 *  A sample program to demonstrate how to use servlet to 
 *  load an image file from the client disk via a web browser
 *  and insert the image into a table in Oracle DB.
 *  
 *  Copyright 2007 COMPUT 391 Team, CS, UofA                             
 *  Author:  Fan Deng
 *                                                                  
 *  Licensed under the Apache License, Version 2.0 (the "License");         
 *  you may not use this file except in compliance with the License.        
 *  You may obtain a copy of the License at                                 
 *      http://www.apache.org/licenses/LICENSE-2.0                          
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *  
 *  Shrink function from
 *  http://www.java-tips.org/java-se-tips/java.awt.image/shrinking-an-image-by-skipping-pixels.html
 *
 *
 *  the table shall be created using the following
      CREATE TABLE pictures (
            pic_id int,
	        pic_desc  varchar(100),
		    pic  BLOB,
		        primary key(pic_id)
      );
      *
      *  One may also need to create a sequence using the following 
      *  SQL statement to automatically generate a unique pic_id:
      *
      *   CREATE SEQUENCE pic_id_sequence;
      *
      ***/

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import oracle.sql.*;
import oracle.jdbc.*;
import java.awt.Image;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

/**
 *  The package commons-fileupload-1.0.jar is downloaded from 
 *         http://jakarta.apache.org/commons/fileupload/ 
 *  and it has to be put under WEB-INF/lib/ directory in your servlet context.
 *  One shall also modify the CLASSPATH to include this jar file.
 */
import org.apache.commons.fileupload.DiskFileUpload;
import org.apache.commons.fileupload.FileItem;

public class UploadImage extends HttpServlet {
    public String response_message = "";
    public void doPost(HttpServletRequest request,HttpServletResponse response)
	throws ServletException, IOException {
	//  change the following parameters to connect to the oracle database
	String username = "vzphung";
	String password = "superman123";
	String drivername = "oracle.jdbc.driver.OracleDriver";
	String dbstring ="jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
	int pic_id;

	try {
	    //Parse the HTTP request to get the image stream
	    DiskFileUpload fu = new DiskFileUpload();
	    List<FileItem> FileItems = fu.parseRequest(request);
	        
	    // Process the uploaded items, assuming only 1 image file uploaded
	    FileItem imagePath = null;
	    String record_id = "";
	    int image_id = -1;
	    long size = 0;
	    for (FileItem item : FileItems){
	    	String fieldName = item.getFieldName();
	    	if (fieldName.equals("image_path")){
	    		imagePath = item;
	    		size = item.getSize();
	    	}else if (fieldName.equals("record_id")){
	    		record_id = item.getString();
	    	}
	    }

	    //Get the image stream
	    InputStream instream = imagePath.getInputStream();

	    BufferedImage img = ImageIO.read(instream);
	    BufferedImage thumbNail = shrink(img, 10);
	    BufferedImage regularImage = shrink(img,2);

        // Connect to the database and create a statement
        Connection conn = getConnected(drivername,dbstring, username,password);
	    conn.setAutoCommit(false); // THIS caused a lot of problems.. 
	    Statement stmt = conn.createStatement();

	    /*
	     *  First, to generate a unique pic_id using an SQL sequence
	     */
	    stmt.setQueryTimeout(60);
	    ResultSet rset1 = stmt.executeQuery("SELECT image_id_sequence.nextval from dual");
	    rset1.next();
	    image_id = rset1.getInt(1);
	    //Insert an empty blob into the table first. Note that you have to 
	    //use the Oracle specific function empty_blob() to create an empty blob

	    stmt.execute("INSERT INTO pacs_images VALUES(" + record_id + ","
					+ image_id + ", empty_blob(), empty_blob(), empty_blob())");

	    // to retrieve the lob_locator 
	    // Note that you must use "FOR UPDATE" in the select statement
 		String cmd = "SELECT * FROM pacs_images WHERE image_id = " + image_id + " AND record_id = "
 			+record_id +"  FOR UPDATE";
		ResultSet rset = stmt.executeQuery(cmd);
		rset.next();
		BLOB thumb = ((OracleResultSet) rset).getBLOB(3);
		BLOB regular = ((OracleResultSet) rset).getBLOB(4);
		BLOB full = ((OracleResultSet) rset).getBLOB(5);

		OutputStream full_outstream = full.getBinaryOutputStream();
		ImageIO.write(img, "jpg", full_outstream);

		OutputStream thumb_outstream = thumb.getBinaryOutputStream();
		ImageIO.write(thumbNail, "jpg", thumb_outstream);

		OutputStream regular_outstream = regular.getBinaryOutputStream();
		ImageIO.write(regularImage, "jpg", regular_outstream);

		instream.close();	
 		full_outstream.close();
 		thumb_outstream.close();
 		regular_outstream.close();



        stmt.executeUpdate("commit");
	    response_message = " Upload OK!  ";
        conn.close();

	} catch( Exception ex ) {
	    response_message = response_message + " "+ ex.toString() ;
	}

	//Output response to the client
	response.setContentType("text/html");
	PrintWriter out = response.getWriter();
	out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 " +
		    "Transitional//EN\">\n" +
		    "<HTML>\n" +
		    "<HEAD><TITLE>Upload Message</TITLE></HEAD>\n" +
		    "<BODY>\n" +
		    "<H1>" +
		            response_message + "   ....as;dfkasjd;fklajsdf"  + 
		    "</H1>\n" +
		    "</BODY></HTML>");
    }

    /*
      /*   To connect to the specified database
    */
    private static Connection getConnected( String drivername,
					    String dbstring,
					    String username, 
					    String password  ) 
	throws Exception {
	Class drvClass = Class.forName(drivername); 
	DriverManager.registerDriver((Driver) drvClass.newInstance());
	return( DriverManager.getConnection(dbstring,username,password));
    } 

    //shrink image by a factor of n, and return the shrinked image
    public static BufferedImage shrink(BufferedImage image, int n) {

        int w = image.getWidth() / n;
        int h = image.getHeight() / n;

        BufferedImage shrunkImage =
            new BufferedImage(w, h, image.getType());

        for (int y=0; y < h; ++y)
            for (int x=0; x < w; ++x)
                shrunkImage.setRGB(x, y, image.getRGB(x*n, y*n));

        return shrunkImage;
    }
}
