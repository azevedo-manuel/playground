/* =================================
NAME: testbackgroundpush.js
AUTHOR: 
 wjb@netcraftsmen.net
 http://www.netcraftsmen.net/blogs/pushbackgroundtoipphone.html
DATE : 2/15/2010

ENHANCED:
 manuel@azevedomail.net
DATE: 29.Fev.2012
* Added error verification in case the script cannot contact the phone
* Added output to text file

COMMENT: No longer a demo

version 0.1


Instructions:

* Configure phone personalization in CUCM
* Add the phones to a user (for authentication to work)
* Add two images (thumbnail and full background - see Cisco's docs for correct size of the model of your phone)
  to a web server. Make sure you can access these images with a web browser and that
  the phones can reach this web server
* Configure the script to:
   - Username and password of the auth user
   - IP addresses of the phones to be updated
   - The URL of the thumbnail
   - The URL of the background
   - The name of the file to output debug data
   
 When running the script, the output file will be generated. When the string "--- *** FINISHED *** ---"
 appears at the end of the file, the script finished execution.
   
================================== */
//BEGIN: modify the following
var myuserid="userid";//this is the user object associated to the phone(s)
var mypassword="password";//this is the user password

//modify the myphonelistr to include a list of phones you want updated
//a string value of one IP address is perfectly acceptable

var myphoneliststr = "10.201.1.11,10.201.1.12,10.201.1.13,10.201.1.16";

var thumbnailurl = "http://10.10.2.106/thumbnail.png"; //the thumbnail image
var backgroundurl = "http://10.10.2.106/background.png"; //this is the actual background

var outputfile = "output.txt";

//END: modify

var objFSO = new ActiveXObject("Scripting.FileSystemObject");
objFSO.CreateTextFile(outputfile,true,true);
var objFile = objFSO.GetFile(outputfile);

var textStream=objFile.OpenAsTextStream(2,-1);


var myphonearr = myphoneliststr.split(","); //create an array to walk through
var myauth = text2base64(myuserid + ":" + mypassword);//Create HTML basic auth string
var xmlhttp = new ActiveXObject("Msxml2.ServerXMLHTTP.6.0"); //Object used for client connection

// Loop through the phone list
for (var i=0;i<myphonearr.length;i++) {
	 //WScript.Echo("Processing phone record: " + myphonearr[i]);
	 textStream.WriteLine("Processing phone record: " + myphonearr[i]);
	 var myxml = "XML=<setBackground> <background><image>"
			   + backgroundurl + "</image> <icon>" + thumbnailurl
			   + "</icon></background></setBackground>";
	 var WebServer = "http://" + myphonearr[i] + "/CGI/Execute";
	 try {
		 xmlhttp.open("POST", WebServer, false);
		 with (xmlhttp){
			setRequestHeader("Man", "POST " + WebServer + " HTTP/1.1");
			setRequestHeader("MessageType", "CALL");
			setRequestHeader("Content-Type", "text/xml");
			setRequestHeader("Host", myphonearr[i] + ":80");
			setRequestHeader("Authorization", "Basic " + myauth);
			setRequestHeader("Content-length", myxml.length);
		}
		try {
			xmlhttp.send(myxml);
			textStream.WriteLine(xmlhttp.responseText);
			//WScript.Echo(xmlhttp.responseText);
		}
		catch(e) {
			textStream.Write("Error trying to send: "+e);
		}
	 }
	 catch(e) {
		textStream.Write("Error trying to open: "+e);
	 }
	 textStream.WriteLine("------------------");
}

textStream.WriteLine("---*** FINISHED ***---");
textStream.Close();

/******************************************************
function text2base64() Used to create hashed string
******************************************************/
function text2base64(text) {
  var j = 0;
  var i = 0;
  var base64 = new Array();
  var base64string = "";
  var base64key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  var text0, text1, text2;

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Step thru the input text string 3 characters per loop, creating 4 output characters per loop  //
////////////////////////////////////////////////////////////////////////////////////////////////////

  for (i=0; i < text.length;  )
  {
    text0 = text.charCodeAt(i);
    text1 = text.charCodeAt(i+1);
    text2 = text.charCodeAt(i+2);

    base64[j] = base64key.charCodeAt((text0 & 252) >> 2);
    if ((i+1)<text.length)      // i+1 is still part of string
    {
      base64[j+1] = base64key.charCodeAt(((text0 & 3) << 4)|((text1 & 240) >> 4));
      if ((i+2)<text.length)  // i+2 is still part of string
      {
        base64[j+2] = base64key.charCodeAt(((text1 & 15) << 2) | ((text2 & 192) >> 6));
        base64[j+3] = base64key.charCodeAt((text2 & 63));
      }
      else
      {
        base64[j+2] = base64key.charCodeAt(((text1 & 15) << 2));
        base64[j+3] = 61;
      }
    }
    else
    {
      base64[j+1] = base64key.charCodeAt(((text0 & 3) << 4));
      base64[j+2] = 61;
      base64[j+3] = 61;
    }
    i=i+3;
    j=j+4;
  }
 
  ////////////////////////////////////////////
  //  Create output string from byte array  //
  ////////////////////////////////////////////

  for (i=0; i<base64.length; i++)
  {
    base64string += String.fromCharCode(base64[i]);
  }

  return base64string;
}