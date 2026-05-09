// Fade-up on scroll — one subtle 8px translation per section, runs once.
(function () {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    var targets = document.querySelectorAll(".section, .hero");

    var observer = new IntersectionObserver(
        function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add("fade-up", "visible");
                    observer.unobserve(entry.target);
                }
            });
        },
        { threshold: 0.1 }
    );

    targets.forEach(function (el) {
        el.classList.add("fade-up");
        observer.observe(el);
    });
})();
