# GEO Audit Report: SitTall - Fix Your Posture

**Audit Date:** April 13, 2026
**URL:** https://www.sittall.app
**Business Type:** SaaS (Free macOS App)
**Pages Analyzed:** 21 (8 in sitemap, 13 additional blog articles discovered)

---

## Executive Summary

**Overall GEO Score: 40/100 (Poor)**

SitTall - Fix Your Posture has solid technical foundations — static HTML, open crawler access, and clean schema implementation — but is critically undermined by near-zero external brand presence and weak content authority signals. The site launched approximately one week ago with 16 blog articles published within 2-3 days, no individual author attribution, no external citations, and no presence on any platform that AI models use for entity recognition (Reddit, YouTube, Product Hunt, Wikipedia). Until SitTall - Fix Your Posture builds an external footprint, it will remain invisible to AI search engines regardless of on-site optimization.

### Score Breakdown

| Category | Score | Weight | Weighted Score |
|---|---|---|---|
| AI Citability | 52/100 | 25% | 13.0 |
| Brand Authority | 2/100 | 20% | 0.4 |
| Content E-E-A-T | 31/100 | 20% | 6.2 |
| Technical GEO | 76/100 | 15% | 11.4 |
| Schema & Structured Data | 34/100 | 10% | 3.4 |
| Platform Optimization | 38/100 | 10% | 3.8 |
| **Overall GEO Score** | | | **38.2 → 40/100** |

---

## Critical Issues (Fix Immediately)

### 1. Zero External Brand Presence (Brand Authority: 2/100)
SitTall - Fix Your Posture has no mentions on Reddit, YouTube, Product Hunt, LinkedIn, Wikipedia, Wikidata, G2, Capterra, AlternativeTo, or any tech press outlet. AI models construct entity knowledge from cross-platform corroboration. A brand that exists only on its own domain is unverified and will not be surfaced in AI responses. Competitors like Posture Pal have Reddit threads, 9to5Mac coverage, and Product Hunt launches — giving them the AI visibility SitTall - Fix Your Posture lacks.

**Fix:** Launch on Product Hunt. Post authentic "I built this" threads on r/macapps, r/airpods, r/posture. Pitch to 9to5Mac, MacObserver, Cult of Mac. Create a LinkedIn company page. Create a Wikidata entry for SitTall - Fix Your Posture.

### 2. No Individual Author Attribution (E-E-A-T: 5/25 Expertise)
Every article is attributed to "SitTall - Fix Your Posture" as an organization. No named author, no credentials, no bio, no linked professional profile. For health-adjacent content (posture advice, biomechanical claims), this is a significant E-E-A-T deficit.

**Fix:** Add individual author bylines to all blog content. Create an About page with founder identity, background, and why you built SitTall - Fix Your Posture. Link to LinkedIn or other verifiable profiles.

### 3. Undisclosed Self-Promotion in Comparison Article
"Best Posture Reminder Apps for Mac in 2026" features SitTall - Fix Your Posture prominently without disclosing that the article is published by SitTall - Fix Your Posture. This is a trust violation that both Google quality raters and AI systems will penalize.

**Fix:** Add disclosure at the top: "Disclosure: SitTall - Fix Your Posture is our product. We've included competitors to provide a fair comparison."

### 4. Uncited Health Claims (E-E-A-T: 12/25 Trustworthiness)
The biomechanical claim that forward head posture adds "10 lbs per inch" is presented without citation (source: Hansraj, 2014, Surgical Technology International). The "7 Posture Tips" article claims to be "evidence-based" while citing zero evidence. For a health-adjacent product, unsourced medical claims are a YMYL trust liability.

**Fix:** Add citations to all health-related claims. Link to Apple's CMHeadphoneMotionManager docs, PubMed research, and ergonomics guidelines (OSHA, Mayo Clinic).

---

## High Priority Issues

### 5. Incomplete Sitemap (13 Blog Articles Missing)
The sitemap lists only 8 URLs while 16 blog articles exist. 13 articles are undiscoverable by crawlers relying on the sitemap. This is the single most impactful technical fix.

**Fix:** Update `sitemap.xml` to include all pages. Differentiate `<lastmod>` dates per page.

