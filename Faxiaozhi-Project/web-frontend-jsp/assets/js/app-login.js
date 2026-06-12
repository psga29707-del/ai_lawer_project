// ── 登录页 Vue App ──

const { createApp, ref, reactive, onMounted, onUnmounted } = Vue;

let cleanupShader;

createApp({
    setup() {
        const tab = ref('login');
        const loading = ref(false);
        const message = reactive({ text: '', isError: false });
        const loginForm = reactive({ username: '', password: '' });
        const regForm = reactive({ username: '', password: '' });

        onMounted(() => {
            cleanupShader = initShader();
        });

        onUnmounted(() => {
            if (cleanupShader) cleanupShader();
        });

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
