import * as React from "react";
import Link from "next/link";

export function Footer() {
  return (
    <footer className="relative border-t border-[var(--border)] bg-[var(--muted-bg)]/30">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-8">
          <div>
            <Link href="#top" className="flex items-center gap-2">
              <span className="inline-flex h-8 w-8 items-center justify-center rounded-xl bg-[linear-gradient(135deg,#FF5A36,#7B5CFF_60%,#00D4A8)] text-white font-black text-sm shadow-md shadow-[var(--color-coral)]/30">
                R
              </span>
              <span className="font-extrabold text-lg tracking-tight">
                Run<span className="text-gradient-aurora">Vie</span>
              </span>
            </Link>
            <p className="mt-3 text-sm text-[var(--muted)] leading-relaxed max-w-xs">
              App chạy bộ và đếm bước AI tiếng Việt. Sắp ra mắt 2026.
            </p>
          </div>

          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider mb-3">Sản phẩm</h4>
            <ul className="space-y-2 text-sm">
              <li><a href="#features" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">Tính năng</a></li>
              <li><a href="#compare" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">So sánh</a></li>
              <li><a href="#pricing" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">Giá</a></li>
              <li><a href="#faq" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">FAQ</a></li>
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider mb-3">Pháp lý</h4>
            <ul className="space-y-2 text-sm">
              <li><Link href="/privacy" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">Chính sách bảo mật</Link></li>
              <li><Link href="/terms" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">Điều khoản sử dụng</Link></li>
              <li><a href="mailto:hello@runvie.vn" className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors">hello@runvie.vn</a></li>
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-bold uppercase tracking-wider mb-3">Kết nối</h4>
            <ul className="space-y-2 text-sm">
              <li>
                <a
                  href="https://zalo.me/runvie"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 text-[var(--muted)] hover:text-[var(--foreground)] transition-colors"
                >
                  <SocialIcon type="zalo" />
                  Zalo OA
                </a>
              </li>
              <li>
                <a
                  href="https://www.tiktok.com/@runvie"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 text-[var(--muted)] hover:text-[var(--foreground)] transition-colors"
                >
                  <SocialIcon type="tiktok" />
                  TikTok
                </a>
              </li>
              <li>
                <a
                  href="https://www.instagram.com/runvie"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 text-[var(--muted)] hover:text-[var(--foreground)] transition-colors"
                >
                  <SocialIcon type="instagram" />
                  Instagram
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-6 border-t border-[var(--border)] flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-[var(--muted)]">
          <p>(C) 2026 RunVie. Made with care in Vietnam.</p>
          <p>v0.1.0 - Pre-launch</p>
        </div>
      </div>
    </footer>
  );
}

function SocialIcon({ type }: { type: "zalo" | "tiktok" | "instagram" }) {
  if (type === "zalo")
    return (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
        <path d="M12 2C6.48 2 2 5.94 2 10.8c0 2.46 1.16 4.67 3.04 6.27L4 22l5.3-2.04c.86.2 1.77.3 2.7.3 5.52 0 10-3.94 10-8.8S17.52 2 12 2z" />
      </svg>
    );
  if (type === "tiktok")
    return (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
        <path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-5.2 1.74 2.89 2.89 0 0 1 2.31-4.64c.3 0 .59.04.87.13V9.4a6.84 6.84 0 0 0-1-.07A6.33 6.33 0 0 0 5.8 20.1a6.34 6.34 0 0 0 10.86-4.43V9.01a8.16 8.16 0 0 0 4.77 1.52v-3.4a4.85 4.85 0 0 1-1.84-.44z" />
      </svg>
    );
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
      <rect x="3" y="3" width="18" height="18" rx="5" ry="5" />
      <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
      <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
    </svg>
  );
}
