-- CRITICAL SECURITY FIX: Remove customer data exposure
-- This migration fixes the critical security issue where customer personal information
-- was publicly accessible through the events table

-- Drop the problematic policy that exposes customer data
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;

-- Create a public view that only shows non-sensitive event information
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
FROM public.events 
WHERE status = 'confirmed';

-- Create a new RLS policy that only allows viewing the public view
-- This ensures customer data (client_name, client_email, client_phone) remains private
CREATE POLICY "Anyone can view public event information"
ON public.events
FOR SELECT
USING (false); -- This effectively blocks all direct access to the events table

-- Grant access to the public view
GRANT SELECT ON public.public_events TO anon, authenticated;

-- Create admin-only policies for managing events
-- These will be properly secured once authentication is implemented
CREATE POLICY "Admins can view all events"
ON public.events
FOR SELECT
USING (false); -- Will be updated when auth is implemented

CREATE POLICY "Admins can update events"
ON public.events
FOR UPDATE
USING (false); -- Will be updated when auth is implemented

CREATE POLICY "Admins can delete events"
ON public.events
FOR DELETE
USING (false); -- Will be updated when auth is implemented
