import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold transition-colors",
  {
    variants: {
      variant: {
        default: "bg-[var(--color-coral)]/10 text-[var(--color-coral)] border border-[var(--color-coral)]/20",
        mint: "bg-[var(--color-mint)]/10 text-[var(--color-mint)] border border-[var(--color-mint)]/20",
        lavender: "bg-[var(--color-lavender)]/10 text-[var(--color-lavender)] border border-[var(--color-lavender)]/20",
        outline: "border border-[var(--border)] text-[var(--foreground)]",
      },
    },
    defaultVariants: { variant: "default" },
  }
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return <div className={cn(badgeVariants({ variant }), className)} {...props} />;
}

export { Badge, badgeVariants };
