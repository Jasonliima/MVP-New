const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const router = express.Router();

const authMiddleware = require('../middleware/auth');

// Inicializa o SDK do Gemini buscando a chave do seu arquivo .env
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Configurações globais e banco de dados em memória para o MVP
let chatConfig = {
  userMessageLimit: 3 // Limite de mensagens padrão para usuários comuns
};
const userUsage = {}; // Histórico de contagem por usuário

// Rota exclusiva para ADMIN alterar o limite de uso
router.post('/admin/settings', authMiddleware, (req, res) => {
  const { newLimit } = req.body;
  const role = req.userRole; // Extraído do JWT no middleware!
  
  if (role !== 'admin') {
    return res.status(403).json({ error: 'Acesso negado. Apenas administradores podem realizar esta ação.' });
  }
  
  chatConfig.userMessageLimit = newLimit;
  return res.json({ message: 'Limite atualizado com sucesso!', newLimit });
});

router.post('/', authMiddleware, async (req, res) => {
  try {
    const { message } = req.body;
    const role = req.userRole; // Extraído do JWT de forma totalmente segura
    const userId = req.userId; // Extraído do JWT de forma totalmente segura

    if (!message) {
      return res.status(400).json({ error: 'Mensagem é obrigatória' });
    }

    // Aplica a restrição de limite APENAS para usuários comuns
    if (role === 'user') {
      if (!userUsage[userId]) userUsage[userId] = 0;
      if (userUsage[userId] >= chatConfig.userMessageLimit) {
        return res.status(403).json({ error: `Limite atingido. Você só pode enviar ${chatConfig.userMessageLimit} mensagens.` });
      }
      userUsage[userId]++; // Incrementa o uso
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    const result = await model.generateContent(message);
    const response = await result.response;
    const text = response.text();

    res.json({ reply: text });
  } catch (error) {
    console.error('Erro na integração com Gemini:', error);
    res.status(500).json({ error: 'Erro interno ao processar a mensagem' });
  }
});

module.exports = router;