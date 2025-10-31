import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
const Gallery = () => {
  // Buscar imagens visíveis da galeria
  const {
    data: galleryImages = []
  } = useQuery({
    queryKey: ["gallery-images"],
    queryFn: async () => {
      const {
        data,
        error
      } = await supabase.from("gallery_images").select("id, image_url, title, description, alt_text, display_order, is_visible, created_at, updated_at").eq("is_visible", true).order("display_order", {
        ascending: true
      });
      if (error) {
        console.error("Error fetching gallery images:", error);
        return [];
      }
      return data || [];
    }
  });
  return <section id="gallery" className="py-20 md:py-32 bg-card">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">
            Galeria
          </h2>
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">Momentos especiais captados nos nossos eventos</p>
        </div>

        {galleryImages.length === 0 ? <p className="text-center text-muted-foreground">
            Nenhuma imagem disponível no momento.
          </p> : <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {galleryImages.map(image => <div key={image.id} className="relative overflow-hidden rounded-lg group aspect-[4/3]">
                <img src={image.image_url} alt={image.alt_text || image.title || "Imagem da galeria"} className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" onError={e => {
            console.error("Erro ao carregar imagem:", image.image_url, e);
            const target = e.target as HTMLImageElement;
            target.style.display = 'none';
          }} loading="lazy" />
                <div className="absolute inset-0 bg-gradient-to-t from-background/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  {image.title && <div className="absolute bottom-4 left-4 right-4">
                      <h3 className="text-white font-extralight text-base">
                        {image.title}
                      </h3>
                      {image.description && <p className="text-white/80 text-sm mt-1 font-sans font-normal">
                          {image.description}
                        </p>}
                    </div>}
                </div>
              </div>)}
          </div>}
      </div>
    </section>;
};
export default Gallery;