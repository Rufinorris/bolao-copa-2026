// =============================================
// CONFIGURAÇÃO SUPABASE
// =============================================
const SUPABASE_URL = 'https://depjjhmzisjmknechkcv.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlcGpqaG16aXNqbWtuZWNoa2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1MTAxMTUsImV4cCI6MjA5ODA4NjExNX0.Rthld2jJItVOrjIHsRwd6gU0MjLQXbPRvuVgS1gmGTs';

const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Auth helpers
async function getUser() {
  const { data: { user } } = await db.auth.getUser();
  return user;
}

const SITE_URL = 'https://bolao-copa-2026-three-psi.vercel.app';

async function signInWithEmail(email) {
  const { error } = await db.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: SITE_URL + '/index.html'
    }
  });
  return { error };
}

async function signOut() {
  await db.auth.signOut();
  window.location.href = 'index.html';
}

// Utilitários
function slugify(text) {
  return text.toLowerCase()
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '') +
    '-' + Math.random().toString(36).slice(2, 7);
}

function formatMoeda(valor) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valor);
}

function formatData(iso) {
  if (!iso) return 'A definir';
  const d = new Date(iso);
  return d.toLocaleDateString('pt-BR', { weekday: 'short', day: '2-digit', month: '2-digit' }) +
    ' ' + d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
}

function nomeFase(fase) {
  const map = {
    round32: 'Segunda Rodada',
    oitavas: 'Oitavas de Final',
    quartas: 'Quartas de Final',
    semi: 'Semifinal',
    terceiro: '3º Lugar',
    final: 'Final'
  };
  return map[fase] || fase;
}

function iniciais(nome) {
  return nome.split(' ').map(p => p[0]).slice(0, 2).join('').toUpperCase();
}

// Toast global
function showToast(msg, type = '') {
  let el = document.getElementById('toast');
  if (!el) {
    el = document.createElement('div');
    el.id = 'toast';
    el.className = 'toast';
    document.body.appendChild(el);
  }
  el.textContent = msg;
  el.className = `toast ${type}`;
  el.classList.add('show');
  setTimeout(() => el.classList.remove('show'), 3000);
}
