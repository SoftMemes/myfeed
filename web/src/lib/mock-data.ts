import type { FeedItem, MockChannel } from "./domain";

export const MOCK_CHANNELS: MockChannel[] = [
  {
    id: "ch_techforge",
    name: "TechForge",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=TechForge",
    description: "Deep dives into software engineering, tooling, and developer productivity.",
    videoTitles: [
      "Why Rust is taking over systems programming",
      "Building a compiler from scratch in 2 hours",
      "The real cost of technical debt",
      "10 terminal tools every developer should know",
      "How to read a flamegraph",
      "Database indexing explained visually",
      "Stop using ORMs for this one thing",
      "My entire dev setup in 2026",
      "Writing fast Python with zero dependencies",
      "The architecture behind large-scale microservices",
      "How git really works under the hood",
      "WebAssembly is not what you think",
      "Profiling Node.js applications in production",
      "When to use a message queue",
      "Designing APIs that don't break",
    ],
  },
  {
    id: "ch_pixelcraft",
    name: "PixelCraft Studio",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=PixelCraft",
    description: "UI design, animation, and the craft of building great visual experiences.",
    videoTitles: [
      "Designing a design system from nothing",
      "The science of readable typography",
      "How I animate interfaces in Figma",
      "Color theory for developers",
      "Building accessible UI without thinking about it",
      "Motion design principles that actually matter",
      "Dark mode: doing it right",
      "The 5 layout patterns every UI needs",
      "Icon design from sketch to SVG",
      "Why whitespace is your best design tool",
      "Responsive design in 2026",
      "Glassmorphism — tasteful or overdone?",
      "Designing for ADHD users",
      "The anatomy of a great loading state",
      "Design handoff without the pain",
    ],
  },
  {
    id: "ch_cloudnative",
    name: "Cloud Native Weekly",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=CloudNative",
    description: "Kubernetes, containers, observability, and platform engineering at scale.",
    videoTitles: [
      "Kubernetes networking for beginners",
      "How to not get a huge cloud bill",
      "Observability vs monitoring — what's the difference",
      "Writing good Terraform from day one",
      "Service mesh: do you actually need it",
      "Container security you're probably missing",
      "The GitOps workflow that actually works",
      "When serverless makes sense",
      "Database migrations with zero downtime",
      "Multi-region deployment without the chaos",
      "FinOps for small teams",
      "Debugging pods in production",
      "The platform engineering playbook",
      "Building internal developer portals",
      "SLOs that developers actually care about",
    ],
  },
  {
    id: "ch_aihorizon",
    name: "AI Horizon",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=AIHorizon",
    description: "Practical machine learning, LLMs, and AI engineering for builders.",
    videoTitles: [
      "Fine-tuning LLMs without going broke",
      "RAG pipelines that actually work in production",
      "Embeddings explained from scratch",
      "The hidden cost of AI inference",
      "Evaluating LLM outputs — a practical guide",
      "Building agents that don't hallucinate",
      "Vector databases: which one should you use",
      "Prompt engineering is dead, long live prompting",
      "How diffusion models work under the hood",
      "AI in production: lessons from 1 year",
      "Structured output from LLMs — techniques compared",
      "The state of open-source models in 2026",
      "Building a personal AI second brain",
      "Why context windows matter more than model size",
      "Multimodal AI for developers",
    ],
  },
  {
    id: "ch_opensourcediary",
    name: "Open Source Diary",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=OpenSourceDiary",
    description: "Building and maintaining open source software — the real experience.",
    videoTitles: [
      "Growing a side project to 10,000 stars",
      "How I handle bug reports without burning out",
      "Documentation that developers love",
      "Dealing with toxic contributors",
      "Versioning and release management for OSS",
      "GitHub Actions workflows for maintainers",
      "The economics of open source in 2026",
      "Writing a good README",
      "Monorepo tools: turborepo vs nx vs bazel",
      "How I built a dev community around my project",
      "Responding to CVEs as an OSS maintainer",
      "The funding models that work",
      "Going from hobby project to production-grade",
      "Why I sunset my open source library",
      "Contributing to projects that intimidate you",
    ],
  },
  {
    id: "ch_systemslab",
    name: "Systems Lab",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=SystemsLab",
    description: "Low-level systems, performance engineering, and OS internals.",
    videoTitles: [
      "How CPU caches actually work",
      "Writing a syscall from scratch",
      "Memory allocators — a visual tour",
      "Epoll and async I/O demystified",
      "The anatomy of a context switch",
      "Writing a network stack in C",
      "SIMD for the rest of us",
      "How lock-free data structures work",
      "Tracing Linux programs with eBPF",
      "Why benchmarks lie and how to fix them",
      "Page faults, TLBs, and virtual memory",
      "Profiling with perf on Linux",
      "How Linux boots — step by step",
      "Signals and processes in Unix",
      "The cost of a function call",
    ],
  },
  {
    id: "ch_prodeng",
    name: "Product Engineer",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=ProductEngineer",
    description: "Full-stack indie building and shipping products solo.",
    videoTitles: [
      "I built a SaaS in a weekend — here's what happened",
      "The stack I use to ship fast",
      "Pricing your product: lessons from 3 launches",
      "How to find your first 100 users",
      "The landing page that actually converts",
      "Building a waitlist that doesn't die",
      "SEO for developers who hate SEO",
      "Payments, taxes, and other boring things",
      "My postmortem on a failed launch",
      "Cold email outreach that doesn't suck",
      "Running a one-person software business",
      "Product Hunt launch checklist",
      "When to build vs buy as a solo founder",
      "Feedback loops that improve your product",
      "Making money while you sleep with an API",
    ],
  },
  {
    id: "ch_codeaesthetics",
    name: "Code Aesthetics",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=CodeAesthetics",
    description: "Code quality, refactoring, and the philosophy of clean software.",
    videoTitles: [
      "The refactor that changed how I write code",
      "Naming things is hard — here's a system",
      "When abstraction hurts more than it helps",
      "SOLID principles are overrated",
      "Code reviews that make people better",
      "The pragmatic case for functional programming",
      "Why I stopped writing clever code",
      "Testing philosophy — beyond coverage numbers",
      "Dependency injection without a framework",
      "Immutability for skeptics",
      "The hidden complexity of simple conditionals",
      "Error handling is a design decision",
      "Why I write more comments now, not fewer",
      "Code that explains itself",
      "The architecture of small programs",
    ],
  },
  {
    id: "ch_webperf",
    name: "Web Performance Lab",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=WebPerfLab",
    description: "Making websites fast — deep dives into core web vitals, loading, rendering.",
    videoTitles: [
      "CLS: the most misunderstood core web vital",
      "How the browser rendering pipeline works",
      "Image optimization in 2026",
      "JavaScript bundle analysis from scratch",
      "HTTP/3 and what it means for your site",
      "The real cost of third-party scripts",
      "Font loading strategies that work",
      "Critical CSS: is it worth it",
      "Service workers for performance",
      "Edge computing — where it actually helps",
      "React performance without memo hell",
      "The network waterfall you should care about",
      "Compression: gzip vs brotli vs zstd",
      "Pre-fetching and pre-loading done right",
      "Real user monitoring vs synthetic",
    ],
  },
  {
    id: "ch_dataeng",
    name: "Data Engineering Today",
    avatarUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=DataEngToday",
    description: "Data pipelines, warehousing, and the modern data stack.",
    videoTitles: [
      "dbt from zero to production",
      "Why your data warehouse is a mess",
      "Stream processing vs batch — when to use each",
      "The modern data stack in 2026",
      "Building reliable data pipelines",
      "Column-oriented databases explained",
      "Iceberg tables and the open lakehouse",
      "Orchestration with Airflow vs Dagster",
      "Data contracts — what they are and why you need them",
      "The metrics layer debate",
      "How Kafka really works",
      "Slowly changing dimensions — a visual guide",
      "Schema evolution without breaking things",
      "Reverse ETL and the operational data stack",
      "Cost optimisation in your data warehouse",
    ],
  },
];

