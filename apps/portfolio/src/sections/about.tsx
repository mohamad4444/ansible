import { motion } from "framer-motion"
import { Section } from "../components/section"

export function About() {
  return (
    <Section id="about" className="bg-secondary/20">
      <div className="grid md:grid-cols-2 gap-12 items-center">
        {/* Terminal/Placeholder Column */}
        <motion.div
           initial={{ opacity: 0, x: -50 }}
           whileInView={{ opacity: 1, x: 0 }}
           viewport={{ once: true }}
           transition={{ duration: 0.5 }}
           className="relative aspect-square md:aspect-4/5 flex items-center justify-center p-4"
        >
            <div className="w-full max-w-sm bg-card rounded-xl overflow-hidden border shadow-2xl font-mono text-sm">
                <div className="bg-muted px-4 py-2 border-b flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full bg-red-500/80"></div>
                    <div className="w-3 h-3 rounded-full bg-yellow-500/80"></div>
                    <div className="w-3 h-3 rounded-full bg-green-500/80"></div>
                    <div className="ml-auto text-xs text-muted-foreground">bash</div>
                </div>
                <div className="p-4 space-y-2 text-muted-foreground">
                    <p><span className="text-green-500">➜</span> <span className="text-blue-500">~</span> whoami</p>
                    <p className="text-foreground">devops_engineer</p>
                    
                    <p className="mt-4"><span className="text-green-500">➜</span> <span className="text-blue-500">~</span> neofetch</p>
                    <div className="flex gap-4 mt-2">
                        <div className="text-primary hidden sm:block whitespace-pre font-mono leading-none text-[10px] sm:text-xs">
{`  ___
 (.. \\
 ( <> |
/ __  \\
( /  \\ /|
_/\ __)/_)
 \/-____\/`}
                        </div>
                        <div className="flex flex-col gap-1">
                            <p><span className="font-bold text-foreground">Role:</span> DevOps & Backend</p>
                            <p><span className="font-bold text-foreground">OS:</span> Linux</p>
                            <p><span className="font-bold text-foreground">Shell:</span> Zsh</p>
                            <p><span className="font-bold text-foreground">Editor:</span> VS Code</p>
                            <p><span className="font-bold text-foreground">Uptime:</span> 7+ Years</p>
                        </div>
                    </div>
                    <p className="mt-2 animate-pulse"><span className="text-green-500">➜</span> <span className="text-blue-500">~</span> <span className="w-2 h-4 bg-foreground inline-block align-middle"></span></p>
                </div>
            </div>
        </motion.div>

        {/* Content Column */}
        <motion.div
          initial={{ opacity: 0, x: 50 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-6">About Me</h2>
          <p className="text-lg text-muted-foreground mb-6">
            Motivated Junior DevOps Engineer & Backend Developer with a B.Sc. in Applied Computer Science.
            Experienced in building cloud-native applications using Kubernetes, Helm, and Spring Boot.
          </p>
          <p className="text-lg text-muted-foreground mb-8">
            Strong background in CI/CD automation and modern infrastructure. I enjoy solving complex
            problems and optimizing workflows.
          </p>
          
          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 bg-background rounded-xl border shadow-sm">
              <h4 className="font-bold text-2xl mb-1 text-primary">7+</h4>
              <p className="text-sm text-muted-foreground font-medium">Years Coding</p>
            </div>
            <div className="p-4 bg-background rounded-xl border shadow-sm">
              <h4 className="font-bold text-2xl mb-1 text-primary">10+</h4>
              <p className="text-sm text-muted-foreground font-medium">Projects Completed</p>
            </div>
          </div>
        </motion.div>
      </div>
    </Section>
  )
}
