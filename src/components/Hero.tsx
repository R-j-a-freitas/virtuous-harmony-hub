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
  return <section className="relative h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0 bg-cover bg-center" style={{
      backgroundImage: `url(${hero3})`
    }}>
        <div className="absolute inset-0 flex items-center justify-center">
          <img src={faixa} alt="Virtuous Ensemble" className="max-w-2xl w-full px-4" />
        </div>
      </div>

      {/* Content */}
      <div className="relative z-10 text-center px-4 max-w-4xl mx-auto mr-[200px]">
        <h1 className="font-serif text-4xl md:text-6xl mb-6 animate-fade-in py-[150px] text-[#e6c068] lg:text-8xl">Harmonia perfeita para 
momentos únicos</h1>
        <p className="text-lg text-muted-foreground mb-8 font-sans animate-fade-in md:text-3xl">Música que eleva o seu evento, com a sofisticação e emoção que merece</p>
        <button onClick={scrollToContact} className="bg-primary text-primary-foreground px-8 py-4 rounded-full text-lg font-sans font-medium hover:bg-primary/90 transition-all hover:scale-105 animate-fade-in">
          Reserve o Seu Evento
        </button>
      </div>
    </section>;
};
export default Hero;