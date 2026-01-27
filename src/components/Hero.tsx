import { motion } from 'framer-motion';
import { ZenGardenBackground } from './ZenTextures';

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Static background */}
      <div className="absolute inset-0 z-0">
        <ZenGardenBackground />
        
        {/* Static decorative stones */}
        <div className="absolute top-1/4 left-1/4">
          <Stone className="w-24 h-16 text-stone-400 opacity-60" />
        </div>
        <div className="absolute top-1/3 right-1/4">
          <Stone className="w-32 h-20 text-stone-500 opacity-50" />
        </div>
        <div className="absolute bottom-1/4 left-1/3">
          <Stone className="w-20 h-14 text-stone-300 opacity-70" />
        </div>

        {/* Soft accent blurs */}
        <div className="absolute top-1/3 left-1/6 w-16 h-8 rounded-full bg-bamboo-300/30 blur-xl" />
        <div className="absolute bottom-1/3 right-1/5 w-24 h-12 rounded-full bg-moss-400/20 blur-2xl" />
      </div>

      {/* Content */}
      <div className="relative z-10 text-center px-6 max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.1 }}
        >
          <h1 className="text-6xl md:text-8xl lg:text-9xl font-serif text-stone-800 mb-6 tracking-tight">
            Sean Grove
          </h1>
        </motion.div>
        
        <motion.p
          className="text-xl md:text-2xl text-stone-600 font-light mb-8 tracking-wide"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.3 }}
        >
          Founder and hacker, on most days
        </motion.p>

        <motion.div
          className="flex flex-col sm:flex-row gap-4 justify-center items-center"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
        >
          <a 
            href="#journey" 
            className="px-8 py-3 bg-stone-800 text-sand-50 rounded-full hover:bg-stone-700 transition-colors duration-200 text-sm tracking-wider uppercase"
          >
            The Journey
          </a>
          <a 
            href="#talks" 
            className="px-8 py-3 border border-stone-400 text-stone-700 rounded-full hover:border-bamboo-600 hover:text-bamboo-700 transition-colors duration-200 text-sm tracking-wider uppercase"
          >
            Watch Talks
          </a>
        </motion.div>

        {/* Simple scroll indicator */}
        <div className="absolute bottom-12 left-1/2 -translate-x-1/2 text-stone-400">
          <svg className="w-6 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 40">
            <rect x="1" y="1" width="22" height="38" rx="11" strokeWidth="2" />
            <circle cx="12" cy="12" r="3" fill="currentColor" />
          </svg>
        </div>
      </div>

      {/* Bottom fade */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-sand-50 to-transparent z-20" />
    </section>
  );
}

function Stone({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 100 60" className={className} fill="currentColor">
      <ellipse cx="50" cy="35" rx="45" ry="22" opacity="0.3" />
      <path d="M10 30 Q20 10 50 8 Q80 10 90 30 Q85 50 50 52 Q15 50 10 30Z" />
    </svg>
  );
}
