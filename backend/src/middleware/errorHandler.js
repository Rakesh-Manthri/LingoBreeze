/**
 * Centralized error-handling middleware for Express.
 * Catches all errors and returns a consistent JSON response.
 */
function errorHandler(err, req, res, next) {
  console.error("❌ Error:", err.message);

  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";

  res.status(statusCode).json({
    success: false,
    error: {
      message,
      ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    },
  });
}

/**
 * Wrapper for async route handlers to catch errors
 * and forward them to the error-handling middleware.
 */
function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

module.exports = { errorHandler, asyncHandler };
