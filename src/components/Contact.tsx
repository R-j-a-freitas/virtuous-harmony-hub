import { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/integrations/supabase/client";

const Contact = () => {
  const { toast } = useToast();
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    date: "",
    location: "",
    time: "",
    message: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    // Validate required fields
    if (!formData.name || !formData.email || !formData.phone || !formData.date || !formData.location) {
      toast({
        title: "Erro",
        description: "Por favor, preencha todos os campos obrigatórios",
        variant: "destructive",
      });
      setIsSubmitting(false);
      return;
    }

    // Save to database
    const { error: dbError } = await supabase.from("events").insert({
      title: `Evento - ${formData.name}`,
      event_date: formData.date,
      event_time: formData.time || null,
      location: formData.location,
      description: formData.message,
      client_name: formData.name,
      client_email: formData.email,
      client_phone: formData.phone,
      status: "pending",
    });

    if (dbError) {
      console.error("Database error:", dbError);
      toast({
        title: "Erro",
        description: "Ocorreu um erro ao guardar os dados",
        variant: "destructive",
      });
      setIsSubmitting(false);
      return;
    }

    // Call edge function to send email
    try {
      const { error: emailError } = await supabase.functions.invoke("send-contact-email", {
        body: formData,
      });

      if (emailError) {
        console.error("Email error:", emailError);
      }
    } catch (err) {
      console.error("Error calling edge function:", err);
    }

    toast({
      title: "Sucesso!",
      description: "A sua mensagem foi enviada. Entraremos em contacto em breve!",
    });

    // Reset form
    setFormData({
      name: "",
      email: "",
      phone: "",
      date: "",
      location: "",
      time: "",
      message: "",
    });
    setIsSubmitting(false);
  };

  return (
    <section id="contact" className="py-20 md:py-32 bg-card">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="font-serif text-4xl md:text-5xl text-foreground mb-6">
            Contacte-nos
          </h2>
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto font-sans">
            Estamos prontos para tornar o seu evento inesquecível
          </p>
        </div>

        <div className="max-w-3xl mx-auto">
          <form onSubmit={handleSubmit} className="space-y-6 bg-background border border-border rounded-lg p-8">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Nome *</label>
                <Input
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  placeholder="O seu nome"
                  required
                />
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Email *</label>
                <Input
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder="email@exemplo.com"
                  required
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Telemóvel *</label>
                <Input
                  name="phone"
                  type="tel"
                  value={formData.phone}
                  onChange={handleChange}
                  placeholder="+351 ..."
                  required
                />
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Data da Cerimónia *</label>
                <Input
                  name="date"
                  type="date"
                  value={formData.date}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label className="block text-foreground mb-2 font-sans">Local *</label>
                <Input
                  name="location"
                  value={formData.location}
                  onChange={handleChange}
                  placeholder="Local do evento"
                  required
                />
              </div>
              <div>
                <label className="block text-foreground mb-2 font-sans">Hora</label>
                <Input
                  name="time"
                  type="time"
                  value={formData.time}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div>
              <label className="block text-foreground mb-2 font-sans">Mensagem</label>
              <Textarea
                name="message"
                value={formData.message}
                onChange={handleChange}
                placeholder="Conte-nos mais sobre o seu evento..."
                rows={6}
              />
            </div>

            <Button
              type="submit"
              disabled={isSubmitting}
              className="w-full bg-primary text-primary-foreground hover:bg-primary/90"
            >
              {isSubmitting ? "A enviar..." : "Enviar Pedido"}
            </Button>
          </form>
        </div>
      </div>
    </section>
  );
};

export default Contact;
