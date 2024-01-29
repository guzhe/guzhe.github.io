$(function(){
	const title = $("#post-info .post-title").html();
	if (title && title == '装修清单'){
		if (prompt('请输入密码','') != '930505'){
			 history.go(-1);
		}
	}
});