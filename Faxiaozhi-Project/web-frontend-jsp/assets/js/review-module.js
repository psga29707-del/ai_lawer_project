// ── 合同审查/修改模块 ──
// 注意：不要在此文件顶层解构 Vue.ref/Vue.computed，否则与 app-inspect.js 冲突

function useReview(shared) {
    const contractText = Vue.ref('');
    const reviewResult = Vue.ref('');
    const modifyResult = Vue.ref('');
    const reviewLoading = Vue.ref(false);
    const modifyLoading = Vue.ref(false);
    const activeTab = Vue.ref('review');

    const renderedReview = Vue.computed(() => {
        if (!reviewResult.value) return '';
        return renderMarkdown(reviewResult.value);
    });
    const renderedModify = Vue.computed(() => {
        if (!modifyResult.value) return '';
        return renderMarkdown(modifyResult.value);
    });

    const submitReview = async () => {
        if (!contractText.value.trim()) {
            shared.error.value = '请先输入合同条款内容';
            return;
        }
        activeTab.value = 'review';
        reviewLoading.value = true;
        shared.error.value = '';
        reviewResult.value = '';
        try {
            const res = await axios.post(API_REVIEW, {
                text: contractText.value
            }, {
                headers: { 'Content-Type': 'application/json' },
                timeout: 120000
            });
            if (res.data.status === 'success') {
                reviewResult.value = res.data.report;
            } else {
                shared.error.value = res.data.message || '审查失败，请重试';
            }
        } catch (err) {
            if (err.code === 'ECONNABORTED') {
                shared.error.value = '请求超时，请稍后重试';
            } else if (err.response) {
                shared.error.value = '服务器错误: ' + err.response.status;
            } else if (err.request) {
                shared.error.value = '无法连接到后端服务(端口8001)';
            } else {
                shared.error.value = '请求失败: ' + err.message;
            }
        } finally {
            reviewLoading.value = false;
        }
    };

    const submitModify = async () => {
        if (!contractText.value.trim()) {
            shared.error.value = '请先输入合同条款内容';
            return;
        }
        activeTab.value = 'modify';
        modifyLoading.value = true;
        shared.error.value = '';
        modifyResult.value = '';
        try {
            const res = await axios.post(API_MODIFY, {
                text: contractText.value
            }, {
                headers: { 'Content-Type': 'application/json' },
                timeout: 120000
            });
            if (res.data.status === 'success') {
                modifyResult.value = res.data.modified_text;
            } else {
                shared.error.value = res.data.message || '修改失败，请重试';
            }
        } catch (err) {
            if (err.code === 'ECONNABORTED') {
                shared.error.value = '请求超时，AI 分析耗时较长，请稍后重试';
            } else if (err.response) {
                shared.error.value = '服务器错误: ' + err.response.status;
            } else if (err.request) {
                shared.error.value = '无法连接到后端服务(端口8001)';
            } else {
                shared.error.value = '请求失败: ' + err.message;
            }
        } finally {
            modifyLoading.value = false;
        }
    };

    return {
        contractText, reviewResult, modifyResult,
        reviewLoading, modifyLoading, activeTab,
        renderedReview, renderedModify,
        submitReview, submitModify,
    };
}
