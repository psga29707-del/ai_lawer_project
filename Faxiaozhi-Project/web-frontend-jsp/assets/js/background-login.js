// ── 登录页 WebGL Shader 动态背景 ──

let _animationId;
let _renderer, _scene, _camera, _material, _geometry;

function initShader() {
    const container = document.getElementById('shader-bg');
    if (!container) return () => {};

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

    _camera = new THREE.Camera();
    _camera.position.z = 1;

    _scene = new THREE.Scene();
    _geometry = new THREE.PlaneGeometry(2, 2);

    const uniforms = {
        time: { type: "f", value: 1.0 },
        resolution: { type: "v2", value: new THREE.Vector2() },
    };

    _material = new THREE.ShaderMaterial({
        uniforms: uniforms,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader,
    });

    const mesh = new THREE.Mesh(_geometry, _material);
    _scene.add(mesh);

    _renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    _renderer.setPixelRatio(window.devicePixelRatio);
    container.appendChild(_renderer.domElement);

    const onWindowResize = () => {
        const width = container.clientWidth;
        const height = container.clientHeight;
        _renderer.setSize(width, height);
        uniforms.resolution.value.x = _renderer.domElement.width;
        uniforms.resolution.value.y = _renderer.domElement.height;
    };

    onWindowResize();
    window.addEventListener("resize", onWindowResize, false);

    const animate = () => {
        _animationId = requestAnimationFrame(animate);
        uniforms.time.value += 0.05;
        _renderer.render(_scene, _camera);
    };

    animate();

    return () => {
        window.removeEventListener("resize", onWindowResize);
        cancelAnimationFrame(_animationId);
        if (container && _renderer.domElement) {
            container.removeChild(_renderer.domElement);
        }
        _renderer.dispose();
        _geometry.dispose();
        _material.dispose();
    };
}
