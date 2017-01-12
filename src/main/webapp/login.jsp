<%@ page 
	language="java" 
	contentType="text/html; charset=UTF-8" 
	pageEncoding="UTF-8" 
	import="java.util.Date,java.net.*" 
	isThreadSafe="true" 
	isErrorPage="false" 
	autoFlush="true" 
	buffer="8kb" 
	session="false" 
	isELIgnored="false"
%>
<!DOCTYPE html>
<html>
<head>
	<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>geetest</title>
    <link href="${pageContext.request.contextPath}/geetest.css" rel="stylesheet" type="text/css" >
</head>
<body>
<h1>极验验证SDKDemo</h1>
<br><br>
<hr>
<br><br>
<!-- 为使用方便，直接使用jquery.js库，如您代码中不需要，可以去掉 -->
<script src="http://code.jquery.com/jquery-1.12.3.min.js"></script>
<!-- 引入封装了failback的接口--initGeetest -->
<script src="http://static.geetest.com/static/tools/gt.js"></script>
<!-- 若是https，使用以下接口 -->
<!-- <script src="https://code.jquery.com/jquery-1.12.3.min.js"></script> -->
<!-- <script src="https://static.geetest.com/static/tools/gt.js"></script> -->
<div class="popup">
    <h2>弹出式Demo，使用ajax形式提交二次验证码所需的验证结果值</h2><br>
    <p>
        <label>用户名：</label>
        <input id="username1" class="inp" type="text" value="极验验证">
    </p>
    <br>
    <p>
        <label>密&nbsp;&nbsp;&nbsp;&nbsp;码：</label>
        <input id="password1" class="inp" type="password" value="123456">
    </p>

    <br>
    <input class="btn" id="popup-submit" type="submit" value="提交">

    <div id="popup-captcha"></div>
</div>
<script>
    var handlerPopup = function (captchaObj) {
        // 成功的回调
        captchaObj.onSuccess(function () {
            var validate = captchaObj.getValidate();
            $.ajax({
                url: "pc-geetest/validate", // 进行二次验证
                type: "post",
                dataType: "json",
                data: {
                    username: $('#username1').val(),
                    password: $('#password1').val(),
                    geetest_challenge: validate.geetest_challenge,
                    geetest_validate: validate.geetest_validate,
                    geetest_seccode: validate.geetest_seccode
                },
                success: function (data) {
                    if (data && (data.status === "success")) {
                        $(document.body).html('<h1>登录成功</h1>');
                    } else {
                        $(document.body).html('<h1>登录失败</h1>');
                    }
                }
            });
        });
        $("#popup-submit").click(function () {
            captchaObj.show();
        });
        // 将验证码加到id为captcha的元素里
        captchaObj.appendTo("#popup-captcha");
        // 更多接口参考：http://www.geetest.com/install/sections/idx-client-sdk.html
    };
    // 验证开始需要向网站主后台获取id，challenge，success（是否启用failback）
    $.ajax({
        url: "pc-geetest/register?t=" + (new Date()).getTime(), // 加随机数防止缓存
        type: "get",
        dataType: "json",
        success: function (data) {
            // 使用initGeetest接口
            // 参数1：配置参数
            // 参数2：回调，回调的第一个参数验证码对象，之后可以使用它做appendTo之类的事件
            initGeetest({
                gt: data.gt,
                challenge: data.challenge,
                product: "popup", // 产品形式，包括：float，embed，popup。注意只对PC版验证码有效
                offline: !data.success // 表示用户后台检测极验服务器是否宕机，一般不需要关注
                // 更多配置参数请参见：http://www.geetest.com/install/sections/idx-client-sdk.html#config
            }, handlerPopup);
        }
    });
</script>
<br><br>
<hr>
<br><br>
<!-- <form class="popup" action="pc-geetest/validate" method="post">
    <h2>嵌入式Demo，使用表单形式提交二次验证所需的验证结果值</h2>
    <br>
    <p>
        <label for="username2">用户名：</label>
        <input class="inp" id="username2" type="text" value="极验验证">
    </p>
    <br>
    <p>
        <label for="password2">密&nbsp;&nbsp;&nbsp;&nbsp;码：</label>
        <input class="inp" id="password2" type="password" value="123456">
    </p>

    <div id="embed-captcha"></div>
    <p id="wait" class="show">正在加载验证码......</p>
    <p id="notice" class="hide">请先拖动验证码到相应位置</p>

    <br>
    <input class="btn" id="embed-submit" type="submit" value="提交">
