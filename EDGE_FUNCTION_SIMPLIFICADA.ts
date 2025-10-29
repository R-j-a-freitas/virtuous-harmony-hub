// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { Resend } from 'https://esm.sh/resend@3.0.0'

Deno.serve(async (req) => {
  // CORS headers - IMPORTANTE para funcionar
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Only allow POST requests
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { 
          status: 405,
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          }
        }
      );
    }

    // Parse request body
    const body = await req.json();
    
    // Extract data (simplified validation)
    const { name, email, phone, date, location, time, message } = body;

    // Get the RESEND API key
    const resendApiKey = Deno.env.get('RESEND_API_KEY') || 're_faU39bCe_LTtaa6azqp4PYmEj6Ezgprom';
    
    // Initialize Resend client
    const resend = new Resend(resendApiKey);

    // Prepare HTML email content (simplified)
    const emailHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
</head>
<body style="font-family: Arial, sans-serif; padding: 20px;">
  <h2>📧 Nova Mensagem de Contacto</h2>
  <p>Recebida através do website Virtuous Ensemble</p>
  
  <h3>👤 Dados do Cliente</h3>
  <p><strong>Nome:</strong> ${name || 'N/A'}</p>
  <p><strong>Email:</strong> ${email || 'N/A'}</p>
  <p><strong>Telemóvel:</strong> ${phone || 'N/A'}</p>
  
  <h3>📅 Detalhes do Evento</h3>
  <p><strong>Data:</strong> ${date || 'N/A'}</p>
  <p><strong>Hora:</strong> ${time || 'Não especificada'}</p>
  <p><strong>Local:</strong> ${location || 'N/A'}</p>
  
  ${message ? `<h3>💬 Mensagem</h3><p>${message}</p>` : ''}
  
  <hr>
  <p style="font-size: 12px; color: #666;">
    Esta mensagem foi enviada automaticamente através do formulário de contacto.
    Responda diretamente ao cliente através do email: ${email || 'N/A'}
  </p>
</body>
</html>
    `.trim();

    // Send email using Resend
    console.log('📧 Attempting to send email...');
    console.log('📧 To: virtuousensemble@gmail.com');
    
    const emailResult = await resend.emails.send({
      from: 'onboarding@resend.dev',
      to: 'virtuousensemble@gmail.com',
      subject: `Nova mensagem de contacto - ${name || 'Cliente'}`,
      html: emailHtml,
    });

    if (emailResult.error) {
      console.error('❌ Email error:', emailResult.error);
      return new Response(
        JSON.stringify({ 
          error: 'Failed to send email',
          message: emailResult.error.message || 'Unknown error',
          details: emailResult.error
        }),
        { 
          status: 500,
          headers: { 
            'Content-Type': 'application/json',
            ...corsHeaders
          }
        }
      );
    }

    console.log('✅ Email sent successfully:', emailResult.data?.id);

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email sent successfully',
        emailId: emailResult.data?.id
      }),
      { 
        status: 200,
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    );

  } catch (error) {
    console.error('❌ Function error:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    const errorStack = error instanceof Error ? error.stack : undefined;
    
    console.error('❌ Error details:', { message: errorMessage, stack: errorStack });
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: errorMessage,
        stack: errorStack
      }),
      { 
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          ...corsHeaders
        }
      }
    );
  }
});
