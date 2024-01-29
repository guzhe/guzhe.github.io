$(function(){
	var tile = $('.post-title').html();
	console.log(tile == '记录一个webflux的异常问题');
	if(tile == '记录一个webflux的异常问题'){
		if (prompt('请输入文章密码') !== '123456'){
                alert('密码错误！');
                history.back();
        }
	}	
});