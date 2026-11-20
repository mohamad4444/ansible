import { motion } from "framer-motion"
import { Section } from "../components/section"
import { 
  SiSpring, SiPython, SiCplusplus, SiHaskell, 
  SiSpringboot, SiKubernetes, SiHelm, SiDocker, SiJenkins, SiAnsible, 
  SiPostgresql, SiMongodb, SiHtml5, SiCss3, SiJavascript, SiTypescript,
  SiAmazon, SiGrafana, SiPrometheus, SiDebian, SiFedora, SiJira
} from "react-icons/si"

const skills = [
  {
    category: "Languages",
    items: [
      { name: "Java", icon: <SiSpring className="w-8 h-8 text-[#6DB33F]" /> },
      { name: "Python", icon: <SiPython className="w-8 h-8 text-[#3776AB]" /> },
      { name: "C++", icon: <SiCplusplus className="w-8 h-8 text-[#00599C]" /> },
      { name: "Haskell", icon: <SiHaskell className="w-8 h-8 text-[#5D4F85]" /> },
    ],
  },
  {
    category: "Backend & DB",
    items: [
      { name: "Spring Boot", icon: <SiSpringboot className="w-8 h-8 text-[#6DB33F]" /> },
      { name: "PostgreSQL", icon: <SiPostgresql className="w-8 h-8 text-[#4169E1]" /> },
      { name: "MongoDB", icon: <SiMongodb className="w-8 h-8 text-[#47A248]" /> },
    ],
  },
  {
    category: "DevOps & Cloud",
    items: [
      { name: "AWS", icon: <SiAmazon className="w-8 h-8 text-[#232F3E]" /> },
      { name: "Kubernetes", icon: <SiKubernetes className="w-8 h-8 text-[#326CE5]" /> },
      { name: "Helm", icon: <SiHelm className="w-8 h-8 text-[#0F1689]" /> },
      { name: "Docker", icon: <SiDocker className="w-8 h-8 text-[#2496ED]" /> },
      { name: "Jenkins", icon: <SiJenkins className="w-8 h-8 text-[#D24939]" /> },
      { name: "Ansible", icon: <SiAnsible className="w-8 h-8 text-[#EE0000]" /> },
    ],
  },
  {
    category: "Frontend",
    items: [
      { name: "HTML", icon: <SiHtml5 className="w-8 h-8 text-[#E34F26]" /> },
      { name: "CSS", icon: <SiCss3 className="w-8 h-8 text-[#1572B6]" /> },
      { name: "JavaScript", icon: <SiJavascript className="w-8 h-8 text-[#F7DF1E]" /> },
      { name: "TypeScript", icon: <SiTypescript className="w-8 h-8 text-[#3178C6]" /> },
    ],
  },
  {
    category: "Observability",
    items: [
      { name: "Grafana Alloy", icon: <SiGrafana className="w-8 h-8 text-[#F46800]" /> },
      { name: "Prometheus", icon: <SiPrometheus className="w-8 h-8 text-[#E6522C]" /> },
      { name: "Promtail", icon: <SiGrafana className="w-8 h-8 text-[#F46800]" /> },
      { name: "Loki", icon: <SiGrafana className="w-8 h-8 text-[#F46800]" /> },
    ],
  },
  {
    category: "Operating Systems",
    items: [
      { name: "Debian", icon: <SiDebian className="w-8 h-8 text-[#A81D33]" /> },
      { name: "Fedora", icon: <SiFedora className="w-8 h-8 text-[#51A2DA]" /> },
    ],
  },
  {
    category: "Methodologies",
    items: [
      { name: "Scrum", icon: <SiJira className="w-8 h-8 text-[#009FD6]" /> },
    ],
  },
]

export function Skills() {
  return (
    <Section id="skills" className="py-20">
      <div className="text-center mb-16">
        <h2 className="text-3xl md:text-4xl font-bold mb-4">Tech Stack & Skills</h2>
        <p className="text-muted-foreground max-w-2xl mx-auto">
          Tools and technologies I use to build scalable applications.
        </p>
      </div>

      <div className="max-w-4xl mx-auto bg-card/30 backdrop-blur-sm border rounded-3xl p-8 shadow-sm">
        {skills.map((group, groupIndex) => (
          <motion.div
            key={group.category}
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.3, delay: groupIndex * 0.05 }}
          >
            <div className="grid md:grid-cols-[180px_1fr] gap-6 items-center py-6">
                <h3 className="text-sm font-bold text-primary/80 uppercase tracking-widest md:text-right">{group.category}</h3>
                
                <div className="flex flex-wrap gap-x-6 gap-y-4">
                    {group.items.map((skill, i) => (
                        <motion.div
                            key={i}
                            whileHover={{ scale: 1.1 }}
                            className="flex items-center gap-2 group cursor-default"
                        >
                            <div className="w-6 h-6 flex items-center justify-center transition-transform duration-300">
                                {skill.icon}
                            </div>
                            <span className="text-sm font-medium text-muted-foreground/80 group-hover:text-primary transition-colors">{skill.name}</span>
                        </motion.div>
                    ))}
                </div>
            </div>
            {groupIndex < skills.length - 1 && (
                <div className="h-px bg-border/50 w-full" />
            )}
          </motion.div>
        ))}
      </div>
    </Section>
  )
}
