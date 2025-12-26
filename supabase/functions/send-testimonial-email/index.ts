// @ts-nocheck - This file runs in Deno runtime, not Node.js
// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { z } from "https://esm.sh/zod@3.22.4"

// Input validation schema for testimonial emails
const testimonialEmailSchema = z.object({
  name: z.string()
    .min(2, "Nome deve ter pelo menos 2 caracteres")
    .max(100, "Nome não pode exceder 100 caracteres"),
  content: z.string()
    .min(10, "Testemunho deve ter pelo menos 10 caracteres")
    .max(1000, "Testemunho não pode exceder 1000 caracteres"),
  rating: z.number()
    .min(1, "Avaliação deve ser pelo menos 1 estrela")
    .max(5, "Avaliação não pode exceder 5 estrelas"),
});

// Rate limiting storage (in production, use Redis or database)
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

// Rate limiting function
function checkRateLimit(ip: string): boolean {
  const now = Date.now();
  const windowMs = 15 * 60 * 1000; // 15 minutes
  const maxRequests = 5; // Max 5 requests per 15 minutes

  const current = rateLimitMap.get(ip);
  
  if (!current || now > current.resetTime) {
    rateLimitMap.set(ip, { count: 1, resetTime: now + windowMs });
    return true;
  }
  
  if (current.count >= maxRequests) {
    return false;
  }
  
  current.count++;
  return true;
}

