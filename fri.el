;;; fri.el --- Functions to operate FRI

;; This file is not part of GNU Emacs.

;;; Code:
(defun fri-startp (name)
  (start-nix-worker-process (concat "fri-" name) (concat name "-start")))

(defun start ()
  (fri-startp "elk"))

(start)
