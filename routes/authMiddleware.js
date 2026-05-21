const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.status(401).json({ error: 'Acesso negado. Token não fornecido.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Descriptografa o token usando a mesma senha do auth.js
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'chave_super_secreta_mvp');
    req.userId = decoded.id;
    req.userRole = decoded.role; // Agora o cargo "admin" chega aqui perfeitamente!
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token inválido ou expirado.' });
  }
};