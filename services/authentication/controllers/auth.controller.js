import { addEntity, getEntity } from '../util/index.js';
import { v4 as uuidv4 } from 'uuid';

export async function registerUser(user) {
  const { name, email, password, type } = user;

  if (!name || !email || !password || !type) throw new Error('Todos os campos são obrigatórios.');

  const existingUser = await getEntity(null, 'users', '*', { email });
  if (existingUser) throw new Error('E-mail já cadastrado.');

  const user = await addEntity({
    id: uuidv4(),
    name,
    email,
    password,
    type,
  }, 'users');

  return user;
}
