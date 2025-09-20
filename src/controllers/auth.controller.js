import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { validationResult } from "express-validator";
import User from "../models/User.js";

// função auxiliar para criar um token JWT
function signToken(userId) {
  return jwt.sign({ sub: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES || "1d", // expiração (default 1 dia)
  });
}

// controlador de registro de usuário
export async function register(req, res, next) {
  try {
    // valida os dados da requisição (vem do express-validator)
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { name, email, password } = req.body;

    // checa se já existe usuário com esse email
    const exists = await User.findOne({ email });
    if (exists) return res.status(409).json({ message: "Email já cadastrado" });

    // gera hash da senha antes de salvar no banco
    const passwordHash = await bcrypt.hash(password, 10);

    // cria o usuário no MongoDB
    const user = await User.create({ name, email, passwordHash });

    // gera token JWT para o novo usuário
    const token = signToken(user._id);

    // retorna o token + dados do usuário (sem a senha)
    res.status(201).json({ token, user: { id: user._id, name: user.name, email: user.email } });
  } catch (err) {
    // se der erro de índice único (concorrência rara)
    if (err?.code === 11000) {
      return res.status(409).json({ message: "Email já cadastrado" });
    }
    next(err);
  }
}

// controlador de login de usuário
export async function login(req, res, next) {
  try {
    // valida os dados de entrada
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { email, password } = req.body;

    // procura o usuário no banco
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ message: "Credenciais inválidas" });

    // compara senha recebida com o hash salvo
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ message: "Credenciais inválidas" });

    // gera token se estiver tudo certo
    const token = signToken(user._id);

    res.json({ token, user: { id: user._id, name: user.name, email: user.email } });
  } catch (err) {
    next(err);
  }
}
