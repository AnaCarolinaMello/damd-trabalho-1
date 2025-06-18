import { addEntity, query } from '../util/index.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AppError } from '../util/appError.js';
import validator from 'validator';

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

  // Validação de entrada
  if (!email || !password) {
    throw new AppError('Email e senha são obrigatórios.', 400);
  }

  // Validar formato de e-mail
  if (!validator.isEmail(email)) {
    throw new AppError('Formato de email inválido.', 400);
  }

  // Obter usuário com tratamento de erros
  let user;
  try {
    user = await getEntity(null, 'users', '*', { email });
  } catch (err) {
    throw new AppError('Erro ao buscar usuário.', 500);
  }

  if (!user) {
    throw new AppError('Credenciais inválidas.', 401);
  }

  // Verifique se a conta está bloqueada
  if (user.failed_attempts >= 5) {
    throw new AppError('Conta temporariamente bloqueada. Tente novamente mais tarde.', 403);
  }

  // Verificar senha
  const isPasswordValid = await bcrypt.compare(password, user.password);

  if (!isPasswordValid) {
    await query(
      'UPDATE users SET failed_attempts = failed_attempts + 1 WHERE id = $1',
      [user.id]
    );
    throw new AppError('Credenciais inválidas.', 401);
  }

  await query(
    'UPDATE users SET failed_attempts = 0 WHERE id = $1',
    [user.id]
  );

  // Gerar token
  const token = jwt.sign(
    {
      id: user.id,
      email: user.email,
      type: user.type
    },
    JWT_SECRET,
    { expiresIn: '1h' }
  );

  // Gerar token de atualização
  const refreshToken = jwt.sign(
    { id: user.id },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    type: user.type,
    token,
    refreshToken
  };
}

export async function validateToken(token) {
  const decoded = jwt.verify(token, JWT_SECRET);
  return decoded;
}
