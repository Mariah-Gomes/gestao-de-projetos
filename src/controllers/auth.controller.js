import bcrypt from "bcrypt";                        // lib para gerar/verificar hash de senha
import jwt from "jsonwebtoken";                     // lib para gerar/verificar tokens JWT
import { validationResult } from "express-validator"; // validação dos dados recebidos
import User from "../models/User.js";               // model do usuário no MongoDB

function signToken(userId) {                        // função auxiliar para criar JWT
  return jwt.sign(                                  // gera token
    { sub: userId },                                // payload → id do usuário
    process.env.JWT_SECRET,                         // segredo do .env
    { expiresIn: process.env.JWT_EXPIRES || "1d" }  // expiração (default 1 dia)
  );
}

export async function register(req, res, next) {    // controlador de registro
  try {
    const errors = validationResult(req);           // checa validação da rota
    if (!errors.isEmpty())                          // se houver erros de input
      return res.status(400).json({ errors: errors.array() });

    const { name, email, password } = req.body;     // pega dados do body

    const exists = await User.findOne({ email });   // verifica se email já existe
    if (exists) return res.status(409).json({ message: "Email já cadastrado" });

    const passwordHash = await bcrypt.hash(password, 10); // gera hash da senha (salt=10)

    const user = await User.create({                // cria usuário no banco
      name, 
      email, 
      passwordHash 
    });

    const token = signToken(user._id);              // gera token JWT

    res.status(201).json({                          // retorna token + dados (sem senha)
      token, 
      user: { id: user._id, name: user.name, email: user.email }
    });
  } catch (err) {
    if (err?.code === 11000) {                      // erro de índice único (email duplicado)
      return res.status(409).json({ message: "Email já cadastrado" });
    }
    next(err);                                      // manda pro errorMiddleware
  }
}

export async function login(req, res, next) {       // controlador de login
  try {
    const errors = validationResult(req);           // checa validação da rota
    if (!errors.isEmpty())                          // se input inválido
      return res.status(400).json({ errors: errors.array() });

    const { email, password } = req.body;           // pega dados do body

    const user = await User.findOne({ email });     // procura usuário no banco
    if (!user) return res.status(401).json({ message: "Credenciais inválidas" });

    const ok = await bcrypt.compare(password, user.passwordHash); // compara senha x hash
    if (!ok) return res.status(401).json({ message: "Credenciais inválidas" });

    const token = signToken(user._id);              // gera novo token JWT

    res.json({                                      // retorna token + dados
      token, 
      user: { id: user._id, name: user.name, email: user.email }
    });
  } catch (err) {
    next(err);                                      // manda erro pro errorMiddleware
  }
}