### 6. No llms.txt File
No `llms.txt` exists at the domain root. This emerging protocol tells AI systems what the site is about and where to find key content.

**Fix:** Create `llms.txt` with site summary, key page links, and content hierarchy. Create `llms-full.txt` with comprehensive plain-text content for direct AI ingestion.

### 7. Missing Open Graph & Twitter Card Tags on Blog
All 16 blog articles and the blog index are missing `og:title`, `og:description`, `og:image`, `og:url`, `twitter:card`, etc. When these articles are shared or previewed by AI systems, they have no structured preview.

**Fix:** Add OG and Twitter Card meta tags to all pages. Create a branded social share image (1200x630px).

### 8. Bulk Content Publication Pattern (AI Content Risk)
16 blog posts published within 2-3 days (April 6-8, 2026) is a strong indicator of bulk AI-generated content. Google's March 2024 spam policy explicitly targets "scaled content abuse." The content reads as well-structured but contains no original data, no personal experience, and no unique insights.

**Fix:** Stagger future publication (1-2 posts/week). Add original data only SitTall - Fix Your Posture can provide (e.g., anonymized posture statistics, detection accuracy testing results). Add real implementation details to technical articles.

### 9. No About Page
No About page exists. Visitors and AI quality systems have no way to evaluate who is behind the product or content.

**Fix:** Create an About page with founder/team info, mission, and credentials.

### 10. Missing Organization Schema with sameAs
No standalone Organization schema exists. No `sameAs` links to any external profile. AI models cannot build an entity graph for SitTall - Fix Your Posture.

**Fix:** Add Organization schema to homepage with `sameAs` linking to App Store listing, GitHub, social profiles, and Wikidata entry (once created).

---

## Medium Priority Issues

### 11. Incomplete FAQPage Schema
Support page has 8 Q&A pairs but only 4 are in FAQPage schema. Expanding coverage increases the surface area for AI citation on long-tail queries.

### 12. Article Schema Missing Key Properties
Blog Article schemas lack `dateModified`, structured `author` (as Person with url/sameAs), `publisher.logo`, `image`, and `speakable` properties. These are required for Article rich result eligibility and AI voice response selection.

### 13. No RSS Feed Auto-Discovery
`feed.xml` exists in `/blog/` but is not referenced in `<head>` via `<link rel="alternate">`. AI aggregation tools cannot auto-discover the feed.

### 14. Missing Meta Descriptions
Support page, blog index (confirmed present on re-check), privacy page, and terms page are missing meta descriptions. AI systems use these as content summaries for retrieval.

### 15. No YouTube Presence
No videos demonstrating SitTall - Fix Your Posture. YouTube is Gemini's strongest supplementary content source and appears in Google AI Overview video carousels.

### 16. Security Headers Incomplete
GitHub Pages provides HTTPS and HSTS but missing CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, and Permissions-Policy. Consider Cloudflare (free tier) as a proxy.

---

## Low Priority Issues

### 17. No IndexNow Protocol Support
No IndexNow API key for Bing. Without this, Bing (and by extension Bing Copilot) may have delayed indexing.

### 18. Missing Image Heights on Homepage
Screenshot images have `width` but no `height`, potentially causing minor CLS.

### 19. No Mobile Navigation Toggle
Nav links hidden below 900px with no hamburger menu. Footer provides alternative navigation.

### 20. No `speakable` Property on Any Schema
No content marked as suitable for AI assistant voice responses.

### 21. No AlternativeTo Listing
Missing from software comparison platform frequently cited by AI models.

---

## Category Deep Dives

### AI Citability (52/100)

**Strongest content blocks for AI citation:**
- Homepage hero: "SitTall - Fix Your Posture monitors your posture silently from the menu bar, using the motion sensors already in your AirPods. No camera. No subscription. No excuses." (Score: 68)
- Real-time detection feature: "Continuously tracks forward head drift, side tilt, and gradual posture collapse using your AirPods' 6-axis motion sensors — 60 times per second." (Score: 65)
- Privacy guarantee: "All motion analysis runs locally on your Mac. No camera used, no account required, no data ever leaves your device." (Score: 62)
- FAQ answers: Well-structured Q&A format with direct answers (Score: 55-58)

