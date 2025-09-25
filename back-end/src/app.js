import express from "express";                   // framework web
import morgan from "morgan";                     // logs de requisições HTTP
import cors from "cors";                         // libera acesso cross-origin
import rateLimit from "express-rate-limit";      // limita requisições
import { errorMiddleware } from "./middlewares/error.js";   // tratador global de erros
import authRoutes from "./routes/auth.routes.js";           // rotas de autenticação
import transactionRoutes from "./routes/transaction.routes.js"; // rotas de transações

const app = express();                           // cria instância do express

app.use(cors());                                 // habilita CORS p/ qualquer origem
app.use(express.json());                         // parseia JSON no body das reqs
app.use(morgan("dev"));                          // mostra logs no console

const authLimiter = rateLimit({                  // configura rate limit
  windowMs: 15 * 60 * 1000,                      // janela de 15 minutos
  max: 100,                                      // até 100 reqs por IP
});
app.use("/auth", authLimiter);                   // aplica limite só nas rotas /auth

app.get("/health", (_req, res) => {              // rota p/ checar se API está viva
  res.json({ status: "ok" });
});

app.use("/auth", authRoutes);                    // registra rotas de cadastro/login
app.use("/transactions", transactionRoutes);     // registra rotas de transações

app.use(errorMiddleware);                        // captura erros no fim da cadeia

export default app;                              // exporta p/ usar no server.js
