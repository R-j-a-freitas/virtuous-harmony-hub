import { Facebook, Instagram, Youtube } from "lucide-react";
import logo from "@/assets/logo.jpeg";

const Footer = () => {
  return (
    <footer className="bg-background border-t border-border py-12">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
          {/* Logo and Description */}
          <div>
            <img src={logo} alt="Virtuous Ensemble" className="h-16 w-auto mb-4" />
            <p className="text-muted-foreground font-sans">
              Música elegante e personalizada para casamentos, cerimónias e eventos especiais.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-serif text-lg text-foreground mb-4">Links Rápidos</h3>
            <ul className="space-y-2">
              <li>
                <a href="#about" className="text-muted-foreground hover:text-primary transition-colors font-sans">
                  Sobre
                </a>
              </li>
              <li>
                <a href="#services" className="text-muted-foreground hover:text-primary transition-colors font-sans">
                  Serviços
                </a>
              </li>
              <li>
                <a href="#gallery" className="text-muted-foreground hover:text-primary transition-colors font-sans">
                  Galeria
                </a>
              </li>
              <li>
                <a href="#testimonials" className="text-muted-foreground hover:text-primary transition-colors font-sans">
                  Testemunhos
                </a>
              </li>
              <li>
                <a href="#contact" className="text-muted-foreground hover:text-primary transition-colors font-sans">
                  Contacto
                </a>
              </li>
            </ul>
          </div>

          {/* Social Media */}
          <div>
            <h3 className="font-serif text-lg text-foreground mb-4">Redes Sociais</h3>
            <div className="flex gap-4">
              <a
                href="https://www.instagram.com/virtuousensemble?igsh=cXhpbnpvMXh4b2p4"
                target="_blank"
                rel="noopener noreferrer"
                className="w-10 h-10 rounded-full bg-card border border-border flex items-center justify-center hover:border-primary transition-colors"
              >
                <Instagram className="w-5 h-5 text-foreground" />
              </a>
              <a
                href="https://www.facebook.com/share/1AhZcSBF5B/?mibextid=wwXIfr"
                target="_blank"
                rel="noopener noreferrer"
                className="w-10 h-10 rounded-full bg-card border border-border flex items-center justify-center hover:border-primary transition-colors"
              >
                <Facebook className="w-5 h-5 text-foreground" />
              </a>
              <a
                href="https://www.youtube.com/@VirtuousEnsemble"
                target="_blank"
                rel="noopener noreferrer"
                className="w-10 h-10 rounded-full bg-card border border-border flex items-center justify-center hover:border-primary transition-colors"
              >
                <Youtube className="w-5 h-5 text-foreground" />
              </a>
            </div>
          </div>
        </div>

        <div className="border-t border-border pt-8 text-center">
          <p className="text-muted-foreground font-sans text-sm">
            © {new Date().getFullYear()} Virtuous Ensemble. Todos os direitos reservados.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