**Weakest areas:**
- Marketing headings ("Everything you need. Nothing you don't.") — unparseable by AI
- Blog articles average ~45 citability score due to zero external citations and no named authors
- No content block contains a cited statistic or research reference
- Trust metrics ("0 Camera access") are visual fragments, not natural language

### Brand Authority (2/100)

| Platform | Status |
|---|---|
| Wikipedia | Absent |
| Wikidata | Absent |
| Reddit | Absent |
| YouTube | Absent |
| LinkedIn | Absent |
| Product Hunt | Absent |
| G2/Capterra/AlternativeTo | Absent |
| Tech Press | Absent |
| Mac App Store | Present (only external presence) |

This is the most critical deficit. SitTall - Fix Your Posture exists in an information vacuum. Competitors (Posture Pal, PodPosture, Dorso) have community discussions, tech press coverage, and Product Hunt launches that make them visible to AI.

### Content E-E-A-T (31/100)

| Dimension | Score | Key Issue |
|---|---|---|
| Experience | 6/25 | No case studies, no user stories, no before/after data, no "I built this" narrative |
| Expertise | 5/25 | No individual authors, no credentials, technical vocabulary used but unsourced |
| Authoritativeness | 5/25 | No About page, no external recognition, new site with no publication history |
| Trustworthiness | 12/25 | Good privacy policy and terms, but uncited health claims and undisclosed self-promotion |

**AI Content Assessment:** Likely AI-generated with light editing. 16 posts in 72 hours, no original data, no authorial voice, perfect structure with thin substance, keyword-targeting patterns across variations of "posture" + "Mac" + "AirPods."

### Technical GEO (76/100)

**Strengths:**
- Static HTML (100% server-rendered, ideal for AI crawlers)
- All AI crawlers allowed (GPTBot, ClaudeBot, PerplexityBot, etc.)
- Clean URL structure, consistent canonicals
- Minimal JavaScript (24 lines, cosmetic only)
- Good Core Web Vitals indicators (inline CSS, font preloading, lazy loading)
- Mobile-responsive with fluid typography

**Weaknesses:**
- Incomplete sitemap (8 of 21 pages)
- No llms.txt
- Missing OG/Twitter tags on blog content
- Missing security headers (GitHub Pages limitation)
- No RSS auto-discovery

### Schema & Structured Data (34/100)

**Present:** SoftwareApplication (homepage), FAQPage (support, 4/8 questions), Article + BreadcrumbList (blog posts)

**Missing:**
- Organization schema with sameAs (0 cross-platform links)
- Person schema for authors
- dateModified on Articles
- publisher.logo on Articles
- speakable property
- WebSite schema
- BreadcrumbList on non-blog pages

### Platform Optimization (38/100)

| Platform | Score | Key Gap |
|---|---|---|
| Google AI Overviews | 48 | No question-format headings, no comparison tables, no external citations |
| Bing Copilot | 37 | No IndexNow, no Bing Webmaster verification, no LinkedIn presence |
| Perplexity AI | 35 | Zero Reddit/community presence, no publication timestamps, no original data |
| Google Gemini | 32 | No YouTube, no Knowledge Graph signals, no topical cluster architecture |
| ChatGPT Web Search | 30 | No Wikidata entity, no author attribution, no external trust signals |

---

## Quick Wins (Implement This Week)

1. **Create a Wikidata entry** for SitTall - Fix Your Posture with structured properties (developer, platform, license, website, App Store ID). Takes 30 minutes, impacts all AI platforms.
2. **Update sitemap.xml** to include all 21 pages with accurate lastmod dates. 15-minute fix with immediate crawler impact.
3. **Create llms.txt** at domain root with site summary and key page links. 20-minute task.
4. **Add conflict-of-interest disclosure** to the comparison article. 2-minute fix.
5. **Add OG/Twitter meta tags** to all blog articles and blog index. Template-based, ~1 hour.

## 30-Day Action Plan

