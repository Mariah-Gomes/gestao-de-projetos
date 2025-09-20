import express from "express";
import morgan from "morgan";
import cors from "cors";
import rateLimit from "express-rate-limit";
import { errorMiddleware } from "./middlewares/error.js";
import authRoutes from "./routes/auth.routes.js";

const app = express();

// Middlewares globais
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

// Limita requisições em /auth (mitiga brute-force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // janela de 15 minutos
  max: 100,                  // até 100 reqs por IP nessa janela
});
app.use("/auth", authLimiter);

// Healthcheck
app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

// Rotas de autenticação
app.use("/auth", authRoutes);

// Middleware global de erros (sempre por último)
app.use(errorMiddleware);

export default app;
