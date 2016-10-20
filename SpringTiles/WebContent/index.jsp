
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
 <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><tiles:insertAttribute name="title" ignore="true" /></title>
</head>
<body>
		<div>
			<%@include file="/WEB-INF/jsp/header.jsp" %>	
		</div>
		
		<div style="float:left;padding:10px;width:15%;">
				<%@include file="/WEB-INF/jsp/menu.jsp" %>
		</div>
		
		<div style="float:left;padding:10px;width:80%;border-left:1px solid pink;">
		
				<a href="hello.html">Hello Spring</a> | 
			<a href="contact.html">Contact</a>
		</div>
		
    	<div style="clear:both">
    		<%@include file="/WEB-INF/jsp/footer.jsp" %>
    	</div>
    	
</body>
</html>

