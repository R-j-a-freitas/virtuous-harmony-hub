import heroImage from "@/assets/hero-image.jpg";
import hero3 from "@/assets/hero3.png";
import faixa from "@/assets/faixa.png";
const Hero = () => {
  const scrollToContact = () => {
    const element = document.getElementById("contact");
    if (element) {
      element.scrollIntoView({
        behavior: "smooth"
      });
    }
  };
  return <section className="relative min-h-screen flex flex-col overflow-hidden">
      {/* Background Image */}
      <div className="w-full h-[60vh] bg-cover bg-center" style={{
      backgroundImage: `url(${faixa})`
    }}>
      </div>

      {/* Content */}
      <div className="flex-1 flex items-center justify-center px-4 py-16 bg-background">
        <div className="text-center max-w-4xl mx-auto">
          <h1 className="font-serif text-4xl md:text-6xl lg:text-8xl mb-6 animate-fade-in text-gold">
            Harmonia perfeita para momentos únicos
          </h1>
          <p className="text-lg md:text-3xl text-muted-foreground mb-8 font-sans animate-fade-in">
            Música que eleva o seu evento, com a sofisticação e emoção que merece
          </p>
          <button onClick={scrollToContact} className="bg-primary text-primary-foreground px-8 py-4 rounded-full text-lg font-sans font-medium hover:bg-primary/90 transition-all hover:scale-105 animate-fade-in">
            Reserve o Seu Evento
          </button>
        </div>
      </div>
    </section>;
};
export default Hero;