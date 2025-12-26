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
      
      // Insert testimonial into database
      const {
        error: dbError
      } = await supabase.from("testimonials").insert({
        name: sanitizedName.trim(),
        content: sanitizedContent.trim(),
        rating,
        approved: false // Sempre começa como não aprovado
      });
      
      if (dbError) {
        console.error("Database error:", dbError);
        console.error("Error code:", dbError.code);
        console.error("Error message:", dbError.message);
        console.error("Error details:", dbError.details);
        console.error("Error hint:", dbError.hint);
        
        // Mostrar mensagem de erro mais específica
        let errorMessage = "Ocorreu um erro ao enviar o testemunho. Tente novamente.";
        if (dbError.code === '42501' || dbError.message?.includes('permission') || dbError.message?.includes('policy')) {
          errorMessage = "Erro de permissão. Verifique se a política RLS permite inserção pública de testemunhos.";
        } else if (dbError.message) {
          errorMessage = `Erro: ${dbError.message}`;
        }
        
        toast({
          title: "Erro ao Enviar",
          description: errorMessage,
          variant: "destructive"
        });
        setIsSubmitting(false);
        return;
      }

      // Send email notification
      let emailSent = false;
      let errorMessage = "";
      try {
        console.log("📧 Attempting to send testimonial email via edge function...");
        console.log("📧 Function name: send-testimonial-email");
        console.log("📧 Data being sent:", {
          name: sanitizedName.trim(),
          content: sanitizedContent.trim().substring(0, 50) + "...",
          rating
        });
        
        const {
          data,
          error: emailError
        } = await supabase.functions.invoke("send-testimonial-email", {
          body: {
            name: sanitizedName.trim(),
            content: sanitizedContent.trim(),
            rating
          }
        });
        
        console.log("📧 Function response received:", {
          data,
          error: emailError,
          hasData: !!data,
          hasError: !!emailError
        });
        
        if (emailError) {
          console.error("❌ Supabase function error:", emailError);
          console.error("❌ Error type:", typeof emailError);
          console.error("❌ Error details:", JSON.stringify(emailError, null, 2));
          
          // Check for specific error types
          if (emailError.message?.includes('not found') || emailError.message?.includes('404')) {
            errorMessage = "Edge function 'send-testimonial-email' não encontrada. Verifique se está deployada no Supabase.";
          } else if (emailError.message?.includes('CORS') || emailError.message?.includes('cors')) {
            errorMessage = "Erro de CORS. A função não está retornando headers CORS corretos.";
          } else if (emailError.message?.includes('Failed to send a request')) {
            errorMessage = "Não foi possível conectar à edge function. Verifique se está deployada e acessível.";
          } else {
            errorMessage = emailError.message || emailError.toString() || JSON.stringify(emailError);
          }
          emailSent = false;
        } else if (data) {
          console.log("✅ Function response data:", data);
          if (data.success === true || data.success === false) {
            emailSent = data.success;
            if (!data.success && data.error) {
              errorMessage = data.error.message || data.error || "Erro ao enviar email";
              console.error("❌ Email sending failed:", data.error);
            } else {
              console.log("✅ Email sent successfully according to response");
            }
          } else if (data.message || data.emailId) {
            emailSent = true;
            console.log("✅ Email sent successfully (message or emailId present)");
          } else if (data.error) {
            errorMessage = data.error.message || data.error || "Erro desconhecido";
            emailSent = false;
            console.error("❌ Error in response data:", data.error);
          } else {
            emailSent = !data.error;
            console.log("⚠️ No explicit success, but no error either. Assuming success.");
          }
        } else {
          console.log("⚠️ No data or error returned, assuming success");
          emailSent = true;
        }
      } catch (err: any) {
        console.error("❌ Exception calling edge function:", err);
        console.error("❌ Error name:", err?.name);
        console.error("❌ Error message:", err?.message);
        console.error("❌ Error stack:", err?.stack);
        console.error("❌ Full error:", JSON.stringify(err, Object.getOwnPropertyNames(err), 2));
        
        // Check for specific error types
        if (err?.message?.includes('not found') || err?.message?.includes('404')) {
          errorMessage = "Edge function 'send-testimonial-email' não encontrada (404). Verifique se está deployada no Supabase.";
        } else if (err?.message?.includes('CORS') || err?.message?.includes('cors')) {
          errorMessage = "Erro de CORS. A função não está retornando headers CORS corretos.";
        } else if (err?.message?.includes('Failed to send a request')) {
          errorMessage = "Não foi possível conectar à edge function. Verifique se está deployada e acessível.";
        } else {
          errorMessage = err?.message || err?.toString() || "Erro desconhecido ao chamar o serviço de email";
        }
        emailSent = false;
      }

      // Show success message regardless of email status (testimonial was saved)
      toast({
        title: "Sucesso!",
        description: emailSent 
          ? "O seu testemunho foi enviado e será analisado em breve. Receberá uma notificação por email."
          : "O seu testemunho foi enviado e será analisado em breve."
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
        <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans mb-8">O que dizem sobre nós</p>
        <Button onClick={() => setIsFormOpen(!isFormOpen)} className="bg-primary text-primary-foreground hover:bg-primary/90">
          {isFormOpen ? "Cancelar" : "Deixar Testemunho"}
        </Button>
      </div>

      {isFormOpen && (
        <form onSubmit={handleSubmit} className="max-w-2xl mx-auto mb-16 bg-card border border-border rounded-lg p-8 animate-fade-in">
          <h3 className="text-2xl font-serif text-foreground mb-6">Deixe o seu testemunho</h3>
          
          <div className="space-y-6">
            <div>
              <label className="block text-foreground mb-2 font-sans">Nome *</label>
              <Input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="O seu nome"
                required
                maxLength={100}
                className={errors.name ? "border-red-500" : ""}
                disabled={isSubmitting}
              />
              {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
            </div>

            <div>
              <label className="block text-foreground mb-2 font-sans">Avaliação *</label>
              <div className="flex gap-2">
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    key={star}
                    type="button"
                    onClick={() => setRating(star)}
                    disabled={isSubmitting}
                    className="focus:outline-none"
                  >
                    <Star
                      className={`w-8 h-8 ${
                        star <= rating
                          ? "fill-primary text-primary"
                          : "fill-none text-muted-foreground"
                      } transition-colors`}
                    />
                  </button>
                ))}
              </div>
              {errors.rating && <p className="text-red-500 text-sm mt-1">{errors.rating}</p>}
            </div>

            <div>
              <label className="block text-foreground mb-2 font-sans">Testemunho *</label>
              <Textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Partilhe a sua experiência connosco..."
                required
                rows={6}
                maxLength={1000}
                className={errors.content ? "border-red-500" : ""}
                disabled={isSubmitting}
              />
              {errors.content && <p className="text-red-500 text-sm mt-1">{errors.content}</p>}
              <p className="text-sm text-muted-foreground mt-1">
                {content.length}/1000 caracteres
              </p>
            </div>

            <Button
              type="submit"
              disabled={isSubmitting}
              className="w-full bg-primary text-primary-foreground hover:bg-primary/90"
            >
              {isSubmitting ? "A enviar..." : "Enviar Testemunho"}
            </Button>
          </div>
        </form>
      )}

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