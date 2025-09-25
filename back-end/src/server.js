import "dotenv/config";                     // carrega variáveis do .env automaticamente
import app from "./app.js";                 // importa a aplicação express já configurada
import { connectDB } from "./config/db.js"; // função para conectar no MongoDB

const PORT = process.env.PORT || 3000;      // pega porta do .env ou usa 3000

async function start() {                    // função principal para iniciar o servidor
  try {
    await connectDB(process.env.MONGO_URI); // conecta no MongoDB
    app.listen(PORT, () => {                // inicia o servidor na porta definida
      console.log(`API ouvindo na porta ${PORT}`);
    });
  } catch (err) {
    console.error("Erro ao iniciar a aplicação:", err); // mostra erro no console
    process.exit(1);                                   // encerra processo se der erro
  }
}

start();                                    // chama a função para rodar tudo
