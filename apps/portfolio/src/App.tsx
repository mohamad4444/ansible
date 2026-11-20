import { ThemeProvider } from "./components/theme-provider"
import { Navbar } from "./components/navbar"
import { Footer } from "./components/footer"
import { Hero } from "./sections/hero"
import { About } from "./sections/about"
import { Skills } from "./sections/skills"
import { Projects } from "./sections/projects"
import { Contact } from "./sections/contact"
import { Toaster } from "@/components/ui/toaster"
import { BrowserRouter, Routes, Route } from "react-router-dom"

function Home() {
  return (
    <>
      <Navbar />
      <main>
        <Hero />
        <About />
        <Skills />
        <Projects />
        <Contact />
      </main>
      <Footer />
    </>
  )
}

function App() {
  return (
    <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <BrowserRouter>
        <div className="min-h-screen bg-background text-foreground transition-colors duration-300">
          <Routes>
            <Route path="/" element={<Home />} />
          </Routes>
          <Toaster />
        </div>
      </BrowserRouter>
    </ThemeProvider>
  )
}

export default App

