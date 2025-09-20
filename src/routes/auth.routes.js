import { Router } from "express";
import { body } from "express-validator";
import { register, login } from "../controllers/auth.controller.js";

const router = Router();

// Rota de registro
router.post(
  "/register",
  [
    // validações simples do corpo da requisição
    body("name").isString().isLength({ min: 2 }),
    body("email").isEmail(),
    body("password").isLength({ min: 6 }),
  ],
  register
);

// Rota de login
router.post(
  "/login",
  [
    body("email").isEmail(),
    body("password").isString().notEmpty(),
  ],
  login
);

export default router;
