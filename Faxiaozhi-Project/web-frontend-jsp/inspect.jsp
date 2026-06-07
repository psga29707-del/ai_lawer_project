<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>法小智 - 劳动合同智能审查控制台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #05080c;
            --bg-1: #0b0f14;
            --bg-2: #11161d;
            --bg-3: #161b22;
            --panel-border: rgba(163, 186, 210, 0.18);
            --panel-border-strong: rgba(122, 199, 255, 0.34);
            --panel-shadow: 0 24px 70px rgba(0, 0, 0, 0.42);
            --text-main: #f3f7fb;
            --text-subtle: rgba(243, 247, 251, 0.72);
            --text-muted: rgba(243, 247, 251, 0.46);
            --accent: #74d0ff;
            --accent-strong: #8bd8ff;
            --success: #73e2b4;
            --danger: #ff8e70;
            --mono: "Consolas", "SFMono-Regular", "Cascadia Mono", "Liberation Mono", monospace;
            --sans: "Segoe UI", "PingFang SC", "Microsoft YaHei", system-ui, sans-serif;
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            margin: 0;
            color: var(--text-main);
            font-family: var(--sans);
            background:
                radial-gradient(circle at top left, rgba(45, 82, 132, 0.10), transparent 26%),
                radial-gradient(circle at top right, rgba(40, 72, 112, 0.06), transparent 24%),
                linear-gradient(180deg, #010203 0%, #030508 46%, #020305 100%);
            position: relative;
            overflow-x: hidden;
        }

        body::before,
        body::after {
            content: "";
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
        }

        body::before {
            background:
                linear-gradient(180deg, rgba(255, 255, 255, 0.03), transparent 18%, transparent 82%, rgba(255, 255, 255, 0.015)),
                repeating-linear-gradient(
                    180deg,
                    rgba(255, 255, 255, 0.014) 0,
                    rgba(255, 255, 255, 0.014) 1px,
                    transparent 1px,
                    transparent 5px
                );
            opacity: 0.08;
        }

        body::after {
            background:
                radial-gradient(circle at 50% 0%, rgba(255, 255, 255, 0.05), transparent 22%),
                linear-gradient(90deg, transparent 0, rgba(116, 208, 255, 0.025) 50%, transparent 100%);
            opacity: 0.16;
        }

        #three-bg {
            position: fixed;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            overflow: hidden;
        }

        #three-bg canvas {
            width: 100%;
            height: 100%;
            display: block;
        }

        .ambient-background {
            position: fixed;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            overflow: hidden;
        }

        .ambient-grid,
        .ambient-grid-secondary,
        .ambient-glow,
        .ambient-orbit,
        .ambient-axis,
        .ambient-constellation,
        .ambient-geometry,
        .ambient-noise {
            position: absolute;
            inset: 0;
        }

        .ambient-grid {
            background-image: radial-gradient(circle, rgba(255, 255, 255, 0.44) 0 1.4px, transparent 1.6px);
            background-size: 42px 42px;
            background-position: 0 0;
            opacity: 0.2;
            transform: scale(1.04);
            animation: dotDriftPrimary 34s linear infinite;
        }

        .ambient-grid-secondary {
            background-image: radial-gradient(circle, rgba(139, 216, 255, 0.32) 0 1px, transparent 1.3px);
            background-size: 84px 84px;
            background-position: 18px 12px;
            opacity: 0.12;
            animation: dotDriftSecondary 44s linear infinite;
        }

        .ambient-glow-left {
            left: -18%;
            top: 10%;
            width: 52vw;
            height: 72vh;
            background: radial-gradient(circle at 42% 34%, rgba(144, 198, 255, 0.18), rgba(67, 106, 170, 0.08) 34%, transparent 68%);
            filter: blur(18px);
            opacity: 0.72;
            animation: glowPulse 16s ease-in-out infinite;
        }

        .ambient-glow-right {
            left: auto;
            right: -16%;
            top: -6%;
            width: 42vw;
            height: 56vh;
            background: radial-gradient(circle at 50% 50%, rgba(116, 208, 255, 0.09), transparent 66%);
            filter: blur(22px);
            opacity: 0.56;
            animation: glowPulse 20s ease-in-out infinite reverse;
        }

        .ambient-orbit {
            border-radius: 50%;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background-repeat: no-repeat;
        }

        .ambient-orbit-large {
            left: -6%;
            top: 16%;
            width: 46rem;
            height: 46rem;
            opacity: 0.38;
            background:
                radial-gradient(circle at 36% 28%, rgba(255, 255, 255, 0.24) 0 8%, transparent 10%),
                radial-gradient(circle at 30% 34%, rgba(255, 255, 255, 0.92) 0 1.7px, transparent 2px);
            background-size: auto, 10px 10px;
            mask-image: radial-gradient(circle at center, rgba(0, 0, 0, 0.92) 0 70%, transparent 88%);
            box-shadow:
                inset 0 0 48px rgba(255, 255, 255, 0.04),
                0 0 90px rgba(116, 208, 255, 0.04);
            animation: orbitFloatLarge 26s ease-in-out infinite;
        }

        .ambient-orbit-large::before,
        .ambient-orbit-large::after,
        .ambient-orbit-small::before,
        .ambient-orbit-small::after {
            content: "";
            position: absolute;
            border-radius: 50%;
        }

        .ambient-orbit-large::before {
            inset: 15%;
            border: 1px solid rgba(255, 255, 255, 0.24);
            border-right-color: transparent;
            border-top-color: transparent;
            transform: rotate(18deg);
        }

        .ambient-orbit-large::after {
            left: 7%;
            right: 7%;
            top: 49%;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.28), transparent);
            transform: rotate(-1deg);
        }

        .ambient-orbit-small {
            left: 8%;
            top: 58%;
            width: 12rem;
            height: 12rem;
            opacity: 0.22;
            background:
                radial-gradient(circle at 50% 50%, transparent 0 59%, rgba(255, 255, 255, 0.12) 60%, transparent 61%);
            animation: orbitFloatSmall 19s ease-in-out infinite;
        }

        .ambient-orbit-small::before {
            inset: 12%;
            border: 1px solid rgba(255, 255, 255, 0.14);
            border-left-color: transparent;
            border-bottom-color: transparent;
            transform: rotate(-24deg);
        }

        .ambient-orbit-small::after {
            left: -24%;
            top: 50%;
            width: 148%;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(139, 216, 255, 0.26), transparent);
        }

        .ambient-axis-horizontal {
            top: 47%;
            left: 4%;
            width: 35%;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.16), transparent);
            opacity: 0.52;
            animation: axisFlicker 8s ease-in-out infinite;
        }

        .ambient-axis-vertical {
            top: 30%;
            left: 12%;
            width: 1px;
            height: 54%;
            background: linear-gradient(180deg, transparent, rgba(255, 255, 255, 0.14), transparent);
            opacity: 0.4;
            animation: axisFlicker 10s ease-in-out infinite reverse;
        }

        .ambient-constellation {
            left: 1%;
            top: 18%;
            width: 34rem;
            height: 42rem;
            inset: auto;
            opacity: 0.34;
            background:
                radial-gradient(circle at 38% 22%, rgba(255, 255, 255, 0.72) 0 1.8px, transparent 2.1px),
                radial-gradient(circle at 40% 26%, rgba(255, 255, 255, 0.48) 0 10%, transparent 12%),
                radial-gradient(circle, rgba(255, 255, 255, 0.74) 0 1.6px, transparent 1.9px);
            background-size: auto, auto, 8px 8px;
            background-position: center, center, 0 0;
            mask-image:
                radial-gradient(circle at 46% 24%, rgba(0, 0, 0, 1) 0 34%, transparent 56%),
                radial-gradient(circle at 44% 44%, rgba(0, 0, 0, 0.84) 0 28%, transparent 52%),
                linear-gradient(180deg, transparent 0, rgba(0, 0, 0, 0.94) 8%, rgba(0, 0, 0, 0.94) 82%, transparent 100%);
            mask-composite: add;
            filter: blur(0.2px);
            animation: constellationFloat 22s ease-in-out infinite;
        }

        .ambient-constellation::before,
        .ambient-constellation::after,
        .ambient-geometry::before,
        .ambient-geometry::after {
            content: "";
            position: absolute;
        }

        .ambient-constellation::before {
            left: 10%;
            top: 18%;
            width: 66%;
            height: 66%;
            border: 1px solid rgba(255, 255, 255, 0.18);
            border-radius: 50%;
            border-top-color: rgba(255, 255, 255, 0.32);
            border-right-color: transparent;
            transform: rotate(9deg);
        }

        .ambient-constellation::after {
            left: 22%;
            top: 36%;
            width: 60%;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.32), transparent);
            transform: rotate(-7deg);
        }

        .ambient-geometry {
            left: 4%;
            bottom: 13%;
            width: 28rem;
            height: 22rem;
            inset: auto;
            opacity: 0.24;
            animation: geometryFloat 24s ease-in-out infinite;
        }

        .ambient-geometry::before {
            left: 0;
            bottom: 0;
            width: 78%;
            height: 74%;
            border-left: 1px solid rgba(255, 255, 255, 0.16);
            border-bottom: 1px solid rgba(255, 255, 255, 0.16);
            box-shadow:
                inset 0 0 0 1px rgba(255, 255, 255, 0.02),
                16rem -9rem 0 -15.9rem rgba(255, 255, 255, 0.2);
        }

        .ambient-geometry::after {
            left: 12%;
            bottom: 20%;
            width: 46%;
            height: 46%;
            border: 1px solid rgba(255, 255, 255, 0.16);
            border-radius: 50%;
            border-left-color: transparent;
            border-bottom-color: transparent;
            transform: rotate(28deg);
            box-shadow:
                7.8rem 2.2rem 0 -7.6rem rgba(255, 255, 255, 0.18),
                11.8rem -5.2rem 0 -11.5rem rgba(139, 216, 255, 0.32);
        }

        .ambient-noise {
            inset: -20%;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(255, 255, 255, 0.09) 0 0.7px, transparent 0.8px),
                radial-gradient(circle at 70% 60%, rgba(255, 255, 255, 0.07) 0 0.65px, transparent 0.75px),
                radial-gradient(circle at 40% 75%, rgba(116, 208, 255, 0.08) 0 0.8px, transparent 0.9px);
            background-size: 160px 160px, 210px 210px, 260px 260px;
            opacity: 0.08;
            animation: noiseShift 24s linear infinite;
        }

        a {
            color: inherit;
        }

        #app {
            position: relative;
            z-index: 1;
        }

        .shell-frame {
            width: min(1360px, calc(100% - 32px));
            margin: 0 auto;
        }

        .system-bar {
            position: sticky;
            top: 0;
            z-index: 20;
            backdrop-filter: blur(16px);
            background: rgba(3, 5, 8, 0.82);
            border-bottom: 1px solid rgba(255, 255, 255, 0.07);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.18);
        }

        .system-bar-inner {
            min-height: 76px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1.25rem;
            padding: 1rem 0;
        }

        .system-brand {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-width: 0;
        }

        .brand-mark {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            white-space: nowrap;
            position: relative;
        }

        .brand-mark i {
            font-size: 0.92rem;
            color: var(--accent-strong);
            transform: translateY(-1px);
            filter: drop-shadow(0 0 10px rgba(139, 216, 255, 0.35));
        }

        .brand-title {
            position: relative;
            display: inline-block;
            padding: 0.05rem 0.18rem 0.05rem 0;
            color: #f7fbff;
            font-family: "Bahnschrift SemiCondensed", "Arial Narrow", "Microsoft YaHei UI", "PingFang SC", sans-serif;
            font-size: 1.32rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            line-height: 1;
            text-shadow: 0 0 16px rgba(255, 255, 255, 0.05);
        }

        .brand-title::after {
            content: "";
            position: absolute;
            right: -0.18rem;
            top: 50%;
            width: 5px;
            height: 5px;
            background: var(--accent-strong);
            transform: translateY(-50%) rotate(45deg);
            box-shadow: 0 0 12px rgba(139, 216, 255, 0.45);
        }

        .brand-divider {
            width: 28px;
            height: 1px;
            margin-top: 0.12rem;
            background: linear-gradient(90deg, rgba(116, 208, 255, 0.95) 0%, rgba(116, 208, 255, 0.32) 70%, transparent 100%);
            flex-shrink: 0;
        }

        .brand-caption {
            color: var(--text-subtle);
            font-family: var(--mono);
            font-size: 0.8rem;
            letter-spacing: 0.15em;
            text-transform: uppercase;
        }

        .system-meta {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .status-chip,
        .user-chip {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            min-height: 38px;
            padding: 0.55rem 0.9rem;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.03);
            color: var(--text-subtle);
            font-family: var(--mono);
            font-size: 0.78rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 999px;
            background: var(--success);
            box-shadow: 0 0 12px rgba(115, 226, 180, 0.8);
        }

        .console-ghost-btn,
        .console-btn {
            border-radius: 0;
            border: 1px solid transparent;
            box-shadow: none;
            transition: transform 0.18s ease, border-color 0.18s ease, background 0.18s ease, color 0.18s ease;
        }

        .console-ghost-btn {
            min-height: 38px;
            padding: 0.55rem 0.95rem;
            background: transparent;
            border-color: rgba(255, 255, 255, 0.14);
            color: var(--text-main);
            font-size: 0.82rem;
            letter-spacing: 0.06em;
        }

        .console-ghost-btn:hover {
            background: rgba(255, 255, 255, 0.06);
            border-color: rgba(255, 255, 255, 0.24);
            color: var(--text-main);
        }

        .workspace {
            padding: 2rem 0 2.5rem;
        }

        .workspace-hero {
            margin-bottom: 1.5rem;
            padding: 1.6rem 1.75rem;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background:
                linear-gradient(135deg, rgba(8, 12, 18, 0.94), rgba(4, 7, 11, 0.90)),
                radial-gradient(circle at top right, rgba(116, 208, 255, 0.06), transparent 42%);
            box-shadow: var(--panel-shadow);
            position: relative;
            overflow: hidden;
        }

        .workspace-hero::before,
        .workspace-hero::after,
        .console-panel::before,
        .console-panel::after {
            content: "";
            position: absolute;
            width: 18px;
            height: 18px;
            border-color: rgba(255, 255, 255, 0.18);
            pointer-events: none;
        }

        .workspace-hero::before,
        .console-panel::before {
            top: 12px;
            left: 12px;
            border-top: 1px solid currentColor;
            border-left: 1px solid currentColor;
            color: rgba(255, 255, 255, 0.16);
        }

        .workspace-hero::after,
        .console-panel::after {
            right: 12px;
            bottom: 12px;
            border-right: 1px solid currentColor;
            border-bottom: 1px solid currentColor;
            color: rgba(116, 208, 255, 0.22);
        }

        .workspace-hero-content {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 1.25rem;
            position: relative;
            z-index: 1;
        }

        .hero-kicker,
        .panel-kicker,
        .support-kicker {
            display: inline-flex;
            align-items: center;
            gap: 0.55rem;
            margin-bottom: 0.8rem;
            color: var(--text-muted);
            font-family: var(--mono);
            font-size: 0.78rem;
            letter-spacing: 0.16em;
            text-transform: uppercase;
        }

        .hero-kicker::before,
        .panel-kicker::before,
        .support-kicker::before {
            content: "";
            width: 24px;
            height: 1px;
            background: rgba(116, 208, 255, 0.8);
        }

        .hero-title {
            margin: 0 0 0.85rem;
            font-size: clamp(1.9rem, 3vw, 2.8rem);
            font-weight: 700;
            letter-spacing: 0.04em;
        }

        .hero-copy {
            max-width: 760px;
            margin: 0;
            color: var(--text-subtle);
            line-height: 1.7;
        }

        .hero-telemetry {
            display: grid;
            grid-template-columns: repeat(2, minmax(120px, 1fr));
            gap: 0.85rem;
            min-width: 280px;
        }

        .telemetry-card {
            padding: 0.9rem 1rem;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.03);
        }

        .telemetry-label {
            display: block;
            margin-bottom: 0.35rem;
            color: var(--text-muted);
            font-family: var(--mono);
            font-size: 0.74rem;
            letter-spacing: 0.14em;
            text-transform: uppercase;
        }

        .telemetry-value {
            display: block;
            color: var(--text-main);
            font-size: 0.95rem;
            font-weight: 600;
        }

        .workspace-grid {
            display: grid;
            grid-template-columns: minmax(0, 0.95fr) minmax(0, 1.05fr);
            gap: 1.5rem;
            align-items: stretch;
        }

        .console-panel {
            position: relative;
            padding: 1.45rem;
            border: 1px solid var(--panel-border);
            background:
                linear-gradient(180deg, rgba(10, 14, 20, 0.94), rgba(5, 8, 12, 0.92));
            box-shadow: var(--panel-shadow);
            overflow: hidden;
        }

        .panel-header,
        .panel-toolbar {
            position: relative;
            z-index: 1;
        }

        .panel-header {
            display: flex;
            align-items: start;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.15rem;
        }

        .panel-title {
            margin: 0 0 0.4rem;
            font-size: 1.2rem;
            font-weight: 700;
            letter-spacing: 0.04em;
        }

        .panel-description {
            margin: 0;
            color: var(--text-subtle);
            line-height: 1.65;
        }

        .panel-badge {
            flex-shrink: 0;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            min-height: 36px;
            padding: 0.5rem 0.8rem;
            border: 1px solid rgba(116, 208, 255, 0.24);
            background: rgba(116, 208, 255, 0.08);
            color: var(--accent-strong);
            font-family: var(--mono);
            font-size: 0.76rem;
            letter-spacing: 0.1em;
            text-transform: uppercase;
        }

        .contract-textarea {
            min-height: 420px;
            padding: 1.15rem 1.15rem 1.25rem;
            border-radius: 0 !important;
            border: 1px solid rgba(255, 255, 255, 0.11);
            background:
                linear-gradient(180deg, rgba(7, 10, 15, 0.96), rgba(11, 15, 22, 0.98));
            color: var(--text-main);
            line-height: 1.75;
            resize: vertical;
            box-shadow: inset 0 0 0 1px rgba(116, 208, 255, 0.04);
        }

        .contract-textarea:focus {
            background: linear-gradient(180deg, rgba(9, 13, 19, 0.98), rgba(11, 17, 24, 1));
            border-color: var(--panel-border-strong);
            box-shadow: 0 0 0 0.2rem rgba(116, 208, 255, 0.10);
            color: var(--text-main);
        }

        .contract-textarea::placeholder {
            color: rgba(243, 247, 251, 0.34);
        }

        .input-meta-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            margin: 0.95rem 0 1rem;
            color: var(--text-muted);
            font-family: var(--mono);
            font-size: 0.76rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .meta-separator {
            flex: 1;
            height: 1px;
            background: linear-gradient(90deg, rgba(116, 208, 255, 0.34), transparent);
        }

        .action-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 0.85rem;
        }

        .console-btn {
            min-height: 56px;
            padding: 0.95rem 1.1rem;
            color: var(--text-main);
            font-weight: 600;
            letter-spacing: 0.04em;
        }

        .console-btn i {
            margin-right: 0.35rem;
        }

        .console-btn-primary {
            background: linear-gradient(135deg, rgba(91, 175, 255, 0.24), rgba(18, 28, 42, 0.98));
            border-color: rgba(116, 208, 255, 0.42);
        }

        .console-btn-primary:hover {
            transform: translateY(-1px);
            border-color: rgba(139, 216, 255, 0.62);
            background: linear-gradient(135deg, rgba(91, 175, 255, 0.34), rgba(18, 28, 42, 1));
            color: var(--text-main);
        }

        .console-btn-success {
            background: linear-gradient(135deg, rgba(115, 226, 180, 0.22), rgba(17, 27, 25, 0.98));
            border-color: rgba(115, 226, 180, 0.4);
        }

        .console-btn-success:hover {
            transform: translateY(-1px);
            border-color: rgba(145, 241, 200, 0.65);
            background: linear-gradient(135deg, rgba(115, 226, 180, 0.32), rgba(17, 27, 25, 1));
            color: var(--text-main);
        }

        .console-btn:disabled,
        .console-btn:disabled:hover {
            background: rgba(255, 255, 255, 0.04);
            border-color: rgba(255, 255, 255, 0.08);
            color: rgba(243, 247, 251, 0.38);
            transform: none;
            cursor: not-allowed;
        }

        .alert-console {
            margin-top: 1rem;
            border-radius: 0;
            border: 1px solid rgba(255, 142, 112, 0.28);
            background: rgba(255, 142, 112, 0.10);
            color: #ffd1c2;
        }

        .panel-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .mode-switch {
            display: inline-flex;
            gap: 0.55rem;
            padding: 0.25rem;
            margin: 0;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.02);
        }

        .mode-switch .nav-link {
            border-radius: 0;
            min-height: 40px;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            padding: 0.65rem 0.95rem;
            color: var(--text-muted);
            font-family: var(--mono);
            font-size: 0.78rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            border: 1px solid transparent;
        }

        .mode-switch .nav-link:hover {
            color: var(--text-main);
            background: rgba(255, 255, 255, 0.03);
        }

        .mode-switch .nav-link.active {
            background: rgba(116, 208, 255, 0.12);
            color: var(--text-main);
            border-color: rgba(116, 208, 255, 0.3);
            box-shadow: inset 0 0 0 1px rgba(116, 208, 255, 0.08);
        }

        .result-shell {
            min-height: 610px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background:
                linear-gradient(180deg, rgba(6, 9, 13, 0.97), rgba(10, 14, 19, 0.98));
            position: relative;
        }

        .result-shell::before {
            content: "";
            position: absolute;
            top: 0;
            right: 0;
            width: 160px;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(116, 208, 255, 0.75));
        }

        .report-container {
            min-height: 610px;
            padding: 1.4rem;
            background: transparent;
            color: var(--text-main);
        }

        .report-state {
            min-height: 610px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 1.6rem;
            color: var(--text-subtle);
        }

        .report-state-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 88px;
            height: 88px;
            margin-bottom: 1.2rem;
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(255, 255, 255, 0.03);
            font-size: 2.25rem;
            color: var(--accent-strong);
        }

        .report-state-title {
            margin: 0 0 0.55rem;
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-main);
        }

        .report-state-copy {
            max-width: 360px;
            margin: 0 auto;
            color: var(--text-subtle);
            line-height: 1.7;
        }

        .analysis-loader {
            width: 68px;
            height: 68px;
            margin: 0 auto 1.15rem;
            border: 1px solid rgba(116, 208, 255, 0.28);
            border-top-color: var(--accent-strong);
            border-radius: 50%;
            animation: spin 1.1s linear infinite;
            position: relative;
        }

        .analysis-loader::after {
            content: "";
            position: absolute;
            inset: 10px;
            border: 1px solid rgba(116, 208, 255, 0.18);
            border-bottom-color: var(--accent-strong);
            border-radius: 50%;
        }

        .spinner-container {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .report-content {
            line-height: 1.82;
            color: var(--text-subtle);
        }

        .report-content > :first-child {
            margin-top: 0;
        }

        .report-content h1,
        .report-content h2,
        .report-content h3,
        .report-content h4 {
            margin: 1.6rem 0 0.9rem;
            color: var(--text-main);
            line-height: 1.35;
            font-weight: 700;
        }

        .report-content h1,
        .report-content h2 {
            padding-bottom: 0.6rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .report-content p,
        .report-content li {
            color: var(--text-subtle);
        }

        .report-content ul,
        .report-content ol {
            padding-left: 1.6rem;
            margin-bottom: 1rem;
        }

        .report-content li + li {
            margin-top: 0.4rem;
        }

        .report-content strong {
            color: var(--text-main);
        }

        .report-content blockquote {
            margin: 1.25rem 0;
            padding: 0.85rem 1rem;
            border-left: 3px solid var(--accent);
            background: rgba(116, 208, 255, 0.08);
            color: var(--text-main);
        }

        .report-content code {
            padding: 0.16rem 0.4rem;
            background: rgba(255, 255, 255, 0.06);
            color: #c6ecff;
        }

        .report-content pre {
            padding: 1rem;
            overflow-x: auto;
            background: rgba(0, 0, 0, 0.28);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .report-content pre code {
            padding: 0;
            background: transparent;
        }

        .report-content hr {
            border-color: rgba(255, 255, 255, 0.08);
            opacity: 1;
        }

        .report-content table {
            width: 100%;
            margin: 1rem 0;
            border-collapse: collapse;
        }

        .report-content th,
        .report-content td {
            padding: 0.75rem;
            border: 1px solid rgba(255, 255, 255, 0.08);
        }

        .report-content th {
            color: var(--text-main);
            background: rgba(255, 255, 255, 0.04);
        }

        .support-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 1rem;
            margin-top: 1.4rem;
        }

        .support-card {
            padding: 1.15rem 1.2rem;
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(255, 255, 255, 0.03);
            box-shadow: 0 18px 48px rgba(0, 0, 0, 0.16);
        }

        .support-card i {
            font-size: 1.35rem;
            margin-bottom: 0.8rem;
        }

        .support-card h5 {
            margin-bottom: 0.55rem;
            color: var(--text-main);
        }

        .support-card p {
            margin-bottom: 0;
            color: var(--text-subtle);
            line-height: 1.65;
        }

        .console-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-top: 1.5rem;
            padding: 1rem 0 0;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            color: var(--text-muted);
            font-size: 0.88rem;
        }

        .footer-copy {
            margin: 0;
        }

        .footer-meta {
            color: var(--text-muted);
            font-family: var(--mono);
            font-size: 0.76rem;
            letter-spacing: 0.1em;
            text-transform: uppercase;
        }

        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        @keyframes dotDriftPrimary {
            from { transform: translate3d(0, 0, 0) scale(1.04); }
            50% { transform: translate3d(-18px, 8px, 0) scale(1.045); }
            to { transform: translate3d(-36px, 16px, 0) scale(1.04); }
        }

        @keyframes dotDriftSecondary {
            from { transform: translate3d(0, 0, 0); }
            50% { transform: translate3d(12px, -10px, 0); }
            to { transform: translate3d(24px, -20px, 0); }
        }

        @keyframes glowPulse {
            0%, 100% { transform: scale(1) translate3d(0, 0, 0); opacity: 0.55; }
            50% { transform: scale(1.05) translate3d(10px, -6px, 0); opacity: 0.78; }
        }

        @keyframes orbitFloatLarge {
            0%, 100% { transform: translate3d(0, 0, 0) rotate(0deg); }
            50% { transform: translate3d(12px, -10px, 0) rotate(2deg); }
        }

        @keyframes orbitFloatSmall {
            0%, 100% { transform: translate3d(0, 0, 0) rotate(0deg); }
            50% { transform: translate3d(-8px, 10px, 0) rotate(-3deg); }
        }

        @keyframes axisFlicker {
            0%, 100% { opacity: 0.16; }
            48% { opacity: 0.34; }
            52% { opacity: 0.22; }
        }

        @keyframes noiseShift {
            from { transform: translate3d(0, 0, 0); }
            to { transform: translate3d(-20px, 14px, 0); }
        }

        @keyframes constellationFloat {
            0%, 100% { transform: translate3d(0, 0, 0) rotate(0deg); opacity: 0.28; }
            50% { transform: translate3d(10px, -8px, 0) rotate(1.4deg); opacity: 0.38; }
        }

        @keyframes geometryFloat {
            0%, 100% { transform: translate3d(0, 0, 0); opacity: 0.18; }
            50% { transform: translate3d(-8px, 10px, 0); opacity: 0.28; }
        }

        @media (max-width: 1199.98px) {
            .ambient-orbit-large {
                width: 32rem;
                height: 32rem;
                left: -12%;
            }

            .ambient-constellation {
                left: -5%;
                width: 28rem;
                height: 34rem;
            }

            .ambient-geometry {
                width: 22rem;
                height: 18rem;
                left: 1%;
            }

            .workspace-hero-content {
                flex-direction: column;
                align-items: start;
            }

            .hero-telemetry {
                width: 100%;
                min-width: 0;
            }

            .workspace-grid {
                grid-template-columns: 1fr;
            }

            .result-shell,
            .report-container,
            .report-state {
                min-height: 520px;
            }
        }

        @media (max-width: 767.98px) {
            .ambient-grid {
                background-size: 34px 34px;
                opacity: 0.11;
            }

            .ambient-grid-secondary,
            .ambient-axis-horizontal,
            .ambient-axis-vertical {
                display: none;
            }

            .ambient-orbit-large {
                width: 24rem;
                height: 24rem;
                left: -26%;
                top: 16%;
                opacity: 0.18;
            }

            .ambient-orbit-small {
                left: 62%;
                top: auto;
                bottom: 9%;
                width: 8rem;
                height: 8rem;
                opacity: 0.14;
            }

            .ambient-constellation {
                left: -28%;
                top: 22%;
                width: 22rem;
                height: 28rem;
                opacity: 0.18;
            }

            .ambient-geometry {
                display: none;
            }

            .shell-frame {
                width: min(100% - 20px, 1360px);
            }

            .system-bar-inner,
            .panel-header,
            .panel-toolbar,
            .console-footer {
                flex-direction: column;
                align-items: start;
            }

            .system-meta {
                width: 100%;
                justify-content: flex-start;
            }

            .brand-caption {
                display: none;
            }

            .workspace {
                padding-top: 1rem;
            }

            .workspace-hero,
            .console-panel {
                padding: 1.1rem;
            }

            .hero-telemetry,
            .support-grid {
                grid-template-columns: 1fr;
            }

            .mode-switch {
                width: 100%;
            }

            .mode-switch .nav-item,
            .mode-switch .nav-link {
                flex: 1;
                justify-content: center;
            }

            .result-shell,
            .report-container,
            .report-state {
                min-height: 460px;
            }
        }

        @media (max-width: 479.98px) {
            .action-grid {
                grid-template-columns: 1fr;
            }

            .hero-title {
                font-size: 1.55rem;
            }

            .status-chip,
            .user-chip,
            .console-ghost-btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
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

    <main class="workspace">
        <div class="shell-frame">
            <section class="workspace-hero">
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

            <section class="workspace-grid">
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

            <section class="support-grid">
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

            <footer class="console-footer">
                <p class="footer-copy">
                    2026 法小智 | 面向青年就业权益保护的劳动合同智能审查平台，仅供学习与参考。
                </p>
                <div class="footer-meta">Console Status: Active Session</div>
            </footer>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/vue@3.3.4/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios@1.5.0/dist/axios.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/marked@9.0.0/marked.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.149.0/build/three.min.js"></script>

<script>
    const { createApp, ref, computed, onMounted, onUnmounted } = Vue;

    function drawDot(ctx, x, y, radius, alpha) {
        ctx.globalAlpha = alpha;
        ctx.beginPath();
        ctx.arc(x, y, radius, 0, Math.PI * 2);
        ctx.fill();
    }

    function drawDottedSegment(ctx, x1, y1, x2, y2, spacing, radius, alpha) {
        const dx = x2 - x1;
        const dy = y2 - y1;
        const dist = Math.hypot(dx, dy);
        const steps = Math.max(2, Math.floor(dist / spacing));
        for (let i = 0; i <= steps; i += 1) {
            const t = i / steps;
            drawDot(ctx, x1 + dx * t, y1 + dy * t, radius, alpha * (0.88 + 0.12 * Math.sin(t * Math.PI)));
        }
    }

    function sampleCubic(points, t) {
        const mt = 1 - t;
        const mt2 = mt * mt;
        const t2 = t * t;
        return {
            x: mt2 * mt * points[0].x + 3 * mt2 * t * points[1].x + 3 * mt * t2 * points[2].x + t2 * t * points[3].x,
            y: mt2 * mt * points[0].y + 3 * mt2 * t * points[1].y + 3 * mt * t2 * points[2].y + t2 * t * points[3].y,
        };
    }

    function drawDottedBezier(ctx, points, steps, radius, alpha) {
        for (let i = 0; i <= steps; i += 1) {
            const t = i / steps;
            const p = sampleCubic(points, t);
            drawDot(ctx, p.x, p.y, radius, alpha);
        }
    }

    function drawDottedArc(ctx, cx, cy, r, start, end, density, radius, alpha) {
        const arcLength = Math.abs(end - start) * r;
        const steps = Math.max(16, Math.floor(arcLength / density));
        for (let i = 0; i <= steps; i += 1) {
            const t = i / steps;
            const angle = start + (end - start) * t;
            drawDot(ctx, cx + Math.cos(angle) * r, cy + Math.sin(angle) * r, radius, alpha);
        }
    }

    function drawDottedEllipseFill(ctx, cx, cy, rx, ry, spacing, radius, alpha, exponent) {
        for (let y = cy - ry; y <= cy + ry; y += spacing) {
            for (let x = cx - rx; x <= cx + rx; x += spacing) {
                const nx = (x - cx) / rx;
                const ny = (y - cy) / ry;
                const distance = nx * nx + ny * ny;
                if (distance <= 1) {
                    const density = Math.pow(1 - distance, exponent);
                    if (Math.random() < density) {
                        drawDot(ctx, x, y, radius, alpha * density);
                    }
                }
            }
        }
    }

    function drawPointField(ctx, width, height) {
        const step = Math.max(28, Math.round(width / 48));
        for (let y = 14; y <= height; y += step) {
            for (let x = 10; x <= width; x += step) {
                const offset = ((Math.floor(y / step) % 2) * step) / 2;
                const px = x + offset;
                const radius = px < width * 0.44 ? 1.28 : 1.05;
                const alpha = 0.18 + (Math.sin((px + y) * 0.012) + 1) * 0.05;
                drawDot(ctx, px, y, radius, alpha);
                if ((x + y) % (step * 5) === 0) {
                    drawDot(ctx, px + 5, y, 0.85, alpha * 0.9);
                }
            }
        }
    }

    function drawTechnicalFrame(ctx, width, height) {
        ctx.fillStyle = "rgba(255,255,255,0.72)";
        drawDottedSegment(ctx, width * 0.065, height * 0.84, width * 0.31, height * 0.84, 11, 1.05, 0.22);
        drawDottedSegment(ctx, width * 0.065, height * 0.84, width * 0.065, height * 0.45, 11, 1.05, 0.22);
        drawDottedSegment(ctx, width * 0.31, height * 0.84, width * 0.31, height * 0.62, 11, 1.05, 0.18);
        drawDottedSegment(ctx, width * 0.12, height * 0.45, width * 0.31, height * 0.45, 11, 1.0, 0.18);
        drawDottedSegment(ctx, width * 0.23, height * 0.70, width * 0.23, height * 0.84, 11, 1.0, 0.18);
        drawDottedArc(ctx, width * 0.24, height * 0.74, width * 0.05, 0, Math.PI * 2, 8, 0.9, 0.18);
    }

    function drawSisyphusScene(ctx, width, height) {
        ctx.fillStyle = "rgba(255,255,255,0.84)";
        const centerX = width * 0.22;
        const centerY = height * 0.39;
        const boulderR = Math.min(width, height) * 0.18;

        drawDottedArc(ctx, centerX, centerY, boulderR, 0, Math.PI * 2, 7.5, 1.45, 0.32);
        drawDottedArc(ctx, centerX + boulderR * 0.02, centerY + boulderR * 0.06, boulderR * 0.66, Math.PI * 0.18, Math.PI * 1.64, 7.2, 1.05, 0.22);
        drawDottedArc(ctx, centerX, centerY, boulderR * 0.92, Math.PI * 0.12, Math.PI * 1.68, 10, 0.9, 0.14);
        drawDottedEllipseFill(ctx, centerX - boulderR * 0.14, centerY - boulderR * 0.16, boulderR * 0.36, boulderR * 0.28, 7, 1.1, 0.28, 1.4);

        drawDottedBezier(ctx, [
            { x: width * 0.10, y: height * 0.84 },
            { x: width * 0.18, y: height * 0.69 },
            { x: width * 0.28, y: height * 0.52 },
            { x: width * 0.33, y: height * 0.45 }
        ], 96, 1.08, 0.24);
        drawDottedSegment(ctx, width * 0.09, height * 0.84, width * 0.31, height * 0.84, 9, 1.12, 0.20);

        drawDottedArc(ctx, width * 0.23, height * 0.46, width * 0.13, Math.PI * 0.96, Math.PI * 2.05, 8, 0.95, 0.16);
        drawDottedSegment(ctx, width * 0.07, height * 0.46, width * 0.33, height * 0.46, 10, 1.02, 0.16);
        drawDottedSegment(ctx, width * 0.19, height * 0.28, width * 0.19, height * 0.84, 10, 0.98, 0.13);

        drawDottedArc(ctx, width * 0.17, height * 0.65, width * 0.022 * height, 0, Math.PI * 2, 5, 1.05, 0.32);

        drawDottedBezier(ctx, [
            { x: width * 0.18, y: height * 0.67 },
            { x: width * 0.20, y: height * 0.65 },
            { x: width * 0.22, y: height * 0.61 },
            { x: width * 0.24, y: height * 0.57 }
        ], 30, 1.0, 0.28);
        drawDottedBezier(ctx, [
            { x: width * 0.24, y: height * 0.57 },
            { x: width * 0.255, y: height * 0.55 },
            { x: width * 0.27, y: height * 0.51 },
            { x: width * 0.285, y: height * 0.48 }
        ], 24, 1.0, 0.30);
        drawDottedBezier(ctx, [
            { x: width * 0.235, y: height * 0.60 },
            { x: width * 0.215, y: height * 0.68 },
            { x: width * 0.205, y: height * 0.76 },
            { x: width * 0.185, y: height * 0.84 }
        ], 34, 1.0, 0.26);

        drawDottedSegment(ctx, width * 0.236, height * 0.60, width * 0.29, height * 0.54, 6.5, 1.0, 0.30);
        drawDottedSegment(ctx, width * 0.24, height * 0.62, width * 0.30, height * 0.60, 6.5, 1.0, 0.26);
        drawDottedSegment(ctx, width * 0.215, height * 0.70, width * 0.275, height * 0.76, 6.2, 1.0, 0.28);
        drawDottedSegment(ctx, width * 0.208, height * 0.70, width * 0.16, height * 0.80, 6.2, 1.0, 0.28);
        drawDottedSegment(ctx, width * 0.274, height * 0.76, width * 0.29, height * 0.84, 5.8, 1.0, 0.26);
        drawDottedSegment(ctx, width * 0.16, height * 0.80, width * 0.12, height * 0.84, 5.8, 1.0, 0.26);

        drawDottedArc(ctx, width * 0.26, height * 0.68, width * 0.10, Math.PI * 0.55, Math.PI * 1.34, 8, 0.95, 0.16);
        drawDottedArc(ctx, width * 0.30, height * 0.80, width * 0.045, Math.PI * 0.78, Math.PI * 1.82, 7, 0.9, 0.12);
    }

    function generateBackgroundTexture(width, height) {
        const canvas = document.createElement("canvas");
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext("2d");

        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = "rgba(255,255,255,0.9)";
        drawPointField(ctx, width, height);
        drawTechnicalFrame(ctx, width, height);
        drawSisyphusScene(ctx, width, height);

        return canvas;
    }

    function initThreeBackground() {
        const container = document.getElementById("three-bg");
        if (!container || !window.THREE) {
            return () => {};
        }

        const scene = new THREE.Scene();
        const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
        const renderer = new THREE.WebGLRenderer({
            antialias: true,
            alpha: false,
            powerPreference: "high-performance",
        });
        renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
        renderer.outputEncoding = THREE.sRGBEncoding;
        container.innerHTML = "";
        container.appendChild(renderer.domElement);

        let texture;
        const uniforms = {
            uTime: { value: 0 },
            uResolution: { value: new THREE.Vector2(1, 1) },
            uMap: { value: null },
        };

        const material = new THREE.ShaderMaterial({
            uniforms,
            vertexShader: `
                varying vec2 vUv;
                void main() {
                    vUv = uv;
                    gl_Position = vec4(position.xy, 0.0, 1.0);
                }
            `,
            fragmentShader: `
                precision highp float;
                uniform sampler2D uMap;
                uniform vec2 uResolution;
                uniform float uTime;
                varying vec2 vUv;

                float rectMask(vec2 uv, vec2 minBound, vec2 maxBound) {
                    float mx = smoothstep(minBound.x, minBound.x + 0.08, uv.x) * (1.0 - smoothstep(maxBound.x - 0.08, maxBound.x, uv.x));
                    float my = smoothstep(minBound.y, minBound.y + 0.08, uv.y) * (1.0 - smoothstep(maxBound.y - 0.08, maxBound.y, uv.y));
                    return mx * my;
                }

                void main() {
                    vec2 aspectUv = (vUv - 0.5) * vec2(uResolution.x / uResolution.y, 1.0);
                    float vignette = smoothstep(1.26, 0.16, length(aspectUv));
                    float breath = 0.94 + 0.06 * sin(uTime * 0.22);
                    vec2 driftA = vUv + vec2(uTime * 0.00045, sin(uTime * 0.03 + vUv.y * 4.0) * 0.0014);
                    vec2 driftB = vUv + vec2(-uTime * 0.00025, cos(uTime * 0.025 + vUv.x * 3.0) * 0.0011);

                    float mapA = texture2D(uMap, driftA).r;
                    float mapB = texture2D(uMap, driftB).r;
                    float field = mapA * 0.92 + mapB * 0.38;

                    float leftGlow = pow(max(0.0, 1.0 - distance(vUv, vec2(0.20, 0.44)) * 2.15), 2.15);
                    float rightGlow = pow(max(0.0, 1.0 - distance(vUv, vec2(0.78, 0.12)) * 2.8), 3.0);
                    float scan = sin(vUv.y * uResolution.y * 0.09 + uTime * 0.34) * 0.012;
                    float panelMask = rectMask(vUv, vec2(0.14, 0.14), vec2(0.86, 0.94));
                    float attenuation = mix(1.0, 0.48, panelMask);

                    vec3 color = vec3(0.005, 0.007, 0.011);
                    color += vec3(0.018, 0.034, 0.062) * leftGlow * 0.52 * attenuation;
                    color += vec3(0.010, 0.018, 0.028) * rightGlow * 0.20;
                    color += vec3(0.80, 0.85, 0.92) * field * 0.38 * attenuation * breath;
                    color += vec3(scan);
                    color *= vignette;

                    gl_FragColor = vec4(color, 1.0);
                }
            `,
        });

        const mesh = new THREE.Mesh(new THREE.PlaneGeometry(2, 2), material);
        scene.add(mesh);

        const clock = new THREE.Clock();
        let frameId = 0;

        const rebuildTexture = () => {
            const width = Math.max(1400, Math.floor(window.innerWidth * 1.2));
            const height = Math.max(1000, Math.floor(window.innerHeight * 1.2));
            const canvas = generateBackgroundTexture(width, height);
            const nextTexture = new THREE.CanvasTexture(canvas);
            nextTexture.minFilter = THREE.LinearFilter;
            nextTexture.magFilter = THREE.LinearFilter;
            nextTexture.wrapS = THREE.ClampToEdgeWrapping;
            nextTexture.wrapT = THREE.ClampToEdgeWrapping;
            nextTexture.needsUpdate = true;
            if (texture) {
                texture.dispose();
            }
            texture = nextTexture;
            uniforms.uMap.value = texture;
        };

        const onResize = () => {
            const width = window.innerWidth;
            const height = window.innerHeight;
            renderer.setSize(width, height, false);
            uniforms.uResolution.value.set(width, height);
            rebuildTexture();
        };

        const render = () => {
            frameId = requestAnimationFrame(render);
            uniforms.uTime.value = clock.getElapsedTime();
            renderer.render(scene, camera);
        };

        onResize();
        render();
        window.addEventListener("resize", onResize);

        return () => {
            window.removeEventListener("resize", onResize);
            cancelAnimationFrame(frameId);
            mesh.geometry.dispose();
            material.dispose();
            if (texture) {
                texture.dispose();
            }
            renderer.dispose();
            container.innerHTML = "";
        };
    }

    createApp({
        setup() {
            const currentUser = ref('');
            let cleanupBackground = () => {};

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

            const contractText = ref('');
            const reviewResult = ref('');
            const modifyResult = ref('');
            const reviewLoading = ref(false);
            const modifyLoading = ref(false);
            const error = ref('');
            const activeTab = ref('review');

            const API_REVIEW = 'http://127.0.0.1:8001/api/v1/review';
            const API_MODIFY = 'http://127.0.0.1:8001/api/v1/agent_modify';

            const renderedReview = computed(() => {
                if (!reviewResult.value) return '';
                marked.setOptions({ breaks: true, gfm: true });
                return marked.parse(reviewResult.value);
            });
            const renderedModify = computed(() => {
                if (!modifyResult.value) return '';
                marked.setOptions({ breaks: true, gfm: true });
                return marked.parse(modifyResult.value);
            });

            const submitReview = async () => {
                if (!contractText.value.trim()) {
                    error.value = '请先输入合同条款内容';
                    return;
                }
                activeTab.value = 'review';
                reviewLoading.value = true;
                error.value = '';
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
                        error.value = res.data.message || '审查失败，请重试';
                    }
                } catch (err) {
                    if (err.code === 'ECONNABORTED') {
                        error.value = '请求超时，请稍后重试';
                    } else if (err.response) {
                        error.value = '服务器错误: ' + err.response.status;
                    } else if (err.request) {
                        error.value = '无法连接到后端服务(端口8001)';
                    } else {
                        error.value = '请求失败: ' + err.message;
                    }
                } finally {
                    reviewLoading.value = false;
                }
            };

            const submitModify = async () => {
                if (!contractText.value.trim()) {
                    error.value = '请先输入合同条款内容';
                    return;
                }
                activeTab.value = 'modify';
                modifyLoading.value = true;
                error.value = '';
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
                        error.value = res.data.message || '修改失败，请重试';
                    }
                } catch (err) {
                    if (err.code === 'ECONNABORTED') {
                        error.value = '请求超时，AI 分析耗时较长，请稍后重试';
                    } else if (err.response) {
                        error.value = '服务器错误: ' + err.response.status;
                    } else if (err.request) {
                        error.value = '无法连接到后端服务(端口8001)';
                    } else {
                        error.value = '请求失败: ' + err.message;
                    }
                } finally {
                    modifyLoading.value = false;
                }
            };

            return {
                currentUser, logout,
                contractText, reviewResult, modifyResult,
                reviewLoading, modifyLoading, error, activeTab,
                renderedReview, renderedModify,
                submitReview, submitModify,
            };
        }
    }).mount('#app');
</script>
</body>
</html>
