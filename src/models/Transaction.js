import mongoose from "mongoose";

// Schema de transações financeiras
// - Cada transação pertence a um usuário (userId)
// - type: 'income' (entrada) ou 'expense' (saída)
// - amount: valor >= 0
// - date: data da transação
// - description/category: metadados úteis
const transactionSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    type: { type: String, enum: ["income", "expense"], required: true },
    amount: { type: Number, required: true, min: 0 },
    date: { type: Date, required: true },
    description: { type: String, default: "" },
    category: { type: String, default: "General" }
  },
  {
    // createdAt / updatedAt automáticos
    timestamps: true
  }
);

// Exporta como "Transaction" -> coleção "transactions"
export default mongoose.model("Transaction", transactionSchema);
