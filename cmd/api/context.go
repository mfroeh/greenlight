package main

import (
	"context"
	"net/http"

	"github.com/mfroeh/greenlight/internal/data"
)

type contextKey string

const (
	ContextKeyUser = contextKey("user")
)

func (app *application) contextSetUser(r *http.Request, user *data.User) *http.Request {
	ctx := context.WithValue(r.Context(), ContextKeyUser, user)
	return r.WithContext(ctx)
}

func (app *application) contextGetUser(r *http.Request) *data.User {
	user, ok := r.Context().Value(ContextKeyUser).(*data.User)
	if !ok {
		panic("missing user value in request context")
	}
	return user
}
