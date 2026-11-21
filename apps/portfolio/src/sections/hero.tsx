import { motion } from "framer-motion"
import { Github, Linkedin } from "lucide-react"
import { Button } from "../components/ui/button"

export function Hero() {
  return (
    <section className="min-h-screen flex items-center justify-center relative overflow-hidden bg-background pt-16">
      {/* Background decoration */}
      <div className="absolute inset-0 -z-10 h-full w-full bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-size-[14px_24px]"></div>
      <div className="absolute left-0 right-0 top-0 -z-10 m-auto h-77.5 w-77.5 rounded-full bg-primary/20 opacity-20 blur-[100px]"></div>

      <div className="text-center px-4 max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <h2 className="text-sm md:text-base font-semibold text-primary tracking-wide uppercase mb-4">
            DevOps Engineer & Backend Developer
          </h2>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="text-4xl md:text-6xl lg:text-7xl font-bold tracking-tight mb-6 bg-clip-text text-transparent bg-linear-to-r from-primary to-primary/50"
        >
          Mohammad Mahamid
          <br />
          <span className="text-2xl md:text-4xl lg:text-5xl block mt-4 text-foreground">
            Building Cloud-Native apps
          </span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="text-lg md:text-xl text-muted-foreground mb-8 max-w-2xl mx-auto"
        >
          Building reliable, scalable, and secure cloud infrastructure and backend systems.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center"
        >
          <Button size="lg" className="min-w-40" asChild>
            <a href="#projects">View Projects</a>
          </Button>
          <Button size="lg" variant="outline" className="min-w-40" asChild>
            <a href="/Mohammad_Mahamid_CV-with-links.pdf" download>Download CV (with links)</a>
          </Button>
          <Button size="lg" variant="outline" className="min-w-40" asChild>
            <a href="/Mohammad_Mahamid_CV-no-links.pdf" download>Download CV (no links)</a>
          </Button>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.5 }}
          className="mt-12 flex justify-center gap-6 text-muted-foreground hover:text-primary transition-colors"
        >
          <a href="https://github.com/mohamad4444" target="_blank" rel="noopener noreferrer" aria-label="GitHub" className="hover:text-primary transition-colors"><Github className="w-6 h-6" /></a>
          <a href="https://linkedin.com/in/mohamad4444" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="hover:text-primary transition-colors"><Linkedin className="w-6 h-6" /></a>
        </motion.div>
      </div>
    </section>
  )
}
