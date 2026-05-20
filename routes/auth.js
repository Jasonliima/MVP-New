const express = require('express');
const router = express.Router();
const { User } = require('../models');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ error: 'Todos os campos são obrigatórios' });
    }

    if (!['admin', 'user'].includes(role)) {
      return res.status(400).json({ error: 'Tipo de usuário inválido' });
    }

    // Verifica se já existe uma conta com este e-mail
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: 'Este e-mail já está cadastrado' });
    }

    // Criptografa a senha antes de salvar no banco de dados
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await User.create({
      name,
      email,
      password: hashedPassword,
      role
    });
    
    res.status(201).json({
      message: 'Conta criada com sucesso!',
      user: { 
        id: newUser.id.toString(), 
        name: newUser.name, 
        email: newUser.email, 
        role: newUser.role 
      }
    });
  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({ error: 'Erro interno ao criar a conta' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email } });
    
    if (!user) {
      return res.status(401).json({ error: 'E-mail ou senha incorretos' });
    }

    // Compara a senha digitada no app com a senha criptografada do banco
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'E-mail ou senha incorretos' });
    }

    // Gera o token JWT com o ID e a Role do usuário
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET || 'chave_super_secreta_mvp',
      { expiresIn: '1d' } // O token irá expirar em 1 dia
    );

    res.json({
      message: 'Login realizado com sucesso',
      token,
      user: { 
        id: user.id.toString(), name: user.name, role: user.role 
      }
    });
  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({ error: 'Erro interno ao realizar login' });
  }
});

module.exports = router;