// ── 聊天模块（单纯聊聊）──

function useChat(shared) {
    const activeModule = Vue.ref('review');
    const chatConversations = Vue.ref([]);
    const currentConversationId = Vue.ref(null);
    const chatMessages = Vue.ref([]);
    const chatInput = Vue.ref('');
    const isChatLoading = Vue.ref(false);
    const chatStreamText = Vue.ref('');
    const messagesRef = Vue.ref(null);
    const showChatSidebar = Vue.ref(window.innerWidth >= 992);

    const switchModule = (module) => {
        activeModule.value = module;
        if (module === 'chat') loadConversations();
    };

    const scrollToBottom = () => {
        Vue.nextTick(() => {
            if (messagesRef.value) {
                messagesRef.value.scrollTop = messagesRef.value.scrollHeight;
            }
        });
    };

    /* ── 加载对话列表 ── */
    const loadConversations = async () => {
        try {
            const res = await axios.post(`${API_CHAT_BASE}/conversations`, {
                username: shared.currentUser.value,
            }, { timeout: 10000 });
            if (res.data.status === 'success') {
                chatConversations.value = res.data.conversations || [];
            }
        } catch (err) {
            console.error('加载对话列表失败', err);
        }
    };

    /* ── 切换对话 ── */
    const switchConversation = async (convId) => {
        if (isChatLoading.value) return;

        currentConversationId.value = convId;
        chatMessages.value = [];
        chatStreamText.value = '';

        try {
            const res = await axios.post(
                `${API_CHAT_BASE}/conversations/${convId}/messages`,
                { username: shared.currentUser.value },
                { timeout: 10000 }
            );
            if (res.data.status === 'success') {
                chatMessages.value = res.data.messages || [];
            }
        } catch (err) {
            console.error('加载消息失败', err);
        }
    };

    /* ── 创建新对话 ── */
    const createNewConversation = async () => {
        if (isChatLoading.value) return;

        try {
            const res = await axios.post(`${API_CHAT_BASE}/conversations/create`, {
                username: shared.currentUser.value,
                title: '新对话',
            }, { timeout: 10000 });
            if (res.data.status === 'success') {
                await loadConversations();
                currentConversationId.value = res.data.conversation.id;
                chatMessages.value = [];
                chatStreamText.value = '';
            }
        } catch (err) {
            console.error('创建对话失败', err);
        }
    };

    /* ── 删除对话 ── */
    const deleteConversation = async (convId) => {
        if (isChatLoading.value) return;
        if (!confirm('确定删除此对话？此操作不可撤销。')) return;

        try {
            await axios.delete(`${API_CHAT_BASE}/conversations/${convId}`, {
                data: { username: shared.currentUser.value },
                headers: { 'Content-Type': 'application/json' },
                timeout: 10000,
            });
            if (currentConversationId.value === convId) {
                currentConversationId.value = null;
                chatMessages.value = [];
            }
            await loadConversations();
        } catch (err) {
            console.error('删除对话失败', err);
        }
    };

    /* ── 发送消息（SSE 流式） ── */
    const sendChatMessage = async () => {
        const text = chatInput.value.trim();
        if (!text || isChatLoading.value) return;

        let convId = currentConversationId.value;
        if (!convId) {
            try {
                const res = await axios.post(`${API_CHAT_BASE}/conversations/create`, {
                    username: shared.currentUser.value,
                    title: text.slice(0, 30),
                }, { timeout: 10000 });
                if (res.data.status === 'success') {
                    convId = res.data.conversation.id;
                    currentConversationId.value = convId;
                    await loadConversations();
                }
            } catch (err) {
                console.error('创建对话失败', err);
                return;
            }
        }

        chatMessages.value.push({
            id: Date.now(),
            role: 'user',
            content: text,
        });
        chatInput.value = '';
        isChatLoading.value = true;
        chatStreamText.value = '';
        scrollToBottom();

        try {
            const response = await fetch(`${API_CHAT_BASE}/stream`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    username: shared.currentUser.value,
                    conversation_id: convId,
                    message: text,
                }),
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const reader = response.body.getReader();
            const decoder = new TextDecoder();
            let buffer = '';

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;

                buffer += decoder.decode(value, { stream: true });
                const lines = buffer.split('\n');
                buffer = lines.pop() || '';

                for (const line of lines) {
                    if (line.startsWith('data: ')) {
                        try {
                            const data = JSON.parse(line.slice(6));
                            if (data.type === 'token') {
                                chatStreamText.value += data.content;
                            } else if (data.type === 'done') {
                                chatMessages.value.push({
                                    id: Date.now() + 1,
                                    role: 'assistant',
                                    content: chatStreamText.value,
                                });
                                chatStreamText.value = '';
                                await loadConversations();
                            } else if (data.type === 'error') {
                                shared.error.value = data.content;
                            }
                        } catch (e) {
                            console.error('SSE 解析错误', e);
                        }
                    }
                }
                scrollToBottom();
            }
        } catch (err) {
            if (err.name === 'AbortError') {
                // 用户切换或取消
            } else {
                shared.error.value = '连接失败: ' + (err.message || '未知错误');
            }
        } finally {
            isChatLoading.value = false;
        }
    };

    return {
        activeModule, switchModule,
        showChatSidebar,
        chatConversations, currentConversationId, chatMessages,
        chatInput, isChatLoading, chatStreamText, messagesRef,
        loadConversations, switchConversation,
        createNewConversation, deleteConversation,
        sendChatMessage,
    };
}
