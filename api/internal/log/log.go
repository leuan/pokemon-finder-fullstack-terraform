package log

import (
	"log/slog"
	"os"
	"strings"
)

func InitLogger() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		AddSource: true,
		Level:     LevelFromEnv(),
	}))
	slog.SetDefault(logger)
}

func LevelFromEnv() slog.Level {
	env := os.Getenv("LOG_LEVEL")

	switch strings.ToLower(env) {
	case "debug":
		return slog.LevelDebug
	case "warn":
		return slog.LevelWarn
	case "error":
		return slog.LevelError
	default:
		return slog.LevelInfo // default to info
	}
}
