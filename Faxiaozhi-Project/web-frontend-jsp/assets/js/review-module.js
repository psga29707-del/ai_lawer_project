// ── 合同审查/修改模块 ──
// 注意：不要在此文件顶层解构 Vue.ref/Vue.computed，否则与 app-inspect.js 冲突

function useReview(shared) {
    const contractText = Vue.ref('');
    const reviewResult = Vue.ref('');
    const modifyResult = Vue.ref('');
    const reviewLoading = Vue.ref(false);
    const modifyLoading = Vue.ref(false);
    const activeTab = Vue.ref('review');
    // 文件上传状态
    const uploadedFile = Vue.ref(null);
    const isUploading = Vue.ref(false);
    const fileInputRef = Vue.ref(null);

    /** 触发隐藏的文件选择器 */
    const triggerFilePicker = () => {
        if (!isUploading.value && fileInputRef.value) {
            fileInputRef.value.click();
        }
    };

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

    // ── 文件上传与文本提取 ──

    /** 格式化文件大小 */
    const formatFileSize = (bytes) => {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
    };

    /** 校验文件类型与大小 */
    const validateFile = (file) => {
        const ext = file.name.split('.').pop().toLowerCase();
        if (!['pdf', 'doc', 'docx'].includes(ext)) {
            shared.error.value = '不支持的文件格式，请上传 PDF 或 Word 文档（.docx）';
            return false;
        }
        if (file.size > 10 * 1024 * 1024) {
            shared.error.value = '文件大小超过 10MB 限制，请压缩后上传';
            return false;
        }
        return true;
    };

    /** 文件选择处理（input change） */
    const handleFileSelect = (event) => {
        const file = event.target.files?.[0];
        if (!file) return;
        if (!validateFile(file)) {
            event.target.value = '';
            return;
        }
        uploadedFile.value = file;
        shared.error.value = '';
        uploadAndExtract();
    };

    /** 拖拽释放处理 */
    const handleFileDrop = (event) => {
        event.preventDefault();
        const file = event.dataTransfer?.files?.[0];
        if (!file) return;
        if (!validateFile(file)) return;
        uploadedFile.value = file;
        shared.error.value = '';
        uploadAndExtract();
    };

    /** 上传文件并提取文本 */
    const uploadAndExtract = async () => {
        if (!uploadedFile.value) return;
        isUploading.value = true;
        shared.error.value = '';
        try {
            const formData = new FormData();
            formData.append('file', uploadedFile.value);
            const res = await axios.post(API_EXTRACT, formData, {
                timeout: 30000,
            });
            if (res.data.status === 'success' && res.data.text) {
                contractText.value = res.data.text;
                // 提取成功后清除文件状态
                uploadedFile.value = null;
            } else {
                shared.error.value = res.data.message || '文件解析失败，请重试';
            }
        } catch (err) {
            if (err.code === 'ECONNABORTED') {
                shared.error.value = '文件解析超时，请尝试更小的文件';
            } else if (err.response) {
                shared.error.value = err.response.data?.detail || '服务器错误: ' + err.response.status;
            } else if (err.request) {
                shared.error.value = '无法连接到后端服务(端口8001)';
            } else {
                shared.error.value = '上传失败: ' + err.message;
            }
        } finally {
            isUploading.value = false;
        }
    };

    /** 清除已选文件 */
    const removeFile = () => {
        uploadedFile.value = null;
    };

    return {
        contractText, reviewResult, modifyResult,
        reviewLoading, modifyLoading, activeTab,
        renderedReview, renderedModify,
        submitReview, submitModify,
        // 文件上传
        uploadedFile, isUploading, fileInputRef,
        handleFileSelect, handleFileDrop,
        uploadAndExtract, removeFile, formatFileSize,
        triggerFilePicker,
    };
}
