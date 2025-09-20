import mongoose from "mongoose"; // importa mongoose para definir schema/modelo

const userSchema = new mongoose.Schema( // cria o schema de usuário
  {
    name: {                             // nome do usuário
      type: String,                     // tipo texto
      required: true,                   // obrigatório
      minlength: 2,                      // mínimo 2 caracteres
      maxlength: 60,                     // máximo 60 caracteres
      trim: true                         // remove espaços extras
    },

    email: {                            // email do usuário
      type: String,                     // tipo texto
      required: true,                   // obrigatório
      unique: true,                     // não pode repetir no banco
      lowercase: true,                  // salva sempre em minúsculo
      index: true,                      // cria índice para buscas rápidas
      trim: true                        // remove espaços extras
    },

    passwordHash: {                     // senha criptografada
      type: String,                     // tipo texto
      required: true                    // obrigatório
    }
  },
  {
    timestamps: true                    // adiciona createdAt e updatedAt automaticamente
  }
);

export default mongoose.model("User", userSchema); // exporta o model "User" (coleção "users")
