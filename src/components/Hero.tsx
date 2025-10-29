import heroImage from "@/assets/hero-image.jpg";
import hero3 from "@/assets/hero3.png";
const Hero = () => {
  const scrollToContact = () => {
    const element = document.getElementById("contact");
    if (element) {
      element.scrollIntoView({
        behavior: "smooth"
      });
    }
  };
  return <section className="relative h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0 bg-cover bg-center" style={{
      backgroundImage: `url(${hero3})`
    }}>
        <div className="absolute inset-0 bg-gradient-to-b from-background/80 via-background/60 to-background/90" />
      </div>

      {/* Content */}
      <div className="relative z-10 text-center px-4 max-w-4xl mx-auto mr-[200px]">
        <h1 className="font-serif text-4xl md:text-6xl lg:text-7xl text-foreground mb-6 animate-fade-in">

A Harmonia Perfeita para os Seus Momentos Únicos</h1>
        <p className="text-lg md:text-xl text-muted-foreground mb-8 font-sans animate-fade-in">Música que eleva o seu evento, com a sofisticação e emoção que merece</p>
        <button onClick={scrollToContact} className="bg-primary text-primary-foreground px-8 py-4 rounded-full text-lg font-sans font-medium hover:bg-primary/90 transition-all hover:scale-105 animate-fade-in">
          Reserve o Seu Evento
        </button>
      </div>
    </section>;
};
export default Hero;