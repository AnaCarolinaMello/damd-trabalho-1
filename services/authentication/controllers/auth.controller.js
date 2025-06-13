import { addEntity, getEntity } from '../util/index.js';
import { v4 as uuidv4 } from 'uuid';

const registerUser = async (req, res) => {
  const { name, email, password, type } = req.body;

  if (!name || !email || !password || !type) {
    return res.status(400).json({ message: 'Todos os campos são obrigatórios.' });
  }

  // ver se email ja existe
  try {
    const existingUser = await getEntity(null, 'users', '*', { email });
    if (existingUser) {
      return res.status(409).json({ message: 'E-mail já cadastrado.' });
    }

    const user = await addEntity({
      id: uuidv4(),
      name,
      email,
      password,
      type,
    }, 'users');

    return res.status(201).json({ message: 'Usuário cadastrado com sucesso.', id: user.id });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Erro interno do servidor.' });
  }
};

export { registerUser };
