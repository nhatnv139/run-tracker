"use client";

import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-full text-sm font-semibold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-coral)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--background)] disabled:pointer-events-none disabled:opacity-50 active:scale-[0.98]",
  {
    variants: {
      variant: {
        default:
          "bg-[var(--color-coral)] text-white hover:bg-[var(--color-coral-soft)] shadow-lg shadow-[var(--color-coral)]/25",
        aurora:
          "text-white shadow-xl shadow-[var(--color-coral)]/30 bg-[linear-gradient(110deg,#FF5A36,#7B5CFF_60%,#00D4A8)] bg-[length:200%_100%] hover:bg-[position:100%_0%] transition-[background-position] duration-500",
        outline:
          "border border-[var(--border)] bg-transparent hover:bg-[var(--muted-bg)] text-[var(--foreground)]",
        ghost:
          "hover:bg-[var(--muted-bg)] text-[var(--foreground)]",
        mint:
          "bg-[var(--color-mint)] text-[#062D26] hover:bg-[var(--color-mint-soft)]",
      },
      size: {
        default: "h-11 px-6 py-2",
        sm: "h-9 px-4 text-xs",
        lg: "h-12 px-8 text-base",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = "Button";

export { Button, buttonVariants };
