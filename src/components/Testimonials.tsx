import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Star } from "lucide-react";
import { useState } from "react";
import { Button } from "./ui/button";
import { Textarea } from "./ui/textarea";
import { Input } from "./ui/input";
import { useToast } from "@/hooks/use-toast";

const Testimonials = () => {
  const { toast } = useToast();
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [name, setName] = useState("");
  const [content, setContent] = useState("");
  const [rating, setRating] = useState(5);

  const { data: testimonials, refetch } = useQuery({
    queryKey: ["testimonials"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("testimonials")
        .select("*")
        .eq("approved", true)
        .order("created_at", { ascending: false })
        .limit(6);

      if (error) throw error;
      return data;
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!name.trim() || !content.trim()) {
      toast({
        title: "Erro",
        description: "Por favor, preencha todos os campos",
        variant: "destructive",
      });
      return;
    }

    const { error } = await supabase.from("testimonials").insert({
      name: name.trim(),
      content: content.trim(),
      rating,
    });

    if (error) {
      toast({
        title: "Erro",
        description: "Ocorreu um erro ao enviar o testemunho",
        variant: "destructive",
      });
      return;
    }

    toast({
      title: "Sucesso!",
      description: "O seu testemunho foi enviado e será analisado em breve",
    });

    setName("");
    setContent("");
    setRating(5);
    setIsFormOpen(false);
    refetch();
  };

  return (
    <section id="testimonials" className="py-20 md:py-32 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="font-serif text-4xl md:text-5xl text-foreground mb-6">
            Testemunhos
          </h2>
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans mb-8">
            O que os nossos clientes dizem sobre nós
          </p>
          <Button
            onClick={() => setIsFormOpen(!isFormOpen)}
            className="bg-primary text-primary-foreground hover:bg-primary/90"
          >
            {isFormOpen ? "Cancelar" : "Deixar Testemunho"}
          </Button>
        </div>

        {isFormOpen && (
          <div className="max-w-2xl mx-auto mb-16 bg-card border border-border rounded-lg p-8">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Nome</label>
                <Input
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="O seu nome"
                  className="w-full"
                />
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Testemunho</label>
                <Textarea
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  placeholder="Partilhe a sua experiência..."
                  rows={4}
                  className="w-full"
                />
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Avaliação</label>
                <div className="flex gap-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <button
                      key={star}
                      type="button"
                      onClick={() => setRating(star)}
                      className="focus:outline-none"
                    >
                      <Star
                        className={`w-8 h-8 ${
                          star <= rating ? "fill-primary text-primary" : "text-muted-foreground"
                        }`}
                      />
                    </button>
                  ))}
                </div>
              </div>
              <Button type="submit" className="w-full bg-primary text-primary-foreground hover:bg-primary/90">
                Enviar Testemunho
              </Button>
            </form>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials?.map((testimonial) => (
            <div
              key={testimonial.id}
              className="bg-card border border-border rounded-lg p-6 hover:border-primary transition-all"
            >
              <div className="flex gap-1 mb-4">
                {Array.from({ length: testimonial.rating }).map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-primary text-primary" />
                ))}
              </div>
              <p className="text-foreground mb-4 font-sans italic">"{testimonial.content}"</p>
              <p className="text-primary font-serif font-semibold">{testimonial.name}</p>
              {testimonial.event_type && (
                <p className="text-muted-foreground text-sm font-sans">{testimonial.event_type}</p>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
