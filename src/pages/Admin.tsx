import React, { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { 
  Calendar, 
  Clock, 
  MapPin, 
  Users, 
  Phone, 
  Mail, 
  MessageSquare,
  Eye,
  EyeOff,
  Plus,
  Edit,
  Trash2,
  Save,
  X,
  LogOut,
  Lock
} from "lucide-react";
import { toast } from "@/components/ui/use-toast";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useEffect } from "react";

const AdminPanel = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const [loginData, setLoginData] = useState({ email: "", password: "" });
  const [showAddEventForm, setShowAddEventForm] = useState(false);
  const queryClient = useQueryClient();

  // Verificar autenticação ao carregar
  useEffect(() => {
    checkAuth();
    
    // Listener para mudanças de autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setIsAuthenticated(!!session);
      setIsCheckingAuth(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const checkAuth = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      setIsAuthenticated(!!session);
      
      // Verificar se o usuário tem role de admin
      if (session) {
        const { data: roleData, error: roleError } = await supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', session.user.id)
          .eq('role', 'admin')
          .single();
        
        if (roleError || !roleData) {
          // Usuário não é admin
          await supabase.auth.signOut();
          setIsAuthenticated(false);
        }
      }
    } catch (error) {
      console.error('Error checking auth:', error);
      setIsAuthenticated(false);
    } finally {
      setIsCheckingAuth(false);
    }
  };

  const [newEvent, setNewEvent] = useState({
    title: "",
    date: "",
    time: "",
    location: "",
    description: "",
    clientName: "",
    clientEmail: "",
    clientPhone: "",
    guests: 0
  });

  // Buscar eventos da base de dados
  const { data: events = [], isLoading: eventsLoading } = useQuery({
    queryKey: ["admin-events"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("events")
        .select("*")
        .order("event_date", { ascending: true });

      if (error) {
        console.error("Error fetching events:", error);
        throw error;
      }
      return data || [];
    },
    enabled: isAuthenticated,
    refetchInterval: 5000, // Refetch every 5 seconds to see updates
  });

  // Buscar testemunhos da base de dados
  const { data: testimonials = [], isLoading: testimonialsLoading } = useQuery({
    queryKey: ["admin-testimonials"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("testimonials")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) {
        console.error("Error fetching testimonials:", error);
        throw error;
      }
      return data || [];
    },
    enabled: isAuthenticated,
    refetchInterval: 5000, // Refetch every 5 seconds
  });

  // Mutation para atualizar status do evento
  const updateEventStatus = useMutation({
    mutationFn: async ({ eventId, status }: { eventId: string; status: string }) => {
      const { error } = await supabase
        .from("events")
        .update({ status })
        .eq("id", eventId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-events"] });
      queryClient.invalidateQueries({ queryKey: ["public-events"] }); // Refresh public page too
    },
  });

  // Mutation para atualizar aprovação de testemunho
  const updateTestimonialApproval = useMutation({
    mutationFn: async ({ testimonialId, approved }: { testimonialId: string; approved: boolean }) => {
      const { error } = await supabase
        .from("testimonials")
        .update({ approved })
        .eq("id", testimonialId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-testimonials"] });
      queryClient.invalidateQueries({ queryKey: ["testimonials"] }); // Refresh public page too
    },
  });

  // Mutation para criar evento
  const createEvent = useMutation({
    mutationFn: async (eventData: any) => {
      const { error } = await supabase
        .from("events")
        .insert({
          title: eventData.title,
          event_date: eventData.date,
          event_time: eventData.time || null,
          location: eventData.location,
          description: eventData.description || null,
          client_name: eventData.clientName,
          client_email: eventData.clientEmail,
          client_phone: eventData.clientPhone,
          status: "pending",
        });

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-events"] });
      setNewEvent({
        title: "",
        date: "",
        time: "",
        location: "",
        description: "",
        clientName: "",
        clientEmail: "",
        clientPhone: "",
        guests: 0
      });
      setShowAddEventForm(false);
    },
  });

  // Mutation para deletar evento
  const deleteEvent = useMutation({
    mutationFn: async (eventId: string) => {
      const { error } = await supabase
        .from("events")
        .delete()
        .eq("id", eventId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-events"] });
      queryClient.invalidateQueries({ queryKey: ["public-events"] });
    },
  });

  // Mutation para deletar testemunho
  const deleteTestimonial = useMutation({
    mutationFn: async (testimonialId: string) => {
      const { error } = await supabase
        .from("testimonials")
        .delete()
        .eq("id", testimonialId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-testimonials"] });
      queryClient.invalidateQueries({ queryKey: ["testimonials"] });
    },
  });

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      // Fazer login com Supabase Auth
      const { data, error } = await supabase.auth.signInWithPassword({
        email: loginData.email,
        password: loginData.password,
      });

      if (error) {
        toast({
          title: "Erro de autenticação",
          description: error.message || "Email ou senha incorretos",
          variant: "destructive"
        });
        return;
      }

      if (!data.user) {
        toast({
          title: "Erro de autenticação",
          description: "Não foi possível realizar o login",
          variant: "destructive"
        });
        return;
      }

      // Verificar se o usuário tem role de admin
      const { data: roleData, error: roleError } = await supabase
        .from('user_roles')
        .select('role')
        .eq('user_id', data.user.id)
        .eq('role', 'admin')
        .single();

      if (roleError || !roleData) {
        // Usuário não é admin - fazer logout
        await supabase.auth.signOut();
        toast({
          title: "Acesso negado",
          description: "Você não tem permissões de administrador",
          variant: "destructive"
        });
        return;
      }

      // Login bem-sucedido
      setIsAuthenticated(true);
      setLoginData({ email: "", password: "" });
      toast({
        title: "Login realizado com sucesso",
        description: "Bem-vindo ao painel administrativo!",
      });
    } catch (error: any) {
      console.error('Login error:', error);
      toast({
        title: "Erro de autenticação",
        description: error.message || "Ocorreu um erro ao fazer login",
        variant: "destructive"
      });
    }
  };

  const handleLogout = async () => {
    try {
      await supabase.auth.signOut();
      setIsAuthenticated(false);
      setLoginData({ email: "", password: "" });
      toast({
        title: "Logout realizado",
        description: "Sessão encerrada com sucesso",
      });
    } catch (error: any) {
      console.error('Logout error:', error);
      toast({
        title: "Erro",
        description: "Ocorreu um erro ao fazer logout",
        variant: "destructive"
      });
    }
  };

  const handleEventStatusChange = async (eventId: string, status: string) => {
    try {
      await updateEventStatus.mutateAsync({ eventId, status });
      toast({
        title: "Status atualizado",
        description: `Evento ${status === "confirmed" ? "aprovado" : "pendente"}`,
      });
    } catch (error: any) {
      console.error("Error updating event status:", error);
      toast({
        title: "Erro",
        description: error.message || "Falha ao atualizar status do evento",
        variant: "destructive"
      });
    }
  };

  const handleTestimonialVisibility = async (testimonialId: string, approved: boolean) => {
    try {
      await updateTestimonialApproval.mutateAsync({ testimonialId, approved });
      toast({
        title: "Visibilidade atualizada",
        description: `Testemunho ${approved ? "aprovado" : "ocultado"}`,
      });
    } catch (error: any) {
      console.error("Error updating testimonial:", error);
      toast({
        title: "Erro",
        description: error.message || "Falha ao atualizar testemunho",
        variant: "destructive"
      });
    }
  };

  const handleAddEvent = async () => {
    if (!newEvent.title || !newEvent.date) {
      toast({
        title: "Erro",
        description: "Preencha pelo menos o título e data do evento",
        variant: "destructive"
      });
      return;
    }

    try {
      await createEvent.mutateAsync(newEvent);
      toast({
        title: "Sucesso",
        description: "Evento adicionado com sucesso!",
      });
    } catch (error: any) {
      console.error("Error creating event:", error);
      toast({
        title: "Erro",
        description: error.message || "Falha ao criar evento",
        variant: "destructive"
      });
    }
  };

  const handleDeleteEvent = async (eventId: string) => {
    if (!window.confirm("Tem certeza que deseja excluir este evento?")) {
      return;
    }

    try {
      await deleteEvent.mutateAsync(eventId);
      toast({
        title: "Evento excluído",
        description: "Evento removido com sucesso",
      });
    } catch (error: any) {
      console.error("Error deleting event:", error);
      toast({
        title: "Erro",
        description: error.message || "Falha ao excluir evento",
        variant: "destructive"
      });
    }
  };

  const handleDeleteTestimonial = async (testimonialId: string) => {
    if (!window.confirm("Tem certeza que deseja excluir este testemunho?")) {
      return;
    }

    try {
      await deleteTestimonial.mutateAsync(testimonialId);
      toast({
        title: "Testemunho excluído", 
        description: "Testemunho removido com sucesso",
      });
    } catch (error: any) {
      console.error("Error deleting testimonial:", error);
      toast({
        title: "Erro",
        description: error.message || "Falha ao excluir testemunho",
        variant: "destructive"
      });
    }
  };

  // Mostrar loading enquanto verifica autenticação
  if (isCheckingAuth) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Card className="w-full max-w-md">
          <CardContent className="p-8">
            <div className="flex flex-col items-center gap-4">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
              <p className="text-muted-foreground">A verificar autenticação...</p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Se não estiver autenticado, mostrar formulário de login
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle className="text-center flex items-center justify-center gap-2">
              <Lock className="h-5 w-5" />
              Painel Administrativo
            </CardTitle>
            <p className="text-center text-sm text-muted-foreground mt-2">
              Acesso restrito a administradores
            </p>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={loginData.email}
                  onChange={(e) => setLoginData({ ...loginData, email: e.target.value })}
                  placeholder="admin@example.com"
                  required
                  autoComplete="email"
                />
              </div>
              <div>
                <Label htmlFor="password">Senha</Label>
                <Input
                  id="password"
                  type="password"
                  value={loginData.password}
                  onChange={(e) => setLoginData({ ...loginData, password: e.target.value })}
                  placeholder="Digite sua senha"
                  required
                  autoComplete="current-password"
                />
              </div>
              <Button type="submit" className="w-full" disabled={!loginData.email || !loginData.password}>
                <Lock className="mr-2 h-4 w-4" />
                Entrar
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Se estiver autenticado, mostrar painel administrativo
  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8 flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-foreground mb-2">
              Painel Administrativo
            </h1>
            <p className="text-muted-foreground">
              Gerencie eventos e depoimentos do Virtuous Ensemble
            </p>
          </div>
          <Button onClick={handleLogout} variant="outline">
            <LogOut className="mr-2 h-4 w-4" />
            Sair
          </Button>
        </div>

        <Tabs defaultValue="events" className="space-y-6">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="events">Eventos</TabsTrigger>
            <TabsTrigger value="testimonials">Testemunhos</TabsTrigger>
          </TabsList>

          {/* Aba de Eventos */}
          <TabsContent value="events" className="space-y-6">
            {/* Botão para Adicionar Novo Evento */}
            <div className="flex justify-center">
              <Button 
                onClick={() => setShowAddEventForm(!showAddEventForm)}
                className="w-full max-w-md"
                variant={showAddEventForm ? "outline" : "default"}
              >
                <Plus className="mr-2 h-4 w-4" />
                {showAddEventForm ? "Cancelar Adição de Evento" : "Adicionar Novo Evento"}
              </Button>
            </div>

            {/* Formulário de Adicionar Evento (condicional) */}
            {showAddEventForm && (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Plus className="h-5 w-5" />
                    Adicionar Novo Evento
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="title">Título do Evento</Label>
                      <Input
                        id="title"
                        value={newEvent.title}
                        onChange={(e) => setNewEvent({ ...newEvent, title: e.target.value })}
                        placeholder="Ex: Casamento Elegante"
                      />
                    </div>
                    <div>
                      <Label htmlFor="date">Data</Label>
                      <Input
                        id="date"
                        type="date"
                        value={newEvent.date}
                        onChange={(e) => setNewEvent({ ...newEvent, date: e.target.value })}
                      />
                    </div>
                    <div>
                      <Label htmlFor="time">Hora</Label>
                      <Input
                        id="time"
                        type="time"
                        value={newEvent.time}
                        onChange={(e) => setNewEvent({ ...newEvent, time: e.target.value })}
                      />
                    </div>
                    <div>
                      <Label htmlFor="location">Local</Label>
                      <Input
                        id="location"
                        value={newEvent.location}
                        onChange={(e) => setNewEvent({ ...newEvent, location: e.target.value })}
                        placeholder="Ex: Quinta do Lago"
                      />
                    </div>
                    <div>
                      <Label htmlFor="clientName">Nome do Cliente</Label>
                      <Input
                        id="clientName"
                        value={newEvent.clientName}
                        onChange={(e) => setNewEvent({ ...newEvent, clientName: e.target.value })}
                        placeholder="Ex: Ana Silva"
                      />
                    </div>
                    <div>
                      <Label htmlFor="clientEmail">Email do Cliente</Label>
                      <Input
                        id="clientEmail"
                        type="email"
                        value={newEvent.clientEmail}
                        onChange={(e) => setNewEvent({ ...newEvent, clientEmail: e.target.value })}
                        placeholder="Ex: ana@email.com"
                      />
                    </div>
                    <div>
                      <Label htmlFor="clientPhone">Telefone do Cliente</Label>
                      <Input
                        id="clientPhone"
                        value={newEvent.clientPhone}
                        onChange={(e) => setNewEvent({ ...newEvent, clientPhone: e.target.value })}
                        placeholder="Ex: +351 912 345 678"
                      />
                    </div>
                  </div>
                  <div>
                    <Label htmlFor="description">Descrição</Label>
                    <Textarea
                      id="description"
                      value={newEvent.description}
                      onChange={(e) => setNewEvent({ ...newEvent, description: e.target.value })}
                      placeholder="Descrição detalhada do evento..."
                      rows={3}
                    />
                  </div>
                  <div className="flex gap-2">
                    <Button 
                      onClick={handleAddEvent} 
                      className="flex-1"
                      disabled={createEvent.isPending}
                    >
                      <Plus className="mr-2 h-4 w-4" />
                      {createEvent.isPending ? "A adicionar..." : "Adicionar Evento"}
                    </Button>
                    <Button 
                      onClick={() => setShowAddEventForm(false)} 
                      variant="outline"
                      className="flex-1"
                    >
                      <X className="mr-2 h-4 w-4" />
                      Cancelar
                    </Button>
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Lista de Eventos */}
            <div className="space-y-4">
              <h3 className="text-xl font-semibold">Eventos Existentes</h3>
              {eventsLoading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
                  <p className="mt-2 text-muted-foreground">A carregar eventos...</p>
                </div>
              ) : events.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">
                  <p>Nenhum evento encontrado.</p>
                </div>
              ) : (
                events.map((event) => (
                  <Card key={event.id}>
                    <CardContent className="p-6">
                      <div className="flex justify-between items-start mb-4">
                        <div>
                          <h4 className="text-lg font-semibold">{event.title}</h4>
                          <div className="flex items-center gap-4 text-sm text-muted-foreground mt-2">
                            <div className="flex items-center gap-1">
                              <Calendar className="h-4 w-4" />
                              {new Date(event.event_date).toLocaleDateString('pt-PT')}
                            </div>
                            {event.event_time && (
                              <div className="flex items-center gap-1">
                                <Clock className="h-4 w-4" />
                                {event.event_time}
                              </div>
                            )}
                            <div className="flex items-center gap-1">
                              <MapPin className="h-4 w-4" />
                              {event.location}
                            </div>
                          </div>
                        </div>
                        <Badge variant={event.status === "confirmed" ? "default" : "secondary"}>
                          {event.status === "confirmed" ? "Confirmado" : event.status === "pending" ? "Pendente" : event.status || "Pendente"}
                        </Badge>
                      </div>

                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        {event.client_name && (
                          <div>
                            <p className="text-sm font-medium">Cliente:</p>
                            <p className="text-sm text-muted-foreground">{event.client_name}</p>
                          </div>
                        )}
                        {event.client_email && (
                          <div>
                            <p className="text-sm font-medium">Email:</p>
                            <p className="text-sm text-muted-foreground">{event.client_email}</p>
                          </div>
                        )}
                        {event.client_phone && (
                          <div>
                            <p className="text-sm font-medium">Telefone:</p>
                            <p className="text-sm text-muted-foreground">{event.client_phone}</p>
                          </div>
                        )}
                        {event.description && (
                          <div>
                            <p className="text-sm font-medium">Descrição:</p>
                            <p className="text-sm text-muted-foreground">{event.description}</p>
                          </div>
                        )}
                      </div>

                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          variant={event.status === "confirmed" ? "outline" : "default"}
                          onClick={() => handleEventStatusChange(event.id, event.status === "confirmed" ? "pending" : "confirmed")}
                          disabled={updateEventStatus.isPending}
                        >
                          {event.status === "confirmed" ? (
                            <>
                              <EyeOff className="mr-2 h-4 w-4" />
                              Desaprovar
                            </>
                          ) : (
                            <>
                              <Eye className="mr-2 h-4 w-4" />
                              Aprovar
                            </>
                          )}
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => handleDeleteEvent(event.id)}
                          disabled={deleteEvent.isPending}
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Excluir
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          </TabsContent>

          {/* Aba de Testemunhos */}
          <TabsContent value="testimonials" className="space-y-6">
            <div className="space-y-4">
              <h3 className="text-xl font-semibold">Testemunhos</h3>
              {testimonialsLoading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
                  <p className="mt-2 text-muted-foreground">A carregar testemunhos...</p>
                </div>
              ) : testimonials.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">
                  <p>Nenhum testemunho encontrado.</p>
                </div>
              ) : (
                testimonials.map((testimonial) => (
                  <Card key={testimonial.id}>
                    <CardContent className="p-6">
                      <div className="flex justify-between items-start mb-4">
                        <div>
                          <h4 className="text-lg font-semibold">{testimonial.name}</h4>
                          {testimonial.event_type && (
                            <p className="text-sm text-muted-foreground">{testimonial.event_type}</p>
                          )}
                          <div className="flex items-center gap-1 mt-2">
                            {[...Array(5)].map((_, i) => (
                              <span key={i} className={`text-lg ${i < (testimonial.rating || 0) ? 'text-yellow-400' : 'text-gray-300'}`}>
                                ★
                              </span>
                            ))}
                          </div>
                        </div>
                        <Badge variant={testimonial.approved ? "default" : "secondary"}>
                          {testimonial.approved ? "Visível" : "Oculto"}
                        </Badge>
                      </div>

                      <p className="text-sm mb-4">{testimonial.content}</p>

                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          variant={testimonial.approved ? "outline" : "default"}
                          onClick={() => handleTestimonialVisibility(testimonial.id, !testimonial.approved)}
                          disabled={updateTestimonialApproval.isPending}
                        >
                          {testimonial.approved ? (
                            <>
                              <EyeOff className="mr-2 h-4 w-4" />
                              Ocultar
                            </>
                          ) : (
                            <>
                              <Eye className="mr-2 h-4 w-4" />
                              Mostrar
                            </>
                          )}
                        </Button>
                        <Button
                          size="sm"
                          variant="destructive"
                          onClick={() => handleDeleteTestimonial(testimonial.id)}
                          disabled={deleteTestimonial.isPending}
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Excluir
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))
              )}
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
};

export default AdminPanel;