import express from "express";
import morgan from "morgan";
import cors from "cors";
import { errorMiddleware } from "./middlewares/error.js";

const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

/* sempre por último */
app.use(errorMiddleware);

export default app;
