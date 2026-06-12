<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>法小智 - 登录</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/login.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Barlow:wght@300;400;500;600&display=swap" rel="stylesheet">
</head>
<body>
<div id="shader-bg"></div>

<div id="app" class="container">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6 col-xl-5">

            <div class="login-container-wrapper">
                <div class="personal-logo">gassp_lawer</div>

                <div class="login-card">
                    <div class="brand-section">
                        <a href="login.jsp" class="brand-link">
                            <i class="bi bi-scale brand-icon" aria-hidden="true"></i>
                            <h1 class="h3 mt-2 fw-bold">法小智</h1>
                        </a>
                        <p class="mb-0 opacity-75">青年就业权益智能法律审查平台</p>
                    </div>

                    <div class="form-section">
                        <ul class="nav nav-pills justify-content-center mb-4">
                            <li class="nav-item">
                                <a class="nav-link" :class="{ active: tab === 'login' }"
                                   href="#" @click.prevent="tab='login'" role="button">登录</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" :class="{ active: tab === 'register' }"
                                   href="#" @click.prevent="tab='register'" role="button">注册</a>
                            </li>
                        </ul>

                        <form v-if="tab==='login'" @submit.prevent="handleLogin">
                            <div class="mb-3">
                                <label for="loginUser" class="form-label">用户名</label>
                                <input id="loginUser" v-model="loginForm.username"
                                       type="text" class="form-control form-control-lg"
                                       placeholder="请输入用户名" autocomplete="username" required>
                            </div>
                            <div class="mb-4">
                                <label for="loginPass" class="form-label">密码</label>
                                <input id="loginPass" v-model="loginForm.password"
                                       type="password" class="form-control form-control-lg"
                                       placeholder="请输入密码" autocomplete="current-password" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100 btn-lg"
                                    :disabled="loading">
                                    <span v-if="loading" class="spinner-container">
                                        <span class="spinner-border spinner-border-sm" role="status"></span>
                                        登录中...
                                    </span>
                                <span v-else><i class="bi bi-box-arrow-in-right" aria-hidden="true"></i> 登录</span>
                            </button>
                        </form>

                        <form v-if="tab==='register'" @submit.prevent="handleRegister">
                            <div class="mb-3">
                                <label for="regUser" class="form-label">用户名</label>
                                <input id="regUser" v-model="regForm.username"
                                       type="text" class="form-control form-control-lg"
                                       placeholder="请设置用户名" autocomplete="username" required>
                            </div>
                            <div class="mb-4">
                                <label for="regPass" class="form-label">密码</label>
                                <input id="regPass" v-model="regForm.password"
                                       type="password" class="form-control form-control-lg"
                                       placeholder="请设置密码" autocomplete="new-password" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100 btn-lg"
                                    :disabled="loading">
                                    <span v-if="loading" class="spinner-container">
                                        <span class="spinner-border spinner-border-sm" role="status"></span>
                                        注册中...
                                    </span>
                                <span v-else><i class="bi bi-person-plus" aria-hidden="true"></i> 注册</span>
                            </button>
                        </form>

                        <div v-if="message.text"
                             class="alert mt-3 mb-0"
                             :class="message.isError ? 'alert-danger' : 'alert-success'"
                             role="alert">
                            <i class="bi" :class="message.isError ? 'bi-exclamation-triangle' : 'bi-check-circle'" aria-hidden="true"></i>
                            {{ message.text }}
                        </div>
                    </div>
                </div>
            </div> <p class="text-center text-white-50 mt-3 small">
            © 2026 法小智 · 仅供学习参考
        </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios@1.5.0/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.149.0/build/three.min.js"></script>

<script src="assets/js/constants.js"></script>
<script src="assets/js/background-login.js"></script>
<script src="assets/js/app-login.js"></script>

<!-- 滚动入场动效 -->
<script>
(function(){
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    var ro = new IntersectionObserver(function(entries) {
        entries.forEach(function(e) {
            if (e.isIntersecting) { e.target.classList.add('revealed'); ro.unobserve(e.target); }
        });
    }, { rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.reveal').forEach(function(el) { ro.observe(el); });
})();
</script>
</body>
</html>