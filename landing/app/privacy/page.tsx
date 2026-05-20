import type { Metadata } from "next";
import Link from "next/link";
import { Nav } from "@/components/nav";
import { Footer } from "@/components/footer";

export const metadata: Metadata = {
  title: "Chính sách bảo mật - RunVie",
  description:
    "Cách RunVie thu thập, sử dụng và bảo vệ dữ liệu cá nhân, vị trí, sức khoẻ của bạn.",
};

export default function PrivacyPage() {
  return (
    <>
      <Nav />
      <main className="pt-32 pb-20">
        <article className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
          <h1 className="text-4xl font-extrabold tracking-tight">Chính sách bảo mật</h1>
          <p className="text-sm text-[var(--muted)] mt-2">Cập nhật 20/05/2026</p>

          <h2 className="text-2xl font-bold mt-10">1. Dữ liệu chúng tôi thu thập</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Khi bạn đăng ký waitlist, RunVie chỉ lưu email và loại người dùng bạn chọn. Khi bạn dùng
            app chính thức, chúng tôi thu thập số bước, dữ liệu GPS, nhịp tim (nếu cấp quyền), và
            các chỉ số tập luyện cần thiết để hiển thị tiến độ.
          </p>

          <h2 className="text-2xl font-bold mt-8">2. Cách chúng tôi sử dụng dữ liệu</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Dữ liệu dùng để cá nhân hoá AI Coach, tính RunCoin và phân tích nội bộ. Chúng tôi không
            bán dữ liệu cho bên thứ ba. Quảng cáo bên thứ ba (nếu có) chỉ dùng dữ liệu tổng hợp,
            không định danh.
          </p>

          <h2 className="text-2xl font-bold mt-8">3. Bảo mật vị trí</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Tất cả route GPS được mã hoá AES-256 khi truyền và khi lưu trên Supabase. Route mặc định
            là riêng tư. Bạn có thể ẩn 200m đầu và cuối khi chia sẻ.
          </p>

          <h2 className="text-2xl font-bold mt-8">4. Quyền của bạn</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Bạn có quyền yêu cầu xem, sửa, xoá hoặc xuất dữ liệu cá nhân bất cứ lúc nào. Gửi yêu cầu
            tới <a href="mailto:privacy@runvie.vn" className="text-[var(--color-coral)] hover:underline">privacy@runvie.vn</a>.
          </p>

          <h2 className="text-2xl font-bold mt-8">5. Liên hệ</h2>
          <p className="text-[var(--muted)] leading-relaxed mt-2">
            Câu hỏi về chính sách này, vui lòng gửi tới{" "}
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
