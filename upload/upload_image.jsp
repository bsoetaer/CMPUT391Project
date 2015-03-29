<!DOCTYPE html PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252"> 
<title>Upload image</title> 
</head>
<body> 

<h4>Upload Image!
</h4>
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
    <th>Record Id </th>
    <td><input name="record_id" type="number"></td>
  </tr>
  <tr>
    <td colspan="2" align="CENTER"><input name=".submit" value="Upload" type="submit"></td>
  </tr>
</tbody></table>
</form>
 
${param.rid}
</body></html>