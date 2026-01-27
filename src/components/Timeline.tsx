import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

interface TimelineEntry {
  company: string;
  role: string;
  period: string;
  description: string;
  highlight?: string;
}

const timeline: TimelineEntry[] = [
  {
    company: "Linzumi",
    role: "Founder & CEO",
    period: "Nov 2025 — Present",
    description: "Building clarity at scale. Helping organizations cut through complexity with AI-powered tools for decision making and communication.",
    highlight: "Clarity at Scale"
  },
  {
    company: "OpenAI",
    role: "Member of Technical Staff",
    period: "Sep 2023 — Sep 2025",
    description: "Post-training & Alignment team. Working on making AI systems more helpful, harmless, and honest through human feedback and novel training techniques."
  },
  {
    company: "Netlify",
    role: "Principal Architect",
    period: "Nov 2021 — Aug 2023",
    description: "Shaped the future of web infrastructure. Led architectural initiatives for the Jamstack ecosystem and developer experience."
  },
  {
    company: "OneGraph",
    role: "Founder",
    period: "May 2018 — Nov 2021",
    description: "Built a unified GraphQL gateway connecting dozens of APIs. Acquired by Netlify. Made complex integrations feel simple."
  },
  {
    company: "Earlier",
    role: "Founder & Engineer",
    period: "2012 — 2018",
    description: "PayGarden — Gift card platform. Bushido (YC S13) — Developer tools. Sauce Labs — Cross-browser testing infrastructure.",
  }
];

export default function Timeline() {
  return (
    <section id="journey" className="py-32 px-6 relative">
      {/* Section header */}
      <div className="max-w-6xl mx-auto mb-20">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.8 }}
          className="text-center"
        >
          <span className="text-moss-600 text-sm tracking-[0.3em] uppercase mb-4 block">
            The Path
          </span>
          <h2 className="text-4xl md:text-6xl font-serif text-stone-800 mb-6">
            A Journey in Building
          </h2>
          <p className="text-stone-600 text-lg max-w-2xl mx-auto">
            From early startups to the frontier of AI, each step has been about 
            making complex things accessible.
          </p>
        </motion.div>
      </div>

      {/* Timeline */}
      <div className="max-w-4xl mx-auto relative">
        {/* Center line */}
        <div className="absolute left-1/2 top-0 bottom-0 w-px bg-gradient-to-b from-transparent via-stone-300 to-transparent hidden md:block" />

        {timeline.map((entry, index) => (
          <TimelineItem key={entry.company} entry={entry} index={index} />
        ))}
      </div>
    </section>
  );
}

function TimelineItem({ entry, index }: { entry: TimelineEntry; index: number }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });
  const isEven = index % 2 === 0;

  return (
    <motion.div
      ref={ref}
      className={`relative flex items-center mb-16 md:mb-24 ${
        isEven ? 'md:flex-row' : 'md:flex-row-reverse'
      }`}
      initial={{ opacity: 0, x: isEven ? -50 : 50 }}
      animate={isInView ? { opacity: 1, x: 0 } : {}}
      transition={{ duration: 0.8, delay: 0.2 }}
    >
      {/* Content card */}
      <div className={`w-full md:w-1/2 ${isEven ? 'md:pr-12 md:text-right' : 'md:pl-12'}`}>
        <div className="timeline-item bg-white/60 backdrop-blur-sm rounded-2xl p-8 shadow-lg shadow-stone-200/50 border border-sand-200">
          {entry.highlight && (
            <span className="inline-block px-3 py-1 bg-moss-100 text-moss-700 text-xs tracking-wider uppercase rounded-full mb-4">
              {entry.highlight}
            </span>
          )}
          <h3 className="text-2xl font-serif text-stone-800 mb-1">{entry.company}</h3>
          <p className="text-warmth font-medium mb-2">{entry.role}</p>
          <p className="text-stone-500 text-sm mb-4">{entry.period}</p>
          <p className="text-stone-600 leading-relaxed">{entry.description}</p>
        </div>
      </div>

      {/* Center dot */}
      <div className="hidden md:flex absolute left-1/2 -translate-x-1/2 items-center justify-center">
        <motion.div
          className="w-4 h-4 rounded-full bg-stone-400 border-4 border-sand-50"
          initial={{ scale: 0 }}
          animate={isInView ? { scale: 1 } : {}}
          transition={{ duration: 0.4, delay: 0.4 }}
        />
        {/* Ripple effect */}
        <motion.div
          className="absolute w-8 h-8 rounded-full border border-stone-300"
          initial={{ scale: 0.5, opacity: 0 }}
          animate={isInView ? { scale: 1.5, opacity: [0, 0.5, 0] } : {}}
          transition={{ duration: 1, delay: 0.5 }}
        />
      </div>

      {/* Empty space for alternating layout */}
      <div className="hidden md:block w-1/2" />
    </motion.div>
  );
}
