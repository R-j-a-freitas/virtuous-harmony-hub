import { createClient } from '@supabase/supabase-js';
import type { Database } from './types';

// Configuração do Supabase
const SUPABASE_URL = 'https://mhzhxwmxnofltgdmshcq.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oemh4d214bm9mbHRnZG1zaGNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTgxMDksImV4cCI6MjA3NzIzNDEwOX0.K-6RaZxiRbY-xCgSN7wIAkoi4YuBp7YTW26NseStmPA';

// Import the supabase client like this:
// import { supabase } from "@/integrations/supabase/client";

export const supabase = createClient<Database>(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storage: localStorage,
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  }
});