/* ============================================================
   SKYRESERVE — Ultra-Premium JavaScript Engine
   3D Tilt | Parallax | GSAP-like Animations | Counter
   ============================================================ */

/* ── Sidebar Toggle ─────────────────────────────────────── */
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    if (!sidebar) return;
    sidebar.classList.toggle('sidebar-open');

    let overlay = document.getElementById('sidebar-overlay');
    if (sidebar.classList.contains('sidebar-open')) {
        if (!overlay) {
            overlay = document.createElement('div');
            overlay.id = 'sidebar-overlay';
            overlay.style.cssText = `
                position:fixed; inset:0;
                background:rgba(0,0,0,0.45);
                backdrop-filter:blur(4px);
                z-index:999;
                animation: fadeIn 0.3s ease;
            `;
            overlay.addEventListener('click', () => toggleSidebar());
            document.body.appendChild(overlay);
        }
    } else {
        if (overlay) overlay.remove();
    }
}

/* ── Counter Animation ───────────────────────────────────── */
function animateCounter(el, target, duration = 1400) {
    const start = 0;
    const startTime = performance.now();
    function tick(now) {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 4); // ease-out quart
        el.textContent = Math.round(start + (target - start) * eased).toLocaleString();
        if (progress < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
}

function initCounterAnimations() {
    document.querySelectorAll('.stat-value').forEach(el => {
        const text = el.textContent.trim();
        if (/^\d+$/.test(text)) {
            const target = parseInt(text);
            el.textContent = '0';
            // Delay start for staggered effect
            setTimeout(() => animateCounter(el, target), 200);
        }
    });
}

/* ── Scroll Reveal (IntersectionObserver) ─────────────────── */
function initScrollReveal() {
    if (!('IntersectionObserver' in window)) return;
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.animationPlayState = 'running';
                entry.target.classList.add('revealed');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });

    document.querySelectorAll('.animate-fade-in').forEach(el => observer.observe(el));
}

/* ── 3D Tilt Cards ───────────────────────────────────────── */
function init3DTilt() {
    const cards = document.querySelectorAll('.stat-card, .currency-card, .query-card');
    cards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            const rotateX = ((y - centerY) / centerY) * -6;
            const rotateY = ((x - centerX) / centerX) * 6;
            card.style.transform = `perspective(800px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-4px) scale(1.02)`;
        });

        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(800px) rotateX(0) rotateY(0) translateY(0) scale(1)';
        });
    });
}

/* ── Ripple Effect ───────────────────────────────────────── */
function initRipple() {
    document.querySelectorAll('.btn-primary, .btn-login, .query-card').forEach(btn => {
        btn.addEventListener('click', function (e) {
            const rect = this.getBoundingClientRect();
            const ripple = document.createElement('span');
            const size = Math.max(rect.width, rect.height);
            ripple.style.cssText = `
                position:absolute; width:${size}px; height:${size}px;
                left:${e.clientX - rect.left - size / 2}px;
                top:${e.clientY - rect.top - size / 2}px;
                background:rgba(255,255,255,0.25);
                border-radius:50%; transform:scale(0);
                animation:rippleAnim 0.65s ease-out;
                pointer-events:none;
            `;
            this.style.position = 'relative';
            this.style.overflow = 'hidden';
            this.appendChild(ripple);
            setTimeout(() => ripple.remove(), 700);
        });
    });
}

/* ── Auto Dismiss Alerts ─────────────────────────────────── */
function initAlertDismiss() {
    document.querySelectorAll('.alert-dismissible').forEach(alert => {
        // Add fade-in animation
        alert.style.animation = 'fadeInUp 0.5s ease';
        setTimeout(() => {
            if (typeof bootstrap !== 'undefined') {
                const bsAlert = bootstrap.Alert.getOrCreateInstance(alert);
                if (bsAlert) bsAlert.close();
            }
        }, 5000);
    });
}

/* ── Keyboard Shortcuts ──────────────────────────────────── */
function initKeyboardShortcuts() {
    document.addEventListener('keydown', (e) => {
        if (e.ctrlKey && e.key === 'k') {
            e.preventDefault();
            const search = document.querySelector('.search-form input[type="text"]');
            if (search) search.focus();
        }
    });
}

/* ── Parallax on Hero Banner ─────────────────────────────── */
function initParallax() {
    const hero = document.querySelector('.hero-banner-bg, .login-hero-bg, .page-hero-bg');
    if (!hero) return;
    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        hero.style.transform = `translateY(${scrolled * 0.3}px)`;
    }, { passive: true });
}

