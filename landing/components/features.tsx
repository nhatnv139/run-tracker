"use client";

import * as React from "react";
import { motion } from "framer-motion";
import {
  Footprints,
  Navigation,
  Flame,
  Mic,
  Award,
  Trophy,
} from "lucide-react";

const features = [
  {
    icon: Footprints,
    title: "Đếm bước chính xác",
    caption: "CMPedometer + Health Connect. Bước được lưu cả khi tắt app, không xả pin.",
    accent: "bg-[var(--color-coral)]/15 text-[var(--color-coral)]",
    visual: "step",
  },
  {
    icon: Navigation,
    title: "GPS Run & Walk",
    caption: "Kalman filter + auto-pause khi dừng đèn đỏ. Sai số dưới 1.5% trên route 10km.",
    accent: "bg-[var(--color-mint)]/15 text-[var(--color-mint)]",
    visual: "gps",
  },
  {
    icon: Flame,
    title: "Đếm calo Mifflin-St Jeor",
    caption: "Công thức chuẩn y khoa kết hợp MET theo độ dốc, tuổi, cân nặng và nhịp tim.",
    accent: "bg-[var(--color-lavender)]/15 text-[var(--color-lavender)]",
    visual: "calorie",
  },
  {
    icon: Mic,
    title: "Voice Coach giọng Việt",
    caption: "ElevenLabs TTS Bắc - Nam. Nhắc tốc độ, nhịp, động viên mỗi km tự nhiên như bạn thật.",
    accent: "bg-[var(--color-coral)]/15 text-[var(--color-coral)]",
    visual: "voice",
  },
  {
    icon: Award,
    title: "Huy hiệu & Streak",
    caption: "Hơn 50 badge cốt lõi. Streak freeze 2 lần mỗi tuần để không sợ gãy chuỗi khi ốm.",
    accent: "bg-[var(--color-mint)]/15 text-[var(--color-mint)]",
    visual: "badge",
  },
  {
    icon: Trophy,
    title: "Virtual Race HN - SG",
    caption: "Chạy ảo Hà Nội đến Sài Gòn 1,720 km. Hoàn thành nhận medal gốm Bát Tràng giao tận nhà.",
    accent: "bg-[var(--color-lavender)]/15 text-[var(--color-lavender)]",
    visual: "race",
  },
];

export function Features() {
  return (
    <section id="features" className="relative py-20 sm:py-28 bg-[var(--muted-bg)]">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-bold uppercase tracking-widest text-[var(--color-mint)] mb-3">
            Tính năng nổi bật
          </p>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-balance">
            Mọi thứ bạn cần để bắt đầu <span className="text-gradient-aurora">vận động</span>
          </h2>
          <p className="mt-4 text-base text-[var(--muted)]">
            6 tính năng cốt lõi sẵn sàng từ ngày ra mắt - không phải chờ update.
          </p>
        </div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {features.map((f, i) => {
            const Icon = f.icon;
            return (
              <motion.div
                key={f.title}
                initial={{ opacity: 0, y: 24 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-60px" }}
                transition={{ duration: 0.5, delay: (i % 3) * 0.08, ease: "easeOut" }}
                className="card-surface rounded-3xl p-5 hover:border-[var(--color-coral)]/30 transition-all group"
              >
                <FeatureVisual kind={f.visual} accent={f.accent} />
                <div className="mt-5 flex items-start gap-3">
                  <div className={`inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${f.accent}`}>
                    <Icon className="h-5 w-5" />
                  </div>
                  <div>
                    <h3 className="font-bold tracking-tight">{f.title}</h3>
                    <p className="mt-1 text-sm text-[var(--muted)] leading-relaxed">{f.caption}</p>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

function FeatureVisual({ kind, accent }: { kind: string; accent: string }) {
  // Stylized SVG placeholders, no external images. Each unique.
  return (
    <div className={`relative h-40 w-full rounded-2xl overflow-hidden ${accent}`}>
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_30%,rgba(255,255,255,0.6),transparent_60%)]" />
      <svg
        viewBox="0 0 320 160"
        className="absolute inset-0 h-full w-full"
        preserveAspectRatio="xMidYMid slice"
      >
        {kind === "step" && (
          <g>
            {[20, 60, 100, 140, 180, 220, 260].map((x, i) => (
              <g key={i} opacity={0.4 + i * 0.08}>
                <ellipse cx={x} cy={70 + (i % 2) * 30} rx="14" ry="20" fill="currentColor" />
              </g>
            ))}
          </g>
        )}
        {kind === "gps" && (
          <g fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round">
            <path d="M20 130 Q 70 30, 140 80 T 280 50" opacity="0.5" />
            <path d="M20 130 Q 70 30, 140 80 T 280 50" strokeDasharray="6 8" />
            <circle cx="20" cy="130" r="6" fill="currentColor" />
            <circle cx="280" cy="50" r="6" fill="currentColor" />
          </g>
        )}
        {kind === "calorie" && (
          <g>
            <path
              d="M160 30 C 130 60, 110 90, 130 120 C 140 140, 180 140, 190 120 C 210 90, 190 60, 160 30 Z"
              fill="currentColor"
              opacity="0.6"
            />
            <path
              d="M160 50 C 145 70, 135 90, 145 110 C 152 122, 175 122, 180 110 C 188 92, 178 72, 160 50 Z"
              fill="currentColor"
            />
          </g>
        )}
        {kind === "voice" && (
          <g fill="currentColor">
            {[40, 80, 120, 160, 200, 240, 280].map((x, i) => {
              const heights = [40, 70, 100, 130, 100, 60, 40];
              return (
                <rect
                  key={i}
                  x={x - 8}
                  y={80 - heights[i] / 2}
                  width="14"
                  height={heights[i]}
                  rx="6"
                  opacity={0.5 + (i % 3) * 0.15}
                />
              );
            })}
          </g>
        )}
        {kind === "badge" && (
          <g>
            <polygon
              points="160,20 200,55 195,110 160,140 125,110 120,55"
              fill="currentColor"
              opacity="0.7"
            />
            <polygon
              points="160,40 188,65 184,105 160,125 136,105 132,65"
              fill="currentColor"
            />
            <circle cx="160" cy="85" r="14" fill="rgba(255,255,255,0.6)" />
          </g>
        )}
        {kind === "race" && (
          <g fill="currentColor">
            <circle cx="60" cy="80" r="10" opacity="0.7" />
            <text x="60" y="115" fontSize="10" textAnchor="middle" opacity="0.8" fontWeight="700">
              HN
            </text>
            <circle cx="260" cy="80" r="10" opacity="0.7" />
            <text x="260" y="115" fontSize="10" textAnchor="middle" opacity="0.8" fontWeight="700">
              SG
            </text>
            <path
              d="M70 80 Q 160 30, 250 80"
              fill="none"
              stroke="currentColor"
              strokeWidth="3"
              strokeDasharray="4 6"
            />
            <circle cx="160" cy="56" r="7" />
          </g>
        )}
      </svg>
    </div>
  );
}
