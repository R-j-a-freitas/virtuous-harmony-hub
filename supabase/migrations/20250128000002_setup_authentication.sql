-- AUTHENTICATION AND USER ROLES SETUP
-- This migration creates the authentication system and admin access control

-- Enable Supabase Auth (if not already enabled)
-- This is typically done in the Supabase dashboard, but we'll ensure the schema is ready

-- Create user_roles table for role-based access control
CREATE TABLE public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS on user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own role
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Only admins can manage roles (will be updated when we have admin users)
CREATE POLICY "Admins can manage roles"
ON public.user_roles
FOR ALL
USING (false); -- Will be updated when auth is implemented

-- Create function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to check if user is moderator or admin
CREATE OR REPLACE FUNCTION public.is_moderator_or_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role IN ('admin', 'moderator')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update events table policies to use authentication
DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
DROP POLICY IF EXISTS "Admins can update events" ON public.events;
DROP POLICY IF EXISTS "Admins can delete events" ON public.events;

-- New secure policies for events
CREATE POLICY "Admins can view all events"
ON public.events
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Admins can update events"
ON public.events
FOR UPDATE
USING (public.is_admin());

CREATE POLICY "Admins can delete events"
ON public.events
FOR DELETE
USING (public.is_admin());

-- Update testimonials policies to use authentication
DROP POLICY IF EXISTS "Anyone can insert testimonials" ON public.testimonials;

-- Only authenticated users can insert testimonials (prevents spam)
CREATE POLICY "Authenticated users can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- Add policies for admin management of testimonials
CREATE POLICY "Admins can view all testimonials"
ON public.testimonials
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Moderators and admins can approve testimonials"
ON public.testimonials
FOR UPDATE
USING (public.is_moderator_or_admin());

CREATE POLICY "Admins can delete testimonials"
ON public.testimonials
FOR DELETE
USING (public.is_admin());

-- Create trigger for user_roles timestamp updates
CREATE TRIGGER update_user_roles_updated_at
BEFORE UPDATE ON public.user_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
