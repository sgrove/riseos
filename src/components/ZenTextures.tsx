import React from 'react';

export function ZenGardenBackground() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {/* Base gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-sand-100 via-sand-50 to-pottery-50" />
      
      {/* Zen garden SVG background */}
      <div 
        className="absolute inset-0 opacity-60"
        style={{
          backgroundImage: `url('/images/hero-zen-garden.svg')`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat'
        }}
      />
      
      {/* Raked sand texture overlay */}
      <div 
        className="absolute inset-0 opacity-20"
        style={{
          backgroundImage: `
            repeating-linear-gradient(
              90deg,
              transparent 0px,
              transparent 15px,
              rgba(120, 113, 108, 0.1) 15px,
              rgba(120, 113, 108, 0.1) 17px
            ),
            repeating-linear-gradient(
              45deg,
              transparent 0px,
              transparent 20px,
              rgba(168, 162, 158, 0.05) 20px,
              rgba(168, 162, 158, 0.05) 22px
            )
          `,
        }}
      />
      
      {/* Mist effect */}
      <div className="absolute inset-0 bg-gradient-to-t from-transparent via-white/5 to-white/20 opacity-60" />
      
      {/* Floating particles for zen atmosphere */}
      <div className="absolute top-1/4 left-1/4 w-2 h-2 bg-stone-300/30 rounded-full animate-float" />
      <div className="absolute top-1/2 right-1/3 w-1 h-1 bg-bamboo-400/40 rounded-full animate-float" style={{ animationDelay: '2s' }} />
      <div className="absolute bottom-1/3 left-1/3 w-1.5 h-1.5 bg-brown-300/35 rounded-full animate-float" style={{ animationDelay: '4s' }} />
    </div>
  );
}

export function MossTexture() {
  return (
    <div 
      className="absolute inset-0 opacity-30"
      style={{
        background: `
          radial-gradient(circle at 20% 30%, rgba(90, 114, 71, 0.2) 0%, transparent 50%),
          radial-gradient(circle at 80% 60%, rgba(107, 138, 79, 0.15) 0%, transparent 40%),
          radial-gradient(circle at 40% 80%, rgba(74, 94, 59, 0.25) 0%, transparent 35%)
        `,
      }}
    />
  );
}

export function BambooStalks() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {/* Bamboo segments as vertical lines */}
      <div 
        className="absolute right-8 top-0 bottom-0 w-3 opacity-20"
        style={{
          background: `
            linear-gradient(to bottom, 
              transparent 0%,
              rgba(90, 114, 71, 0.6) 10%,
              rgba(107, 138, 79, 0.4) 50%,
              rgba(90, 114, 71, 0.6) 90%,
              transparent 100%
            )
          `,
        }}
      />
      <div 
        className="absolute right-16 top-8 bottom-8 w-2 opacity-15"
        style={{
          background: `
            linear-gradient(to bottom, 
              transparent 0%,
              rgba(107, 138, 79, 0.5) 15%,
              rgba(90, 114, 71, 0.3) 45%,
              rgba(107, 138, 79, 0.5) 85%,
              transparent 100%
            )
          `,
        }}
      />
    </div>
  );
}

export function WaterRipples() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {/* Water ripples SVG background */}
      <div 
        className="absolute inset-0 opacity-20"
        style={{
          backgroundImage: `url('/images/water-ripples.svg')`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat'
        }}
      />
      
      {/* Animated circles overlay */}
      <svg className="absolute bottom-16 left-16 w-32 h-32 text-stone-300/20" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="10" fill="none" stroke="currentColor" strokeWidth="0.5">
          <animate attributeName="r" values="10;30;10" dur="4s" repeatCount="indefinite" />
          <animate attributeName="opacity" values="1;0.2;1" dur="4s" repeatCount="indefinite" />
        </circle>
        <circle cx="50" cy="50" r="20" fill="none" stroke="currentColor" strokeWidth="0.5">
          <animate attributeName="r" values="20;40;20" dur="4s" repeatCount="indefinite" begin="1s" />
          <animate attributeName="opacity" values="1;0.2;1" dur="4s" repeatCount="indefinite" begin="1s" />
        </circle>
        <circle cx="50" cy="50" r="30" fill="none" stroke="currentColor" strokeWidth="0.5">
          <animate attributeName="r" values="30;50;30" dur="4s" repeatCount="indefinite" begin="2s" />
          <animate attributeName="opacity" values="1;0.2;1" dur="4s" repeatCount="indefinite" begin="2s" />
        </circle>
      </svg>
      
      {/* Additional smaller ripples */}
      <svg className="absolute top-1/4 right-1/4 w-20 h-20 text-bamboo-300/15" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="15" fill="none" stroke="currentColor" strokeWidth="0.8">
          <animate attributeName="r" values="15;25;15" dur="3s" repeatCount="indefinite" />
          <animate attributeName="opacity" values="0.8;0.3;0.8" dur="3s" repeatCount="indefinite" />
        </circle>
      </svg>
    </div>
  );
}