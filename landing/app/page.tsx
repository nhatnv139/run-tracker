import { Nav } from "@/components/nav";
import { Hero } from "@/components/hero";
import { USP } from "@/components/usp";
import { Features } from "@/components/features";
import { Compare } from "@/components/compare";
import { Pricing } from "@/components/pricing";
import { FAQ } from "@/components/faq";
import { Waitlist } from "@/components/waitlist";
import { Footer } from "@/components/footer";

export default function HomePage() {
  return (
    <>
      <Nav />
      <main>
        <Hero />
        <USP />
        <Features />
        <Compare />
        <Pricing />
        <FAQ />
        <Waitlist />
      </main>
      <Footer />
    </>
  );
}
