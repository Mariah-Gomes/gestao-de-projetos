import { validationResult } from "express-validator";
import Transaction from "../models/Transaction.js";

// Criar uma nova transação
export async function createTransaction(req, res, next) {
  try {
    // valida os dados da requisição
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { type, amount, date, description, category } = req.body;

    // cria no banco vinculando ao usuário logado (req.userId vem do middleware auth)
    const tx = await Transaction.create({
      userId: req.userId,
      type,
      amount,
      date,
      description,
      category,
    });

    res.status(201).json(tx);
  } catch (err) {
    next(err);
  }
}

// Listar todas as transações do usuário (com filtros opcionais)
export async function getTransactions(req, res, next) {
  try {
    const { type, startDate, endDate } = req.query;

    const query = { userId: req.userId };

    // filtro por tipo (income/expense)
    if (type) query.type = type;

    // filtro por intervalo de datas
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    const txs = await Transaction.find(query).sort({ date: -1 });
    res.json(txs);
  } catch (err) {
    next(err);
  }
}

// Atualizar uma transação (apenas do usuário dono)
export async function updateTransaction(req, res, next) {
  try {
    const { id } = req.params;

    // busca transação e garante que pertence ao usuário logado
    const tx = await Transaction.findOneAndUpdate(
      { _id: id, userId: req.userId },
      req.body,
      { new: true, runValidators: true } // retorna atualizado e aplica validações
    );

    if (!tx) return res.status(404).json({ message: "Transação não encontrada" });

    res.json(tx);
  } catch (err) {
    next(err);
  }
}

// Deletar uma transação (apenas do usuário dono)
export async function deleteTransaction(req, res, next) {
  try {
    const { id } = req.params;

    const tx = await Transaction.findOneAndDelete({ _id: id, userId: req.userId });
    if (!tx) return res.status(404).json({ message: "Transação não encontrada" });

    res.json({ message: "Transação removida com sucesso" });
  } catch (err) {
    next(err);
  }
}