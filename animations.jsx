// animations.jsx — Lightweight animation playback framework for React
// Provides: Stage, useTime, Easing, clamp

const TimeContext = React.createContext(0);
function useTime() { return React.useContext(TimeContext); }

function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }

const Easing = {
  easeOutCubic: (t) => 1 - Math.pow(1 - t, 3),
  easeInOutCubic: (t) => t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2,
};

function Stage({ width, height, duration, background, persistKey, loop, children }) {
  const [time, setTime] = React.useState(0);
  const [playing, setPlaying] = React.useState(false);
  const rafRef = React.useRef(null);
  const lastRef = React.useRef(null);

  // Persist time in sessionStorage
  React.useEffect(() => {
    if (persistKey) {
      const saved = sessionStorage.getItem(persistKey);
      if (saved != null) setTime(parseFloat(saved));
    }
  }, []);

  React.useEffect(() => {
    if (persistKey) sessionStorage.setItem(persistKey, time.toString());
  }, [time, persistKey]);

  // Animation loop
  React.useEffect(() => {
    if (!playing) {
      lastRef.current = null;
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
      return;
    }
    const tick = (ts) => {
      if (lastRef.current != null) {
        const dt = (ts - lastRef.current) / 1000;
        setTime((prev) => {
          const next = prev + dt;
          if (next >= duration) {
            if (loop) return 0;
            setPlaying(false);
            return duration;
          }
          return next;
        });
      }
      lastRef.current = ts;
      rafRef.current = requestAnimationFrame(tick);
    };
    rafRef.current = requestAnimationFrame(tick);
    return () => { if (rafRef.current) cancelAnimationFrame(rafRef.current); };
  }, [playing, duration, loop]);

  const pct = duration > 0 ? (time / duration) * 100 : 0;
  const fmt = (s) => {
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    const ms = Math.floor((s % 1) * 10);
    return `${m}:${sec.toString().padStart(2, '0')}.${ms}`;
  };

  const handleScrub = (e) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    setTime(clamp(x, 0, 1) * duration);
  };

  const handleKeyDown = React.useCallback((e) => {
    if (e.code === 'Space') { e.preventDefault(); setPlaying((p) => !p); }
    if (e.code === 'ArrowLeft') setTime((t) => clamp(t - 0.5, 0, duration));
    if (e.code === 'ArrowRight') setTime((t) => clamp(t + 0.5, 0, duration));
    if (e.code === 'Home') { setTime(0); setPlaying(false); }
    if (e.code === 'End') { setTime(duration); setPlaying(false); }
  }, [duration]);

  React.useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  const CTRL_H = 48;

  return (
    <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', background: '#000' }}>
      {/* Viewport */}
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{
          width, height, position: 'relative', transformOrigin: 'center center',
          background: background || '#000',
          aspectRatio: `${width}/${height}`,
          maxWidth: '100%', maxHeight: '100%',
        }}>
          <TimeContext.Provider value={time}>
            {children}
          </TimeContext.Provider>
        </div>
      </div>

      {/* Transport controls */}
      <div style={{
        height: CTRL_H, background: '#111114', borderTop: '1px solid #222',
        display: 'flex', alignItems: 'center', padding: '0 16px', gap: 14,
        fontFamily: "'JetBrains Mono', monospace", fontSize: 12, color: '#888',
        userSelect: 'none', flexShrink: 0,
      }}>
        {/* Play/Pause */}
        <button onClick={() => { if (time >= duration) setTime(0); setPlaying((p) => !p); }} style={{
          background: 'none', border: 'none', color: '#ccc', cursor: 'pointer',
          fontSize: 18, padding: '2px 6px', lineHeight: 1,
        }}>
          {playing ? '⏸' : '▶'}
        </button>

        {/* Time */}
        <span style={{ minWidth: 80, textAlign: 'center', color: '#aaa' }}>
          {fmt(time)} / {fmt(duration)}
        </span>

        {/* Scrub bar */}
        <div
          onClick={handleScrub}
          onMouseDown={(e) => {
            handleScrub(e);
            const move = (ev) => handleScrub(ev);
            const up = () => { window.removeEventListener('mousemove', move); window.removeEventListener('mouseup', up); };
            window.addEventListener('mousemove', move);
            window.addEventListener('mouseup', up);
          }}
          style={{
            flex: 1, height: 6, background: '#2a2a2e', borderRadius: 3,
            cursor: 'pointer', position: 'relative',
          }}
        >
          <div style={{
            width: `${pct}%`, height: '100%', background: '#2dd4bf',
            borderRadius: 3, transition: playing ? 'none' : 'width 0.1s',
          }} />
          <div style={{
            position: 'absolute', top: -5, left: `${pct}%`, transform: 'translateX(-50%)',
            width: 14, height: 14, borderRadius: '50%', background: '#2dd4bf',
            border: '2px solid #111114', boxShadow: '0 0 6px rgba(45,212,191,0.4)',
          }} />
        </div>

        {/* Speed (not functional, just display) */}
        <span style={{ color: '#555', fontSize: 11 }}>1×</span>
      </div>
    </div>
  );
}
