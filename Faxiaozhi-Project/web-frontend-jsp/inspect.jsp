<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>法小智 - 劳动合同智能审查控制台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/inspect.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Barlow:wght@300;400;500;600&display=swap" rel="stylesheet">
</head>
<body>
<div id="app">
    <div id="three-bg" aria-hidden="true"></div>

    <header class="system-bar">
        <div class="shell-frame system-bar-inner">
            <div class="system-brand">
                <div class="brand-mark">
                    <i class="bi bi-scale" aria-hidden="true"></i>
                    <span class="brand-title">法小智</span>
                </div>
                <span class="brand-divider" aria-hidden="true"></span>
                <span class="brand-caption">青年就业权益智能审查控制台</span>
            </div>

            <div class="system-meta">
                <span class="status-chip">
                    <span class="status-dot" aria-hidden="true"></span>
                    System Ready
                </span>
                <span class="user-chip" v-if="currentUser">
                    <i class="bi bi-person-badge" aria-hidden="true"></i>
                    {{ currentUser }}
                </span>
                <button class="console-ghost-btn" @click="logout">
                    <i class="bi bi-box-arrow-right" aria-hidden="true"></i>
                    退出
                </button>
            </div>
        </div>
    </header>

    <!-- 模块导航栏 -->
    <nav class="module-nav">
        <div class="shell-frame module-nav-inner">
            <div class="nav nav-tabs" role="tablist">
                <button class="nav-link" :class="{ active: activeModule === 'review' }"
                        @click="switchModule('review')" role="tab">
                    <i class="bi bi-file-earmark-code" aria-hidden="true"></i>
                    代码审查
                </button>
                <button class="nav-link" :class="{ active: activeModule === 'chat' }"
                        @click="switchModule('chat')" role="tab">
                    <i class="bi bi-chat-dots" aria-hidden="true"></i>
                    单纯聊聊
                </button>
            </div>
        </div>
    </nav>

    <main class="workspace" :class="{ 'workspace-chat': activeModule === 'chat' }">
        <div class="shell-frame">
            <section v-if="activeModule === 'review'" class="workspace-hero">
                <div class="workspace-hero-content">
                    <div>
                        <div class="hero-kicker">Contract Review Console</div>
                        <h1 class="hero-title">劳动合同审查与智能修订工作台</h1>
                        <p class="hero-copy">
                            将合同条款、offer 说明或补充协议粘贴到工作区，系统会基于法律知识库输出风险审查报告，或生成更合规的修改建议。
                        </p>
                    </div>

                    <div class="hero-telemetry" aria-hidden="true">
                        <div class="telemetry-card">
                            <span class="telemetry-label">Mode</span>
                            <span class="telemetry-value">Review / Modify</span>
                        </div>
                        <div class="telemetry-card">
                            <span class="telemetry-label">Engine</span>
                            <span class="telemetry-value">AI + Law KB</span>
                        </div>
                    </div>
                </div>
            </section>

            <section v-if="activeModule === 'review'" class="workspace-grid">
                <div class="console-panel">
                    <div class="panel-header">
                        <div>
                            <div class="panel-kicker">Input Zone</div>
                            <h2 class="panel-title">合同文本输入</h2>
                            <p class="panel-description">
                                输入需要审查的劳动合同、试用协议、竞业限制条款或离职约定，保持原文越完整，分析结果越准确。
                            </p>
                        </div>
                        <div class="panel-badge">
                            <i class="bi bi-file-earmark-lock2" aria-hidden="true"></i>
                            Secure Session
                        </div>
                    </div>

                    <!-- 文件上传拖拽区 -->
                    <div class="file-upload-zone"
                         @click="triggerFilePicker"
                         @dragover.prevent
                         @drop.prevent="handleFileDrop"
                         :class="{ 'upload-active': isUploading }">
                        <input type="file" ref="fileInputRef"
                               accept=".pdf,.doc,.docx"
                               @change="handleFileSelect"
                               style="display:none">

                        <!-- 正在上传 -->
                        <div v-if="isUploading" class="upload-state">
                            <span class="spinner-border spinner-border-sm me-2" role="status"></span>
                            <span>正在解析文件...</span>
                        </div>

                        <!-- 文件已选中 -->
                        <div v-else-if="uploadedFile" class="upload-file-info">
                            <i class="bi bi-file-earmark-text" aria-hidden="true"></i>
                            <span class="file-name">{{ uploadedFile.name }}</span>
                            <span class="file-size">{{ formatFileSize(uploadedFile.size) }}</span>
                            <button class="file-remove-btn ms-2" @click.stop="removeFile" title="移除文件">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>

                        <!-- 空状态 -->
                        <div v-else class="upload-placeholder">
                            <i class="bi bi-cloud-upload" aria-hidden="true"></i>
                            <span>拖拽 PDF/Word 文件到此处，或点击选择</span>
                            <span class="upload-hint">支持 .pdf .docx，最大 10MB</span>
                        </div>
                    </div>

                    <textarea
                        v-model="contractText"
                        class="form-control contract-textarea"
                        rows="12"
                        placeholder="请粘贴需要分析的合同内容。

