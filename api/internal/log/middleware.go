package log

import (
	"context"
	"log/slog"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const (
	loggerKey = "logger"
)

// LoggerMiddleware returns a gin middleware that logs request start and end with metadata and errors
func LoggerMiddleware() gin.HandlerFunc {
	baseLogger := slog.Default()

	return func(c *gin.Context) {
		start := time.Now()

		// get pre-handler attributes
		// todo: generate request id in nginx
		reqID := c.GetHeader("X-Request-ID")
		if reqID == "" {
			reqID = uuid.NewString()
		}

		preAttrs := []any{
			slog.String("method", c.Request.Method),
			slog.String("path", c.Request.URL.Path),
			slog.String("requestID", reqID),
			slog.String("clientIP", c.ClientIP()),
		}

		// bake attributes into logger
		reqLogger := baseLogger.With(preAttrs...)

		// log request start
		reqLogger.Info("REQUEST START")

		// store logger in the request context
		ctx := context.WithValue(c.Request.Context(), loggerKey, reqLogger)
		c.Request = c.Request.WithContext(ctx)

		// execute handler
		c.Next()

		// get post handler attributes
		status := c.Writer.Status()

		postAttrs := []any{
			slog.Int("status", status),
			slog.Duration("latency", time.Since(start)),
		}

		reqEndLogger := reqLogger.With(postAttrs...)

		// log request end
		if status >= 500 {
			if len(c.Errors) > 0 {
				reqEndLogger.Error("REQUEST END", "error", c.Errors.String())
			} else {
				reqEndLogger.Error("REQUEST END")
			}
		} else {
			reqEndLogger.Info("REQUEST END")
		}
	}
}


// FromContext extracts the logger attached by middleware, or falls back to slog.Default()
func FromContext(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(loggerKey).(*slog.Logger); ok {
		return logger
	}
	return slog.Default()
}