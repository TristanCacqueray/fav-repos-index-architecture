;;; fri.el --- Functions to operate FRI

;; This file is not part of GNU Emacs.

;;; Code:
(defun fri-startp (name)
  (start-nix-worker-process (concat "fri-" name) (concat name "-start")))

(defun fri-repl ()
  (start-nix-worker-process "fri-repl" "cabal repl -O0"))

(defun fri-ghcid ()
  (start-nix-worker-process "fri-ghcid" "ghcid"))

(defun start ()
  (fri-startp "elk")
  (fri-repl))
(start)
