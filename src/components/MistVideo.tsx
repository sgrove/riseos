import React from 'react';

export default function MistVideo() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {/* Animated SVG mist overlay */}
      <object
        type="image/svg+xml"
        data="/videos/hero-mist-animation.svg"
        className="absolute inset-0 w-full h-full opacity-40"
        style={{ pointerEvents: 'none' }}
      >
        {/* Fallback to CSS animation if SVG doesn't load */}
        <div className="absolute inset-0">
          {/* Base mist layer */}
          <div 
            className="absolute inset-0 opacity-30"
            style={{
              background: `
                radial-gradient(circle at 20% 70%, rgba(255, 255, 255, 0.4) 0%, transparent 50%),
                radial-gradient(circle at 80% 30%, rgba(245, 245, 244, 0.3) 0%, transparent 60%),
                radial-gradient(circle at 40% 20%, rgba(255, 255, 255, 0.2) 0%, transparent 40%)
              `,
              animation: 'mistFloat1 20s infinite ease-in-out',
            }}
          />
          
          {/* Secondary mist layer */}
          <div 
            className="absolute inset-0 opacity-20"
            style={{
              background: `
                radial-gradient(circle at 60% 80%, rgba(250, 250, 249, 0.5) 0%, transparent 55%),
                radial-gradient(circle at 10% 40%, rgba(255, 255, 255, 0.3) 0%, transparent 45%),
                radial-gradient(circle at 90% 60%, rgba(245, 245, 244, 0.4) 0%, transparent 50%)
              `,
              animation: 'mistFloat2 25s infinite ease-in-out reverse',
            }}
          />
          
          {/* Tertiary mist layer */}
          <div 
            className="absolute inset-0 opacity-15"
            style={{
              background: `
                radial-gradient(circle at 30% 50%, rgba(255, 255, 255, 0.6) 0%, transparent 60%),
                radial-gradient(circle at 70% 10%, rgba(250, 250, 249, 0.4) 0%, transparent 50%)
              `,
              animation: 'mistFloat3 30s infinite ease-in-out',
            }}
          />
        </div>
      </object>
      
      {/* CSS animations for fallback mist */}
      <style jsx>{`
        @keyframes mistFloat1 {
          0%, 100% { transform: translateX(-10px) translateY(0px) scale(1); }
          25% { transform: translateX(15px) translateY(-5px) scale(1.05); }
          50% { transform: translateX(-5px) translateY(-10px) scale(0.95); }
          75% { transform: translateX(20px) translateY(-3px) scale(1.02); }
        }
        
        @keyframes mistFloat2 {
          0%, 100% { transform: translateX(5px) translateY(-5px) scale(0.98); }
          30% { transform: translateX(-15px) translateY(5px) scale(1.03); }
          60% { transform: translateX(10px) translateY(-8px) scale(0.97); }
          80% { transform: translateX(-8px) translateY(3px) scale(1.01); }
        }
        
        @keyframes mistFloat3 {
          0%, 100% { transform: translateX(0px) translateY(-3px) scale(1.01); }
          40% { transform: translateX(12px) translateY(8px) scale(0.96); }
          70% { transform: translateX(-12px) translateY(-6px) scale(1.04); }
        }
      `}</style>
    </div>
  );
}