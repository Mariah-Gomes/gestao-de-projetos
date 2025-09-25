import mongoose from "mongoose";              // importa o mongoose (ODM p/ MongoDB)

export async function connectDB(uri) {        // exporta função assíncrona p/ conectar no banco
  mongoose.set("strictQuery", true);          // exige que buscas usem campos definidos no schema
  await mongoose.connect('mongodb+srv://sousaarthur840:sXFWGkNwWCcpknkq@estoque.djdf0fe.mongodb.net/?retryWrites=true&w=majority&appName=Estoque');                // abre conexão com o MongoDB usando a URI recebida
  console.log("MongoDB conectado");           // mostra no terminal que deu tudo certo
}