/* ── Smooth Page Transition Feel ─────────────────────────── */
function initPageTransition() {
    document.body.style.opacity = '0';
    document.body.style.transition = 'opacity 0.4s ease';
    requestAnimationFrame(() => {
        document.body.style.opacity = '1';
    });
}

/* ── Image Error Fallback ────────────────────────────────── */
function initImageFallbacks() {
    document.querySelectorAll('img[data-fallback]').forEach(img => {
        img.addEventListener('error', function() {
            this.src = this.dataset.fallback;
        });
    });
    // For background images that fail
    document.querySelectorAll('[data-bg-fallback]').forEach(el => {
        const img = new Image();
        const bgUrl = getComputedStyle(el).backgroundImage.replace(/url\(["']?(.*?)["']?\)/, '$1');
        img.onerror = () => {
            el.style.background = el.dataset.bgFallback;
        };
        img.src = bgUrl;
    });
}

/* ── Animate route lines in tables ───────────────────────── */
function initRouteAnimations() {
    document.querySelectorAll('.route-line').forEach(line => {
        line.style.animation = 'none';
        line.offsetHeight; // trigger reflow
        line.style.animation = 'routePulse 2s ease infinite';
    });
}

/* ── Inject dynamic style keyframes ──────────────────────── */
const dynamicStyles = document.createElement('style');
dynamicStyles.textContent = `
    @keyframes rippleAnim {
        to { transform: scale(4); opacity: 0; }
    }
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    @keyframes routePulse {
        0%, 100% { opacity: 0.5; }
        50% { opacity: 1; }
    }
    @keyframes takeoff {
        0% { transform: translateY(0) rotate(0); opacity: 1; }
        100% { transform: translateY(-200px) rotate(-15deg); opacity: 0; }
    }
    @keyframes glow {
        0%, 100% { box-shadow: 0 0 8px rgba(12,142,235,0.2); }
        50% { box-shadow: 0 0 24px rgba(12,142,235,0.4); }
    }
`;
document.head.appendChild(dynamicStyles);

/* ── Table Row Hover Sound-like Feedback ─────────────────── */
function initTableInteractions() {
    document.querySelectorAll('.table-custom tbody tr').forEach(row => {
        row.style.cursor = 'default';
    });
}

/* ════════════════════════════════════════════════════════════
   3D HOMEPAGE ENGINE (Globe, Particles, GSAP)
   ════════════════════════════════════════════════════════════ */

function initHomePage3D() {
    // 1. TS Particles Background (Constellation)
    const particlesContainer = document.getElementById('tsparticles');
    if (particlesContainer && typeof tsParticles !== 'undefined') {
        tsParticles.load("tsparticles", {
            preset: "stars",
            particles: {
                color: { value: "#ffffff" },
                links: { enable: true, color: "#36a9fa", distance: 150, opacity: 0.2 },
                move: { enable: true, speed: 0.5 },
                number: { value: 60 }
            },
            background: { color: "transparent" }
        });
    }

    // 2. Globe.gl Initialization
    const globeElem = document.getElementById('globeViz');
    if (globeElem && typeof Globe !== 'undefined') {
        // Airline Hubs (12 Cities from DB Case Study)
        const cities = [
            { id: 1, name: 'Toronto', country: 'Canada', air: 'AirCan', lat: 43.6532, lng: -79.3832 },
            { id: 2, name: 'Montreal', country: 'Canada', air: 'AirCan', lat: 45.5017, lng: -73.5673 },
            { id: 3, name: 'New York', country: 'USA', air: 'USAir', lat: 40.7128, lng: -74.0060 },
            { id: 4, name: 'Chicago', country: 'USA', air: 'USAir', lat: 41.8781, lng: -87.6298 },
            { id: 5, name: 'London', country: 'UK', air: 'BritAir', lat: 51.5074, lng: -0.1278 },
            { id: 6, name: 'Edinburgh', country: 'UK', air: 'BritAir', lat: 55.9533, lng: -3.1883 },
            { id: 7, name: 'Paris', country: 'France', air: 'AirFrance', lat: 48.8566, lng: 2.3522 },
            { id: 8, name: 'Nice', country: 'France', air: 'AirFrance', lat: 43.7102, lng: 7.2620 },
            { id: 9, name: 'Bonn', country: 'Germany', air: 'LuftAir', lat: 50.7374, lng: 7.0982 },
            { id: 10, name: 'Berlin', country: 'Germany', air: 'LuftAir', lat: 52.5200, lng: 13.4050 },
            { id: 11, name: 'Rome', country: 'Italy', air: 'ItalAir', lat: 41.9028, lng: 12.4964 },
            { id: 12, name: 'Naples', country: 'Italy', air: 'ItalAir', lat: 40.8518, lng: 14.2681 }
        ];

        // Generate mock arcs
        const arcsData = [];
        for (let i = 0; i < 15; i++) {
            const start = cities[Math.floor(Math.random() * cities.length)];
            let end = cities[Math.floor(Math.random() * cities.length)];
            while (start === end) end = cities[Math.floor(Math.random() * cities.length)];
            arcsData.push({
                startLat: start.lat,
                startLng: start.lng,
                endLat: end.lat,
                endLng: end.lng,
                name: `${start.name} ➔ ${end.name}`,
                airline: start.air,
                color: ['#36a9fa', '#ef4444', '#10b981', '#fbbf24'][Math.floor(Math.random() * 4)]
            });
        }

        const world = Globe()
            (globeElem)
            .globeImageUrl('https://unpkg.com/three-globe/example/img/earth-blue-marble.jpg')
            .bumpImageUrl('https://unpkg.com/three-globe/example/img/earth-topology.png')
            .backgroundColor('rgba(0,0,0,0)')
            
            // Labels for cities
            .labelsData(cities)
            .labelLat('lat')
            .labelLng('lng')
            .labelText('name')
            .labelSize(1.5)
            .labelDotRadius(0.5)
            .labelColor(() => 'rgba(255, 255, 255, 0.9)')
            .labelResolution(2)
            
            // Arcs
            .arcsData(arcsData)
            .arcColor('color')
            .arcDashLength(0.4)
            .arcDashGap(0.2)
            .arcDashInitialGap(() => Math.random())
            .arcDashAnimateTime(2000)
            .arcStroke(0.6)
            
            // Tooltip template
            .arcLabel(d => `
                <div class="globe-tooltip">
                    <div class="globe-tooltip-airline">${d.airline}</div>
                    <div class="globe-tooltip-route">${d.name}</div>
                    <div class="globe-tooltip-meta">Interactive 3D Flight Map</div>
                </div>
            `);

        // Globe Controls
        world.controls().autoRotate = true;
        world.controls().autoRotateSpeed = 0.5;
        world.controls().enableZoom = true;
        
        // Atmosphere Glow
        const material = world.globeMaterial();
        const directionalLight = world.scene().children.find(obj3d => obj3d.type === 'DirectionalLight');
        if (directionalLight) directionalLight.intensity = 1.2;

        const resetBtn = document.getElementById('resetGlobeBtn');
        if (resetBtn) {
            resetBtn.addEventListener('click', () => {
                world.pointOfView({ lat: 48, lng: -20, altitude: 2 }, 1500);
            });
        }
        
        // Initial point of view to fit map
        world.pointOfView({ lat: 45, lng: -40, altitude: 2.2 }, 0);
    }

    // 3. GSAP Entrance Animations
    if (typeof gsap !== 'undefined') {
        gsap.registerPlugin(ScrollTrigger);

        // Hero Entrance
        gsap.from(".gsap-hero-item", {
            y: 80,
            opacity: 0,
            rotationX: -45,
            transformOrigin: "0% 50% -50",
            duration: 1.2,
            stagger: 0.15,
            ease: "power3.out"
        });

        // Dashboard/Nav Fade
        gsap.from(".hero-navbar", {
            y: -100,
            opacity: 0,
            duration: 1,
            delay: 0.5,
            ease: "power2.out"
        });

        // Features Scroll Animations
        gsap.utils.toArray(".gsap-fade-up").forEach(elem => {
            gsap.from(elem, {
                scrollTrigger: {
                    trigger: elem,
                    start: "top 80%",
                },
                y: 60,
                opacity: 0,
                duration: 1,
                ease: "power3.out"
            });
        });

        // 3D Staggered Cards
        gsap.from(".gsap-card-stagger", {
            scrollTrigger: {
                trigger: ".features-section",
                start: "top 75%"
            },
            y: 100,
            opacity: 0,
            rotationY: 20,
            rotationX: 10,
            stagger: 0.2,
            duration: 1.2,
            ease: "power3.out"
        });
    }

    // Vanilla Tilt manually attach (if elements added dynamically or require custom init)
    // Included via CDN property `data-tilt` automatically binds them, 
    // but just checking if any custom action is needed.
}

/* ════════════════════════════════════════════════════════════
   INITIALIZE ALL
   ════════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
    initPageTransition();
    initCounterAnimations();
    initScrollReveal();
    init3DTilt(); // Existing basic tilt for other pages
    initRipple();
    initAlertDismiss();
    initKeyboardShortcuts();
    initParallax();
    initImageFallbacks();
    initRouteAnimations();
    initTableInteractions();
    
    // Launch New 3D Engine
    initHomePage3D();
});

