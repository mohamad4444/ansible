import { cn } from "../lib/utils"
import type { ReactNode } from "react"

interface SectionProps {
  id?: string
  className?: string
  children: ReactNode
}

export function Section({ id, className, children }: SectionProps) {
  return (
    <section
      id={id}
      className={cn("py-20 px-4 sm:px-6 lg:px-8 w-full max-w-7xl mx-auto", className)}
    >
      {children}
    </section>
  )
}
