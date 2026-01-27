import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

export default function About() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  const values = [
    { 
      icon: "○", 
      title: "Clarity", 
      description: "Complex problems deserve simple solutions. I believe in cutting through noise to find signal." 
    },
    { 
      icon: "△", 
      title: "Craftsmanship", 
      description: "Details matter. From code architecture to user experience, quality compounds over time." 
    },
    { 
      icon: "□", 
      title: "Levity", 
      description: "The best work happens when we don't take ourselves too seriously. Joy is a feature." 
    }
  ];

  return (
    <section id="about" className="py-32 px-6 relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {/* Moss texture background */}
        <div 
          className="absolute inset-0 opacity-[0.03]"
          style={{
            backgroundImage: `url('/images/moss-texture.svg')`,
            backgroundSize: '400px 400px',
            backgroundRepeat: 'repeat'
          }}
        />
        
        <svg className="absolute -right-32 top-1/4 w-96 h-96 text-moss-200/30" viewBox="0 0 200 200">
          <circle cx="100" cy="100" r="80" fill="none" stroke="currentColor" strokeWidth="0.5" />
          <circle cx="100" cy="100" r="60" fill="none" stroke="currentColor" strokeWidth="0.5" />
          <circle cx="100" cy="100" r="40" fill="none" stroke="currentColor" strokeWidth="0.5" />
        </svg>
        
        {/* Bamboo stalks decoration */}
        <div
          className="absolute right-0 top-0 h-full w-1/3 opacity-[0.02]"
          style={{
            backgroundImage: `url('/images/bamboo-texture.svg')`,
            backgroundSize: 'contain',
            backgroundRepeat: 'no-repeat',
            backgroundPosition: 'right center'
          }}
        />
      </div>

      <div className="max-w-6xl mx-auto">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Text content */}
          <motion.div
            ref={ref}
            initial={{ opacity: 0, x: -40 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8 }}
          >
            <span className="text-moss-600 text-sm tracking-[0.3em] uppercase mb-4 block">
              About
            </span>
            <h2 className="text-4xl md:text-5xl font-serif text-stone-800 mb-8 leading-tight">
              Building at the intersection of 
              <span className="text-warmth"> craft </span> 
              and 
              <span className="text-moss-600"> technology</span>
            </h2>
            
            <div className="space-y-6 text-stone-600 text-lg leading-relaxed">
              <p>
                I've spent the last decade starting companies and shipping products — 
                from developer tools to AI systems. The through-line has always been 
                the same: making powerful technology accessible.
              </p>
              <p>
                Currently building <span className="font-medium text-stone-800">Linzumi</span>, 
                where we're tackling one of the hardest problems in organizations: 
                achieving clarity at scale.
              </p>
              <p>
                When I'm not coding, you'll find me exploring the intersection of 
                design and engineering, or explaining complex systems to anyone 
                who'll listen.
              </p>
            </div>
          </motion.div>

          {/* Values */}
          <motion.div
            className="space-y-6"
            initial={{ opacity: 0, x: 40 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            {values.map((value, index) => (
              <motion.div
                key={value.title}
                className="zen-card bg-white/60 backdrop-blur-sm rounded-2xl p-6 border border-sand-200"
                initial={{ opacity: 0, y: 20 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 0.6, delay: 0.3 + index * 0.1 }}
              >
                <div className="flex items-start gap-4">
                  <span className="text-3xl text-moss-500 font-light">{value.icon}</span>
                  <div>
                    <h3 className="text-xl font-serif text-stone-800 mb-2">{value.title}</h3>
                    <p className="text-stone-600">{value.description}</p>
                  </div>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
}
