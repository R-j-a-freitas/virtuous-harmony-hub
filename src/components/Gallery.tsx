import gallery1 from "@/Galeria/1.jpeg";
import gallery2 from "@/Galeria/2.jpeg";
import gallery3 from "@/Galeria/3.jpeg";
import gallery4 from "@/Galeria/4.jpeg";
const Gallery = () => {
  const images = [{
    src: gallery1,
    alt: "Performance em casamento elegante"
  }, {
    src: gallery2,
    alt: "Quarteto de cordas em cerimónia"
  }, {
    src: gallery3,
    alt: "Música ao vivo em recepção"
  }, {
    src: gallery4,
    alt: "Ensemble em evento ao ar livre"
  }];
  return <section id="gallery" className="py-20 md:py-32 bg-card">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">
            Galeria
          </h2>
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">
            Momentos especiais capturados durante os nossos eventos
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {images.map((image, index) => <div key={index} className="relative overflow-hidden rounded-lg group aspect-[4/3]">
              <img src={image.src} alt={image.alt} className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-background/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
            </div>)}
        </div>
      </div>
    </section>;
};
export default Gallery;