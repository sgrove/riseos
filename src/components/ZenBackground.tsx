import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';

export default function ZenBackground() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll();
  
  const y1 = useTransform(scrollYProgress, [0, 1], ['0%', '30%']);
  const y2 = useTransform(scrollYProgress, [0, 1], ['0%', '20%']);
  const y3 = useTransform(scrollYProgress, [0, 1], ['0%', '40%']);

  return (
    <div ref={ref} className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
      {/* Base gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-sand-100 via-sand-50 to-stone-100" />
      
      {/* Raked sand pattern - full page */}
      <svg className="absolute inset-0 w-full h-full opacity-[0.15]" preserveAspectRatio="none">
        <defs>
          <pattern id="zen-rake-full" width="120" height="24" patternUnits="userSpaceOnUse">
            <path 
              d="M0 12 Q30 8 60 12 Q90 16 120 12" 
              fill="none" 
              stroke="currentColor" 
              strokeWidth="0.8" 
              className="text-stone-500" 
            />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#zen-rake-full)" />
      </svg>

      {/* Floating stones with parallax */}
      <motion.div 
        className="absolute top-[10%] left-[8%]"
        style={{ y: y1 }}
      >
        <ZenStone className="w-40 h-28 text-stone-300/60" />
      </motion.div>
      
      <motion.div 
        className="absolute top-[30%] right-[5%]"
        style={{ y: y2 }}
      >
        <ZenStone className="w-56 h-36 text-stone-400/50" />
      </motion.div>
      
      <motion.div 
        className="absolute top-[60%] left-[3%]"
        style={{ y: y3 }}
      >
        <ZenStone className="w-32 h-20 text-stone-300/40" />
      </motion.div>

      <motion.div 
        className="absolute top-[80%] right-[15%]"
        style={{ y: y1 }}
      >
        <ZenStone className="w-24 h-16 text-stone-400/30" />
      </motion.div>

      {/* Moss patches */}
      <motion.div 
        className="absolute top-[25%] left-[15%] w-48 h-24 rounded-full bg-moss-300/15 blur-3xl"
        style={{ y: y2 }}
      />
      <motion.div 
        className="absolute top-[55%] right-[10%] w-64 h-32 rounded-full bg-moss-400/10 blur-3xl"
        style={{ y: y3 }}
      />
      <motion.div 
        className="absolute top-[85%] left-[20%] w-40 h-20 rounded-full bg-moss-300/12 blur-2xl"
        style={{ y: y1 }}
      />

      {/* Subtle mist overlay */}
      <div className="absolute inset-0 bg-gradient-to-t from-sand-50/80 via-transparent to-sand-100/50" />
    </div>
  );
}

function ZenStone({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 140 90" className={className} fill="currentColor">
      {/* Shadow */}
      <ellipse cx="70" cy="75" rx="55" ry="12" opacity="0.25" />
      {/* Stone body */}
      <path d="M20 50 Q25 20 70 15 Q115 20 120 50 Q115 75 70 78 Q25 75 20 50Z" />
      {/* Highlight */}
      <ellipse cx="55" cy="35" rx="20" ry="10" opacity="0.15" fill="white" />
    </svg>
  );
}
