// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  // CORS headers - OBRIGATÓRIO
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('📧 Function called');
    
    // Parse body
    const body = await req.json();
    console.log('📧 Body received:', JSON.stringify(body));
    
    const { name, email, phone, date, location, time, message } = body;

    // API Key do Resend
    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') || 're_faU39bCe_LTtaa6azqp4PYmEj6Ezgprom';
    console.log('📧 API Key:', RESEND_API_KEY ? 'SET' : 'NOT SET');

    // Preparar email HTML simples
    const emailHtml = `
      <h2>Nova Mensagem de Contacto</h2>
      <p><strong>Nome:</strong> ${name || 'N/A'}</p>
      <p><strong>Email:</strong> ${email || 'N/A'}</p>
      <p><strong>Telemóvel:</strong> ${phone || 'N/A'}</p>
      <p><strong>Data:</strong> ${date || 'N/A'}</p>
      <p><strong>Hora:</strong> ${time || 'Não especificada'}</p>
      <p><strong>Local:</strong> ${location || 'N/A'}</p>
      ${message ? `<p><strong>Mensagem:</strong> ${message}</p>` : ''}
    `;

    // Enviar email usando fetch direto ao Resend API
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'onboarding@resend.dev',
        to: 'virtuousensemble@gmail.com',
        subject: `Nova mensagem de contacto - ${name || 'Cliente'}`,
        html: emailHtml,
      }),
    });

    console.log('📧 Resend response status:', resendResponse.status);

    const resendData = await resendResponse.json();
    console.log('📧 Resend response:', JSON.stringify(resendData, null, 2));

    if (!resendResponse.ok) {
      console.error('❌ Resend error:', resendData);
      return new Response(
        JSON.stringify({ 
          success: false,
          error: 'Failed to send email',
          details: resendData
        }),
        { 
          status: 500,
          headers: corsHeaders
        }
      );
    }

    console.log('✅ Email sent successfully:', resendData.id);

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email sent successfully',
        emailId: resendData.id
      }),
      { 
        status: 200,
        headers: corsHeaders
      }
    );

  } catch (error) {
    console.error('❌ Function error:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    console.error('❌ Error details:', errorMessage);

    return new Response(
      JSON.stringify({ 
        success: false,
        error: 'Internal server error',
        message: errorMessage
      }),
      { 
        status: 500,
        headers: corsHeaders
      }
    );
  }
});
