// ── 审查页 Vue App 入口 ──
// 组合 review 和 chat 两个功能模块

const { createApp, ref, onMounted, onUnmounted } = Vue;

let cleanupBackground = () => {};

createApp({
    setup() {
        const currentUser = ref('');
        const error = ref('');

        onMounted(() => {
            const user = localStorage.getItem('faxiaozhi_user');
            if (!user) {
                window.location.href = 'login.jsp';
                return;
            }
            currentUser.value = user;
            cleanupBackground = initThreeBackground();
        });

        onUnmounted(() => {
            cleanupBackground();
        });

        const logout = () => {
            localStorage.removeItem('faxiaozhi_user');
            window.location.href = 'login.jsp';
        };

        // 共享状态（error 供 review 和 chat 共同写入）
        const shared = { error, currentUser };
        const review = useReview(shared);
        const chat = useChat(shared);

        return {
            currentUser, logout, error,
            renderMarkdown, formatTime,
            ...review,
            ...chat,
        };
    }
}).mount('#app');
