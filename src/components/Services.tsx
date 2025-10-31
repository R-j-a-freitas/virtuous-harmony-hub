import { Check } from "lucide-react";
const Services = () => {
  const services = [{
    title: "Casamentos",
    description: "Música elegante para cerimónias e recepções",
    features: ["Entrada dos noivos", "Cerimónia completa (religiosa e civil)", "Cocktail de boas-vindas"]
  }, {
    title: "Eventos Corporativos",
    description: "Sofisticação para eventos empresariais",
    features: ["Jantares de gala", "Cocktails corporativos", "Lançamentos de produtos", "Conferências"]
  }, {
    title: "Eventos Privados",
    description: "Momentos especiais com música personalizada",
    features: ["Aniversários", "Celebrações familiares", "Jantares privados", "Eventos temáticos"]
  }];
  return <section id="services" className="py-20 md:py-32 bg-background">
      <div className="container mx-auto px-4">
      <div className="text-center mb-16 animate-fade-in">
        <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">
          Os Nossos Serviços
        </h2>
        <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">
          Oferecemos música ao vivo personalizada para diversos tipos de eventos, sempre com o mais alto nível de profissionalismo e elegância.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {services.map((service, index) => <div key={index} className="bg-card border border-border rounded-lg p-8 hover:border-primary transition-all hover:scale-105 animate-fade-in" style={{
              animationDelay: `${index * 0.15}s`
            }}>
              <h3 className="font-serif mb-3 text-4xl text-[#e6c068]">{service.title}</h3>
              <p className="text-muted-foreground mb-6 font-sans">{service.description}</p>
              <ul className="space-y-3">
                {service.features.map((feature, idx) => <li key={idx} className="flex items-center gap-2 text-foreground font-sans">
                    <Check className="w-5 h-5 text-primary flex-shrink-0" />
                    {feature}
                  </li>)}
              </ul>
            </div>)}
        </div>
      </div>
    </section>;
};
export default Services;