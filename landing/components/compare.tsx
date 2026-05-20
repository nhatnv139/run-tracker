"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Check, X, Minus } from "lucide-react";

type Cell = true | false | "partial" | string;
type Row = { label: string; runvie: Cell; strava: Cell; nrc: Cell; sweatcoin: Cell };

const rows: Row[] = [
  { label: "Tiếng Việt native", runvie: true, strava: false, nrc: false, sweatcoin: "partial" },
  { label: "AI Coach hội thoại", runvie: true, strava: false, nrc: "partial", sweatcoin: false },
  { label: "Walking-first UX", runvie: true, strava: false, nrc: false, sweatcoin: true },
  { label: "Voucher tiền thật (Shopee/Grab/MoMo)", runvie: true, strava: false, nrc: false, sweatcoin: "partial" },
  { label: "Giá hợp ví Việt", runvie: "99k/tháng", strava: "210k/tháng", nrc: "Free", sweatcoin: "Free" },
  { label: "Giải phong trào VN", runvie: true, strava: "partial", nrc: false, sweatcoin: false },
];

const columns = [
  { key: "runvie", label: "RunVie", highlight: true },
  { key: "strava", label: "Strava" },
  { key: "nrc", label: "Nike Run Club" },
  { key: "sweatcoin", label: "Sweatcoin" },
] as const;

function renderCell(v: Cell) {
  if (v === true)
    return (
      <span className="inline-flex h-7 w-7 items-center justify-center rounded-full bg-[var(--color-mint)]/15 text-[var(--color-mint)]">
        <Check className="h-4 w-4" strokeWidth={3} />
      </span>
    );
  if (v === false)
    return (
      <span className="inline-flex h-7 w-7 items-center justify-center rounded-full bg-[var(--muted-bg)] text-[var(--muted)]">
        <X className="h-4 w-4" strokeWidth={2.5} />
      </span>
    );
  if (v === "partial")
    return (
      <span className="inline-flex h-7 w-7 items-center justify-center rounded-full bg-[var(--color-lavender)]/15 text-[var(--color-lavender)]">
        <Minus className="h-4 w-4" strokeWidth={3} />
      </span>
    );
  return <span className="text-sm font-semibold">{v}</span>;
}

export function Compare() {
  return (
    <section id="compare" className="relative py-20 sm:py-28">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-12 sm:mb-16">
          <p className="text-xs font-bold uppercase tracking-widest text-[var(--color-lavender)] mb-3">
            So sánh
          </p>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-balance">
            RunVie và các app phổ biến
          </h2>
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-60px" }}
          transition={{ duration: 0.7 }}
          className="card-surface rounded-3xl overflow-hidden"
        >
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-[var(--border)]">
                  <th className="p-5 text-xs font-bold uppercase tracking-wider text-[var(--muted)]">
                    Tiêu chí
                  </th>
                  {columns.map((c) => (
                    <th
                      key={c.key}
                      className={`p-5 text-center text-sm font-bold ${
                        c.highlight ? "text-[var(--color-coral)]" : "text-[var(--foreground)]"
                      }`}
                    >
                      {c.highlight ? (
                        <span className="inline-flex items-center gap-1.5">
                          <span className="inline-block h-2 w-2 rounded-full bg-[var(--color-coral)]" />
                          {c.label}
                        </span>
                      ) : (
                        c.label
                      )}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.map((r, idx) => (
                  <tr
                    key={r.label}
                    className={`border-b border-[var(--border)] last:border-0 ${
                      idx % 2 === 1 ? "bg-[var(--muted-bg)]/40" : ""
                    }`}
                  >
                    <td className="p-5 text-sm font-medium">{r.label}</td>
                    {columns.map((c) => (
                      <td
                        key={c.key}
                        className={`p-5 text-center ${
                          c.highlight ? "bg-[var(--color-coral)]/5" : ""
                        }`}
                      >
                        <div className="flex justify-center">
                          {renderCell(r[c.key as keyof Row] as Cell)}
                        </div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </motion.div>

        <p className="mt-5 text-xs text-[var(--muted)] text-center">
          Dữ liệu so sánh tháng 5/2026 từ tài liệu công khai. RunVie cam kết cập nhật khi thị trường thay đổi.
        </p>
      </div>
    </section>
  );
}
