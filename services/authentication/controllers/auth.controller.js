import { addEntity, query } from '../util/index.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export async function registerUser(user) {
  const { name, email, password, type } = user;

  if (!name || !email || !password || !type) throw new Error('Todos os campos são obrigatórios.');

  const existingUser = await query(`SELECT * FROM users WHERE email = $1`, [email]);
  if (existingUser.length) throw new Error('E-mail já cadastrado.');

  // Hash da senha
  const saltRounds = 10;
  const hashedPassword = await bcrypt.hash(password, saltRounds);

  await addEntity({
    name,
    email,
    password: hashedPassword,
    type,
  }, 'users');

  return await loginUser({ email, password });
}

export async function loginUser(credentials) {
  const { email, password } = credentials;

  if (!email || !password) throw new Error('Email e senha são obrigatórios.');

  const users = await query(`SELECT * FROM users WHERE email = $1`, [email]);
  if (!users.length) throw new Error('Credenciais inválidas.');

  const user = users[0];
  const isPasswordValid = await bcrypt.compare(password, user.password);
  
  if (!isPasswordValid) throw new Error('Credenciais inválidas.');

  // Gerar JWT token
  const token = jwt.sign(
    { 
      id: user.id, 
      email: user.email, 
      name: user.name, 
      type: user.type 
    },
    JWT_SECRET,
    { expiresIn: '24h' }
  );

  return {
      id: user.id,
      name: user.name,
      email: user.email,
      type: user.type,
      token
  };
}

export async function validateToken(token) {
  const decoded = jwt.verify(token, JWT_SECRET);
  return decoded;
}
