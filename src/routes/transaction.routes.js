import { Router } from "express";
import { body, param, query } from "express-validator";
import auth from "../middlewares/auth.js";
import {
  createTransaction,
  getTransactions,
  updateTransaction,
  deleteTransaction,
} from "../controllers/transaction.controller.js";

const router = Router();

// todas as rotas abaixo exigem token válido
router.use(auth);

// Criar transação
router.post(
  "/",
  [
    body("type").isIn(["income", "expense"]).withMessage("type deve ser income ou expense"),
    body("amount").isFloat({ min: 0 }).withMessage("amount deve ser >= 0"),
    body("date").isISO8601().withMessage("date deve ser ISO 8601 (YYYY-MM-DD)"),
    body("description").optional().isString(),
    body("category").optional().isString(),
  ],
  createTransaction
);

// Listar transações (com filtros opcionais)
router.get(
  "/",
  [
    query("type").optional().isIn(["income", "expense"]),
    query("startDate").optional().isISO8601(),
    query("endDate").optional().isISO8601(),
  ],
  getTransactions
);

// Atualizar transação
router.put(
  "/:id",
  [
    param("id").isMongoId(),
    body("type").optional().isIn(["income", "expense"]),
    body("amount").optional().isFloat({ min: 0 }),
    body("date").optional().isISO8601(),
    body("description").optional().isString(),
    body("category").optional().isString(),
  ],
  updateTransaction
);

// Deletar transação
router.delete("/:id", [param("id").isMongoId()], deleteTransaction);

export default router;
