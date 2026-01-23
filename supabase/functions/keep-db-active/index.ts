// @ts-nocheck - This file runs in Deno runtime, not Node.js
// Edge Function para manter a base de dados Supabase ativa
// Esta função faz um insert e depois delete na tabela db_keepalive
// Deve ser executada diariamente via cron job do Supabase

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    console.log('🔄 [keep-db-active] Iniciando rotina de keepalive da base de dados');
    
    // Criar cliente Supabase com service_role para bypass RLS
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ [keep-db-active] Variáveis de ambiente não configuradas');
      return new Response(
        JSON.stringify({ 
          error: 'Configuração do Supabase não encontrada',
          success: false 
        }),
        { 
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    console.log('✅ [keep-db-active] Cliente Supabase criado');

    // Passo 1: Fazer um INSERT na tabela db_keepalive
    console.log('📝 [keep-db-active] Executando INSERT...');
    const { data: insertData, error: insertError } = await supabase
      .from('db_keepalive')
      .insert({
        note: `Keepalive ping - ${new Date().toISOString()}`
      })
      .select()
      .single();

    if (insertError) {
      console.error('❌ [keep-db-active] Erro no INSERT:', insertError);
      return new Response(
        JSON.stringify({ 
          error: 'Erro ao inserir registro de keepalive',
          details: insertError.message,
          success: false 
        }),
        { 
          status: 500,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    console.log('✅ [keep-db-active] INSERT realizado com sucesso. ID:', insertData.id);

    // Pequeno delay para garantir que a operação foi registrada
    await new Promise(resolve => setTimeout(resolve, 100));

    // Passo 2: Fazer um DELETE do registro que acabamos de inserir
    console.log('🗑️ [keep-db-active] Executando DELETE...');
    const { error: deleteError } = await supabase
      .from('db_keepalive')
      .delete()
      .eq('id', insertData.id);

    if (deleteError) {
      console.error('❌ [keep-db-active] Erro no DELETE:', deleteError);
      // Mesmo com erro no delete, o insert já foi feito, então consideramos sucesso parcial
      return new Response(
        JSON.stringify({ 
          warning: 'INSERT realizado, mas DELETE falhou',
          details: deleteError.message,
          insertId: insertData.id,
          success: true // Ainda é sucesso porque a DB foi ativada
        }),
        { 
          status: 200,
          headers: { 'Content-Type': 'application/json' }
        }
      );
    }

    console.log('✅ [keep-db-active] DELETE realizado com sucesso');

    // Passo 3: Limpar registros antigos (mais de 7 dias) para manter a tabela limpa
    console.log('🧹 [keep-db-active] Limpando registros antigos...');
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const { error: cleanupError } = await supabase
      .from('db_keepalive')
      .delete()
      .lt('created_at', sevenDaysAgo.toISOString());

    if (cleanupError) {
      console.warn('⚠️ [keep-db-active] Aviso na limpeza de registros antigos:', cleanupError);
      // Não é crítico, apenas logamos o aviso
    } else {
      console.log('✅ [keep-db-active] Limpeza de registros antigos concluída');
    }

    const result = {
      success: true,
      message: 'Base de dados mantida ativa com sucesso',
      timestamp: new Date().toISOString(),
      operations: {
        insert: 'success',
        delete: 'success',
        cleanup: cleanupError ? 'warning' : 'success'
      }
    };

    console.log('✅ [keep-db-active] Rotina concluída com sucesso:', result);

    return new Response(
      JSON.stringify(result),
      { 
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      }
    );

  } catch (error) {
    console.error('❌ [keep-db-active] Erro inesperado:', error);
    
    return new Response(
      JSON.stringify({ 
        error: 'Erro inesperado na rotina de keepalive',
        details: error.message,
        success: false 
      }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
})
