require("dotenv").config();

const express = require("express");
const cors = require("cors");
const { initializeFirebase } = require("./config/firebase");
const { createWordsRouter } = require("./routes/words");
const { errorHandler } = require("./middleware/errorHandler");

// ── Initialize Firebase ─────────────────────────────────────────────
const db = initializeFirebase();

// ── Create Express App ──────────────────────────────────────────────
const app = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ───────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Health Check ────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "LingoBreeze API is running 🚀",
    version: "1.0.0",
  });
});

// ── Routes ──────────────────────────────────────────────────────────
app.use("/words", createWordsRouter(db));

// ── Error Handling ──────────────────────────────────────────────────
app.use(errorHandler);

// ── Start Server ────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🚀 LingoBreeze API running on http://localhost:${PORT}`);
  console.log(`📚 Words endpoint: http://localhost:${PORT}/words\n`);
});