示例：
1. 试用期三个月，试用期工资为转正工资的 60%
2. 员工离职需提前三个月通知，否则支付违约金
3. 竞业限制期限两年，未约定经济补偿"
                        :disabled="reviewLoading || modifyLoading"
                    ></textarea>

                    <div class="input-meta-row">
                        <span>Paste original clauses</span>
                        <span class="meta-separator" aria-hidden="true"></span>
                        <span>JSON API preserved</span>
                    </div>

                    <div class="action-grid">
                        <button
                            class="console-btn console-btn-primary"
                            @click="submitReview"
                            :disabled="reviewLoading || !contractText.trim()"
                        >
                            <span v-if="reviewLoading" class="spinner-container">
                                <span class="spinner-border spinner-border-sm" role="status"></span>
                                正在审查
                            </span>
                            <span v-else>
                                <i class="bi bi-search" aria-hidden="true"></i>
                                一键审查
                            </span>
                        </button>

                        <button
                            class="console-btn console-btn-success"
                            @click="submitModify"
                            :disabled="modifyLoading || !contractText.trim()"
                        >
                            <span v-if="modifyLoading" class="spinner-container">
                                <span class="spinner-border spinner-border-sm" role="status"></span>
                                正在修订
                            </span>
                            <span v-else>
                                <i class="bi bi-wrench-adjustable" aria-hidden="true"></i>
                                智能修改
                            </span>
                        </button>
                    </div>

                    <div v-if="error" class="alert alert-console mb-0" role="alert">
                        <i class="bi bi-exclamation-triangle me-2" aria-hidden="true"></i>
                        {{ error }}
                    </div>
                </div>

                <div class="console-panel">
                    <div class="panel-toolbar">
                        <div>
                            <div class="panel-kicker">Result Viewer</div>
                            <h2 class="panel-title">审查输出面板</h2>
                            <p class="panel-description">
                                查看审查报告或合规修订结果，报告按 Markdown 渲染，适合直接阅读与比对。
                            </p>
                        </div>

                        <ul class="nav nav-pills mode-switch">
                            <li class="nav-item">
                                <a class="nav-link" :class="{ active: activeTab === 'review' }"
                                   href="#" @click.prevent="activeTab='review'">
                                    <i class="bi bi-clipboard-data" aria-hidden="true"></i>
                                    审查报告
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" :class="{ active: activeTab === 'modify' }"
                                   href="#" @click.prevent="activeTab='modify'">
                                    <i class="bi bi-pencil-square" aria-hidden="true"></i>
                                    修改结果
                                </a>
                            </li>
                        </ul>
                    </div>

                    <div class="result-shell">
                        <div v-if="activeTab==='review'">
                            <div v-if="!reviewResult && !reviewLoading" class="report-container report-state">
                                <div>
                                    <div class="report-state-icon">
                                        <i class="bi bi-file-earmark-bar-graph" aria-hidden="true"></i>
                                    </div>
                                    <h3 class="report-state-title">等待生成审查报告</h3>
                                    <p class="report-state-copy">
                                        输入合同文本后点击“一键审查”，系统将从法律知识库检索依据并生成结构化风险分析。
                                    </p>
                                </div>
                            </div>
                            <div v-else-if="reviewLoading" class="report-container report-state">
                                <div>
                                    <div class="analysis-loader" aria-hidden="true"></div>
                                    <h3 class="report-state-title">正在执行合同风险审查</h3>
                                    <p class="report-state-copy">
                                        系统正在检索法律依据、分析条款风险并生成审查报告，请稍候片刻。
                                    </p>
                                </div>
                            </div>
                            <div v-else class="report-container report-content" v-html="renderedReview"></div>
                        </div>

                        <div v-if="activeTab==='modify'">
                            <div v-if="!modifyResult && !modifyLoading" class="report-container report-state">
                                <div>
                                    <div class="report-state-icon">
                                        <i class="bi bi-wrench-adjustable-circle" aria-hidden="true"></i>
                                    </div>
                                    <h3 class="report-state-title">等待生成修改建议</h3>
                                    <p class="report-state-copy">
                                        点击“智能修改”后，系统将逐条识别问题并输出更合规的修订版本，便于直接比对与参考。
                                    </p>
                                </div>
                            </div>
                            <div v-else-if="modifyLoading" class="report-container report-state">
                                <div>
                                    <div class="analysis-loader" aria-hidden="true"></div>
                                    <h3 class="report-state-title">正在生成合规修订文本</h3>
                                    <p class="report-state-copy">
                                        AI Agent 正在逐条分析合同内容，匹配法律依据并生成更稳妥的修改结果。
                                    </p>
                                </div>
                            </div>
                            <div v-else class="report-container report-content" v-html="renderedModify"></div>
                        </div>
                    </div>
                </div>
            </section>

            <section v-if="activeModule === 'review'" class="support-grid">
                <article class="support-card">
                    <div class="support-kicker">Capability 01</div>
                    <i class="bi bi-search" aria-hidden="true"></i>
                    <h5>条款风险识别</h5>
                    <p>自动识别试用期、违约金、竞业限制、工时与离职相关条款中的高风险内容。</p>
                </article>

                <article class="support-card">
                    <div class="support-kicker">Capability 02</div>
                    <i class="bi bi-journal-text" aria-hidden="true"></i>
                    <h5>法律依据匹配</h5>
                    <p>结合劳动法、劳动合同法、民法典等规则，为审查结果提供可追溯的法律支撑。</p>
                </article>

                <article class="support-card">
                    <div class="support-kicker">Capability 03</div>
                    <i class="bi bi-shield-check" aria-hidden="true"></i>
                    <h5>合规修订建议</h5>
                    <p>在保留核心业务信息的前提下，输出更公平、更稳妥、可直接参考的修订文本。</p>
                </article>
            </section>

            <footer v-if="activeModule === 'review'" class="console-footer">
                <p class="footer-copy">
                    2026 法小智 | 面向青年就业权益保护的劳动合同智能审查平台，仅供学习与参考。
                </p>
                <div class="footer-meta">Console Status: Active Session</div>
            </footer>

            <!-- ════════════════════════════════════════════════ -->
            <!-- 聊天界面（单纯聊聊）                             -->
            <!-- ════════════════════════════════════════════════ -->
            <section v-if="activeModule === 'chat'" class="chat-workspace">
                <div class="chat-layout">
                    <!-- 侧边栏：对话列表 -->
                    <aside class="chat-sidebar" :style="{ display: showChatSidebar ? '' : 'none' }">
                        <div class="sidebar-header">
                            <div class="panel-kicker">Chat History</div>
                            <button class="console-ghost-btn" @click="createNewConversation">
                                <i class="bi bi-plus-lg" aria-hidden="true"></i>
                                新对话
                            </button>
                        </div>
                        <div class="conversation-list">
                            <div v-if="chatConversations.length === 0" class="conv-empty">
                                <p>暂无对话记录</p>
                                <p class="conv-empty-hint">点击「新对话」开始聊天</p>
                            </div>
                            <div v-for="conv in chatConversations" :key="conv.id"
                                 class="conversation-item"
                                 :class="{ active: conv.id === currentConversationId }"
                                 @click="switchConversation(conv.id)">
                                <div class="conv-title">{{ conv.title }}</div>
                                <div class="conv-meta">{{ formatTime(conv.updated_at) }}</div>
                                <button class="conv-delete" @click.stop="deleteConversation(conv.id)"
                                        title="删除对话">
                                    <i class="bi bi-trash3"></i>
                                </button>
                            </div>
                        </div>
                    </aside>

                    <!-- 主区域：消息 + 输入 -->
                    <main class="chat-main">
                        <div class="chat-toolbar">
                            <button class="sidebar-toggle-btn console-ghost-btn"
                                    @click="showChatSidebar = !showChatSidebar"
                                    :title="showChatSidebar ? '隐藏对话列表' : '显示对话列表'">
                                <i class="bi" :class="showChatSidebar ? 'bi-layout-sidebar-inset' : 'bi-layout-sidebar'"></i>
                            </button>
                            <button class="console-ghost-btn" @click="createNewConversation">
                                <i class="bi bi-plus-lg" aria-hidden="true"></i>
                                新对话
                            </button>
                        </div>
                        <div class="chat-messages" ref="messagesRef">
                            <!-- 空状态 -->
                            <div v-if="chatMessages.length === 0 && !isChatLoading" class="chat-empty">
                                <div class="chat-empty-icon">
                                    <i class="bi bi-chat-dots"></i>
                                </div>
                                <h3 class="chat-empty-title">开始聊天</h3>
                                <p class="chat-empty-copy">
                                    请输入您关于劳动法、合同条款或职场权益的任何问题，法小智将为您解答。
                                </p>
                                <button class="console-btn console-btn-primary mt-3" @click="createNewConversation" style="min-height:44px;padding:0.65rem 1.5rem;">
                                    <i class="bi bi-plus-lg me-2"></i>新对话
                                </button>
                            </div>

                            <!-- 消息气泡 -->
                            <div v-for="msg in chatMessages" :key="msg.id"
                                 class="chat-bubble"
                                 :class="msg.role">
                                <div class="bubble-avatar" :class="msg.role">
                                    <i :class="msg.role === 'user' ? 'bi bi-person' : 'bi bi-robot'"></i>
                                </div>
                                <div class="bubble-content" v-html="renderMarkdown(msg.content)"></div>
                            </div>

                            <!-- 流式响应占位 -->
                            <div v-if="isChatLoading && chatStreamText" class="chat-bubble assistant">
                                <div class="bubble-avatar assistant">
                                    <i class="bi bi-robot"></i>
                                </div>
                                <div class="bubble-content streaming" v-html="renderMarkdown(chatStreamText)"></div>
                            </div>

                            <!-- 加载动画 -->
                            <div v-if="isChatLoading && !chatStreamText" class="chat-bubble assistant">
                                <div class="bubble-avatar assistant">
                                    <i class="bi bi-robot"></i>
                                </div>
                                <div class="bubble-content">
                                    <span class="thinking-dots">
                                        <span></span><span></span><span></span>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- 输入区域 -->
                        <div class="chat-input-area">
                            <textarea v-model="chatInput"
                                      placeholder="请输入您的问题..."
                                      @keydown.enter.exact.prevent="sendChatMessage"
                                      :disabled="isChatLoading"
                                      rows="2"
                                      class="form-control chat-input"></textarea>
                            <button class="console-btn console-btn-primary send-btn"
                                    @click="sendChatMessage"
                                    :disabled="isChatLoading || !chatInput.trim()">
                                <span v-if="isChatLoading">
                                    <span class="spinner-border spinner-border-sm me-1" role="status"></span>
                                    发送中...
                                </span>
                                <span v-else>
                                    <i class="bi bi-send me-1"></i>
                                    发送
                                </span>
                            </button>
                        </div>
                    </main>
                </div>
            </section>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios@1.5.0/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/marked@9.0.0/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.149.0/build/three.min.js"></script>

<script src="assets/js/constants.js"></script>
<script src="assets/js/utils.js"></script>
<script src="assets/js/background-inspect.js"></script>
<script src="assets/js/review-module.js"></script>
<script src="assets/js/chat-module.js"></script>
<script src="assets/js/app-inspect.js"></script>

<!-- 滚动入场 + 微动效 -->
<script>
(function(){
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    // 滚动入场
    var ro = new IntersectionObserver(function(entries) {
        entries.forEach(function(e) {
            if (e.isIntersecting) { e.target.classList.add('revealed'); ro.unobserve(e.target); }
        });
    }, { rootMargin: '0px 0px -60px 0px' });
    document.querySelectorAll('.reveal').forEach(function(el) { ro.observe(el); });
})();
</script>
</body>
</html>
