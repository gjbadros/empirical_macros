;;; $Id$
;;; doc-property-display.el
;;; By Greg J. Badros -- Sep 15, 1997
;;;
;;; A Rudimentary way to display the 'doc property of
;;; text at the point lazily
;;; e.g., use (put-text-property (point) (+ (point) 5) 'doc "This is a test")
;;; to create a 5 character interval that has a doc property, and turn
;;; the feature on by eval-ing the below code

(defsubst put-face-property-if-none (start end value)
  (put-property-if-none start end 'face value))

(defsubst put-mouse-face-property-if-none (start end value)
  (put-property-if-none start end 'mouse-face value))

(defun put-property-if-none (start end prop value)
  "GJB: Add a face property for between start and end on all characters that don't have one already"
  (let ((curr start)
	(next (next-single-property-change start prop (current-buffer) end)))
    (setq next (if next next end))
    (while (< curr next)
      (if (get-text-property curr prop)
	  ()
	(put-text-property curr next prop value))
      (setq curr next)
      (setq next (next-single-property-change curr prop (current-buffer) end))
      (setq next (if next next end)))))

(defun add-text-property (start end prop value)
  "GJB: Add prop of value to text between start and end, if prop already exists, try prop{1..}"
  (let ((curr start)
	(next (next-single-property-change start prop (current-buffer) end))
	(old-value))
    (setq next (if next next end))
    (while (< curr next)
      (setq old-value (get-text-property curr prop))
      (put-text-property curr next prop (concat old-value (if old-value "\n" "") value))
      (setq curr next)
      (setq next (next-single-property-change curr prop (current-buffer) end))
      (setq next (if next next end)))))

(defun add-list-property (start end prop value)
  "GJB: Add prop of value to list between start and end"
  (let ((curr start)
	(next (next-single-property-change start prop (current-buffer) end))
	(old-value))
    (setq next (if next next end))
    (while (< curr next)
      (setq old-value (get-text-property curr prop))
      (put-text-property curr next prop (append old-value (list value)))
      (setq curr next)
      (setq next (next-single-property-change curr prop (current-buffer) end))
      (setq next (if next next end)))))

(defun make-markers-for (filename start end)
  "GJB: Create a cons cell containing marker objects for the given locations"
  (save-excursion
    (let ((bfr (find-file-noselect filename)))
      (set-buffer bfr))
    (cons (copy-marker start) (copy-marker end))))

(defun add-list-marker-property (start end prop value filename offset-start offset-end)
  "GJB: Add prop of value and a marker with location to list between start and end
The location is specified as a filename and a start and end character offset.
If filename is `nil', the current file is assummed."
  (let ((curr start)
	(next (next-single-property-change start prop (current-buffer) end))
	(value-marker-cons (cons value (make-markers-for filename offset-start offset-end)))
	(old-value))
    (setq next (if next next end))
    (while (< curr next)
      (setq old-value (get-text-property curr prop))
      (put-text-property curr next prop (append old-value (list value-marker-cons)))
      (setq curr next)
      (setq next (next-single-property-change curr prop (current-buffer) end))
      (setq next (if next next end)))))


(defvar doc-property-display-last-message nil)

;; For now, just use message
;;(defsubst doc-property-message (format &rest args)
;;  (apply 'message format args))

(if (not (fboundp 'run-with-idle-timer))
    (error "Must have the run-with-idle-timer function.  Upgrade your Emacs!"))

(defun doc-property-message (fmt &rest args)
  (save-match-data
    (save-excursion
      (let ((old-frame (selected-frame)))
	(select-frame doc-property-display-message-frame)
	(switch-to-buffer doc-property-display-message-buffer)
	(delete-region (point-min) (point-max))
	(insert (apply 'format fmt args))
	(set-window-point (get-buffer-window doc-property-display-message-buffer) (point-max))
	(goto-char (point-max))
	;;      (set-cursor-color "linen") ;; this gets to black for some reason!
	(let ((height (+ 1 (count-lines (point-min) (point-max)))))
	  (if (= (if (= height 1) 2 height) 
		 (frame-height doc-property-display-message-frame))
	      ()
	    (set-frame-height doc-property-display-message-frame height)))
	(select-frame old-frame)))))

(defun doc-property-initialize-frame ()
  (setq doc-property-display-message-frame
	(make-frame '((name . "Doc property") (height . 1) (width . 80) (minibuffer . nil))))
  (setq doc-property-display-message-buffer (get-buffer-create "*Doc Property*"))
  (let ((old-frame (selected-frame)))
    (select-frame doc-property-display-message-frame)
    (switch-to-buffer doc-property-display-message-buffer)
    (select-frame old-frame)))

(defun doc-property-display-install ()
  (interactive)
  (make-variable-buffer-local 'doc-property-shown)
  (if (not doc-property-display-installed)
      (progn
	(add-hook 'post-command-hook 'doc-property-display-hook)
	(add-hook 'pre-command-hook 'doc-property-display-pre-command-refresh-echo-area)
	(cancel-function-timers 'doc-property-display)
	(run-with-idle-timer 
	 doc-property-display-timeout-seconds
	 t 
	 'doc-property-display)
	(setq doc-property-display-installed t)
	(doc-property-initialize-frame))))

(defun doc-property-display-unstall ()
  (interactive)
  (remove-hook 'post-command-hook 'doc-property-display-hook)
  (cancel-function-timers 'doc-property-display)
  (setq doc-property-display-installed nil))

(defun doc-property-display-hook ()
  (setq doc-property-shown nil))

(defvar doc-property-display-timeout-seconds .25)
      
(defvar doc-property-shown nil
  "Non-nil means that the doc property was already shown now.")

(defvar doc-property-display-installed nil
  "Non-nil means that the doc-property-display handlers are installed now.")

(defun make-properties-plist-from-list (L)
  (let ((retval nil))
    (while L
      (setq retval (cons '"" retval))
      (setq retval (cons (car L) retval))
      (setq L (cdr L)))
    retval))

(defvar doc-property-properties 
  '(def subst substexpn final-exp exp expsumm xform doc
	use expuse ifdefuse ifdefexpuse stack))

(defvar doc-property-properties-to-display 
  '(def subst substexpn final-exp exp expsumm xform doc 
	use expuse ifdefuse ifdefexpuse stack))

(defun doc-property-display ()
  (let ((doc (concat-text-properties-at (point) doc-property-properties-to-display)))
    (if doc
	(doc-property-message "%s" doc)
      (doc-property-message ""))))

(doc-property-display-install)

(defun location-description (marker-positions)
  (format "%s:[%d-%d]," (buffer-name (marker-buffer (car marker-positions)))
	  (marker-position (car marker-positions)) (marker-position (cdr marker-positions))))

(defun property-list-stringify (val)
  "GJB: Make val into a string with newlines separating the list elements if it is a list instead of a string; just return it if it is a string"
  (if (not (listp val))
      val
    (let ((result ""))
      (while val
	(setq result (concat result (if (consp (car val))
					(location-description (cdr (car val)))
				      (concat (car val) "\n"))))
	(setq val (cdr val)))
      (substring result 0 -1))))

(defun concat-text-properties-at (posn properties-list)
  "GJB: Make a long string listing the various properties in properties-list at the point"
  (let ((str "")
	(got-one nil))
    (while properties-list
      (let ((val (get-text-property posn (car properties-list)))
	    (property-name (concat (symbol-name (car properties-list)) ": ")))
	(if val
	    (progn
	      (setq got-one t)
	      (put-text-property 0 (length property-name) 'face 'bold property-name) 
	      (setq str (concat str property-name
				(property-list-stringify val) "\n" )))))
      (setq properties-list (cdr properties-list)))
    (if got-one
	(substring str 0 -1)
      nil)))


(defun apply-text-properties-from-textprops-buffer ()
  "GJB: Revert and eval the textprops.el buffer"
  (interactive)
  (let ((bfr (get-buffer "textprops.el")))
    (save-excursion
      (set-buffer bfr) (revert-buffer nil 'NOCONFIRM))
    (eval-buffer bfr)))

(defun apply-text-properties-from-textprops-source-buffer ()
  "GJB: Revert and eval the textprops-source.el buffer"
  (interactive)
  (let ((bfr (get-buffer "textprops-source.el")))
    (save-excursion
      (set-buffer bfr) (revert-buffer nil 'NOCONFIRM))
    (eval-buffer bfr)))

(defun apply-text-properties-for-current-buffer (&optional no-delete-file)
  "GJB: Use filter-for-file-prefix on textprops*.el and eval applicable lines"
  (interactive "P")
  (barf-if-buffer-read-only)
  (font-lock-mode -1)
  (remove-text-properties (point-min) (point-max) 
			  '(face mouse-face))
  (remove-text-properties (point-min) (point-max)
			  (make-properties-plist-from-list doc-property-properties))
  (eval-output-of-shell-command 
   (concat "filter-for-file-prefix " (buffer-name) "  <" 
	   text-properties-directory "textprops*.el")
   no-delete-file))


(defun replace-buffer-substring (start-point end-point text)
  (save-excursion
    (goto-char start-point)
    (barf-if-buffer-read-only)
    (delete-char (- end-point start-point))
    (insert text)))

(defun replace-all-uses (use-prop &optional replacement)
  (let ((curr-use)
	(start)
	(end))
    (while use-prop
      (setq curr-use (car use-prop))
      (setq use-prop (cdr use-prop))
      (let ((expn (car curr-use))
	    (s_start (car (cdr curr-use)))
	    (s_end (cdr (cdr curr-use))))
	(if (null replacement)
	    (setq replacement expn))
	(replace-buffer-substring s_start s_end replacement)))))

(defun replace-all-uses-of-current-def (force)
  (interactive "P")
  (let ((def (get-text-property (point) 'def))
	(uses (get-text-property (point) 'use))
	(xform (get-text-property (point) 'xform)))
    (if (null def)
	(message "Point not at a definition!")
      (if (null uses)
	  (message "Definition has no uses!")
	(if (and (not (null xform)) (not force) )
	    (message "Transformation may not be safe: %s" xform)
	  (replace-all-uses uses))))))

(defun prepare-subst-on-def (def)
  "GJB: Parse the text in def to find the extent of the definition
to be removed and save the start position in register r, and return length"
  (if (string-match "^\\(.*\\) defined \\[\\([0-9]+\\):\\([0-9]+\\)\\]$" def)
      (let ((mname (match-string 1 def))
	    (s_start (string-to-int (match-string 2 def)))
	    (s_end (string-to-int (match-string 3 def))))
	(save-excursion
	  (goto-char s_start)
	  (point-to-register ?r)
	  (cons (- s_end s_start) mname)))
    (nil . nil)))


(defun replace-current-def-with-subst (force)
  (interactive "P")
  (let ((def (get-text-property (point) 'def))
	(uses (get-text-property (point) 'use))
	(xform (get-text-property (point) 'xform))
	(subst (get-text-property (point) 'subst))
	(substexpn (get-text-property (point) 'substexpn))
	(delta))
    (if (null def)
	(message "Point not at a definition!")
      (if (null uses)
	  (message "Definition has no uses!")
	(if (null subst)
	    (message "There is not a pre-defined substitution")
	  (if (and (not (null xform)) (not force) )
	      (message "Transformation may not be safe: %s" xform)
	    (let* ((retval (prepare-subst-on-def def))
		   (subst-length (car retval))
		   (mname (cdr retval)))
	      (if (null subst-length)
		  (message "Cannot determine macro definition location")
		(replace-all-uses uses substexpn)
		(jump-to-register ?r)
		(replace-buffer-substring (point) (+ (point) subst-length) subst)
		))))))))

(provide 'doc-property-display)

;;; TODO:
;;; interactive options for selecting doc-property-properties-to-display
