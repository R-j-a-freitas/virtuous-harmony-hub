import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { z } from "https://esm.sh/zod@3.22.4"
import { Resend } from 'https://esm.sh/resend@3.0.0'

// Input validation schema for contact emails
const contactEmailSchema = z.object({
  name: z.string()
    .min(2, "Nome deve ter pelo menos 2 caracteres")
    .max(100, "Nome não pode exceder 100 caracteres")
    .regex(/^[a-zA-ZÀ-ÿ\s]+$/, "Nome deve conter apenas letras e espaços"),
  email: z.string()
    .email("Email inválido")
    .max(255, "Email não pode exceder 255 caracteres"),
  phone: z.string()
    .min(9, "Telemóvel deve ter pelo menos 9 dígitos")
    .max(20, "Telemóvel não pode exceder 20 caracteres")
    .regex(/^[\+]?[0-9\s\-\(\)]+$/, "Formato de telemóvel inválido"),
  date: z.string()
    .min(1, "Data é obrigatória"),
  location: z.string()
    .min(3, "Local deve ter pelo menos 3 caracteres")
    .max(200, "Local não pode exceder 200 caracteres"),
  time: z.string().optional(),
  message: z.string()
    .max(2000, "Mensagem não pode exceder 2000 caracteres")
    .optional()
    .default(""),
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
    // Only allow POST requests
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { 
          status: 405,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

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
    const body = await req.json();
    
    const validatedData = contactEmailSchema.parse(body);

    // Sanitize inputs to prevent XSS
    const sanitizedData = {
      name: validatedData.name.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
      email: validatedData.email.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
      phone: validatedData.phone.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
      date: validatedData.date,
      location: validatedData.location.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
      time: validatedData.time,
      message: validatedData.message.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ''),
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

    // Get the RESEND API key (fallback to hardcoded key if env var not set)
    const resendApiKey = Deno.env.get('RESEND_API_KEY') || 're_faU39bCe_LTtaa6azqp4PYmEj6Ezgprom';
    
    // Initialize Resend client
    const resend = new Resend(resendApiKey);

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
  </style>
</head>
<body>
  <div class="header">
    <h2 style="margin: 0; color: #007bff;">📧 Nova Mensagem de Contacto</h2>
    <p style="margin: 5px 0 0 0; color: #6c757d;">Recebida através do website Virtuous Ensemble</p>
  </div>

  <div class="section">
    <h3 style="margin-top: 0; color: #007bff;">👤 Dados do Cliente</h3>
    <p><span class="label">Nome:</span><span class="value">${sanitizedData.name}</span></p>
    <p><span class="label">Email:</span><span class="value">${sanitizedData.email}</span></p>
    <p><span class="label">Telemóvel:</span><span class="value">${sanitizedData.phone}</span></p>
  </div>

  <div class="divider"></div>

  <div class="section">
    <h3 style="margin-top: 0; color: #007bff;">📅 Detalhes do Evento</h3>
    <p><span class="label">Data da Cerimónia:</span><span class="value">${sanitizedData.date}</span></p>
    <p><span class="label">Hora:</span><span class="value">${sanitizedData.time || 'Não especificada'}</span></p>
    <p><span class="label">Local:</span><span class="value">${sanitizedData.location}</span></p>
  </div>

  ${sanitizedData.message ? `
  <div class="divider"></div>
  <div class="section">
    <h3 style="margin-top: 0; color: #007bff;">💬 Mensagem</h3>
    <p style="white-space: pre-wrap;">${sanitizedData.message}</p>
  </div>
  ` : ''}

  <div class="footer">
    <p>Esta mensagem foi enviada automaticamente através do formulário de contacto do website Virtuous Ensemble.</p>
    <p>Por favor, responda diretamente ao cliente através do email: <strong>${sanitizedData.email}</strong></p>
  </div>
</body>
</html>
    `.trim();

    // Send email using Resend
    console.log('Attempting to send email to virtuousensemble@gmail.com');
    console.log('Using API key:', resendApiKey ? 'SET' : 'NOT SET');
    
    const emailResult = await resend.emails.send({
      from: 'onboarding@resend.dev',
      to: 'virtuousensemble@gmail.com',
      subject: `Nova mensagem de contacto - ${sanitizedData.name}`,
      html: emailHtml,
    });

    if (emailResult.error) {
      console.error('❌ Email sending failed:', emailResult.error);
      console.error('❌ Error details:', JSON.stringify(emailResult.error, null, 2));
      
      // Return detailed error for debugging
      return new Response(
        JSON.stringify({ 
          error: 'Failed to send email', 
          details: emailResult.error,
          message: emailResult.error.message || 'Unknown error'
        }),
        { 
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    // Log successful email sending (for monitoring)
    console.log('✅ Contact email sent successfully for:', sanitizedData.name, '(', sanitizedData.email, ')');
    console.log('✅ Email ID:', emailResult.data?.id);

    return new Response(
      JSON.stringify({ success: true, message: 'Email sent successfully' }),
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
