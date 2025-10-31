import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { Star } from "lucide-react";
import { useState } from "react";
import { Button } from "./ui/button";
import { Textarea } from "./ui/textarea";
import { Input } from "./ui/input";
import { useToast } from "@/hooks/use-toast";
import { z } from "zod";

// Input validation schema for testimonials
const testimonialSchema = z.object({
  name: z.string().min(2, "Nome deve ter pelo menos 2 caracteres").max(100, "Nome não pode exceder 100 caracteres").regex(/^[a-zA-ZÀ-ÿ\s]+$/, "Nome deve conter apenas letras e espaços"),
  content: z.string().min(10, "Testemunho deve ter pelo menos 10 caracteres").max(1000, "Testemunho não pode exceder 1000 caracteres"),
  rating: z.number().min(1, "Avaliação deve ser pelo menos 1 estrela").max(5, "Avaliação não pode exceder 5 estrelas")
});
type TestimonialFormData = z.infer<typeof testimonialSchema>;
const Testimonials = () => {
  const {
    toast
  } = useToast();
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [name, setName] = useState("");
  const [content, setContent] = useState("");
  const [rating, setRating] = useState(5);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const {
    data: testimonials,
    refetch
  } = useQuery({
    queryKey: ["testimonials"],
    queryFn: async () => {
      const {
        data,
        error
      } = await supabase.from("testimonials").select("*").eq("approved", true).order("created_at", {
        ascending: false
      }).limit(6);
      if (error) throw error;
      return data;
    }
  });
  const validateForm = (): boolean => {
    try {
      testimonialSchema.parse({
        name,
        content,
        rating
      });
      setErrors({});
      return true;
    } catch (error) {
      if (error instanceof z.ZodError) {
        const newErrors: Record<string, string> = {};
        error.errors.forEach(err => {
          if (err.path[0]) {
            newErrors[err.path[0] as string] = err.message;
          }
        });
        setErrors(newErrors);
      }
      return false;
    }
  };
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    // Validate form data
    if (!validateForm()) {
      toast({
        title: "Erro de Validação",
        description: "Por favor, corrija os erros no formulário",
        variant: "destructive"
      });
      setIsSubmitting(false);
      return;
    }
    try {
      // Sanitize inputs to prevent XSS
      const sanitizedName = name.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
      const sanitizedContent = content.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
      const {
        error
      } = await supabase.from("testimonials").insert({
        name: sanitizedName.trim(),
        content: sanitizedContent.trim(),
        rating,
        approved: false // Sempre começa como não aprovado
      });
      if (error) {
        console.error("Database error:", error);
        toast({
          title: "Erro",
          description: "Ocorreu um erro ao enviar o testemunho. Tente novamente.",
          variant: "destructive"
        });
        setIsSubmitting(false);
        return;
      }
      toast({
        title: "Sucesso!",
        description: "O seu testemunho foi enviado e será analisado em breve"
      });
      setName("");
      setContent("");
      setRating(5);
      setErrors({});
      setIsFormOpen(false);
      refetch();
    } catch (error) {
      console.error("Unexpected error:", error);
      toast({
        title: "Erro",
        description: "Ocorreu um erro inesperado. Tente novamente.",
        variant: "destructive"
      });
    } finally {
      setIsSubmitting(false);
    }
  };
  return <section id="testimonials" className="py-20 md:py-32 bg-background">
      <div className="container mx-auto px-4">
      <div className="text-center mb-16 animate-fade-in">
        <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">
          Testemunhos
        </h2>
        <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans mb-8">O que os nossos clientes dizem sobre nós</p>
        <Button onClick={() => setIsFormOpen(!isFormOpen)} className="bg-primary text-primary-foreground hover:bg-primary/90">
          {isFormOpen ? "Cancelar" : "Deixar Testemunho"}
        </Button>
      </div>

      {isFormOpen && <div className="max-w-2xl mx-auto mb-16 bg-card border border-border rounded-lg p-8 animate-fade-in">
...
        </div>}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {testimonials?.map((testimonial, index) => <div key={testimonial.id} className="bg-card border border-border rounded-lg p-6 hover:border-primary transition-all animate-fade-in" style={{
                animationDelay: `${index * 0.1}s`
              }}>
              <div className="flex gap-1 mb-4">
                {Array.from({
              length: testimonial.rating
            }).map((_, i) => <Star key={i} className="w-5 h-5 fill-primary text-primary" />)}
              </div>
              <p className="text-foreground mb-4 font-sans italic">"{testimonial.content}"</p>
              <p className="text-primary font-serif font-thin text-2xl">{testimonial.name}</p>
              {testimonial.event_type && <p className="text-muted-foreground text-sm font-sans">{testimonial.event_type}</p>}
            </div>)}
        </div>
      </div>
    </section>;
};
export default Testimonials;