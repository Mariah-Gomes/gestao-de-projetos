import { validationResult } from "express-validator"; // validação dos dados recebidos
import Transaction from "../models/Transaction.js";   // model de transações no MongoDB

export async function createTransaction(req, res, next) { // cria nova transação
  try {
    const errors = validationResult(req);            // valida inputs
    if (!errors.isEmpty())                           // se inválido, retorna 400
      return res.status(400).json({ errors: errors.array() });

    const { type, amount, date, description, category } = req.body; // pega dados do body

    const tx = await Transaction.create({            // salva transação vinculada ao usuário logado
      userId: req.userId,                            // vem do auth middleware
      type,
      amount,
      date,
      description,
      category,
    });

    res.status(201).json(tx);                        // retorna transação criada
  } catch (err) {
    next(err);                                       // manda erro pro errorMiddleware
  }
}

export async function getTransactions(req, res, next) { // lista transações do usuário
  try {
    const { type, startDate, endDate } = req.query;  // filtros opcionais por query
    const query = { userId: req.userId };            // só busca do usuário logado

    if (type) query.type = type;                     // filtra por tipo

    if (startDate || endDate) {                      // filtra por intervalo de datas
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    const txs = await Transaction.find(query).sort({ date: -1 }); // busca ordenado por data desc
    res.json(txs);                                   // retorna lista
  } catch (err) {
    next(err);
  }
}

export async function updateTransaction(req, res, next) { // atualiza transação
  try {
    const { id } = req.params;                       // pega id da URL

    const tx = await Transaction.findOneAndUpdate(   // procura e atualiza
      { _id: id, userId: req.userId },               // garante que é do usuário logado
      req.body,                                      // aplica mudanças recebidas
      { new: true, runValidators: true }             // retorna atualizado + valida
    );

    if (!tx) return res.status(404).json({ message: "Transação não encontrada" });

    res.json(tx);                                    // retorna atualizado
  } catch (err) {
    next(err);
  }
}

export async function deleteTransaction(req, res, next) { // deleta transação
  try {
    const { id } = req.params;                       // pega id da URL

    const tx = await Transaction.findOneAndDelete({  // procura e remove
      _id: id, 
      userId: req.userId
    });
    if (!tx) return res.status(404).json({ message: "Transação não encontrada" });

    res.json({ message: "Transação removida com sucesso" }); // confirma remoção
  } catch (err) {
    next(err);
  }
}
