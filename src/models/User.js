import mongoose from "mongoose";

// Definindo o schema (molde) de como será um usuário no banco
const userSchema = new mongoose.Schema(
  {
    // Nome do usuário (obrigatório, mínimo 2 e máximo 60 caracteres)
    name: { type: String, required: true, minlength: 2, maxlength: 60, trim: true },

    // Email do usuário (obrigatório, único, sempre em minúsculo e sem espaços extras)
    email: { type: String, required: true, unique: true, lowercase: true, index: true, trim: true },

    // Hash da senha (armazenamos a senha criptografada, nunca a senha pura)
    passwordHash: { type: String, required: true }
  },
  {
    // createdAt: quando o documento foi criado
    // updatedAt: quando o documento foi atualizado pela última vez
    timestamps: true
  }
);

// Exporta o model "User", que vira a coleção "users" no Mongo
export default mongoose.model("User", userSchema);
