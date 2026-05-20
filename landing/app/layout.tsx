import type { Metadata, Viewport } from "next";
import { Be_Vietnam_Pro } from "next/font/google";
import { Toaster } from "sonner";
import { ThemeProvider } from "@/components/theme-provider";
import "./globals.css";

const beVietnamPro = Be_Vietnam_Pro({
  subsets: ["latin", "vietnamese"],
  weight: ["400", "500", "600", "700", "800", "900"],
  display: "swap",
  variable: "--font-sans",
});

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://runvie.vn";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "RunVie - App Chạy Bộ & Đếm Bước AI Việt Nam",
  description:
    "Đo GPS, đếm bước, đếm calo với AI Coach tiếng Việt. RunCoin đổi voucher Shopee, Grab, MoMo. Sắp ra mắt 2026.",
  keywords: [
    "RunVie",
    "app chạy bộ",
    "đếm bước",
    "đếm calo",
    "AI Coach tiếng Việt",
    "GPS chạy bộ",
    "RunCoin",
    "voucher Shopee Grab MoMo",
    "Strava Việt Nam",
    "Nike Run Club thay thế",
  ],
  authors: [{ name: "RunVie Team" }],
  creator: "RunVie",
  publisher: "RunVie",
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "vi_VN",
    url: siteUrl,
    siteName: "RunVie",
    title: "RunVie - App Chạy Bộ & Đếm Bước AI Việt Nam",
    description:
      "Đo GPS, đếm bước, đếm calo với AI Coach tiếng Việt. RunCoin đổi voucher Shopee, Grab, MoMo. Sắp ra mắt 2026.",
    images: [
      {
        url: "/og.svg",
        width: 1200,
        height: 630,
        alt: "RunVie - App chạy bộ AI tiếng Việt",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "RunVie - App Chạy Bộ & Đếm Bước AI Việt Nam",
    description:
      "Đo GPS, đếm bước, đếm calo với AI Coach tiếng Việt. RunCoin đổi voucher Shopee, Grab, MoMo. Sắp ra mắt 2026.",
    images: ["/og.svg"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  icons: {
    icon: [{ url: "/favicon.svg", type: "image/svg+xml" }],
    apple: "/apple-icon.svg",
  },
};

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#FAFAF7" },
    { media: "(prefers-color-scheme: dark)", color: "#0A0A0A" },
  ],
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="vi" className={beVietnamPro.variable} suppressHydrationWarning>
      <body className="font-sans antialiased">
        <ThemeProvider attribute="class" defaultTheme="light" enableSystem>
          {children}
          <Toaster
            position="top-center"
            richColors
            closeButton
            toastOptions={{
              style: {
                fontFamily: "var(--font-sans), ui-sans-serif",
              },
            }}
          />
        </ThemeProvider>
      </body>
    </html>
  );
}
