"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Bot, Footprints, Coins } from "lucide-react";
import { Card } from "@/components/ui/card";

const items = [
  {
    icon: Bot,
    title: "AI Coach tiếng Việt",
    desc: "Huấn luyện viên ảo nói giọng Bắc - Nam tự nhiên. Tư vấn dinh dưỡng, giáo án 5K - 10K - 21K, cổ vũ mỗi km. Hiểu văn hóa và thói quen người Việt.",
    color: "from-[#FF5A36] to-[#FF7A5C]",
    accent: "text-[var(--color-coral)]",
    bg: "bg-[var(--color-coral)]/10",
  },
  {
    icon: Footprints,
    title: "Đi bộ trước, chạy bộ sau",
    desc: "Thiết kế cho 80% người Việt chỉ đi bộ. UX không xấu hổ cho người mới, nâng cấp dần lên chạy bộ. Đếm bước chính xác cả khi để túi quần.",
    color: "from-[#00D4A8] to-[#3DE0BC]",
    accent: "text-[var(--color-mint)]",
    bg: "bg-[var(--color-mint)]/10",
  },
  {
    icon: Coins,
    title: "RunCoin đổi voucher thật",
    desc: "Mỗi bước đi tích RunCoin. Đổi trực tiếp ra voucher Shopee, Grab, Highlands, MoMo. Không crypto rủi ro, không bot farm. Tiền thật, tiêu được liền.",
    color: "from-[#7B5CFF] to-[#9A82FF]",
    accent: "text-[var(--color-lavender)]",
    bg: "bg-[var(--color-lavender)]/10",
  },
];

export function USP() {
  return (
    <section id="usp" className="relative py-20 sm:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-bold uppercase tracking-widest text-[var(--color-coral)] mb-3">
            Vì sao chọn RunVie
          </p>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-balance">
            Ba thứ mà <span className="text-gradient-aurora">Strava, NRC, Sweatcoin</span> không có
          </h2>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {items.map((it, i) => {
            const Icon = it.icon;
            return (
              <motion.div
                key={it.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-80px" }}
                transition={{ duration: 0.6, delay: i * 0.1, ease: "easeOut" }}
              >
                <Card className="h-full group hover:-translate-y-1 hover:shadow-xl hover:shadow-black/5 hover:border-[var(--color-coral)]/30">
                  <div
                    className={`inline-flex h-12 w-12 items-center justify-center rounded-2xl ${it.bg} ${it.accent} mb-5 group-hover:scale-110 transition-transform`}
                  >
                    <Icon className="h-6 w-6" />
                  </div>
                  <h3 className="text-xl font-bold tracking-tight mb-2">{it.title}</h3>
                  <p className="text-sm text-[var(--muted)] leading-relaxed">{it.desc}</p>
                </Card>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
