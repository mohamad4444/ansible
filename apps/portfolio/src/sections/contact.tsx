import { Section } from "../components/section"
import { Button } from "../components/ui/button"
import { Mail, Send, Phone, Github, Linkedin } from "lucide-react"
import { useState } from "react"

export function Contact() {
  const [formState, setFormState] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle')
  const [resultMessage, setResultMessage] = useState("")

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setFormState('submitting')
    setResultMessage("")
    const form = e.currentTarget

    const formData = new FormData(form)
    formData.append("access_key", "4a6f4ab2-6798-4da5-baa1-89aa6e45fa7b")

    try {
      const response = await fetch("https://api.web3forms.com/submit", {
        method: "POST",
        body: formData
      })

      const data = await response.json()

      if (data.success) {
        setFormState('success')
        setResultMessage("Message sent successfully!")
        form.reset()
      } else {
        setFormState('error')
        setResultMessage(data.message || "Something went wrong. Please try again.")
      }
    } catch (error) {
      setFormState('error')
      setResultMessage("Failed to send message. Please check your connection.")
    } finally {
        setTimeout(() => {
            if (formState === 'success') setFormState('idle') // Reset after delay if success
        }, 3000)
    }
  }

  return (
    <Section id="contact" className="py-16">
      <div className="text-center mb-12">
          <h2 className="text-3xl font-bold mb-3">Get In Touch</h2>
          <p className="text-muted-foreground max-w-xl mx-auto text-sm">
            Have a project in mind or want to say hello? I'd love to hear from you.
          </p>
      </div>

      <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto bg-card border rounded-2xl p-6 md:p-8 shadow-sm">
        {/* Contact Info */}
        <div className="flex flex-col">
            <div>
                <h3 className="text-xl font-bold mb-3">Let's connect</h3>
                <p className="text-muted-foreground mb-6 text-sm">
                    Open for freelance projects and full-time opportunities.
                </p>

                <div className="space-y-4">
                    <a href="mailto:mzkariyah@gmail.com" className="flex items-center gap-3 group">
                        <div className="p-2 bg-secondary rounded-full group-hover:bg-primary/20 transition-colors">
                            <Mail className="w-4 h-4 text-primary" />
                        </div>
                        <span className="text-sm font-medium text-muted-foreground group-hover:text-foreground transition-colors">mzkariyah@gmail.com</span>
                    </a>
                    
                    <div className="flex items-center gap-3">
                        <div className="p-2 bg-secondary rounded-full">
                            <Phone className="w-4 h-4 text-primary" />
                        </div>
                        <span className="text-sm font-medium text-muted-foreground">+49 17640480072</span>
                    </div>

                    <div className="flex gap-3 pt-2">
                        <a href="https://github.com/mohamad4444" target="_blank" rel="noopener noreferrer" aria-label="GitHub Profile" className="p-2 bg-secondary rounded-full hover:bg-primary/20 hover:text-primary transition-all">
                            <Github className="w-5 h-5" />
                        </a>
                         <a href="https://linkedin.com/in/mohamad4444" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn Profile" className="p-2 bg-secondary rounded-full hover:bg-primary/20 hover:text-primary transition-all">
                            <Linkedin className="w-5 h-5" />
                        </a>
                    </div>
                </div>
            </div>

            <div className="mt-8 pt-6 border-t">
                <p className="text-xs text-muted-foreground">
                    Based in Zweibrücken, Germany
                </p>
            </div>
        </div>

        {/* Contact Form */}
        <div className="bg-secondary/20 p-5 rounded-xl">
            <form onSubmit={handleSubmit} className="space-y-3">
                <input type="hidden" name="subject" value="New Submission from DevPortfolio" />
                
                <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-1.5">
                        <label htmlFor="name" className="text-xs font-medium">Name</label>
                        <input 
                            required
                            id="name"
                            name="name"
                            type="text" 
                            placeholder="John Doe"
                            className="w-full h-9 px-3 rounded-md border bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
                        />
                    </div>
                    <div className="space-y-1.5">
                        <label htmlFor="email" className="text-xs font-medium">Email</label>
                        <input 
                            required
                            id="email"
                            name="email"
                            type="email" 
                            placeholder="john@example.com"
                            className="w-full h-9 px-3 rounded-md border bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
                        />
                    </div>
                </div>
                
                <div className="space-y-1.5">
                    <label htmlFor="message" className="text-xs font-medium">Message</label>
                    <textarea 
                        required
                        id="message"
                        name="message"
                        rows={4}
                        placeholder="Project details..."
                        className="w-full p-3 rounded-md border bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 resize-none"
                    />
                </div>
                
                <Button type="submit" size="sm" className="w-full gap-2 h-9" disabled={formState === 'submitting'}>
                    {formState === 'submitting' ? 'Sending...' : (
                        <>
                            Send Message <Send className="w-3 h-3" />
                        </>
                    )}
                </Button>
                
                {resultMessage && (
                  <p className={`text-xs text-center mt-2 ${formState === 'success' ? 'text-green-500' : 'text-red-500'}`}>
                    {resultMessage}
                  </p>
                )}
            </form>
        </div>
      </div>
    </Section>
  )
}
