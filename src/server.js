import "dotenv/config";
import app from "./app.js";
import { connectDB } from "./config/db.js";

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await connectDB(process.env.MONGO_URI);
    app.listen(PORT, () => {
      console.log(`API ouvindo na porta ${PORT}`);
    });
  } catch (err) {
    console.error("Erro ao iniciar a aplicação:", err);
    process.exit(1);
  }
}

start();
