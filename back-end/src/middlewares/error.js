export function errorMiddleware(err, _req, res, _next) { // middleware global de erros
  console.error(err);                                    // mostra o erro no console (log p/ debug)
  const status = err.status || 500;                      // pega status do erro ou usa 500 (erro interno)
  res.status(status).json({ message: err.message || "Erro interno" }); // responde em JSON p/ cliente
}
