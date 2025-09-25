import { Router } from "express";                     // cria roteador do Express
import { body } from "express-validator";             // valida inputs do body
import { register, login } from "../controllers/auth.controller.js"; // controllers de auth

const router = Router();                              // inicializa roteador

router.post(                                          // rota POST /auth/register
  "/register",
  [
    body("name").isString().isLength({ min: 2 }),     // name precisa ser string, min 2 chars
    body("email").isEmail(),                          // email válido
    body("password").isLength({ min: 6 }),            // senha min 6 chars
  ],
  register                                            // chama controller register
);

router.post(                                          // rota POST /auth/login
  "/login",
  [
    body("email").isEmail(),                          // email válido
    body("password").isString().notEmpty(),           // senha string e não vazia
  ],
  login                                               // chama controller login
);

export default router;                                // exporta rotas p/ app.js
