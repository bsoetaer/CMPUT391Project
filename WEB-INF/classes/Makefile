JC = javac
CLASSPATH = -classpath ../lib/ojdbc6.jar:../lib/commons-fileupload-1.0.jar:/usr/local/catalina/lib/servlet-api.jar

default: UploadImage.class

UploadImage.class: UploadImage.java
	$(JC) $(CLASSPATH)  UploadImage.java	

clean:
	$(RM) *.class