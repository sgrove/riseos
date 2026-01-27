import { motion } from 'framer-motion';

const socialLinks = [
  { name: 'Twitter', href: 'https://twitter.com/sgrove', icon: TwitterIcon },
  { name: 'GitHub', href: 'https://github.com/sgrove', icon: GitHubIcon },
  { name: 'LinkedIn', href: 'https://linkedin.com/in/seangrove', icon: LinkedInIcon },
];

export default function Footer() {
  return (
    <footer id="contact" className="py-20 px-6 bg-stone-900 text-sand-100 relative overflow-hidden">
      {/* Zen pattern overlay */}
      <div className="absolute inset-0 opacity-5">
        <svg className="w-full h-full" preserveAspectRatio="none">
          <defs>
            <pattern id="footer-lines" width="80" height="30" patternUnits="userSpaceOnUse">
              <path d="M0 15 Q40 5 80 15" fill="none" stroke="currentColor" strokeWidth="1" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#footer-lines)" />
        </svg>
      </div>

      <div className="max-w-4xl mx-auto relative z-10">
        <motion.div
          className="text-center"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <h2 className="text-3xl md:text-5xl font-serif mb-6">
            Let's build something
            <span className="block text-warmth-light">together</span>
          </h2>
          
          <p className="text-sand-400 text-lg mb-8 max-w-xl mx-auto">
            Always interested in conversations about AI, developer tools, 
            and the future of how we build software.
          </p>

          <a 
            href="mailto:sean@riseos.com"
            className="inline-flex items-center gap-2 px-8 py-4 bg-sand-50 text-stone-800 rounded-full hover:bg-white transition-colors font-medium text-lg group"
          >
            sean@riseos.com
            <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 5l7 7m0 0l-7 7m7-7H3" />
            </svg>
          </a>

          {/* Social links */}
          <div className="flex justify-center gap-6 mt-12">
            {socialLinks.map((link) => (
              <motion.a
                key={link.name}
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
                className="w-12 h-12 rounded-full bg-stone-800 flex items-center justify-center text-sand-400 hover:text-sand-100 hover:bg-stone-700 transition-colors"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.95 }}
              >
                <link.icon className="w-5 h-5" />
                <span className="sr-only">{link.name}</span>
              </motion.a>
            ))}
          </div>

          {/* Decorative stones */}
          <div className="flex justify-center gap-3 mt-16 mb-8 opacity-30">
            <div className="w-2 h-2 rounded-full bg-sand-400" />
            <div className="w-3 h-3 rounded-full bg-sand-500" />
            <div className="w-2 h-2 rounded-full bg-sand-400" />
          </div>

          <p className="text-sand-600 text-sm">
            © {new Date().getFullYear()} Sean Grove. Built with intention.
          </p>
        </motion.div>
      </div>
    </footer>
  );
}

function TwitterIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="currentColor" viewBox="0 0 24 24">
      <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
    </svg>
  );
}

function GitHubIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="currentColor" viewBox="0 0 24 24">
      <path fillRule="evenodd" clipRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
    </svg>
  );
}

function LinkedInIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="currentColor" viewBox="0 0 24 24">
      <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
    </svg>
  );
}
