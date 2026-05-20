import type { Metadata } from "next";
import Link from "next/link";
import { Nav } from "@/components/nav";
import { Footer } from "@/components/footer";

export const metadata: Metadata = {
  title: "Điều khoản sử dụng - RunVie",
  description: "Điều khoản và điều kiện khi sử dụng app RunVie.",
};

export default function TermsPage() {
  return (
    <>
      <Nav />
      <main className="pt-32 pb-20">
        <article className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
          <h1 className="text-4xl font-extrabold tracking-tight">Điều khoản sử dụng</h1>
          <p className="text-sm text-[var(--muted)] mt-2">Cập nhật 20/05/2026</p>

          <h2 className="text-2xl font-bold mt-10">1. Chấp nhận điều khoản</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Bằng việc đăng ký waitlist hoặc cài đặt RunVie, bạn đồng ý với các điều khoản dưới đây.
            Nếu không đồng ý, vui lòng không sử dụng dịch vụ.
          </p>

          <h2 className="text-2xl font-bold mt-8">2. Tài khoản</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Bạn chịu trách nhiệm bảo mật tài khoản. RunVie không chịu trách nhiệm cho thiệt hại do
            bạn để lộ mật khẩu hoặc cho người khác mượn tài khoản.
          </p>

          <h2 className="text-2xl font-bold mt-8">3. Sử dụng hợp lệ</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Cấm dùng bot, trình giả lập bước chân, GPS spoof hoặc các hành vi gian lận để tích
            RunCoin. Tài khoản vi phạm sẽ bị khoá vĩnh viễn và không được hoàn tiền.
          </p>

          <h2 className="text-2xl font-bold mt-8">4. Hoàn tiền</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Gói Plus và Pro được hoàn 100% trong 14 ngày đầu. Gói Lifetime được hoàn 100% trong 30
            ngày. Vui lòng gửi yêu cầu qua <a href="mailto:hello@runvie.vn" className="text-[var(--color-coral)] hover:underline">hello@runvie.vn</a>.
          </p>

          <h2 className="text-2xl font-bold mt-8">5. Giới hạn trách nhiệm</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            RunVie không phải thiết bị y tế. Trước khi bắt đầu chương trình tập, hãy hỏi ý kiến bác
            sĩ nếu bạn có bệnh nền. RunVie không chịu trách nhiệm cho chấn thương khi tập luyện.
          </p>

          <h2 className="text-2xl font-bold mt-8">6. Liên hệ</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Mọi câu hỏi về điều khoản, gửi tới{" "}
            <a href="mailto:hello@runvie.vn" className="text-[var(--color-coral)] hover:underline">
              hello@runvie.vn
            </a>.
          </p>

          <p className="mt-10">
            <Link href="/" className="text-[var(--color-coral)] font-semibold hover:underline">
              Về trang chủ
            </Link>
          </p>
        </article>
      </main>
      <Footer />
    </>
  );
}
