"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles, Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { PhoneMockup } from "@/components/phone-mockup";
import { submitWaitlist } from "@/lib/supabase";
import { toast } from "sonner";

export function Hero() {
  const [email, setEmail] = React.useState("");
  const [loading, setLoading] = React.useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!email || !/.+@.+\..+/.test(email)) {
      toast.error("Vui lòng nhập email hợp lệ");
      return;
    }
    setLoading(true);
    const res = await submitWaitlist({ email, user_type: "beginner", source: "hero" });
    setLoading(false);
    if (res.ok) {
      toast.success("Đã ghi nhận! Bạn sẽ là người biết đầu tiên khi RunVie ra mắt.");
      setEmail("");
    } else {
      toast.error("Có lỗi xảy ra, vui lòng thử lại.");
    }
  }

  return (
    <section
      id="top"
      className="relative pt-28 pb-20 sm:pt-36 sm:pb-28 overflow-hidden grain"
    >
      <div className="absolute inset-0 -z-10 bg-aurora pointer-events-none" />
      <div className="absolute -top-32 left-1/2 -translate-x-1/2 -z-10 h-[520px] w-[820px] rounded-full bg-[var(--color-coral)]/25 blur-3xl pointer-events-none" />

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, ease: "easeOut" }}
            className="flex flex-col items-start"
          >
            <Badge variant="lavender" className="mb-5">
              <Sparkles className="h-3 w-3" />
              Sắp ra mắt 2026
            </Badge>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight leading-[1.05] text-balance">
              Chạy bộ, đi bộ, đốt calo <br className="hidden sm:block" />
              cùng <span className="text-gradient-aurora">AI Coach</span> tiếng Việt
            </h1>

            <p className="mt-5 text-base sm:text-lg text-[var(--muted)] max-w-xl leading-relaxed text-balance">
              Đo GPS, đếm bước, đếm calo chính xác. Huấn luyện viên ảo nói tiếng Việt
              tự nhiên cổ vũ mỗi km. Đổi RunCoin lấy voucher Shopee, Grab, MoMo thật.
            </p>

            <form
              onSubmit={onSubmit}
              className="mt-7 flex flex-col sm:flex-row gap-3 w-full max-w-lg"
            >
              <label htmlFor="hero-email" className="sr-only">
                Email của bạn
              </label>
              <Input
                id="hero-email"
                type="email"
                placeholder="email@cua.ban"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="flex-1 h-12"
                autoComplete="email"
              />
              <Button
                type="submit"
                variant="aurora"
                size="lg"
                disabled={loading}
                className="shrink-0"
              >
                <Bell className="h-4 w-4" />
                {loading ? "Đang gửi..." : "Nhận thông báo đầu tiên"}
              </Button>
            </form>

            <div className="mt-5 flex items-center gap-4 text-xs text-[var(--muted)]">
              <span className="inline-flex items-center gap-1.5">
                <span className="inline-block h-2 w-2 rounded-full bg-[var(--color-mint)] animate-pulse" />
                1,247 người đang chờ
              </span>
              <span>Miễn phí - Không thư rác</span>
            </div>

            <div className="mt-8 flex items-center gap-6 opacity-80">
              <div className="text-xs text-[var(--muted)]">
                <span className="block font-bold text-[var(--foreground)] text-base">iOS</span>
                17.0+
              </div>
              <div className="h-8 w-px bg-[var(--border)]" />
              <div className="text-xs text-[var(--muted)]">
                <span className="block font-bold text-[var(--foreground)] text-base">Android</span>
                13.0+
              </div>
              <div className="h-8 w-px bg-[var(--border)]" />
              <div className="text-xs text-[var(--muted)]">
                <span className="block font-bold text-[var(--foreground)] text-base">Zalo</span>
                Mini App
              </div>
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, scale: 0.92 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.9, delay: 0.15, ease: "easeOut" }}
            className="relative flex justify-center lg:justify-end"
          >
            <div className="relative">
              <div className="absolute -inset-10 -z-10 bg-aurora-strong blur-3xl opacity-70 animate-[pulse-slow_4s_ease-in-out_infinite]" />
              <PhoneMockup />
            </div>
          </motion.div>
        </div>
      </div>

      <div className="mt-16 flex justify-center">
        <a
          href="#usp"
          className="group inline-flex items-center gap-2 text-sm text-[var(--muted)] hover:text-[var(--foreground)] transition-colors"
        >
          Khám phá tại sao
          <ArrowRight className="h-4 w-4 rotate-90 group-hover:translate-y-1 transition-transform" />
        </a>
      </div>
    </section>
  );
}
