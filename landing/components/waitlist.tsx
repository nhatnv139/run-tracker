"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Mail, Users } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { submitWaitlist, type WaitlistEntry } from "@/lib/supabase";
import { toast } from "sonner";

const types: Array<{ value: WaitlistEntry["user_type"]; label: string }> = [
  { value: "beginner", label: "Người mới" },
  { value: "walker", label: "Đi bộ" },
  { value: "runner", label: "Chạy bộ" },
  { value: "trainer", label: "PT / HLV" },
];

export function Waitlist() {
  const [email, setEmail] = React.useState("");
  const [userType, setUserType] = React.useState<WaitlistEntry["user_type"]>("beginner");
  const [loading, setLoading] = React.useState(false);
  const [done, setDone] = React.useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!email || !/.+@.+\..+/.test(email)) {
      toast.error("Vui lòng nhập email hợp lệ");
      return;
    }
    setLoading(true);
    const res = await submitWaitlist({ email, user_type: userType, source: "waitlist-final" });
    setLoading(false);
    if (res.ok) {
      toast.success("Đăng ký thành công! Hẹn gặp lại bạn khi RunVie ra mắt.");
      setEmail("");
      setDone(true);
    } else {
      toast.error("Có lỗi xảy ra, vui lòng thử lại.");
    }
  }

  return (
    <section id="waitlist" className="relative py-20 sm:py-28 overflow-hidden">
      <div className="absolute inset-0 -z-10 bg-aurora opacity-80 pointer-events-none" />

      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ duration: 0.7 }}
          className="card-surface rounded-[2rem] p-8 sm:p-12 shadow-2xl shadow-black/5"
        >
          <div className="text-center">
            <div className="inline-flex items-center gap-2 rounded-full border border-[var(--color-mint)]/30 bg-[var(--color-mint)]/10 px-4 py-1.5 text-xs font-bold text-[var(--color-mint)] mb-5">
              <Users className="h-3.5 w-3.5" />
              1.247 người đang chờ
            </div>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-black tracking-tight text-balance">
              Đăng ký <span className="text-gradient-aurora">danh sách chờ</span>
            </h2>
            <p className="mt-4 text-base text-[var(--muted)] max-w-xl mx-auto">
              Nhận thông báo đầu tiên khi mở beta, ưu đãi Lifetime giới hạn,
              và quà tặng độc quyền cho 1.000 thành viên đầu.
            </p>
          </div>

          <form onSubmit={onSubmit} className="mt-9 space-y-6">
            <div className="space-y-2">
              <Label htmlFor="waitlist-email" className="text-sm font-semibold">
                Email của bạn
              </Label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[var(--muted)]" />
                <Input
                  id="waitlist-email"
                  type="email"
                  placeholder="email@cua.ban"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  autoComplete="email"
                  className="h-12 pl-11"
                />
              </div>
            </div>

            <div className="space-y-3">
              <Label className="text-sm font-semibold">Tôi là</Label>
              <RadioGroup
                value={userType}
                onValueChange={(v) => setUserType(v as WaitlistEntry["user_type"])}
                className="grid grid-cols-2 sm:grid-cols-4 gap-3"
              >
                {types.map((t) => (
                  <label
                    key={t.value}
                    htmlFor={`type-${t.value}`}
                    className={`flex items-center gap-2.5 rounded-2xl border px-4 py-3 cursor-pointer transition-all hover:border-[var(--color-coral)]/60 ${
                      userType === t.value
                        ? "border-[var(--color-coral)] bg-[var(--color-coral)]/8"
                        : "border-[var(--border)]"
                    }`}
                  >
                    <RadioGroupItem id={`type-${t.value}`} value={t.value} />
                    <span className="text-sm font-medium">{t.label}</span>
                  </label>
                ))}
              </RadioGroup>
            </div>

            <Button
              type="submit"
              variant="aurora"
              size="lg"
              disabled={loading || done}
              className="w-full"
            >
              {loading
                ? "Đang gửi..."
                : done
                  ? "Đã đăng ký - cảm ơn bạn"
                  : "Đăng ký nhận thông báo"}
            </Button>

            <p className="text-xs text-center text-[var(--muted)]">
              Bằng cách đăng ký, bạn đồng ý nhận email từ RunVie. Có thể huỷ bất cứ lúc nào.
            </p>
          </form>
        </motion.div>
      </div>
    </section>
  );
}
