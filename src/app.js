import express from "express";
import morgan from "morgan";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { errorMiddleware } from "./middlewares/error.js";
import authRoutes from "./routes/auth.routes.js";
import transactionRoutes from "./routes/transaction.routes.js";

const app = express();

// Middlewares globais
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

// Limita requisições em /auth (mitiga brute-force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // janela de 15 minutos
  max: 100,                 // até 100 reqs por IP nessa janela
});
app.use("/auth", authLimiter);

// Healthcheck (rota livre)
app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

// Rotas
app.use("/auth", authRoutes);             // cadastro/login
app.use("/transactions", transactionRoutes); // CRUD de transações

// Middleware global de erros (sempre por último)
app.use(errorMiddleware);

export default app;