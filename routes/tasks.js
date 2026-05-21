const express = require('express');
const router = express.Router();
const authMiddleware = require('./authMiddleware');

// Banco de dados em memória para as tarefas (neste MVP)
let tasks = [];
let taskIdCounter = 1;

// [POST] Criar tarefa (Apenas Admin)
router.post('/', authMiddleware, (req, res) => {
  const { title, description, assignedTo } = req.body;
  if (!title) {
    return res.status(400).json({ error: 'O título é obrigatório.' });
  }
  
  const newTask = {
    id: taskIdCounter++,
    title,
    description: description || '',
    assignedTo: assignedTo ? String(assignedTo).trim() : 'geral',
    status: 'pending' // 'pending' ou 'completed'
  };
  
  tasks.push(newTask);
  res.status(201).json(newTask);
});

// [GET] Listar tarefas
router.get('/', authMiddleware, (req, res) => {
  // Admin vê todas as tarefas do sistema. Usuário vê apenas as dele.
  if (req.userRole === 'admin') {
    return res.json(tasks);
  } else {
    // Converte ambos para String para evitar bugs de tipagem (Int vs String)
    const userTasks = tasks.filter(t => 
      String(t.assignedTo) === String(req.userId).trim() ||
      String(t.assignedTo) === 'geral'
    );
    return res.json(userTasks);
  }
});

// [PUT] Concluir tarefa (Usuário ou Admin)
router.put('/:id/complete', authMiddleware, (req, res) => {
  const taskId = parseInt(req.params.id);
  const task = tasks.find(t => t.id === taskId);
  
  if (!task) {
    return res.status(404).json({ error: 'Recompensa não encontrada.' });
  }
  if (
    req.userRole !== 'admin' && 
    String(task.assignedTo) !== String(req.userId).trim() && 
    String(task.assignedTo) !== 'geral'
  ) {
    return res.status(403).json({ error: 'Você não tem permissão para resgatar esta recompensa.' });
  }

  task.status = 'completed';
  res.json({ message: 'Recompensa resgatada com sucesso!', task });
});

// [DELETE] Excluir tarefa (Apenas Admin)
router.delete('/:id', authMiddleware, (req, res) => {
  if (req.userRole !== 'admin') {
    return res.status(403).json({ error: 'Acesso negado. Apenas administradores podem excluir recompensas.' });
  }
  
  const taskId = parseInt(req.params.id);
  const initialLength = tasks.length;
  tasks = tasks.filter(t => t.id !== taskId);
  
  if (tasks.length === initialLength) {
    return res.status(404).json({ error: 'Recompensa não encontrada.' });
  }

  res.json({ message: 'Recompensa excluída com sucesso!' });
});

module.exports = router;