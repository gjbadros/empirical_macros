;;; $Id$
;;; doc-property-display.el
;;; By Greg J. Badros -- Sep 15, 1997
;;;
;;; A Rudimentary way to display the 'doc property of
;;; text at the point lazily
;;; e.g., use (put-text-property (point) (+ (point) 5) 'doc "This is a test")
;;; to create a 5 character interval that has a doc property, and turn
;;; the feature on by eval-ing the below code
;;; OBSOLETED!!!!
;;; OBSOLETED!!!!  Use doc-property-display.el instead

(if (not (fboundp 'run-with-idle-timer))
    (message "Must have the run-with-idle-timer function.  Upgrad your Emacs!")

  (defvar doc-property-display-last-message nil)

  (defun doc-property-message (fmt &rest args)
    (save-excursion
      (select-frame doc-property-display-message-frame)
      (switch-to-buffer doc-property-display-message-buffer)
      (delete-region (point-min) (point-max))
      (insert (apply 'format fmt args))
      (set-window-point (get-buffer-window doc-property-display-message-buffer) (point-max))
      (goto-char (point-max))
;;      (set-cursor-color "linen") ;; this gets to black for some reason!
      (let ((height (count-lines (point-min) (point-max))))
	(if (<= height (frame-height doc-property-display-message-frame))
	    ()
	  (set-frame-height doc-property-display-message-frame height)))))


  (defun doc-property-display-install ()
    (interactive)
    (if (not doc-property-display-installed)
	(progn
	  (doc-property-initialize-frame)
	  (add-hook 'post-command-hook 'doc-property-display)
	  (setq doc-property-display-installed t))))

  (defun doc-property-display-unstall ()
    (interactive)
    (remove-hook 'post-command-hook 'doc-property-display)
    (setq doc-property-display-installed nil))

  (defvar doc-property-display-installed nil
    "Non-nil means that the doc-property-display handlers are installed now.")

  (defun doc-property-display ()
    (let ((doc (get-text-property (point) 'doc)))
      (if (and doc
	       (not (string= doc doc-property-display-last-message)))
	  (doc-property-message "%s" doc)
	(doc-property-message "") )))

  (defun doc-property-initialize-frame ()
    (setq doc-property-display-message-frame
	  (make-frame '((name . "Doc property") (height . 2) (width . 80) (minibuffer . nil))))
    (setq doc-property-display-message-buffer (get-buffer-create "*Doc Property*"))
    (let ((old-frame (selected-frame)))
      (select-frame doc-property-display-message-frame)
      (switch-to-buffer doc-property-display-message-buffer)
      (select-frame old-frame)))

  (doc-property-display-install))

