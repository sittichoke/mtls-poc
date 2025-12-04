package main

import (
	"fmt"
	"log"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	clientSubject := r.Header.Get("X-SSL-Client-Subject")
	clientVerify := r.Header.Get("X-SSL-Client-Verify")

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{
  "message": "Hello from Go API behind mTLS gateway",
  "client_subject": %q,
  "client_verify": %q
}`, clientSubject, clientVerify)
}

func main() {
	http.HandleFunc("/hello", helloHandler)
	addr := ":8080"
	log.Printf("Starting Go API on %s\n", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatal(err)
	}
}
