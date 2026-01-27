import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';
import { MossTexture, BambooStalks, WaterRipples } from './ZenTextures';

interface SectionDividerProps {
  variant?: 'stones' | 'ripple' | 'moss';
}

export default function SectionDivider({ variant = 'stones' }: SectionDividerProps) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"]
  });

  const x1 = useTransform(scrollYProgress, [0, 1], ["-10%", "10%"]);
  const x2 = useTransform(scrollYProgress, [0, 1], ["10%", "-10%"]);
  const x3 = useTransform(scrollYProgress, [0, 1], ["-5%", "5%"]);

  if (variant === 'stones') {
    return (
      <div ref={ref} className="relative h-32 overflow-hidden">
        <div className="absolute inset-0 flex items-center justify-center gap-8">
          <motion.div style={{ x: x1 }}>
            <Stone className="w-16 h-10 text-stone-300" />
          </motion.div>
          <motion.div style={{ x: x2 }}>
            <Stone className="w-24 h-14 text-stone-400" />
          </motion.div>
          <motion.div style={{ x: x3 }}>
            <Stone className="w-12 h-8 text-stone-300" />
          </motion.div>
        </div>
        {/* Raked sand lines */}
        <svg className="absolute inset-0 w-full h-full opacity-20" preserveAspectRatio="none">
          <defs>
            <pattern id="divider-rake" width="100" height="20" patternUnits="userSpaceOnUse">
              <path d="M0 10 Q50 5 100 10" fill="none" stroke="currentColor" strokeWidth="0.5" className="text-stone-400" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#divider-rake)" />
        </svg>
      </div>
    );
  }

  if (variant === 'ripple') {
    return (
      <div ref={ref} className="relative h-24 flex items-center justify-center overflow-hidden">
        <WaterRipples />
        <motion.div
          className="relative z-10"
          initial={{ opacity: 0.5 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
        >
          {[1, 2, 3].map((i) => (
            <motion.div
              key={i}
              className="absolute rounded-full border border-stone-300/60"
              style={{
                width: 20 + i * 30,
                height: 20 + i * 30,
                top: '50%',
                left: '50%',
                x: '-50%',
                y: '-50%',
              }}
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.4, 0.1, 0.4],
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                delay: i * 0.5,
              }}
            />
          ))}
          <div className="w-3 h-3 rounded-full bg-stone-400 relative z-20" />
        </motion.div>
      </div>
    );
  }

  if (variant === 'moss') {
    return (
      <div ref={ref} className="relative h-16 overflow-hidden">
        <MossTexture />
        <div className="absolute inset-0 flex items-center justify-center gap-4">
          <div className="w-32 h-4 rounded-full bg-bamboo-300/25 blur-md" />
          <div className="w-48 h-6 rounded-full bg-bamboo-400/35 blur-lg" />
          <div className="w-24 h-3 rounded-full bg-bamboo-300/25 blur-md" />
        </div>
      </div>
    );
  }

  return null;
}

function Stone({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 100 60" className={className} fill="currentColor">
      <ellipse cx="50" cy="40" rx="40" ry="18" opacity="0.3" />
      <path d="M15 30 Q25 12 50 10 Q75 12 85 30 Q80 48 50 50 Q20 48 15 30Z" />
    </svg>
  );
}
