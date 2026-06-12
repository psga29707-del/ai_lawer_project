// ── 审查页 Canvas + Three.js 动态背景 ──

/* ============ Canvas 绘图辅助函数 ============ */

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

/* ============ 生成 Canvas 纹理 ============ */

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

/* ============ 初始化 Three.js 背景 ============ */

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
