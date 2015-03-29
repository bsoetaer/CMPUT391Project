<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
<title>Sample program -- Upload image</title> 
</head>
<body> 

<h4> The following can be used to insert an image of BLOB type into an
Oracle database.
</h4>
Note that (1) the table in the database is created by 
<pre>      CREATE TABLE pictures (
            pic_id int,
	    pic_desc  varchar(100),
	    pic  BLOB,
	    primary key(pic_id)
      )
</pre>
(2) an SQL sequence in the database is created by
<pre>   CREATE SEQUENCE pic_id_sequence;
</pre>
<p>
</p><hr>
Please input or select the path of the image!
<form name="upload-image" method="POST" enctype="multipart/form-data" action="UploadImage?rid=${param.rid}">
<table>
  <tbody><tr>
    <th>File path: </th>
    <td><input name="image_path" type="file"></td>
  </tr>
  <tr>
    <th>Record Id </th>
    <td><input name="record_id" type="number"></td>
  </tr>
  <tr>
    <td colspan="2" align="CENTER"><input name=".submit" value="Upload" type="submit"></td>
  </tr>
</tbody></table>
</form>
 
HI!
${param.rid}
</body></html>