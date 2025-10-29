-- =====================================================
-- SECURITY FIX: Authentication System & PII Protection
-- =====================================================
-- This migration addresses two critical security issues:
-- 1. Creates authentication infrastructure (user_roles table)
-- 2. Protects customer PII with public_events view

-- =====================================================
-- STEP 1: Create Role Enum
-- =====================================================
CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user');

-- =====================================================
-- STEP 2: Create user_roles Table
-- =====================================================
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id)
);

-- Enable RLS on user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 3: Create Security Definer Functions
-- =====================================================
-- These functions prevent RLS recursion issues
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.is_moderator_or_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = user_uuid AND role IN ('admin', 'moderator')
  );
$$;

-- =====================================================
-- STEP 4: Apply RLS Policies to user_roles
-- =====================================================
CREATE POLICY "Users can view own role"
ON user_roles FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Only admins can manage roles"
ON user_roles FOR ALL
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Add auto-timestamp trigger
CREATE TRIGGER update_user_roles_updated_at
BEFORE UPDATE ON user_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- STEP 5: Create Public Events View (NO PII)
-- =====================================================
CREATE VIEW public.public_events AS
SELECT 
  id, 
  title, 
  event_date, 
  event_time, 
  location, 
  description, 
  status,
  created_at
FROM events
WHERE status = 'confirmed';

-- Grant access to the view
GRANT SELECT ON public_events TO anon, authenticated;

-- =====================================================
-- STEP 6: Update Events Table Policies
-- =====================================================
-- Remove the vulnerable public SELECT policy
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;

-- Add admin-only policies for full table access
CREATE POLICY "Admins can view all events"
ON events FOR SELECT
USING (public.is_admin());

CREATE POLICY "Admins can insert events"
ON events FOR INSERT
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update events"
ON events FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete events"
ON events FOR DELETE
USING (public.is_admin());

-- Keep the public insert policy for contact form
-- (Already exists: "Anyone can insert events")

-- =====================================================
-- STEP 7: Update Testimonials Table Policies
-- =====================================================
-- Add admin policies for UPDATE/DELETE operations
CREATE POLICY "Admins can update testimonials"
ON testimonials FOR UPDATE
USING (public.is_moderator_or_admin())
WITH CHECK (public.is_moderator_or_admin());

CREATE POLICY "Admins can delete testimonials"
ON testimonials FOR DELETE
USING (public.is_moderator_or_admin());

-- Keep existing policies:
-- - "Anyone can insert testimonials" (public submissions)
-- - "Anyone can view approved testimonials" (public view)