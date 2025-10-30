import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Calendar, MapPin, Clock } from "lucide-react";
const PublicEvents = () => {
  const {
    data: events,
    isLoading,
    error
  } = useQuery({
    queryKey: ["public-events"],
    queryFn: async () => {
      // Usar a view pública que não expõe dados sensíveis dos clientes
      const {
        data,
        error
      } = await supabase.from("public_events").select("*").order("event_date", {
        ascending: true
      });
      if (error) {
        // Fallback: se a view não existir, usar query direta apenas com campos públicos
        console.warn("View public_events não encontrada, usando fallback:", error);
        const {
          data: fallbackData,
          error: fallbackError
        } = await supabase.from("events").select("id, title, event_date, event_time, location, status, created_at").eq("status", "confirmed").order("event_date", {
          ascending: true
        });
        if (fallbackError) throw fallbackError;
        return fallbackData;
      }
      return data;
    }
  });
  if (isLoading) {
    return <section className="py-20 md:py-32 bg-background">
        <div className="container mx-auto px-4">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
            <p className="mt-4 text-muted-foreground">A carregar eventos...</p>
          </div>
        </div>
      </section>;
  }
  if (error) {
    return <section className="py-20 md:py-32 bg-background">
        <div className="container mx-auto px-4">
          <div className="text-center">
            <p className="text-red-500">Erro ao carregar eventos</p>
          </div>
        </div>
      </section>;
  }
  return <section id="events" className="py-20 md:py-32 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">
            Próximos Eventos
          </h2>
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">
            Eventos confirmados que temos o prazer de organizar
          </p>
        </div>

        {events && events.length > 0 ? <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {events.map(event => <div key={event.id} className="bg-card border border-border rounded-lg p-6 hover:border-primary transition-all">
                <div className="flex items-center gap-2 mb-4">
                  <Calendar className="w-5 h-5 text-primary" />
                  <span className="text-sm text-muted-foreground">
                    {new Date(event.event_date).toLocaleDateString('pt-PT', {
                day: '2-digit',
                month: 'long',
                year: 'numeric'
              })}
                  </span>
                </div>
                
                <h3 className="font-serif mb-3 text-2xl text-[#e6c068] font-extralight">
                  {event.title}
                </h3>
                
                <div className="space-y-2 mb-4">
                  <div className="flex items-center gap-2">
                    <MapPin className="w-4 h-4 text-muted-foreground" />
                    <span className="text-sm text-muted-foreground">{event.location}</span>
                  </div>
                  
                  {event.event_time && <div className="flex items-center gap-2">
                      <Clock className="w-4 h-4 text-muted-foreground" />
                      <span className="text-sm text-muted-foreground">
                        {event.event_time}
                      </span>
                    </div>}
                </div>
              </div>)}
          </div> : <div className="text-center">
            <div className="bg-card border border-border rounded-lg p-12">
              <Calendar className="w-16 h-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="font-serif text-xl font-semibold text-foreground mb-2">
                Nenhum evento confirmado
              </h3>
              <p className="text-muted-foreground font-sans">
                Ainda não temos eventos confirmados para mostrar. 
                Entre em contacto connosco para organizar o seu evento especial!
              </p>
            </div>
          </div>}
      </div>
    </section>;
};
export default PublicEvents;