import jwt from "jsonwebtoken";

// Middleware de autenticação
export default function auth(req, res, next) {
  // Pega o header Authorization
  const hdr = req.headers.authorization || "";

  // Espera o formato: "Bearer <token>"
  const token = hdr.startsWith("Bearer ") ? hdr.slice(7) : null;
  if (!token) return res.status(401).json({ message: "Token ausente" });

  try {
    // Valida o token com o segredo do .env
    const payload = jwt.verify(token, process.env.JWT_SECRET);

    // Salva o id do usuário na req, para usar nas rotas
    req.userId = payload.sub;

    next(); // segue para a rota
  } catch {
    return res.status(401).json({ message: "Token inválido ou expirado" });
  }
}