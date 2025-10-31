import { Music, Heart, Star, Users } from "lucide-react";
const About = () => {
  const features = [{
    icon: Music,
    title: "Música Diversa",
    description: "Repertório elegante e sofisticado"
  }, {
    icon: Heart,
    title: "Personalização",
    description: "Adaptamos a música aos seus desejos"
  }, {
    icon: Star,
    title: "Profissionalismo",
    description: "Músicos experientes e dedicados"
  }, {
    icon: Users,
    title: "Experiência",
    description: "Anos de experiência em eventos"
  }];
  return <section id="about" className="py-20 md:py-32 bg-card">
      <div className="container mx-auto px-4">
      <div className="text-center mb-16 animate-fade-in">
        <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">Sobre os Virtuous Ensemble</h2>
        <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">
          Somos um grupo de músicos profissionais dedicados a criar momentos inesquecíveis através da música clássica elegante e personalizada. Com anos de experiência em casamentos, cerimónias e eventos especiais, garantimos que cada performance seja única e memorável.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mt-16">
        {features.map((feature, index) => <div key={index} className="text-center p-6 rounded-lg bg-background border border-border hover:border-primary transition-all hover:scale-105 animate-fade-in" style={{
              animationDelay: `${index * 0.1}s`
            }}>
              <feature.icon className="w-12 h-12 text-primary mx-auto mb-4" />
              <h3 className="font-serif mb-2 text-4xl text-[#e6c068]">{feature.title}</h3>
              <p className="text-muted-foreground font-sans">{feature.description}</p>
            </div>)}
        </div>
      </div>
    </section>;
};
export default About;