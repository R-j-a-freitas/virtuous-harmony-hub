-- Create testimonials table
CREATE TABLE public.testimonials (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  content TEXT NOT NULL,
  rating INTEGER DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
  event_type TEXT,
  event_date DATE,
  approved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view approved testimonials
CREATE POLICY "Anyone can view approved testimonials"
ON public.testimonials
FOR SELECT
USING (approved = true);

-- Policy: Anyone can insert testimonials (they start as not approved)
CREATE POLICY "Anyone can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (true);

-- Create events/agenda table
CREATE TABLE public.events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_time TIME,
  location TEXT NOT NULL,
  description TEXT,
  client_name TEXT,
  client_email TEXT,
  client_phone TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view confirmed events
CREATE POLICY "Anyone can view confirmed events"
ON public.events
FOR SELECT
USING (status = 'confirmed');

-- Policy: Anyone can insert events (for contact form)
CREATE POLICY "Anyone can insert events"
ON public.events
FOR INSERT
WITH CHECK (true);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_testimonials_updated_at
BEFORE UPDATE ON public.testimonials
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_events_updated_at
BEFORE UPDATE ON public.events
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();