function randomBetween(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function hoursAgo(hours: number): string {
  return new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();
}

export function generateFeedItems(
  subscriptionId: string,
  sourceId: string,
  channel: MockChannel,
  count: number,
  maxAgeHours = 14 * 24
): FeedItem[] {
  const titles = [...channel.videoTitles].sort(() => Math.random() - 0.5);
  const items: FeedItem[] = [];

  for (let i = 0; i < Math.min(count, titles.length); i++) {
    const hoursBack = randomBetween(1, maxAgeHours);
    const seed = encodeURIComponent(titles[i]).slice(0, 20);
    items.push({
      id: `${subscriptionId}_${Date.now()}_${i}_${Math.random().toString(36).slice(2, 7)}`,
      subscriptionId,
      sourceId,
      title: titles[i],
      description: `A video from ${channel.name}: ${titles[i]}`,
      thumbnailUrl: `https://picsum.photos/seed/${seed}/640/360`,
      url: `https://www.youtube.com/watch?v=mock_${subscriptionId}_${i}`,
      publishedAt: hoursAgo(hoursBack),
      contentType: "video",
    });
  }

  return items;
}

export function getAllMockChannels(): MockChannel[] {
  return MOCK_CHANNELS;
}

export function searchMockChannels(query: string): MockChannel[] {
  const q = query.toLowerCase().trim();
  if (!q) return MOCK_CHANNELS;
  return MOCK_CHANNELS.filter(
    (c) =>
      c.name.toLowerCase().includes(q) ||
      c.description.toLowerCase().includes(q)
  );
}