serve(async (req) => {
  try {
    console.log('📧 send-testimonial-email function called');
    console.log('📧 Method:', req.method);
    
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
      console.log('📧 Handling OPTIONS preflight request');
      return new Response('ok', {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        },
      });
    }
    
    // Only allow POST requests
    if (req.method !== 'POST') {
      console.log('❌ Method not allowed:', req.method);
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { 
          status: 405,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }
    
    console.log('📧 Processing POST request');

    // Get client IP for rate limiting
    const clientIP = req.headers.get('x-forwarded-for') || 
                     req.headers.get('x-real-ip') || 
                     'unknown';

    // Check rate limit
    if (!checkRateLimit(clientIP)) {
      return new Response(
        JSON.stringify({ error: 'Rate limit exceeded. Please try again later.' }),
        { 
          status: 429,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Parse and validate request body
    console.log('📧 Parsing request body...');
    const body = await req.json();
    console.log('📧 Body received:', JSON.stringify({ name: body.name, rating: body.rating, contentLength: body.content?.length }));
    
    console.log('📧 Validating data...');
    const validatedData = testimonialEmailSchema.parse(body);
    console.log('📧 Data validated successfully');

    // Sanitize inputs to prevent XSS
    const sanitizedData = {
      name: validatedData.name.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
      content: validatedData.content.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
      rating: validatedData.rating,
    };

    // Get Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Get the RESEND API key from environment variables
    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    
    if (!resendApiKey) {
      console.error('❌ RESEND_API_KEY not configured in environment variables');
      return new Response(
        JSON.stringify({ 
          error: 'Email service configuration error. Please contact support.' 
        }),
        { 
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Create stars display
    const starsDisplay = '⭐'.repeat(sanitizedData.rating) + '☆'.repeat(5 - sanitizedData.rating);

    // Prepare HTML email content
    const emailHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background-color: #f8f9fa;
      padding: 20px;
      border-radius: 5px;
      margin-bottom: 20px;
    }
    .section {
      margin-bottom: 20px;
      padding: 15px;
      background-color: #ffffff;
      border-left: 4px solid #007bff;
    }
    .label {
      font-weight: bold;
      color: #555;
    }
    .value {
      margin-left: 10px;
      color: #333;
    }
    .testimonial-content {
      background-color: #f8f9fa;
      padding: 15px;
      border-radius: 5px;
      font-style: italic;
      margin: 15px 0;
    }
    .stars {
      font-size: 20px;
      margin: 10px 0;
    }
    .divider {
      border-top: 2px solid #e9ecef;
      margin: 20px 0;
    }
    .footer {
      margin-top: 30px;
      padding-top: 20px;
      border-top: 1px solid #e9ecef;
      font-size: 12px;
      color: #6c757d;
      text-align: center;
    }
    .action-button {
      display: inline-block;
      margin-top: 20px;
      padding: 10px 20px;
      background-color: #007bff;
      color: white;
      text-decoration: none;
      border-radius: 5px;
    }
  </style>
</head>
<body>
  <div class="header">
    <h2 style="margin: 0; color: #007bff;">⭐ Novo Testemunho Submetido</h2>
    <p style="margin: 5px 0 0 0; color: #6c757d;">Recebido através do website Virtuous Ensemble</p>
  </div>

  <div class="section">
    <h3 style="margin-top: 0; color: #007bff;">👤 Dados do Cliente</h3>
    <p><span class="label">Nome:</span><span class="value">${sanitizedData.name}</span></p>
  </div>

  <div class="divider"></div>

  <div class="section">
    <h3 style="margin-top: 0; color: #007bff;">⭐ Avaliação</h3>
    <div class="stars">${starsDisplay}</div>
    <p><span class="label">Classificação:</span><span class="value">${sanitizedData.rating} de 5 estrelas</span></p>
  </div>

  <div class="divider"></div>

  <div class="section">
    <h3 style="margin-top: 0; color: #007bff;">💬 Testemunho</h3>
    <div class="testimonial-content">
      <p style="white-space: pre-wrap; margin: 0;">${sanitizedData.content}</p>
    </div>
  </div>

  <div class="footer">
    <p><strong>⚠️ AÇÃO NECESSÁRIA:</strong> Este testemunho aguarda aprovação.</p>
    <p>Aceda ao painel de administração para aprovar ou rejeitar este testemunho.</p>
    <p style="margin-top: 15px;">
      <a href="http://virtuousensemble.pt/admin" class="action-button">Aceder ao Painel Admin</a>
    </p>
  </div>
</body>
</html>
    `.trim();

    // Send email using Resend API directly (avoiding Resend library dependency issues)
    console.log('📧 Attempting to send testimonial email to virtuousensemble@gmail.com');
    console.log('📧 Using API key:', resendApiKey ? 'SET' : 'NOT SET');
    console.log('📧 Email subject:', `Novo testemunho aguarda aprovação - ${sanitizedData.name}`);
    
    const emailPayload = {
      from: 'onboarding@resend.dev',
      to: 'virtuousensemble@gmail.com',
      subject: `Novo testemunho aguarda aprovação - ${sanitizedData.name}`,
      html: emailHtml,
    };
    
    console.log('📧 Sending request to Resend API...');
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify(emailPayload),
    });
    
    console.log('📧 Resend API request completed');

    console.log('📧 Resend response status:', resendResponse.status);
    
    const resendData = await resendResponse.json();
    console.log('📧 Resend response:', JSON.stringify(resendData, null, 2));

    if (!resendResponse.ok) {
      // Log detailed error server-side (for debugging)
      console.error('❌ Email sending failed:', resendData);
      console.error('❌ Response status:', resendResponse.status);
      console.error('❌ Error details:', JSON.stringify(resendData, null, 2));
      
      // Return generic error message to client (no internal details)
      return new Response(
        JSON.stringify({ 
          error: 'Unable to send email. Please try again later or contact us directly at virtuousensemble@gmail.com.'
        }),
        { 
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Log successful email sending (for monitoring)
    console.log('✅ Testimonial email sent successfully for:', sanitizedData.name);
    console.log('✅ Email ID:', resendData.id);

    return new Response(
      JSON.stringify({ success: true, message: 'Email sent successfully', emailId: resendData.id }),
      { 
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('Edge function error:', error);
    
    // Return generic error message to client
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
})