</form>

<script>
    var handlerEmbed = function (captchaObj) {
        $("#embed-submit").click(function (e) {
            var validate = captchaObj.getValidate();
            if (!validate) {
                $("#notice")[0].className = "show";
                setTimeout(function () {
                    $("#notice")[0].className = "hide";
                }, 2000);
                e.preventDefault();
            }
        });
        // 将验证码加到id为captcha的元素里，同时会有三个input的值：geetest_challenge, geetest_validate, geetest_seccode
        captchaObj.appendTo("#embed-captcha");
        captchaObj.onReady(function () {
            $("#wait")[0].className = "hide";
        });
        // 更多接口参考：http://www.geetest.com/install/sections/idx-client-sdk.html
    };
    $.ajax({
        // 获取id，challenge，success（是否启用failback）
        url: "pc-geetest/register?t=" + (new Date()).getTime(), // 加随机数防止缓存
        type: "get",
        dataType: "json",
        success: function (data) {
            // 使用initGeetest接口
            // 参数1：配置参数
            // 参数2：回调，回调的第一个参数验证码对象，之后可以使用它做appendTo之类的事件
            initGeetest({
                gt: data.gt,
                challenge: data.challenge,
                product: "embed", // 产品形式，包括：float，embed，popup。注意只对PC版验证码有效
                offline: !data.success // 表示用户后台检测极验服务器是否宕机，一般不需要关注
                // 更多配置参数请参见：http://www.geetest.com/install/sections/idx-client-sdk.html#config
            }, handlerEmbed);
        }
    });
</script>
<br><br>
<hr>
<br><br>
<div class="popup-mobile">
    <h2>移动端手动实现弹出式Demo</h2>
    <br>
    <p>
        <labe for="username3">用户名：</labe>
        <input id="username3" class="inp" type="text" value="极验验证">
    </p>
    <br>
    <p>
        <label for="password3">密&nbsp;&nbsp;&nbsp;&nbsp;码：</label>
        <input id="password3" class="inp" type="password" value="123456">
    </p>
    <br>
    <input class="btn" id="popup-submit-mobile" type="submit" value="提交">
    <div id="mask"></div>
    <div id="popup-captcha-mobile"></div>
</div>

<script>
    $("#mask").click(function () {
        $("#mask, #popup-captcha-mobile").hide();
    });
    $("#popup-submit-mobile").click(function () {
        $("#mask, #popup-captcha-mobile").show();
    });
    var handlerPopupMobile = function (captchaObj) {
        // 将验证码加到id为captcha的元素里
        captchaObj.appendTo("#popup-captcha-mobile");
        //拖动验证成功后两秒(可自行设置时间)自动发生跳转等行为
        captchaObj.onSuccess(function () {
            var validate = captchaObj.getValidate();
            $.ajax({
                url: "mobile-geetest/validate", // 进行二次验证
                type: "post",
                dataType: "json",
                data: {
                    // 二次验证所需的三个值
                    username: $('#username3').val(),
                    password: $('#password3').val(),
                    geetest_challenge: validate.geetest_challenge,
                    geetest_validate: validate.geetest_validate,
                    geetest_seccode: validate.geetest_seccode
                },
                success: function (data) {
                    if (data && (data.status === "success")) {
                        $(document.body).html('<h1>登录成功</h1>');
                    } else {
                        $(document.body).html('<h1>登录失败</h1>');
                    }
                }
            });
        });
        // 更多接口参考：http://www.geetest.com/install/sections/idx-client-sdk.html
    };
    $.ajax({
        // 获取id，challenge，success（是否启用failback）
        url: "mobile-geetest/register?t=" + (new Date()).getTime(), // 加随机数防止缓存
        type: "get",
        dataType: "json",
        success: function (data) {
            // 使用initGeetest接口
            // 参数1：配置参数
            // 参数2：回调，回调的第一个参数验证码对象，之后可以使用它做appendTo之类的事件
            initGeetest({
                gt: data.gt,
                challenge: data.challenge,
                offline: !data.success // 表示用户后台检测极验服务器是否宕机，一般不需要关注
                // 更多配置参数请参见：http://www.geetest.com/install/sections/idx-client-sdk.html#config
            }, handlerPopupMobile);
        }
    });
</script> -->
</body>
</html>