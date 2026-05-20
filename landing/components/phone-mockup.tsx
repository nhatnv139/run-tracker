"use client";

import * as React from "react";
import { motion } from "framer-motion";
import { Activity, MapPin, Flame, Trophy } from "lucide-react";

export function PhoneMockup() {
  return (
    <motion.div
      animate={{ y: [0, -12, 0] }}
      transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
      className="relative mx-auto w-[280px] sm:w-[320px] aspect-[9/19] rounded-[3rem] border-[12px] border-[#1a1a1a] bg-[#0A0A0A] shadow-2xl shadow-black/40"
    >
      <div className="absolute top-2 left-1/2 -translate-x-1/2 h-6 w-24 rounded-full bg-[#1a1a1a] z-20" />

      <div className="relative h-full w-full overflow-hidden rounded-[2rem] bg-[linear-gradient(160deg,#FF5A36_0%,#7B5CFF_55%,#00D4A8_100%)]">
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,rgba(255,255,255,0.18),transparent_60%)]" />

        <div className="relative z-10 flex flex-col h-full p-6 pt-12 text-white">
          <div className="flex items-center justify-between text-xs font-semibold opacity-90">
            <span>9:41</span>
            <div className="flex items-center gap-1">
              <span className="inline-block h-2 w-2 rounded-full bg-white" />
              <span>5G</span>
            </div>
          </div>

          <div className="mt-6">
            <p className="text-xs uppercase tracking-widest opacity-80">Hôm nay</p>
            <p className="text-sm mt-1 opacity-90">Linh ơi, đi bộ 30 phút nha!</p>
          </div>

          <div className="mt-4 grid grid-cols-2 gap-3">
            <Stat icon={<Activity className="h-3.5 w-3.5" />} label="Bước" value="8,420" />
            <Stat icon={<Flame className="h-3.5 w-3.5" />} label="Calo" value="312" />
            <Stat icon={<MapPin className="h-3.5 w-3.5" />} label="Km" value="5.8" />
            <Stat icon={<Trophy className="h-3.5 w-3.5" />} label="Coin" value="+42" />
          </div>

          <div className="mt-5 rounded-2xl bg-white/15 backdrop-blur-md border border-white/20 p-4">
            <div className="flex items-baseline justify-between">
              <p className="text-xs opacity-80">Tuần này</p>
              <p className="text-xs font-bold">82%</p>
            </div>
            <div className="mt-2 h-1.5 w-full rounded-full bg-white/20 overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: "82%" }}
                transition={{ duration: 1.6, delay: 0.5, ease: "easeOut" }}
                className="h-full bg-white rounded-full"
              />
            </div>
            <div className="mt-3 flex items-end justify-between gap-1.5 h-12">
              {[40, 65, 52, 78, 90, 58, 82].map((h, i) => (
                <motion.div
                  key={i}
                  initial={{ height: 0 }}
                  animate={{ height: `${h}%` }}
                  transition={{ duration: 0.7, delay: 0.3 + i * 0.06 }}
                  className="flex-1 rounded-t bg-white/70"
                />
              ))}
            </div>
          </div>

          <div className="mt-auto flex justify-center pb-2">
            <div className="h-1 w-24 rounded-full bg-white/40" />
          </div>
        </div>
      </div>
    </motion.div>
  );
}

function Stat({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
}) {
  return (
    <div className="rounded-2xl bg-white/15 backdrop-blur-md border border-white/20 p-3">
      <div className="flex items-center gap-1.5 opacity-80 text-[10px] uppercase tracking-wider">
        {icon}
        {label}
      </div>
      <p className="mt-1 text-xl font-extrabold">{value}</p>
    </div>
  );
}
