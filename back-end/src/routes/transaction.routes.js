import { Router } from "express";                       // cria roteador do Express
import { body, param, query } from "express-validator"; // valida inputs (body, params, query)
import auth from "../middlewares/auth.js";              // middleware de autenticação (JWT)
import {
  createTransaction,
  getTransactions,
  updateTransaction,
  deleteTransaction,
} from "../controllers/transaction.controller.js";      // controllers de transações

const router = Router();                                // inicializa roteador

router.use(auth);                                       // todas as rotas exigem token válido

router.post(                                            // rota POST /transactions
  "/",
  [
    body("type").isIn(["income", "expense"]).withMessage("type deve ser income ou expense"), // valida tipo
    body("amount").isFloat({ min: 0 }).withMessage("amount deve ser >= 0"),                  // valida valor >= 0
    body("date").isISO8601().withMessage("date deve ser ISO 8601 (YYYY-MM-DD)"),             // valida data ISO
    body("description").optional().isString(),                                              // descrição opcional
    body("category").optional().isString(),                                                 // categoria opcional
  ],
  createTransaction
);

router.get(                                             // rota GET /transactions
  "/",
  [
    query("type").optional().isIn(["income", "expense"]), // filtro opcional por tipo
    query("startDate").optional().isISO8601(),            // filtro opcional data inicial
    query("endDate").optional().isISO8601(),              // filtro opcional data final
  ],
  getTransactions
);

router.put(                                             // rota PUT /transactions/:id
  "/:id",
  [
    param("id").isMongoId(),                              // valida id no formato MongoDB
    body("type").optional().isIn(["income", "expense"]),  // valida campos opcionais
    body("amount").optional().isFloat({ min: 0 }),
    body("date").optional().isISO8601(),
    body("description").optional().isString(),
    body("category").optional().isString(),
  ],
  updateTransaction
);

router.delete(                                          // rota DELETE /transactions/:id
  "/:id",
  [param("id").isMongoId()],                             // valida id
  deleteTransaction
);

export default router;                                   // exporta rotas p/ app.js
