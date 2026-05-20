"use client";

import * as React from "react";
import { motion } from "framer-motion";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const faqs = [
  {
    q: "Khi nào RunVie chính thức ra mắt?",
    a: "Bản beta đóng dự kiến quý 3/2026 cho 1.000 user đầu tiên trong waitlist. Bản chính thức trên App Store và Google Play quý 4/2026.",
  },
  {
    q: "App có tốn pin không?",
    a: "RunVie dùng CMPedometer trên iOS và Health Connect trên Android - các API tiết kiệm pin của hệ điều hành. Đếm bước cả ngày tốn khoảng 2-3% pin. GPS chạy bộ 1 giờ tốn khoảng 8-10% pin tuỳ thiết bị.",
  },
  {
    q: "Có gói miễn phí không?",
    a: "Có. Gói Free vĩnh viễn bao gồm đếm bước, GPS không giới hạn, lịch sử 30 ngày, voice coach 5 câu mẫu và đổi RunCoin tối đa 50.000đ voucher mỗi tháng. Đủ dùng cho hầu hết người tập phong trào.",
  },
  {
    q: "Có cần Apple Watch hay Garmin không?",
    a: "Không cần. RunVie chạy độc lập trên iPhone hoặc Android. Nếu có Apple Watch, Garmin hay Coros chúng tôi sẽ đồng bộ dữ liệu để tăng độ chính xác - nhưng không bắt buộc.",
  },
  {
    q: "Vị trí của tôi được bảo mật ra sao?",
    a: "Dữ liệu GPS được mã hoá AES-256 cả khi truyền và lưu trữ trên Supabase. Route chạy mặc định là riêng tư - chỉ bạn thấy. Bạn có thể chọn ẩn 200m đầu và cuối route trước khi chia sẻ để giấu nhà.",
  },
  {
    q: "Có hỗ trợ Android không?",
    a: "Có. RunVie hỗ trợ song song iOS 17.0 trở lên và Android 13.0 trở lên. Tính năng giống hệt nhau giữa hai nền tảng - không có chuyện iOS có còn Android thiếu.",
  },
  {
    q: "Đổi RunCoin ra voucher như thế nào?",
    a: "Trong app vào tab Phần thưởng, chọn voucher Shopee, Grab, Highlands hoặc MoMo bạn muốn. Hệ thống trừ RunCoin và gửi mã voucher qua app và email trong tối đa 24 giờ. Tỷ lệ ban đầu khoảng 1.000 bước = 100đ.",
  },
  {
    q: "Chính sách hoàn tiền thế nào?",
    a: "Bạn được hoàn tiền 100% trong 14 ngày đầu nếu không hài lòng với gói Plus hoặc Pro - không cần lý do. Gói Lifetime hoàn 100% trong 30 ngày. Gửi yêu cầu qua hello@runvie.vn, xử lý trong 3 ngày làm việc.",
  },
];

export function FAQ() {
  return (
    <section id="faq" className="relative py-20 sm:py-28">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <p className="text-xs font-bold uppercase tracking-widest text-[var(--color-mint)] mb-3">
            Câu hỏi thường gặp
          </p>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight">
            Bạn còn băn khoăn?
          </h2>
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-60px" }}
          transition={{ duration: 0.6 }}
        >
          <Accordion type="single" collapsible className="flex flex-col gap-3">
            {faqs.map((f, i) => (
              <AccordionItem key={i} value={`item-${i}`}>
                <AccordionTrigger>{f.q}</AccordionTrigger>
                <AccordionContent>{f.a}</AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </motion.div>

        <p className="mt-10 text-center text-sm text-[var(--muted)]">
          Câu hỏi khác? Email{" "}
          <a href="mailto:hello@runvie.vn" className="text-[var(--color-coral)] font-semibold hover:underline">
            hello@runvie.vn
          </a>
        </p>
      </div>
    </section>
  );
}