### Week 1: Foundation Fixes
- [ ] Update sitemap.xml to include all pages
- [ ] Create llms.txt and llms-full.txt
- [ ] Add OG and Twitter Card tags to all pages
- [ ] Add disclosure to comparison article
- [ ] Create Wikidata entry for SitTall - Fix Your Posture
- [ ] Add Organization schema with sameAs to homepage
- [ ] Fix Article schemas (add dateModified, publisher.logo, image)
- [ ] Complete FAQPage schema (all 8 questions)

### Week 2: Identity & Authority
- [ ] Create About page with founder info, photo, background
- [ ] Add individual author bylines and bios to all blog articles
- [ ] Create LinkedIn company page
- [ ] Register on AlternativeTo
- [ ] Add external citations to all blog articles (Apple docs, PubMed, Mayo Clinic)
- [ ] Add RSS auto-discovery link to blog pages

### Week 3: External Presence
- [ ] Launch on Product Hunt
- [ ] Post in r/macapps, r/airpods, r/posture (authentic "I built this" posts)
- [ ] Pitch to 9to5Mac, MacObserver, Cult of Mac
- [ ] Create YouTube channel with product demo video
- [ ] Implement IndexNow for Bing

### Week 4: Content Quality
- [ ] Restructure top 5 blog headings into question format with 40-60 word answer targets
- [ ] Add original data content (posture statistics from app usage, detection accuracy results)
- [ ] Build topical cluster architecture with pillar page
- [ ] Add Person schema to all articles with author sameAs
- [ ] Add speakable property to Article schemas
- [ ] Publish editorial standards page
- [ ] Consider Cloudflare proxy for security headers

---

## Appendix: Pages Analyzed

| URL | Title | Key GEO Issues |
|---|---|---|
| / | SitTall - Fix Your Posture – AirPods Posture Reminder for Mac | Missing Organization schema, no OG tags on blog |
| /privacy.html | Privacy Policy – SitTall - Fix Your Posture | No schema, no meta description |
| /terms.html | Terms & Conditions – SitTall - Fix Your Posture | No schema, no meta description |
| /support.html | Support – SitTall - Fix Your Posture | Incomplete FAQ schema (4/8), no meta description |
| /blog/ | Blog – SitTall - Fix Your Posture | No schema, no OG tags, not all articles in sitemap |
| /blog/airpods-posture-tracking.html | How AirPods Motion Sensors Can Monitor Your Posture | No OG tags, no author, no citations |
| /blog/best-posture-reminder-mac.html | Best Posture Reminder Apps for Mac in 2026 | No OG tags, no disclosure, no citations |
| /blog/posture-tips-desk-workers.html | 7 Posture Tips for Mac Users Who Sit All Day | No OG tags, no author, "evidence-based" uncited |
| /blog/posture-self-test.html | How to Tell If Your Posture Is Bad | Not in sitemap |
| /blog/how-long-sit-before-break.html | How Long Should You Sit Before Taking a Break | Not in sitemap |
| /blog/standing-desk-vs-sitting-desk.html | Standing Desk vs Sitting Desk | Not in sitemap |
| /blog/macbook-vs-external-monitor-neck.html | MacBook vs External Monitor | Not in sitemap |
| /blog/best-desk-accessories-posture-2026.html | Best Desk Accessories for Posture 2026 | Not in sitemap |
| /blog/developers-fix-poor-posture.html | How Developers Can Fix Poor Posture | Not in sitemap |
| /blog/what-happens-spine-slouching.html | What Happens to Your Spine When You Slouch | Not in sitemap |
| /blog/laptop-posture-vs-desktop-posture.html | Laptop Posture vs Desktop Posture | Not in sitemap |
| /blog/forward-head-posture-mac.html | How to Fix Forward Head Posture | Not in sitemap |
| /blog/tech-neck-cost-computer.html | Tech Neck: The Hidden Cost | Not in sitemap |
| /blog/mac-desk-ergonomics-setup.html | Ultimate Mac Desk Ergonomics Guide | Not in sitemap |
| /blog/camera-vs-sensor-posture-tracking.html | Camera vs Sensor Posture Tracking | Not in sitemap |
| /blog/neck-pain-after-mac.html | Why Your Neck Hurts After Using a Mac | Not in sitemap |

---

*Report generated by GEO Audit Tool | April 13, 2026*
