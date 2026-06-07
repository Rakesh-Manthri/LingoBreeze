const express = require("express");
const { v4: uuidv4 } = require("uuid");
const { asyncHandler } = require("../middleware/errorHandler");

/**
 * Creates the words router with all vocabulary endpoints.
 * @param {FirebaseFirestore.Firestore} db - Firestore database instance
 * @returns {express.Router} Configured Express router
 */
function createWordsRouter(db) {
  const router = express.Router();
  const wordsCollection = db.collection("words");

  /**
   * GET /words
   * Retrieve all vocabulary words, ordered by creation date (newest first).
   *
   * Response: { success: true, data: [...words] }
   */
  router.get(
    "/",
    asyncHandler(async (req, res) => {
      const snapshot = await wordsCollection
        .orderBy("createdAt", "desc")
        .get();

      const words = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate?.()?.toISOString() || null,
      }));

      res.json({
        success: true,
        data: words,
      });
    })
  );

  /**
   * POST /words
   * Create a new vocabulary word.
   *
   * Body: { word: string, meaning: string, translation: string }
   * Response: { success: true, data: { id, word, meaning, translation, createdAt } }
   */
  router.post(
    "/",
    asyncHandler(async (req, res) => {
      const { word, meaning, translation } = req.body;

      // Validate required fields
      if (!word || !meaning || !translation) {
        const error = new Error(
          "All fields are required: word, meaning, translation"
        );
        error.statusCode = 400;
        throw error;
      }

      // Validate field types
      if (
        typeof word !== "string" ||
        typeof meaning !== "string" ||
        typeof translation !== "string"
      ) {
        const error = new Error("All fields must be strings");
        error.statusCode = 400;
        throw error;
      }

      // Validate field lengths
      if (
        word.trim().length === 0 ||
        meaning.trim().length === 0 ||
        translation.trim().length === 0
      ) {
        const error = new Error("Fields cannot be empty or whitespace only");
        error.statusCode = 400;
        throw error;
      }

      const id = uuidv4();
      const now = new Date();

      const wordData = {
        word: word.trim(),
        meaning: meaning.trim(),
        translation: translation.trim(),
        createdAt: now,
      };

      await wordsCollection.doc(id).set(wordData);

      res.status(201).json({
        success: true,
        data: {
          id,
          ...wordData,
          createdAt: now.toISOString(),
        },
      });
    })
  );

  return router;
}

module.exports = { createWordsRouter };
