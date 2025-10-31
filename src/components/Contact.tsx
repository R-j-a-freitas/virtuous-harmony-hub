import { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";
import TimePicker from "./ui/time-picker";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/integrations/supabase/client";
import { z } from "zod";

// Input validation schema with security constraints
const contactFormSchema = z.object({
  name: z.string().min(2, "Nome deve ter pelo menos 2 caracteres").max(100, "Nome não pode exceder 100 caracteres").regex(/^[a-zA-ZÀ-ÿ\s]+$/, "Nome deve conter apenas letras e espaços"),
  email: z.string().email("Email inválido").max(255, "Email não pode exceder 255 caracteres"),
  phone: z.string().min(9, "Telemóvel deve ter pelo menos 9 dígitos").max(20, "Telemóvel não pode exceder 20 caracteres").regex(/^[\+]?[0-9\s\-\(\)]+$/, "Formato de telemóvel inválido"),
  date: z.string().min(1, "Data é obrigatória").refine(date => {
    const selectedDate = new Date(date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return selectedDate >= today;
  }, "Data deve ser hoje ou no futuro"),
  location: z.string().min(3, "Local deve ter pelo menos 3 caracteres").max(200, "Local não pode exceder 200 caracteres"),
  time: z.string().optional(),
  message: z.string().max(2000, "Mensagem não pode exceder 2000 caracteres").optional().default("")
});
type ContactFormData = z.infer<typeof contactFormSchema>;
const Contact = () => {
  const {
    toast
  } = useToast();
  const [formData, setFormData] = useState<ContactFormData>({
    name: "",
    email: "",
    phone: "",
    date: "",
    location: "",
    time: "",
    message: ""
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const {
      name,
      value
    } = e.target;

    // Sanitize input to prevent XSS
    const sanitizedValue = value.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');
    setFormData(prev => ({
      ...prev,
      [name]: sanitizedValue
    }));

    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ""
      }));
    }
  };
  const validateForm = (): boolean => {
    try {
      contactFormSchema.parse(formData);
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
      // Save to database with validated data
      const {
        error: dbError
      } = await supabase.from("events").insert({
        title: `Evento - ${formData.name}`,
        event_date: formData.date,
        event_time: formData.time || null,
        location: formData.location,
        description: formData.message || null,
        client_name: formData.name,
        client_email: formData.email,
        client_phone: formData.phone,
        status: "pending"
      });
      if (dbError) {
        console.error("Database error:", dbError);
        toast({
          title: "Erro",
          description: "Ocorreu um erro ao guardar os dados. Tente novamente.",
          variant: "destructive"
        });
        setIsSubmitting(false);
        return;
      }

      // Call edge function to send email
      let emailSent = false;
      let errorMessage = "";
      try {
        console.log("📧 Attempting to send email via edge function 'resend-email'...");
        console.log("📧 Form data:", formData);
        const {
          data,
          error: emailError
        } = await supabase.functions.invoke("resend-email", {
          body: formData
        });
        console.log("📧 Response received:", {
          data,
          error: emailError
        });
        if (emailError) {
          console.error("❌ Supabase function error:", emailError);
          console.error("❌ Error type:", typeof emailError);
          console.error("❌ Error details:", JSON.stringify(emailError, null, 2));
          errorMessage = emailError.message || emailError.toString() || JSON.stringify(emailError);
          emailSent = false;
        } else if (data) {
          console.log("✅ Function response:", data);
          if (data.success === true || data.success === false) {
            emailSent = data.success;
            if (!data.success && data.error) {
              errorMessage = data.error.message || data.error || "Erro ao enviar email";
            }
          } else if (data.message || data.emailId) {
            emailSent = true;
          } else if (data.error) {
            errorMessage = data.error.message || data.error || "Erro desconhecido";
            emailSent = false;
          } else {
            // Se não tem success, assume sucesso se não tem error
            emailSent = !data.error;
          }
        } else {
          // Se não tem data nem error, assume que funcionou
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
          errorMessage = "Edge function 'resend-email' não encontrada (404). Verifique se está deployada no Supabase.";
        } else if (err?.message?.includes('CORS') || err?.message?.includes('cors') || err?.message?.includes('CORS')) {
          errorMessage = "Erro de CORS. A função não está retornando headers CORS corretos.";
        } else if (err?.message?.includes('Failed to send a request')) {
          errorMessage = "Não foi possível conectar à edge function. Verifique se está deployada e acessível.";
        } else {
          errorMessage = err?.message || err?.toString() || "Erro desconhecido ao chamar o serviço de email";
        }
        emailSent = false;
      }

      // Show appropriate message based on email status
      if (emailSent) {
        toast({
          title: "✅ Sucesso!",
          description: "A sua mensagem foi enviada. Entraremos em contacto em breve!"
        });
      } else {
        toast({
          title: "⚠️ Formulário Enviado",
          description: `Os seus dados foram guardados. Erro ao enviar email: ${errorMessage || "Erro desconhecido"}. Verifique o console (F12) ou contacte-nos em virtuousensemble@gmail.com`,
          variant: "destructive"
        });
      }

      // Reset form
      setFormData({
        name: "",
        email: "",
        phone: "",
        date: "",
        location: "",
        time: "",
        message: ""
      });
      setErrors({});
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
  return <section id="contact" className="py-20 md:py-32 bg-card">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="font-serif text-4xl text-foreground mb-6 md:text-7xl">
            Contacte-nos
          </h2>
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">Cada detalhe conta e o nosso compromisso é transformar o seu momento num evento inesquecível, com alma, dedicação e excelência.</p>
        </div>

        <div className="max-w-3xl mx-auto">
          <form onSubmit={handleSubmit} className="space-y-6 bg-background border border-border rounded-lg p-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Nome *</label>
                <Input name="name" value={formData.name} onChange={handleChange} placeholder="O seu nome" required maxLength={100} className={errors.name ? "border-red-500" : ""} />
                {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Email *</label>
                <Input name="email" type="email" value={formData.email} onChange={handleChange} placeholder="email@exemplo.com" required maxLength={255} className={errors.email ? "border-red-500" : ""} />
                {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Telemóvel *</label>
                <Input name="phone" type="tel" value={formData.phone} onChange={handleChange} placeholder="+351 ..." required maxLength={20} className={errors.phone ? "border-red-500" : ""} />
                {errors.phone && <p className="text-red-500 text-sm mt-1">{errors.phone}</p>}
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Data da Cerimónia *</label>
                <Input name="date" type="date" value={formData.date} onChange={handleChange} required min={new Date().toISOString().split('T')[0]} className={errors.date ? "border-red-500" : ""} />
                {errors.date && <p className="text-red-500 text-sm mt-1">{errors.date}</p>}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Local *</label>
                <Input name="location" value={formData.location} onChange={handleChange} placeholder="Local do evento" required maxLength={200} className={errors.location ? "border-red-500" : ""} />
                {errors.location && <p className="text-red-500 text-sm mt-1">{errors.location}</p>}
              </div>
              <div>
                <TimePicker value={formData.time} onChange={value => setFormData(prev => ({
                ...prev,
                time: value
              }))} label="Hora" placeholder="Selecione a hora do evento" />
              </div>
            </div>

            <div>
              <label className="block text-foreground mb-2 font-sans">Mensagem</label>
              <Textarea name="message" value={formData.message} onChange={handleChange} placeholder="Conte-nos mais sobre o seu evento..." rows={6} maxLength={2000} className={errors.message ? "border-red-500" : ""} />
              {errors.message && <p className="text-red-500 text-sm mt-1">{errors.message}</p>}
              <p className="text-sm text-muted-foreground mt-1">
                {formData.message.length}/2000 caracteres
              </p>
            </div>

            <Button type="submit" disabled={isSubmitting} className="w-full bg-primary text-primary-foreground hover:bg-primary/90">
              {isSubmitting ? "A enviar..." : "Enviar Pedido"}
            </Button>
          </form>
        </div>
      </div>
    </section>;
};
export default Contact;