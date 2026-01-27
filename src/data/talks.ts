export interface CoverageItem {
  title: string;
  source: string;
  url: string;
  type: 'article' | 'thread' | 'podcast' | 'summary';
}

export interface Talk {
  title: string;
  event: string;
  year: string | number;
  date?: string;
  location?: string;
  type?: string;
  description?: string;
  topic?: string;
  views?: string;
  videoUrl?: string;
  slidesUrl?: string;
  coverage?: CoverageItem[];
  featured?: boolean;
}

export const talks: Talk[] = [
  {
    title: "The New Code",
    event: "AI Engineer World's Fair",
    year: 2025,
    date: "June 2025",
    location: "San Francisco, California",
    type: "conference",
    description: "A provocative thesis that code is only 10-20% of a programmer's value—the rest is structured communication. Sean argues that specifications, not code, are the true source artifact we should be versioning and preserving, showing how OpenAI's model spec serves as both a trust anchor for humans and executable training material for AI alignment.",
    topic: "In an era where AI transforms software development, the most valuable skill isn't writing code - it's communicating intent. Explores specifications as executable blueprints.",
    views: "1M+ views",
    videoUrl: "https://www.youtube.com/watch?v=8rABwKRsec4",
    featured: true,
    coverage: [
      { title: "The Most Valuable Developer Skill in 2025? Writing Code Specifications", source: "Tessl Blog", url: "https://tessl.io/blog/the-most-valuable-developer-skill-in-2025-writing-code-specifications/", type: "article" },
      { title: "The New Code — Sean Grove (OpenAI)", source: "Son-U Paik on LinkedIn", url: "https://www.linkedin.com/posts/sonupaik_the-new-code-sean-grove-openai-activity-7350077335695474688-qj0k", type: "thread" },
      { title: "OpenAI's Sean Grove: Everything is a Spec", source: "YouTube Short", url: "https://www.youtube.com/shorts/hSdP5EiroQI", type: "summary" },
      { title: "Sean from OpenAI says specs are the new code", source: "@mattpocockuk on X", url: "https://x.com/mattpocockuk/status/2009964210667827249", type: "thread" },
      { title: "Incredible Talk. Must see for every dev", source: "@JonasSiebler on X", url: "https://x.com/JonasSiebler/status/1946480806009909546", type: "thread" },
      { title: "This entire keynote talk is worth watching", source: "@JoeChoiGreene on X", url: "https://x.com/JoeChoiGreene/status/1932537473550463201", type: "thread" },
      { title: "Integrated thought clarifier — great talk", source: "@elamadej on X", url: "https://x.com/elamadej/status/1951389903067160582", type: "thread" },
      { title: "앞으로의 십년은 개발자라면 문서를 통한 소통 능력을... (13K views, 97 likes)", source: "@jaeholee_dev on X", url: "https://x.com/jaeholee_dev/status/1949127592130629854", type: "thread" },
      { title: "Thought-provoking talk on communicating intent with precision", source: "@MatousRoskovec on X", url: "https://x.com/MatousRoskovec/status/1945032714102460757", type: "thread" },
      { title: "To learn more, check out this talk from Sean Grove", source: "@ArjunKalsy on X", url: "https://x.com/ArjunKalsy/status/1945468123760476563", type: "thread" },
      { title: "Skills scarcity is over. Coding is ending.", source: "@asystemarchitec on X", url: "https://x.com/asystemarchitec/status/1944482456054460898", type: "thread" }
    ]
  },
  {
    title: "AI is here. The future is brighter than you think",
    event: "Everything NYC (Sanity)",
    year: 2025,
    date: "2025",
    location: "New York City",
    type: "conference",
    description: "Sean explores how to harness the coming wave of AI-powered tokens as a new cognitive power source, drawing parallels to how humanity adapted to steam power by building infrastructure and reshaping problems. He demonstrates a specification-driven approach to AI development where humans become conductors of agent orchestras, expressing intent clearly enough that millions of agents can work autonomously while producing trustworthy, evidence-backed results.",
    topic: "How to harness AI-powered tokens as a new cognitive power source, using a specification-driven approach where humans become conductors of agent orchestras.",
    videoUrl: "https://www.youtube.com/watch?v=gnUxZA7Ew1E",
    coverage: [
      { title: "Everything NYC 2025 recap: A day of AI, Content & Creativity", source: "Sanity Blog", url: "https://www.sanity.io/blog/everything-nyc-2025-all-talks", type: "article" },
      { title: "Specifications are the new code — Sean Grove on the future of AI", source: "Sanity on LinkedIn", url: "https://www.linkedin.com/posts/sanity-io_%F0%9D%97%A6%F0%9D%97%BD%F0%9D%97%B2%F0%9D%97%B0%F0%9D%97%B6%F0%9D%97%B3%F0%9D%97%B6%F0%9D%97%B0%F0%9D%97%AE%F0%9D%98%81%F0%9D%97%B6%F0%9D%97%BC%F0%9D%97%BB%F0%9D%98%80-%F0%9D%97%AE%F0%9D%97%BF%F0%9D%97%B2-%F0%9D%98%81%F0%9D%97%B5-activity-7391856125656309760-71PC", type: "thread" },
      { title: "3 things I'm taking away from Sanity's Everything Conference", source: "Sanity on LinkedIn", url: "https://www.linkedin.com/posts/sanity-io_excellent-summary-of-our-developer-conference-activity-7379191328657707008-LZRp", type: "thread" }
    ]
  },
  {
    title: "Web Development in the Age of AI",
    event: "Reactathon",
    year: 2023,
    date: "May 2023",
    location: "Berkeley, California",
    type: "panel",
    description: "A panel discussion with swyx exploring how AI is transforming web development, from code generation to intelligent tooling. Discusses the practical implications of AI-powered development and what it means for the future of programming.",
    topic: "Panel discussion on AI's impact on web development with swyx.",
    videoUrl: "https://www.youtube.com/watch?v=35nC0AtdlJE"
  },
  {
    title: "Persisted Queries as Legos vs Clay",
    event: "GraphQL in Space",
    year: 2020,
    date: "October 2020",
    location: "YouTube",
    type: "conference",
    description: "This talk explores the tension between flexible GraphQL APIs (like moldable clay) and rigid REST endpoints (like megaliths), showing how persisted queries bridge this gap. Sean demonstrates how persisting queries at build time enables smaller requests, easier caching, rate limiting, and even embedding authentication—allowing developers to create safe, scoped 'serverless functions' from powerful APIs like GitHub and Spotify.",
    topic: "How persisted queries bridge the gap between flexible GraphQL APIs and rigid REST endpoints.",
    videoUrl: "https://www.youtube.com/watch?v=ngmiU3rPB14",
    coverage: [
      { title: "Persisted Queries as Legos vs Clay — GraphQL in Space Discussion", source: "Dgraph Forum", url: "https://discuss.dgraph.io/t/sean-grove-persisted-queries-as-legos-vs-clay-what-if-calling-your-graphql-api-were-as-simple-as-calling-a-serverless-function/10028", type: "thread" },
      { title: "What if we treat GraphQL Queries as the API definition?", source: "WunderGraph Blog", url: "https://wundergraph.com/blog/what_happens_if_we_treat_graphql_queries_as_the_api_definition", type: "article" }
    ]
  },
  {
    title: "The Secrets of Polymorphic Variants",
    event: "ReasonConf",
    year: 2019,
    date: "April 2019",
    location: "Vienna, Austria",
    type: "conference",
    description: "An exploration of structural typing in OCaml/Reason through polymorphic variants and objects. Sean demonstrates how to write more reusable functions that operate on structure rather than names—useful for JSON libraries, shared record fields, and summarizing large variant types—while cautioning about the trade-off of significantly worse error messages.",
    topic: "Polymorphic variants for composable libraries that don't depend on one-another.",
    videoUrl: "https://www.youtube.com/watch?v=TLDNsWXxhbo",
    coverage: [
      { title: "Polymorphic variants make way more sense now (jealous of the emacs setup)", source: "@_hagnerd on X", url: "https://x.com/_hagnerd/status/1126155903168909312", type: "thread" },
      { title: "🎙 Open Stage Video: The Secrets of Polymorphic Variants", source: "@reasonconf on X", url: "https://x.com/reasonconf/status/1126079303999836160", type: "thread" }
    ]
  },
  {
    title: "Making Magic with GraphQL Tooling",
    event: "GraphQL SF",
    year: 2019,
    date: "February 2020",
    location: "Reddit, SF",
    type: "meetup",
    description: "A demo-heavy showcase of GraphQL tooling innovations from OneGraph, including the GraphQL Explorer for intuitive API discovery, automatic code generation for React components, VS Code and Excel integrations, and techniques for schema-driven UI generation. Demonstrates how thoughtful developer tooling can dramatically lower the barrier to API adoption and empower both developers and non-programmers alike.",
    topic: "Schema explorers, code generators, doc systems, and special surprises.",
    videoUrl: "https://www.youtube.com/watch?v=HGqs7pV7c5s",
    coverage: [
      { title: "The Future of APIs, GraphQL, and Developer Tooling with Sean Grove", source: "React Round Up Podcast", url: "https://topenddevs.com/podcasts/react-round-up/episodes/rru-092-the-future-of-apis-graphql-and-developer-tooling-with-sean-grove", type: "podcast" },
      { title: "GraphQL Tooling, Today & Tomorrow", source: "apidays Conference", url: "https://www.youtube.com/watch?v=gAjQ1mg614o", type: "summary" },
      { title: "'tis a thing 'o beauty", source: "@sgrove on X", url: "https://x.com/sgrove/status/1232158339413360645", type: "thread" }
    ]
  },
  {
    title: "Building a Mailing List Unsubscribe App with OneGraph",
    event: "React Meetup SF",
    year: 2019,
    date: "April 2019",
    location: "Prismic, SF",
    type: "meetup",
    description: "A live coding demo building a mass email unsubscribe application using OneGraph's unified GraphQL API. Demonstrates how to connect to multiple services like Gmail and manage subscriptions through a single GraphQL endpoint.",
    topic: "Live coding a practical app using OneGraph's unified API.",
    videoUrl: "https://www.youtube.com/watch?v=rLq2zq1vxmA",
    coverage: [
      { title: "Sean Grove: OneGraph", source: "@atardadi on X", url: "https://x.com/atardadi/status/1114270988378091520", type: "thread" },
      { title: "Watch @sgrove build a mass-unsubscribe app with @onegraphio", source: "@vercel on X", url: "https://x.com/vercel/status/1117857149650681856", type: "thread" }
    ]
  },
  {
    title: "Having Your Cake and Eating It Too — GraphQL in Reason",
    event: "Øredev",
    year: 2018,
    date: "November 2018",
    location: "Malmö, Sweden",
    type: "conference",
    description: "Explores the challenges of using statically-typed languages like ReasonML with external APIs, where JSON parsing becomes tedious and error-prone. Demonstrates how GraphQL's built-in type system and introspection capabilities solve these problems by providing automatic type generation, guaranteed contracts between client and server, and eliminating the boilerplate code typically required for safe data conversion.",
    topic: "GraphQL's type-system enables safety-guarantees and tooling that'll make you swoon.",
    videoUrl: "https://www.youtube.com/watch?v=bdjvLiI5tzA"
  },
  {
    title: "Rust in the Browser for JavaScripters",
    event: "Øredev",
    year: 2018,
    date: "November 2018",
    location: "Malmö, Sweden",
    type: "conference",
    description: "An introduction to Rust and WebAssembly for JavaScript developers, exploring how Rust's type system, pattern matching, and memory safety can bring performance and correctness benefits to browser applications. The talk covers practical approaches to JavaScript-Rust interop, including shared memory techniques, and demonstrates real examples like a GameBoy emulator running in WebAssembly.",
    topic: "How JavaScripters can unlock high-performance concurrency and graphics thanks to Rust.",
    videoUrl: "https://www.youtube.com/watch?v=7JVucZFjOJs",
    coverage: [
      { title: "Sean Grove Speaker Profile", source: "Talks @ Confs", url: "https://talksatconfs.com/speakers/sean-grove", type: "article" }
    ]
  },
  {
    title: "The Age of Reason(ML)",
    event: "ReactiveConf",
    year: 2016,
    date: "November 2016",
    location: "Bratislava, Slovakia",
    type: "conference",
    description: "An energetic introduction to ReasonML, the new developer experience built on OCaml by the creators of React. Sean demonstrates how Reason's powerful type inference, exhaustive pattern matching, and helpful error messages act like a 'robotic pair programmer' that catches bugs at compile time and even auto-formats your code. The talk showcases Reason's impressive reach—from native OpenGL games to JavaScript via BuckleScript—making it a compelling choice for building reliable applications.",
    topic: "Full-stack apps in one language, from hypervisor unikernel to React clients.",
    videoUrl: "https://www.youtube.com/watch?v=8LCmLQ1-YqQ",
    coverage: [
      { title: "ReactiveConf 2016 — The Age of Reason(ML)", source: "cotalks.dev", url: "https://cotalks.dev/talks/reactive-conf-2016-sean-grove-the-age-of-reason-ml", type: "article" },
      { title: "The best React videos on the web", source: "Awesome React", url: "https://awesomereact.com/conferences", type: "article" },
      { title: "ReactiveConf 2016 Schedule", source: "ConfPad", url: "https://confpad.io/2016-10-27-reactiveconf-2016", type: "article" },
      { title: "This is why JavaScript rules the world", source: "Medium (StarLift)", url: "https://medium.com/starliftorg/this-is-why-javascript-rules-the-world-a4a9384f833b", type: "article" },
      { title: "react-conf-videos: List of React conference talks", source: "GitHub", url: "https://github.com/simonccarter/react-conf-videos", type: "article" },
      { title: "Watch @sgrove's #ReactiveConf talk 'The Age of ReasonML'", source: "@ReactiveConf on X", url: "https://x.com/ReactiveConf/status/807581066889859073", type: "thread" },
      { title: "totally deserves to take a look and share!", source: "@lex_fr on X", url: "https://x.com/lex_fr/status/805818912029229056", type: "thread" }
    ]
  }
];

// For homepage: just the key talks with full descriptions
export const homepageTalks = talks;

// Helper to get featured talk
export const featuredTalk = talks.find(t => t.featured);
