import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';
import { talks, type Talk, type CoverageItem } from '../data/talks';

export default function Talks() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  const featuredTalk = talks.find(t => t.featured);
  const otherTalks = talks.filter(t => !t.featured);

  return (
    <section id="talks" className="py-32 px-6 bg-gradient-to-b from-sand-50 via-stone-100/30 to-sand-50">
      <div className="max-w-6xl mx-auto">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.8 }}
          className="text-center mb-20"
        >
          <span className="text-moss-600 text-sm tracking-[0.3em] uppercase mb-4 block">
            Speaking
          </span>
          <h2 className="text-4xl md:text-6xl font-serif text-stone-800 mb-6">
            Ideas Worth Sharing
          </h2>
          <p className="text-stone-600 text-lg max-w-2xl mx-auto">
            Conference talks, podcasts, and conversations about building the future.
          </p>
        </motion.div>

        {/* Featured talk */}
        {featuredTalk && (
          <motion.div
            ref={ref}
            className="mb-16"
            initial={{ opacity: 0, y: 40 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.8 }}
          >
            <div className="relative bg-gradient-to-br from-stone-800 to-stone-900 rounded-3xl p-8 md:p-12 text-sand-50 overflow-hidden">
              {/* Decorative elements */}
              <div className="absolute top-0 right-0 w-64 h-64 bg-moss-600/10 rounded-full blur-3xl" />
              <div className="absolute bottom-0 left-0 w-48 h-48 bg-warmth/10 rounded-full blur-3xl" />
              
              <div className="relative z-10">
                <div className="flex flex-wrap items-center gap-3 mb-6">
                  <span className="px-4 py-1.5 bg-warmth/90 text-white text-sm font-medium rounded-full">
                    Featured
                  </span>
                  {featuredTalk.views && (
                    <span className="px-4 py-1.5 bg-white/10 text-sand-200 text-sm rounded-full">
                      {featuredTalk.views}
                    </span>
                  )}
                </div>
                
                <h3 className="text-3xl md:text-5xl font-serif mb-4">
                  {featuredTalk.title}
                </h3>
                <p className="text-sand-300 mb-2">{featuredTalk.event} · {featuredTalk.year}</p>
                <p className="text-sand-400 text-lg max-w-2xl mb-8 leading-relaxed">
                  {featuredTalk.description}
                </p>
                
                {/* Action buttons */}
                <div className="flex flex-wrap gap-4 mb-10">
                  {featuredTalk.videoUrl && (
                    <a 
                      href={featuredTalk.videoUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 px-6 py-3 bg-sand-50 text-stone-800 rounded-full hover:bg-white transition-colors font-medium group"
                    >
                      <PlayIcon className="w-5 h-5" />
                      Watch Talk
                      <ArrowIcon className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                    </a>
                  )}
                  {featuredTalk.slidesUrl && (
                    <a 
                      href={featuredTalk.slidesUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 px-6 py-3 border border-sand-400 text-sand-200 rounded-full hover:border-sand-200 hover:text-white transition-colors font-medium"
                    >
                      <SlidesIcon className="w-5 h-5" />
                      View Slides
                    </a>
                  )}
                </div>

                {/* Coverage section */}
                {featuredTalk.coverage && featuredTalk.coverage.length > 0 && (
                  <div className="border-t border-sand-700/50 pt-8">
                    <h4 className="text-sand-400 text-sm tracking-wider uppercase mb-4 flex items-center gap-2">
                      <NewsIcon className="w-4 h-4" />
                      Coverage & Discussion
                    </h4>
                    <div className="grid sm:grid-cols-2 gap-3">
                      {featuredTalk.coverage.map((item, index) => (
                        <CoverageLink key={index} item={item} dark />
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Play button decoration */}
              <div className="absolute right-8 bottom-8 md:right-16 md:bottom-16 opacity-10">
                <svg className="w-32 h-32" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z" />
                </svg>
              </div>
            </div>
          </motion.div>
        )}

        {/* Other talks */}
        <div className="space-y-8">
          {otherTalks.map((talk, index) => (
            <motion.div
              key={talk.title}
              className="zen-card bg-white/60 backdrop-blur-sm rounded-2xl p-8 border border-sand-200"
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
            >
              <div className="flex flex-col lg:flex-row lg:items-start gap-6">
                {/* Main content */}
                <div className="flex-1">
                  <p className="text-stone-500 text-sm mb-2">{talk.event} · {talk.year}</p>
                  <h3 className="text-2xl font-serif text-stone-800 mb-3">
                    {talk.title}
                  </h3>
                  <p className="text-stone-600 leading-relaxed mb-4">
                    {talk.description}
                  </p>
                  
                  {/* Links */}
                  <div className="flex flex-wrap gap-3">
                    {talk.videoUrl && (
                      <a 
                        href={talk.videoUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-2 text-sm text-warmth hover:text-warmth-light transition-colors font-medium"
                      >
                        <PlayIcon className="w-4 h-4" />
                        Watch Video
                      </a>
                    )}
                    {talk.slidesUrl && (
                      <a 
                        href={talk.slidesUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-2 text-sm text-stone-600 hover:text-stone-800 transition-colors font-medium"
                      >
                        <SlidesIcon className="w-4 h-4" />
                        Slides
                      </a>
                    )}
                  </div>
                </div>

                {/* Coverage sidebar */}
                {talk.coverage && talk.coverage.length > 0 && (
                  <div className="lg:w-72 lg:border-l lg:border-sand-200 lg:pl-6">
                    <h4 className="text-stone-500 text-xs tracking-wider uppercase mb-3 flex items-center gap-2">
                      <NewsIcon className="w-3 h-3" />
                      Coverage
                    </h4>
                    <div className="space-y-2">
                      {talk.coverage.map((item, i) => (
                        <CoverageLink key={i} item={item} />
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </motion.div>
          ))}
        </div>

        {/* More talks CTA */}
        <motion.div
          className="text-center mt-12"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
        >
          <a 
            href="/talks"
            className="inline-flex items-center gap-2 text-stone-600 hover:text-stone-800 transition-colors"
          >
            View all talks
            <ArrowIcon className="w-4 h-4" />
          </a>
        </motion.div>
      </div>
    </section>
  );
}

function CoverageLink({ item, dark = false }: { item: CoverageItem; dark?: boolean }) {
  const typeIcons = {
    article: ArticleIcon,
    thread: ThreadIcon,
    podcast: PodcastIcon,
    summary: SummaryIcon
  };
  const Icon = typeIcons[item.type];
  
  return (
    <a
      href={item.url}
      target="_blank"
      rel="noopener noreferrer"
      className={`block p-3 rounded-lg transition-colors group ${
        dark 
          ? 'bg-white/5 hover:bg-white/10' 
          : 'bg-sand-100/50 hover:bg-sand-200/50'
      }`}
    >
      <div className="flex items-start gap-2">
        <Icon className={`w-4 h-4 mt-0.5 flex-shrink-0 ${dark ? 'text-sand-500' : 'text-stone-400'}`} />
        <div className="min-w-0">
          <p className={`text-sm font-medium truncate group-hover:text-warmth transition-colors ${
            dark ? 'text-sand-200' : 'text-stone-700'
          }`}>
            {item.title}
          </p>
          <p className={`text-xs ${dark ? 'text-sand-500' : 'text-stone-500'}`}>
            {item.source}
          </p>
        </div>
      </div>
    </a>
  );
}

// Icons
function PlayIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="currentColor" viewBox="0 0 24 24">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}

function ArrowIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
    </svg>
  );
}

function SlidesIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2" />
    </svg>
  );
}

function NewsIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
    </svg>
  );
}

function ArticleIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
    </svg>
  );
}

function ThreadIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="currentColor" viewBox="0 0 24 24">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
  );
}

function PodcastIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
    </svg>
  );
}

function SummaryIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 10h16M4 14h16M4 18h16" />
    </svg>
  );
}
