package main

import (
	"expvar"
	"net/http"
)

func (app *application) routes() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /v1/healthcheck", app.healthcheckHandler)
	mux.Handle("GET /debug/vars", expvar.Handler())

	mux.HandleFunc("POST /v1/movies", app.requirePermission("movies:write", app.createMovieHandler))
	mux.HandleFunc("GET /v1/movies/{id}", app.requirePermission("movies:read", app.showMovieHandler))
	mux.HandleFunc("PATCH /v1/movies/{id}", app.requirePermission("movies:write", app.updateMovieHandler))
	mux.HandleFunc("DELETE /v1/movies/{id}", app.requirePermission("movies:write", app.deleteMovieHandler))
	mux.HandleFunc("GET /v1/movies", app.requirePermission("movies:read", app.listMoviesHandler))

	mux.HandleFunc("POST /v1/users", app.createUserHandler)
	mux.HandleFunc("PUT /v1/users/activated", app.activateUserHandler)
	mux.HandleFunc("POST /v1/tokens/authentication", app.createAuthenticationTokenHandler)

	return app.metrics(app.recoverPanic(app.enableCORS(app.rateLimit(app.authenticate(mux)))))
}
