const db = require('../db');
const { v4: uuidv4 } = require('uuid');

const registerUser = async (req, res) => {
  const { name, email, password, type } = req.body;

  if (!name || !email || !password || !type) {
    return res.status(400).json({ message: 'Todos os campos são obrigatórios.' });
  }

  try {
    // Verifica se o e-mail já existe
    const existingUser = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM users WHERE email = ?', [email], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (existingUser) {
      return res.status(409).json({ message: 'E-mail já cadastrado.' });
    }

    const id = uuidv4();
    await new Promise((resolve, reject) => {
      db.run(
        'INSERT INTO users (id, name, email, password, type) VALUES (?, ?, ?, ?, ?)',
        [id, name, email, password, type],
        function (err) {
          if (err) reject(err);
          else resolve();
        }
      );
    });

    res.status(201).json({ message: 'Usuário cadastrado com sucesso.', id });
  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  }
};

module.exports = { registerUser };
