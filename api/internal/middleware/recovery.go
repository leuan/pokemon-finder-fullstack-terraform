package middleware

import (
	"api/internal/log"
	"log/slog"
	"net/http"
	"runtime/debug"

	"github.com/gin-gonic/gin"
)

// RecoveryMiddleware returns a gin custom recovery middleware that logs the stack trace and the error and gracefully ends the HTTP request
func RecoveryMiddleware() gin.HandlerFunc {
	return gin.CustomRecovery(func(c *gin.Context, recovered any) {
		// capture stack trace
		stack := string(debug.Stack())

		// extract logger from context
		logger := log.FromContext(c.Request.Context())

		// log the error
		logger.Error("Recovered from panic",
			slog.Any("error", recovered),
			slog.String("stack", stack),
		)

		// return 500
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
			"error": "internal server error. sorry :(",
		})
	})
}
