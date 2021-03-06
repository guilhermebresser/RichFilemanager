<%@page import="org.slf4j.LoggerFactory"%>
<%@page import="org.slf4j.Logger"%>
<%@page import="edu.fuberlin.*"%>
<%@ page pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.io.*"%>
<%@include file="auth.jsp"%>
<%
/*
 *  connector filemanager.jsp
 *
 *  @license  MIT License
 *  @author   Dick Toussaint <d.tricky@gmail.com>
 *  @copyright  Authors
 *
 *  CHANGES: 
 *  - check strictServletCompliance 8/16
 *  - dynamic content type setting  8/16
 */ 
  FileManagerI fm =  new RichFileManager(getServletContext(), request);
  final Logger log = LoggerFactory.getLogger("filemanager");
  boolean strictServletCompliance = false; // default value is ISO-8859-1.
  JSONObject responseData = null;
  String mode = "";
    boolean putTextarea = false;
  if(!auth(request)) {
	  responseData = fm.getErrorResponse(fm.lang("AUTHORIZATION_REQUIRED"));
  }
  else { 
    if(request.getMethod().equals("GET")) {
      if(request.getParameter("mode") != null && request.getParameter("mode") != "") {
        mode = request.getParameter("mode");
        // cft. http://wiki.apache.org/tomcat/FAQ/CharacterEncoding#Q2
        String [] queryParams = null;
        Map<String,String> qpm = new HashMap<String,String>();
        if (strictServletCompliance) {
          queryParams  = java.net.URLDecoder.decode(request.getQueryString(), "UTF-8").split("&");
          for (int i = 0; i < queryParams.length; i++) {
            String[] qp = queryParams[i].split("=");
            if (qp.length >1) {
              qpm.put(qp[0], qp[1]);
            } else {
              qpm.put(qp[0], "");
            }
          }
        }
        try {
	        // renamed getinfo to getfile
	        if (mode.equals("getinfo") || mode.equals("getfile")){
	          if(fm.setGetVar("path", (strictServletCompliance)? qpm.get("path"): request.getParameter("path"))) {
	            responseData = fm.getInfo();
	          }
	        }
	        else if (mode.equals("initiate")){
	           responseData = fm.initiate(request);
	        }        
	        else if (mode.equals("getfolder")){
	          if(fm.setGetVar("path",  (strictServletCompliance)? qpm.get("path"):request.getParameter("path"))) {
	            responseData = fm.getFolder(request);
	          }
	        }
	        else if (mode.equals("rename")){
	          if(fm.setGetVar("old",  (strictServletCompliance)? qpm.get("old"):request.getParameter("old")) && 
	              fm.setGetVar("new",  (strictServletCompliance)? qpm.get("new"):request.getParameter("new"))) {
	            responseData = fm.rename();
	          }
	        }
	        else if (mode.equals("delete")){
	          if(fm.setGetVar("path",  (strictServletCompliance)? qpm.get("path"):request.getParameter("path"))) {
	            responseData = fm.delete();
	          }
	        }
	        else if (mode.equals("addfolder")){
	          if(fm.setGetVar("path",  (strictServletCompliance)? qpm.get("path"):request.getParameter("path")) && 
	              fm.setGetVar("name",  (strictServletCompliance)? qpm.get("name"):request.getParameter("name"))) {
	            responseData = fm.addFolder();
	          }
	        }
	        else if (mode.equals("download")){
	          if(fm.setGetVar("path",  (strictServletCompliance)? qpm.get("path"):request.getParameter("path"))) {
	        	  responseData = fm.download(request, response);
	          }
	        }
	        else if (mode.equals("getimage")){
	          if(fm.setGetVar("path",  (strictServletCompliance)? qpm.get("path"):request.getParameter("path"))) {
	            String paramThumbs  =request.getParameter("thumbnail");
	            responseData = fm.preview(request, response);
	          }
	        } 
	        else if (mode.equals("readfile")){
	          if(fm.setGetVar("path",  (strictServletCompliance)? qpm.get("path"):request.getParameter("path"))) { 
	        	  responseData = fm.preview(request, response);
	          }
	        }
	        else if (mode.equals("move")){
	            if(fm.setGetVar("old",  (strictServletCompliance)? qpm.get("old"):request.getParameter("old")) && 
	                    fm.setGetVar("new",  (strictServletCompliance)? qpm.get("new"):request.getParameter("new")) 
	                    ) {
	                responseData = fm.moveItem();
	                }
	        }
	        else if (mode.equals("copy")){
	              responseData = fm.copyItem(request);
	         }
	        else if (mode.equals("summarize")) {
	        	responseData = fm.summarize();
	        } else {
	        	responseData = fm.getErrorResponse(fm.lang("MODE_ERROR"));
	        }
        } catch (Exception e) {
        	// already formatted if from setGetVar
        	log.error("error in filemanager.jsp:",e);
        	responseData = fm.getErrorResponse(e.getMessage());
        }
      }
    } else if(request.getMethod().equals("POST")){
      mode = "upload"; // just informal, real param mode is used in java class
      responseData = fm.add();
      //putTextarea = true;
    }
  }
  if (responseData != null){
      //request.setCharacterEncoding("UTF-8");  
			// only if set
			if (putTextarea) {
				response.setContentType("text/html; charset=UTF-8");
			} else {
				response.setContentType("application/json; charset=UTF-8");
			}
			PrintWriter pw = response.getWriter();
      String responseStr = responseData.toString();
      if (putTextarea)
        responseStr = "<textarea>" + responseStr + "</textarea>";
      pw.print(responseStr);
      pw.close();
  }
  %>  