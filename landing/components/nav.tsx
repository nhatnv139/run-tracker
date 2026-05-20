"use client";

import * as React from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import { cn } from "@/lib/utils";

export function Nav() {
  const [scrolled, setScrolled] = React.useState(false);

  React.useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={cn(
        "fixed top-0 inset-x-0 z-50 transition-all duration-300",
        scrolled
          ? "backdrop-blur-xl bg-[var(--background)]/70 border-b border-[var(--border)]"
          : "bg-transparent"
      )}
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        <Link href="#top" className="flex items-center gap-2 group" aria-label="RunVie trang chủ">
          <span className="relative inline-flex h-9 w-9 items-center justify-center rounded-2xl bg-[linear-gradient(135deg,#FF5A36,#7B5CFF_60%,#00D4A8)] text-white font-black text-base shadow-md shadow-[var(--color-coral)]/30 transition-transform group-hover:scale-105">
            R
          </span>
          <span className="font-extrabold text-lg tracking-tight">
            Run<span className="text-gradient-aurora">Vie</span>
          </span>
        </Link>

        <nav className="hidden md:flex items-center gap-7 text-sm font-medium">
          <a href="#features" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">
            Tính năng
          </a>
          <a href="#compare" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">
            So sánh
          </a>
          <a href="#pricing" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">
            Giá
          </a>
          <a href="#faq" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">
            FAQ
          </a>
        </nav>

        <div className="flex items-center gap-2">
          <ThemeToggle />
          <Button asChild variant="aurora" size="sm" className="hidden sm:inline-flex">
            <a href="#waitlist">Tham gia chờ</a>
          </Button>
          <Button asChild variant="default" size="sm" className="sm:hidden">
            <a href="#waitlist">Đăng ký</a>
          </Button>
        </div>
      </div>
    </header>
  );
}
