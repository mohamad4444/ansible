import { motion } from "framer-motion"
import { Section } from "../components/section"
import { Button } from "../components/ui/button"
import { Github } from "lucide-react"

const projects = [
  {
    title: "Cloud Native Purchase System",
    description: "Scalable purchase and inventory microservices on Kubernetes, packaged with Helm and instrumented for full observability.",
    tags: ["Kubernetes", "Helm", "Spring Boot", "Grafana Alloy"],
    links: { code: "https://github.com/mohamad4444/cloud-native-purchase-system" },
    strengths: ["Cloud-Native", "Observability", "Automation"],
  },
  {
    title: "Ansible Infrastructure",
    description: "Playbooks and roles that provision and manage a VPS: SSH access, firewall, Caddy, and NetBird, with local state sync.",
    tags: ["Ansible", "Python", "DevOps", "IaC"],
    links: { code: "https://github.com/mohamad4444/ansible" },
    strengths: ["Automation", "Infrastructure", "Config Mgmt"],
  },
  {
    title: "Kubernetes Certificate Authority",
    description: "A custom certificate authority for a Kubernetes cluster using cert-manager, with automated issuance and renewal.",
    tags: ["Kubernetes", "cert-manager", "TLS", "YAML"],
    links: { code: "https://github.com/mohamad4444/k8s-certificate-authority" },
    strengths: ["Security", "Kubernetes", "PKI"],
  },
  {
    title: "Terraform AWS Web App Lab",
    description: "Infrastructure as code for a web application on AWS using EC2, an application load balancer, RDS, and S3.",
    tags: ["Terraform", "AWS", "EC2", "RDS"],
    links: { code: "https://github.com/mohamad4444/terraform-aws-webapp-lab" },
    strengths: ["IaC", "Cloud", "Networking"],
  },
  {
    title: "Spring Boot 6 Learning Template",
    description: "A Spring Boot 3.5 / Spring Framework 6 template with a task API, persistence, messaging, and security examples.",
    tags: ["Java", "Spring Boot", "Security", "Messaging"],
    links: { code: "https://github.com/mohamad4444/spring6-learning-template" },
    strengths: ["Backend", "REST APIs", "Spring"],
  },
  {
    title: "Python TOTP Manager",
    description: "Command-line TOTP generator with clipboard support that reads secrets from an external vault file at runtime.",
    tags: ["Python", "CLI", "TOTP", "Security"],
    links: { code: "https://github.com/mohamad4444/python-totp-manager" },
    strengths: ["CLI", "Security", "Packaging"],
  },
  {
    title: "Linux System Automation",
    description: "Administration scripts, installation tasks, infrastructure tooling, and dotfiles for day-to-day Linux operations.",
    tags: ["Bash", "Linux", "Automation", "Dotfiles"],
    links: { code: "https://github.com/mohamad4444/linux-system-automation" },
    strengths: ["Automation", "Sysadmin", "Scripting"],
  },
  {
    title: "Java Annotation Processor",
    description: "Compile-time annotation processor that generates database access classes from annotated DTOs.",
    tags: ["Java", "Annotation Processor", "Codegen"],
    links: { code: "https://github.com/mohamad4444/java-annotation-processor" },
    strengths: ["Backend", "Metaprogramming", "Codegen"],
  },
  {
    title: "DSA Practice Problems",
    description: "A collection of data structures and algorithms solutions with a LeetCode importer for focused practice.",
    tags: ["Java", "Algorithms", "Data Structures"],
    links: { code: "https://github.com/mohamad4444/dsa-practice-problems" },
    strengths: ["Algorithms", "Problem Solving"],
  },
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
              </div>
            </div>
          </motion.div>
        ))}
      </div>
    </Section>
  )
}
