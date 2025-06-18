export class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

router.post("/login", async (req, res) => {
  try {
    const response = await loginUser(req.body);
    return return200(response, res);
  } catch (error) {
    if (error.isOperational) {
      return res.status(error.statusCode).json({
        error: error.message,
        code: error.code || 'AUTH_ERROR'
      });
    }
    console.error('Login error:', error);
    return return500(error, req, res);
  }
});