<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>法小智 - 登录</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            /* 基础暗色毛玻璃色调 */
            --dark-glass: rgba(10, 10, 15, 0.65);
            --border-glass: rgba(255, 255, 255, 0.12);
        }
        body {
            background-color: #000;
            min-height: 100vh;
            display: flex;
            align-items: center;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            margin: 0;
            overflow: hidden;
        }
        /* Shader 背景容器 */
        #shader-bg {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: -1;
        }
        #app {
            position: relative;
            z-index: 1;
        }

        /* 悬浮控制容器，为顶部 Logo 预留空间 */
        .login-container-wrapper {
            position: relative;
            padding-top: 60px;
        }

        /* 新增：个人个人专属 Logo "gassp" 艺术字样式 */
        .personal-logo {
            position: absolute;
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            font-size: 2.8rem;
            font-weight: 900;
            letter-spacing: 0.4em;
            text-transform: uppercase;
            /* 银灰色至微透流体渐变色，模拟高级金属质感 */
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.85) 0%, rgba(255, 255, 255, 0.15) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            /* 微弱发光阴影，使其在动态 Shader 背景上清晰可见 */
            filter: drop-shadow(0 4px 15px rgba(255, 255, 255, 0.15));
            pointer-events: none;
            margin-bottom: 1.5rem;
            text-align: center;
            width: 100%;
        }

        /* 黑色透明毛玻璃卡片 */
        .login-card {
            background: var(--dark-glass);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid var(--border-glass);
            border-radius: 20px;
            box-shadow: 0 30px 70px rgba(0, 0, 0, 0.7);
            overflow: hidden;
        }

        .brand-section {
            background: rgba(255, 255, 255, 0.02);
            border-bottom: 1px solid var(--border-glass);
            color: white;
            padding: 2.5rem 2rem;
            text-align: center;
        }
        .brand-icon {
            font-size: 2.5rem;
            filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.3));
        }
        .form-section {
            padding: 2.5rem;
        }

        .form-label {
            color: rgba(255, 255, 255, 0.8);
            font-weight: 500;
            font-size: 0.95rem;
        }

        /* 输入框暗色半透明 */
        .form-control {
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.15);
            color: #ffffff !important;
            border-radius: 12px;
            transition: all 0.2s ease;
        }
        .form-control:focus {
            background: rgba(255, 255, 255, 0.12);
            border-color: rgba(255, 255, 255, 0.4);
            box-shadow: 0 0 0 0.25rem rgba(255, 255, 255, 0.15);
            color: #ffffff;
        }
        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        /* 优化：切换按键变更为精细的灰色半透明状态 */
        .nav-pills .nav-link {
            color: rgba(255, 255, 255, 0.5);
            font-weight: 600;
            border-radius: 50px;
            padding: 0.5rem 2rem;
            transition: all 0.2s;
            border: 1px solid transparent;
        }
        .nav-pills .nav-link:hover {
            color: #ffffff;
            background: rgba(255, 255, 255, 0.05);
        }
        .nav-pills .nav-link.active {
            background: rgba(255, 255, 255, 0.12);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        /* 优化：主行动按钮变更为极简高级灰色半透明玻璃按键 */
        .btn-primary {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.18);
            color: #ffffff;
            border-radius: 50px;
            padding: 12px;
            font-weight: 600;
            transition: all 0.2s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
        }
        .btn-primary:hover {
            background: rgba(255, 255, 255, 0.18);
            border-color: rgba(255, 255, 255, 0.35);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(255, 255, 255, 0.15);
            color: #ffffff;
        }
        .btn-primary:active {
            transform: translateY(0);
        }
        .btn-primary:disabled {
            background: rgba(255, 255, 255, 0.03);
            border-color: rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.25);
        }

        .brand-link {
            color: white;
            text-decoration: none;
        }
        .brand-link:hover {
            color: rgba(255,255,255,0.8);
        }
        .spinner-container {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        /* 提示框适配 */
        .alert {
            border-radius: 12px;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(5px);
        }
        .alert-danger {
            color: #ff6b6b;
            border: 1px solid rgba(239, 68, 68, 0.25);
        }
        .alert-success {
            color: #51cf66;
            border: 1px solid rgba(34, 197, 94, 0.25);
        }
    </style>
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

<script>
    const { createApp, ref, reactive, onMounted, onUnmounted } = Vue;
    const API_BASE = 'http://127.0.0.1:8001/api/v1';

    createApp({
        setup() {
            const tab = ref('login');
            const loading = ref(false);
            const message = reactive({ text: '', isError: false });
            const loginForm = reactive({ username: '', password: '' });
            const regForm = reactive({ username: '', password: '' });

            // =============== WebGL Shader 动态背景核心逻辑 ===============
            let animationId;
            let renderer, scene, camera, material, geometry;

            const initShader = () => {
                const container = document.getElementById('shader-bg');
                if (!container) return;

                const vertexShader = `
                        void main() {
                            gl_Position = vec4( position, 1.0 );
                        }
                    `;

                const fragmentShader = `
                        #define TWO_PI 6.2831853072
                        #define PI 3.14159265359

                        precision highp float;
                        uniform vec2 resolution;
                        uniform float time;

                        void main(void) {
                            vec2 uv = (gl_FragCoord.xy * 2.0 - resolution.xy) / min(resolution.x, resolution.y);
                            float t = time*0.05;
                            float lineWidth = 0.002;

                            vec3 color = vec3(0.0);
                            for(int j = 0; j < 3; j++){
                                for(int i=0; i < 5; i++){
                                    color[j] += lineWidth*float(i*i) / abs(fract(t - 0.01*float(j)+float(i)*0.01)*5.0 - length(uv) + mod(uv.x+uv.y, 0.2));
                                }
                            }

                            gl_FragColor = vec4(color[0],color[1],color[2],1.0);
                        }
                    `;

                camera = new THREE.Camera();
                camera.position.z = 1;

                scene = new THREE.Scene();
                geometry = new THREE.PlaneGeometry(2, 2);

                const uniforms = {
                    time: { type: "f", value: 1.0 },
                    resolution: { type: "v2", value: new THREE.Vector2() },
                };

                material = new THREE.ShaderMaterial({
                    uniforms: uniforms,
                    vertexShader: vertexShader,
                    fragmentShader: fragmentShader,
                });

                const mesh = new THREE.Mesh(geometry, material);
                scene.add(mesh);

                renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
                renderer.setPixelRatio(window.devicePixelRatio);
                container.appendChild(renderer.domElement);

                const onWindowResize = () => {
                    const width = container.clientWidth;
                    const height = container.clientHeight;
                    renderer.setSize(width, height);
                    uniforms.resolution.value.x = renderer.domElement.width;
                    uniforms.resolution.value.y = renderer.domElement.height;
                };

                onWindowResize();
                window.addEventListener("resize", onWindowResize, false);

                const animate = () => {
                    animationId = requestAnimationFrame(animate);
                    uniforms.time.value += 0.05;
                    renderer.render(scene, camera);
                };

                animate();

                return () => {
                    window.removeEventListener("resize", onWindowResize);
                    cancelAnimationFrame(animationId);
                    if (container && renderer.domElement) {
                        container.removeChild(renderer.domElement);
                    }
                    renderer.dispose();
                    geometry.dispose();
                    material.dispose();
                };
            };

            let cleanupShader;

            onMounted(() => {
                cleanupShader = initShader();
            });

            onUnmounted(() => {
                if (cleanupShader) cleanupShader();
            });
            // =============================================================

            const showMsg = (text, isError = false) => {
                message.text = text;
                message.isError = isError;
            };

            const handleLogin = async () => {
                loading.value = true;
                showMsg('');
                try {
                    const res = await axios.post(`${API_BASE}/login`, {
                        username: loginForm.username.trim(),
                        password: loginForm.password
                    }, { timeout: 10000 });

                    if (res.data.status === 'success') {
                        localStorage.setItem('faxiaozhi_user', loginForm.username.trim());
                        window.location.href = 'inspect.jsp';
                    }
                } catch (err) {
                    const detail = err.response?.data?.detail || '登录失败';
                    showMsg(detail, true);
                } finally {
                    loading.value = false;
                }
            };

            const handleRegister = async () => {
                loading.value = true;
                showMsg('');
                try {
                    const res = await axios.post(`${API_BASE}/register`, {
                        username: regForm.username.trim(),
                        password: regForm.password
                    }, { timeout: 10000 });

                    if (res.data.status === 'success') {
                        showMsg('注册成功！请登录。');
                        loginForm.username = regForm.username.trim();
                        regForm.username = '';
                        regForm.password = '';
                        tab.value = 'login';
                    }
                } catch (err) {
                    const detail = err.response?.data?.detail || '注册失败';
                    showMsg(detail, true);
                } finally {
                    loading.value = false;
                }
            };

            return { tab, loading, message, loginForm, regForm, handleLogin, handleRegister };
        }
    }).mount('#app');
</script>
</body>
</html>