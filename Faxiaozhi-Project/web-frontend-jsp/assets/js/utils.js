// ── 共用工具函数 ──

/** 将 Markdown 渲染为 HTML */
function renderMarkdown(text) {
    if (!text) return '';
    marked.setOptions({ breaks: true, gfm: true });
    return marked.parse(text);
}

/** 格式化 ISO 时间戳 → "HH:mm" 或 "M/D HH:mm" */
function formatTime(isoStr) {
    if (!isoStr) return '';
    const d = new Date(isoStr);
    const now = new Date();
    const isToday = d.toDateString() === now.toDateString();
    const pad = (n) => String(n).padStart(2, '0');
    const time = pad(d.getHours()) + ':' + pad(d.getMinutes());
    if (isToday) return time;
    return pad(d.getMonth() + 1) + '/' + pad(d.getDate()) + ' ' + time;
}
