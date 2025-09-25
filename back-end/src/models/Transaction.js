import mongoose from "mongoose"; // importa mongoose para definir schema/modelo

const transactionSchema = new mongoose.Schema( // cria o schema de transação
  {
    userId: {                                // id do usuário dono da transação
      type: mongoose.Schema.Types.ObjectId,  // referência p/ outro documento (User)
      ref: "User",                           // referencia o model "User"
      required: true,                        // obrigatório
      index: true                            // índice p/ busca rápida por usuário
    },
    type: {                                  // tipo da transação
      type: String,                          // texto
      enum: ["income", "expense"],           // só aceita "income" ou "expense"
      required: true                         // obrigatório
    },
    amount: {                                // valor da transação
      type: Number,                          // número
      required: true,                        // obrigatório
      min: 0                                 // não pode ser negativo
    },
    date: {                                  // data da transação
      type: Date,                            // tipo data
      required: true                         // obrigatório
    },
    description: {                           // descrição opcional
      type: String,
      default: ""                            // padrão: vazio
    },
    category: {                              // categoria opcional
      type: String,
      default: "General"                     // padrão: "General"
    }
  },
  {
    timestamps: true                         // adiciona createdAt e updatedAt automáticos
  }
);

export default mongoose.model("Transaction", transactionSchema); // exporta model "Transaction" (coleção "transactions")
