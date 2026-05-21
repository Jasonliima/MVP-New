const express = require('express');
const router = express.Router();
const authMiddleware = require('./authMiddleware');

// Banco de dados em memória para as rotinas (MVP)
let afazeres = [];
let afazeresIdCounter = 1;
let passosIdCounter = 1;

// [GET] Listar rotinas/afazeres
router.get('/', authMiddleware, (req, res) => {
  // Admin vê tudo. Filho vê apenas as tarefas atreladas ao ID dele.
  if (req.userRole === 'admin') {
    return res.json(afazeres);
  } else {
    const userAfazeres = afazeres.filter(a => 
      String(a.assignedTo) === String(req.userId).trim() || 
      String(a.assignedTo) === 'geral'
    );
    console.log(`[GET] Filho (ID ${req.userId}) buscou afazeres. Encontrados: ${userAfazeres.length}`);
    return res.json(userAfazeres);
  }
});

// [POST] Criar rotina (Apenas Admin/Pai)
router.post('/', authMiddleware, (req, res) => {
  if (req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Apenas o pai pode criar rotinas.' });
  }

  const { titulo, mensagem, assignedTo, tempo } = req.body;
  
  const novoAfazer = {
    id: afazeresIdCounter++,
    assignedTo: assignedTo || req.userId, // ID do filho (ou dele mesmo para teste)
    titulo,
    tempo: tempo || null, // Armazena o tempo na tarefa
    concluida: false,
    mensagem: mensagem || 'Você conseguiu! 🎉',
    passos: []
  };

  afazeres.push(novoAfazer);
  console.log(`[POST] Nova tarefa "${titulo}" atribuída para: ${novoAfazer.assignedTo}`);
  res.status(201).json(novoAfazer);
});

// [DELETE] Excluir rotina (Apenas Admin/Pai)
router.delete('/:id', authMiddleware, (req, res) => {
  if (req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Acesso negado.' });
  }

  const id = parseInt(req.params.id);
  afazeres = afazeres.filter(a => a.id !== id);
  res.json({ message: 'Afazer excluído com sucesso!' });
});

// [PUT] Concluir/Desconcluir rotina
router.put('/:id/concluir', authMiddleware, (req, res) => {
  const id = parseInt(req.params.id);
  const { concluida } = req.body;
  
  const afazer = afazeres.find(a => a.id === id);
  if (!afazer) return res.status(404).json({ error: 'Afazer não encontrado.' });

  afazer.concluida = concluida;
  res.json(afazer);
});

// ================= PASSOS ================= //

// [POST] Criar passo (Apenas Admin)
router.post('/:id/passos', authMiddleware, (req, res) => {
  if (req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Apenas o pai pode criar passos.' });
  }

  const afazer = afazeres.find(a => a.id === parseInt(req.params.id));
  if (!afazer) return res.status(404).json({ error: 'Afazer não encontrado.' });

  const novoPasso = {
    id: passosIdCounter++,
    descricao: req.body.descricao,
    concluido: false
  };

  afazer.passos.push(novoPasso);
  res.status(201).json(novoPasso);
});

// [PUT] Concluir passo
router.put('/:id/passos/:passoId/concluir', authMiddleware, (req, res) => {
  const afazer = afazeres.find(a => a.id === parseInt(req.params.id));
  if (!afazer) return res.status(404).json({ error: 'Afazer não encontrado.' });

  const passo = afazer.passos.find(p => p.id === parseInt(req.params.passoId));
  if (!passo) return res.status(404).json({ error: 'Passo não encontrado.' });

  passo.concluido = req.body.concluido;
  res.json(passo);
});

// [DELETE] Excluir passo (Apenas Admin)
router.delete('/:id/passos/:passoId', authMiddleware, (req, res) => {
  if (req.userRole !== 'admin') return res.status(403).json({ error: 'Acesso negado.' });

  const afazer = afazeres.find(a => a.id === parseInt(req.params.id));
  if (!afazer) return res.status(404).json({ error: 'Afazer não encontrado.' });

  afazer.passos = afazer.passos.filter(p => p.id !== parseInt(req.params.passoId));
  res.json({ message: 'Passo excluído com sucesso!' });
});

module.exports = router;