import { useState, useEffect } from "react";
import { Menu, X } from "lucide-react";
import logo from "@/assets/logo.jpeg";

const Navbar = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: "smooth" });
      setIsMobileMenuOpen(false);
    }
  };

  return (
    <nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled ? "bg-background/95 backdrop-blur-md border-b border-border" : "bg-transparent"
      }`}
    >
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <img src={logo} alt="Virtuous Ensemble" className="h-12 md:h-16 w-auto" />

          {/* Desktop Menu */}
          <div className="hidden md:flex items-center gap-8">
            <button
              onClick={() => scrollToSection("about")}
              className="text-foreground hover:text-primary transition-colors font-sans"
            >
              Sobre
            </button>
            <button
              onClick={() => scrollToSection("services")}
              className="text-foreground hover:text-primary transition-colors font-sans"
            >
              Serviços
            </button>
            <button
              onClick={() => scrollToSection("gallery")}
              className="text-foreground hover:text-primary transition-colors font-sans"
            >
              Galeria
            </button>
            <button
              onClick={() => scrollToSection("testimonials")}
              className="text-foreground hover:text-primary transition-colors font-sans"
            >
              Testemunhos
            </button>
            <button
              onClick={() => scrollToSection("contact")}
              className="bg-primary text-primary-foreground px-6 py-2 rounded-full hover:bg-primary/90 transition-all font-sans font-medium"
            >
              Contacto
            </button>
          </div>

          {/* Mobile Menu Button */}
          <button
            className="md:hidden text-foreground"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {/* Mobile Menu */}
        {isMobileMenuOpen && (
          <div className="md:hidden mt-4 py-4 border-t border-border">
            <div className="flex flex-col gap-4">
              <button
                onClick={() => scrollToSection("about")}
                className="text-foreground hover:text-primary transition-colors font-sans text-left"
              >
                Sobre
              </button>
              <button
                onClick={() => scrollToSection("services")}
                className="text-foreground hover:text-primary transition-colors font-sans text-left"
              >
                Serviços
              </button>
              <button
                onClick={() => scrollToSection("gallery")}
                className="text-foreground hover:text-primary transition-colors font-sans text-left"
              >
                Galeria
              </button>
              <button
                onClick={() => scrollToSection("testimonials")}
                className="text-foreground hover:text-primary transition-colors font-sans text-left"
              >
                Testemunhos
              </button>
              <button
                onClick={() => scrollToSection("contact")}
                className="bg-primary text-primary-foreground px-6 py-2 rounded-full hover:bg-primary/90 transition-all font-sans font-medium text-center"
              >
                Contacto
              </button>
            </div>
          </div>
        )}
      </div>
    </nav>
  );
};

export default Navbar;
