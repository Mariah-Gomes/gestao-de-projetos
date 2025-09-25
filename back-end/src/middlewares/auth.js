import jwt from "jsonwebtoken";                         // lib para criar/verificar tokens JWT

export default function auth(req, res, next) {          // middleware de autenticação
  const hdr = req.headers.authorization || "";          // pega header Authorization (se não vier, fica "")
  const token = hdr.startsWith("Bearer ") ? hdr.slice(7) : null; // extrai token do formato "Bearer <token>"

  if (!token) return res.status(401).json({ message: "Token ausente" }); // sem token → 401

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET); // valida token usando segredo do .env
    req.userId = payload.sub;                                  // salva id do usuário na req
    next();                                                    // chama próxima função/rota
  } catch {
    return res.status(401).json({ message: "Token inválido ou expirado" }); // token inválido → 401
  }
}
