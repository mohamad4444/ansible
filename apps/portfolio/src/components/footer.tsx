import { Github, Linkedin, Terminal, Mail, ArrowUpRight } from "lucide-react"

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="bg-background border-t pt-16 pb-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid md:grid-cols-4 gap-12 mb-16">
          
          {/* Brand Column */}
          <div className="col-span-1 md:col-span-2 space-y-4">
            <div className="flex items-center gap-2">
                <div className="p-2 bg-primary/10 rounded-lg">
                    <Terminal className="h-6 w-6 text-primary" />
                </div>
                <span className="font-bold text-xl tracking-tighter">Mohammad Mahamid</span>
            </div>
            <p className="text-muted-foreground max-w-sm leading-relaxed">
                DevOps Engineer & Full Stack Developer. <br />
                Building robust, scalable, and automated cloud infrastructure with modern web technologies.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-semibold mb-4 text-primary">Quick Links</h3>
            <ul className="space-y-3">
                {['About', 'Skills', 'Projects', 'Contact'].map((item) => (
                    <li key={item}>
                        <a 
                            href={`#${item.toLowerCase()}`} 
                            className="text-muted-foreground hover:text-primary transition-colors inline-block hover:translate-x-1 duration-200"
                        >
                            {item}
                        </a>
                    </li>
                ))}
            </ul>
          </div>

          {/* Connect */}
          <div>
             <h3 className="font-semibold mb-4 text-primary">Connect</h3>
             <ul className="space-y-4">
                <li>
                    <a 
                        href="https://github.com/mohamad4444" 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="flex items-center gap-2 text-muted-foreground hover:text-primary transition-colors group"
                    >
                        <Github className="w-4 h-4" /> 
                        <span>GitHub</span>
                        <ArrowUpRight className="w-3 h-3 opacity-0 -translate-y-1 group-hover:opacity-100 group-hover:translate-y-0 transition-all" />
                    </a>
                </li>
                <li>
                    <a 
                        href="https://linkedin.com/in/mohamad4444" 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="flex items-center gap-2 text-muted-foreground hover:text-primary transition-colors group"
                    >
                        <Linkedin className="w-4 h-4" /> 
                        <span>LinkedIn</span>
                        <ArrowUpRight className="w-3 h-3 opacity-0 -translate-y-1 group-hover:opacity-100 group-hover:translate-y-0 transition-all" />
                    </a>
                </li>

                <li>
                    <a 
                        href="mailto:mzkariyah@gmail.com" 
                        className="flex items-center gap-2 text-muted-foreground hover:text-primary transition-colors group"
                    >
                        <Mail className="w-4 h-4" /> 
                        <span>Email</span>
                        <ArrowUpRight className="w-3 h-3 opacity-0 -translate-y-1 group-hover:opacity-100 group-hover:translate-y-0 transition-all" />
                    </a>
                </li>
             </ul>
          </div>
        </div>

        <div className="border-t pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-muted-foreground">
            <p>© {currentYear} Mohammad Mahamid. All rights reserved.</p>
            <p className="flex items-center gap-1">
                Designed & Built with <span className="text-red-500 animate-pulse">❤️</span> using React & Tailwind
            </p>
        </div>
      </div>
    </footer>
  )
}
