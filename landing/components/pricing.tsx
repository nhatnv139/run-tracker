"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Check, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

const plans = [
  {
    name: "Free",
    price: "0đ",
    period: "mãi mãi",
    desc: "Đếm bước, GPS cơ bản, voice coach 5 câu mẫu.",
    cta: "Bắt đầu miễn phí",
    variant: "outline" as const,
    features: [
      "Đếm bước & GPS không giới hạn",
      "Lịch sử 30 ngày gần nhất",
      "Voice coach 5 câu mẫu",
      "Đổi RunCoin tối đa 50k/tháng",
    ],
    highlight: false,
  },
  {
    name: "Plus",
    price: "99.000đ",
    period: "/tháng",
    desc: "Mở khoá AI Coach đầy đủ + giáo án cá nhân hoá.",
    cta: "Đăng ký Plus",
    variant: "aurora" as const,
    features: [
      "Tất cả tính năng Free",
      "AI Coach hội thoại không giới hạn",
      "Giáo án 5K - 10K - bán marathon",
      "Lịch sử lưu trọn đời",
      "Đổi RunCoin tối đa 300k/tháng",
      "Hỗ trợ ưu tiên",
    ],
    highlight: true,
    badge: "Phổ biến",
  },
  {
    name: "Pro",
    price: "199.000đ",
    period: "/tháng",
    desc: "Cho PT, runner nghiêm túc và doanh nghiệp nhỏ.",
    cta: "Liên hệ",
    variant: "outline" as const,
    features: [
      "Tất cả tính năng Plus",
      "Quản lý nhóm tới 30 học viên",
      "Phân tích nâng cao + biểu đồ tháng",
      "API kết nối Garmin / Coros",
      "Đổi RunCoin không giới hạn",
      "Báo cáo PDF tuỳ chỉnh",
    ],
    highlight: false,
  },
];

export function Pricing() {
  return (
    <section id="pricing" className="relative py-20 sm:py-28 bg-[var(--muted-bg)]">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-bold uppercase tracking-widest text-[var(--color-coral)] mb-3">
            Giá ra mắt
          </p>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-balance">
            Chọn gói phù hợp với <span className="text-gradient-aurora">ví của bạn</span>
          </h2>
          <div className="mt-6 inline-flex items-center gap-2 rounded-full border border-[var(--color-coral)]/30 bg-[var(--color-coral)]/10 px-4 py-2 text-sm font-semibold text-[var(--color-coral)]">
            <Sparkles className="h-4 w-4" />
            Lifetime giới hạn 4.999.000đ cho 1.000 user đầu tiên
          </div>
        </div>

        <div className="grid lg:grid-cols-3 gap-6">
          {plans.map((p, i) => (
            <motion.div
              key={p.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ duration: 0.6, delay: i * 0.1 }}
              className={`relative rounded-3xl p-7 transition-all ${
                p.highlight
                  ? "bg-[linear-gradient(160deg,rgba(255,90,54,0.08),rgba(123,92,255,0.08),rgba(0,212,168,0.08))] border-2 border-[var(--color-coral)] shadow-2xl shadow-[var(--color-coral)]/15 scale-[1.02]"
                  : "card-surface hover:border-[var(--color-coral)]/30"
              }`}
            >
              {p.highlight && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                  <Badge className="bg-[var(--color-coral)] text-white border-0 px-3 py-1 shadow-md">
                    <Sparkles className="h-3 w-3" />
                    {p.badge}
                  </Badge>
                </div>
              )}

              <h3 className="text-xl font-extrabold tracking-tight">{p.name}</h3>
              <p className="mt-1 text-sm text-[var(--muted)]">{p.desc}</p>

              <div className="mt-5 flex items-baseline gap-1.5">
                <span className="text-4xl font-black tracking-tight">{p.price}</span>
                <span className="text-sm text-[var(--muted)]">{p.period}</span>
              </div>

              <Button
                asChild
                variant={p.variant}
                size="lg"
                className="mt-6 w-full"
              >
                <a href="#waitlist">{p.cta}</a>
              </Button>

              <ul className="mt-7 space-y-3">
                {p.features.map((f) => (
                  <li key={f} className="flex items-start gap-2.5 text-sm">
                    <span
                      className={`mt-0.5 inline-flex h-5 w-5 shrink-0 items-center justify-center rounded-full ${
                        p.highlight
                          ? "bg-[var(--color-coral)]/15 text-[var(--color-coral)]"
                          : "bg-[var(--color-mint)]/15 text-[var(--color-mint)]"
                      }`}
                    >
                      <Check className="h-3 w-3" strokeWidth={3} />
                    </span>
                    <span className="text-[var(--foreground)]/90">{f}</span>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
