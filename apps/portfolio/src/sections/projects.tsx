import { motion } from "framer-motion"
import { Section } from "../components/section"
import { Button } from "../components/ui/button"
import { ExternalLink, Github } from "lucide-react"

const projects = [
  {
    title: "Cloud Native Purchase System",
    description: "Architected a scalable, cloud-native purchase system with full observability on Kubernetes. Implemented ephemeral environments and AOP for logging.",
    tags: ["Kubernetes", "Helm", "Spring Boot", "Grafana Alloy"],
    links: { demo: "#", code: "https://github.com/mohamad4444/Purchase-System-Cloud-Native" },
    strengths: ["Cloud-Native", "Observability", "Automation"],
  },
  {
    title: "Ansible Infrastructure",
    description: "Automated infrastructure provisioning and configuration management using Ansible playbooks. Streamlines deployment processes and ensures environment consistency.",
    tags: ["Ansible", "Python", "DevOps", "IaC"],
    links: { demo: "#", code: "https://github.com/mohamad4444/ansible" },
    strengths: ["Automation", "Infrastructure", "Config Mgmt"],
  },
  {
    title: "Events Management System",
    description: "Designed event-management workflows and developed role/permission systems properly integrated with university processes.",
    tags: ["Java", "Spring MVC", "Tomcat", "Maven"],
    links: { demo: "", code: "" },
    strengths: ["Workflow Design", "RBAC", "Backend"],
  },
  {
    title: "LostNFound App",
    description: "Android application for posting and finding lost items, featuring SQLite integration for local data persistence.",
    tags: ["Java", "Android Studio", "SQLite"],
    links: { demo: "", code: "" },
    strengths: ["Mobile Dev", "Persistence", "UX"],
  }
]

export function Projects() {
  return (
    <Section id="projects" className="bg-secondary/20">
      <div className="text-center mb-16">
        <h2 className="text-3xl md:text-4xl font-bold mb-4">Featured Projects</h2>
        <p className="text-muted-foreground max-w-2xl mx-auto">
          A selection of projects that showcase my passion for building
          complex web applications.
        </p>
      </div>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        {projects.map((project, index) => (
          <motion.div
            key={index}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            whileHover={{ y: -5 }}
            viewport={{ once: true, margin: "-50px" }}
            transition={{ duration: 0.4, delay: index * 0.1, ease: "easeOut" }}
            className="group rounded-2xl overflow-hidden border bg-card hover:shadow-2xl transition-shadow duration-300 flex flex-col"
          >

            
            <div className="p-6 flex flex-col grow">
              <h3 className="text-xl font-bold mb-3 group-hover:text-primary transition-colors">
                {project.title}
              </h3>

              <p className="text-muted-foreground mb-6 line-clamp-3 text-sm grow leading-relaxed">
                {project.description}
              </p>
              
              <div className="flex flex-wrap gap-2 mb-8 mt-auto">
                {project.tags.map((tag) => (
                  <span key={tag} className="px-2.5 py-1 bg-secondary/50 text-secondary-foreground text-xs rounded-md font-medium border border-transparent hover:border-border transition-colors">
                    {tag}
                  </span>
                ))}
              </div>

              <div className="flex gap-3 pt-2 mt-auto border-t">
                {project.links.code && project.links.code !== "" && (
                  <Button variant="ghost" size="sm" className="w-full gap-2 hover:bg-primary/10 hover:text-primary transition-colors" asChild>
                    <a href={project.links.code} aria-label={`View code for ${project.title}`} target="_blank" rel="noopener noreferrer">
                      <Github className="w-4 h-4" /> <span className="font-semibold">Code</span>
                    </a>
                  </Button>
                )}
                {project.links.demo && project.links.demo !== "" && (
                   <Button size="sm" className="w-full gap-2 group/btn shadow-md hover:shadow-lg transition-all" asChild>
                    <a href={project.links.demo} aria-label={`View demo for ${project.title}`} target="_blank" rel="noopener noreferrer">
                      <ExternalLink className="w-4 h-4 group-hover/btn:-translate-y-0.5 group-hover/btn:translate-x-0.5 transition-transform" /> <span className="font-semibold">Live Demo</span>
                    </a>
                  </Button>
                )}
              </div>
            </div>
          </motion.div>
        ))}
      </div>
    </Section>
  )
}
