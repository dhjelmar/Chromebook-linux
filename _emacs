; Make desktop shortcut of runemacs
; Right click on shortcut and select properties / shortcut
; Set Target to:
;     "C:\Program Files\EMACS\emacs-21.3\bin\runemacs.exe" . -load "C:\.emacs"
; Set "Start In" to:
;     "C:\Documents and Settings\Owner\My Documents\Dave's Stuff"
; Note reason for above location for .emacs file is that this is considered "home".
; To see this, enter "M-x getenv" and enter environment variable "home".
; Executable is here: /usr/bin/emacs

; A CUSTOM LOOK
; -------------

;; set colors
;;(setq set-background-color blue)

;; colorcode dired mode emacs' font-lock conventions

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-hook 'dired-mode-hook 'turn-on-font-lock)

;; colorcode all visited files
(add-hook 'find-file-hooks 'turn-on-font-lock)

;; Make display-time display day and date also
(setq display-time-day-and-date t)
;; Display time, day and date in modeline
(display-time)

;; List full filename with path
(set-default  'mode-line-buffer-identification
           '(buffer-file-name ("%f") ("%b")))

;; Set display colors (use M-x list-faces to view displays that can be changed)
;;                    (use M-x list-colors to view color choices)
;(set-face-foreground 'modeline  "white")   
;(set-face-background 'modeline  "firebrick")   
(set-face-background 'region    "violet")   
(set-face-background 'highlight "salmon")   
(set-foreground-color           "antique white")   
(set-background-color           "midnightblue")   
(set-cursor-color               "green")   
(set-mouse-color                "green")   

; A CUSTOM FEEL
; -------------

;; do not add new lines when down arrow is used to move past end of file
(set-variable (quote next-line-add-newlines) nil)

;; do not match multiple spaces when search for single space
(set-variable (quote isearch-lax-whitespace) nil)

;; set various variables
(set-variable (quote auto-save-default) nil)
(set-variable (quote version-control) nil)
(set-variable (quote scroll-step) 1)

; not sure why, but following were disabled and I want them
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region    'disabled nil)
(put 'downcase-region  'disabled nil)
(put 'eval-expression  'disabled nil)

; control sequence bindings
(global-set-key "\C-xn" 'narrow-to-region)
(global-set-key "\C-xw"    'widen)
(global-set-key [M-left]  '(lambda() (interactive) (scroll-left 10))) ; executed as Alt-left arrow
(global-set-key [M-right] '(lambda() (interactive) (scroll-right 10))) ; executed as Alt-right arrow1

;; User defined functions
(defun truncate-toggle ()
   "Toggle continuation lines on and off"
   (interactive)
   (setq truncate-lines (not truncate-lines))
   (scroll-up 0))
(defun copy-line ()
   "Duplicate a line from anywhere inside it"
   (interactive)
   (beginning-of-line)
   (let ((start (point)))
     (forward-line)
     (copy-region-as-kill start (point))
     (yank)
     (forward-line -1)))
;; The following defines keyboard macro yessir
;; C-x (
;; yes
;; C-x )
;; M-x name-last-kbd-macro RET yessir RET
;; M-x insert-kbd-macro RET truncate-t RET
(fset 'yessir
   [?y ?e ?s return])

;; User customized key bindings
;; use F1 c then hit key to identify map for specific key
;; use F1 b to find all bindings
;; Chromebook: function key F1 is search-1, etc.
;;             (search key is magnifying glass)
(global-set-key [f1] 'help-for-help)
(global-set-key [f2] 'copy-line)
(global-set-key [f3] 'what-line)
(global-set-key [f4] 'what-cursor-position)
;;(global-set-key [f5] 'fortran-split-line)
(global-set-key [f5] 'call-last-kbd-macro)
(global-set-key [f6] 'query-replace)
(global-set-key [f8] 'shell-command)
(global-set-key [f9]  'kill-rectangle)
(global-set-key [f10] 'yank-rectangle)  ; search--
(global-set-key [f11] 'truncate-toggle) ; search-=
;; (global-set-key [f12] 'kill-line)
(fset 'delete-line
   [?\C-a ?\C-  ?\C-e ?\C-w delete])
(global-set-key [f12] 'delete-line)

;;; map for the keypad (there is no keypad on a chromebook)
;(global-set-key [kp-0] 'other-window)               ; C-x o
;(global-set-key [kp-subtract] 'list-buffers)        ; C-x C-b
;(global-set-key [kp-add] 'enlarge-window)           ; C-x ^
(global-set-key "\C-x=" 'enlarge-window)            ; C-x =     (note: C-x= enlarges font)
;(global-set-key [kp-enter] 'shrink-window)
;(global-set-key [kp-decimal] 'call-last-kbd-macro)  ; no standard shortcut; BOUND TO F5 = search-5
;;    (global-set-key [C-.] 'call-last-kbd-macro)  ; does not work
;;    (global-set-key "\C-." 'call-last-kbd-macro) ; does not work
;(global-set-key [kp-multiply] 'yessir)
;(global-set-key [kp-divide] 'truncate-toggle)       ; F11 = s-- (no standard shortcut)

;; Python mode
;; -----------
;; Python mode is automatically part of emacs
;; As such, some global changes like comment color below affect python mode
;; To check the mode, type C-h m
(set-face-foreground 'font-lock-comment-face "lightgreen")

;; OCTAVE MODE
;; -----------
;; Associate .m files with octave (or matlab)
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
;;; comment indents to beginning of line
;;  comment indents to same level as code
					;   comment indents far to right

;; R mode (rstudio)
;;-----------------
;; ESS package for emacs to get R
;; http://ess.r-project.org/
;; Installation instructions here: https://jekyll.math.byuh.edu/other/howto/R/RE.shtml
;;
;; ### comment indents to beginning of line
;; ##  comment indents to same level as code
;; #   comment indents far to right
;;
;; Windows
;;     (add-to-list 'load-path "c:/program files/emacs/site-lisp/ess/lisp")
;;     (require 'ess-site)
;;
;; Linux
;;     ESS mode configuration (only if ess is in a nonstandard place)
       (add-to-list 'load-path "/home/dlhjel/ProgramFiles/emacs-site-lisp/ess/lisp");;<<CHANGE
       (autoload 'R-mode "ess-site.el" "ESS" t)
       (add-to-list 'auto-mode-alist '("\\.R$" . R-mode))
       (add-to-list 'auto-mode-alist '("\\.r$" . R-mode))
;;       (setq inferior-R-program-name "/opt/miniconda3/envs/conda_env/bin/R");;<<CHANGE
       (setq inferior-R-program-name "/opt/miniconda3/envs/py37rc/bin/R");;<<CHANGE
       ;;R stuff
       (setq ess-eval-visibly-p nil)
       (setq ess-ask-for-ess-directory nil)
       ;;(require 'ess-eldoc)   ;; this seems to be obsolete and does not work
       ;;compile the first target in the Makefile in the current directory using F9
       ;;(global-set-key [f9] 'compile)  ;; already using f9 and not looking to compile
       (setq compilation-read-command nil)
       ;;show matching parentheses
       (show-paren-mode 1)
;;
;; Disable auto replace of _ with <-
;; (defalias 'ess-smart-S-assign 'self-insert-command)  ; leave underscore key alone
;; (defalias 'ess-smart-S-assign 'self-insert-command)  ; leave underscore key alone
;; (setq ess-smart-S-assign nil)
;; (set-variable (quote ess-smart-S-assign) nil)
;; (set-variable (quote ess-toggle-undersore) nil)
;; (ess-toggle-underscore nil)  ; .emacs fails unless r file loaded first
;; following is a two line package attempt
(eval-after-load 'ess-site
'(ess-toggle-underscore nil))

;(setq ess-smart-S-assign-key ";")  ;if ";" needed, press ";" key twice
;(ess-toggle-S-assign nil)
;(ess-toggle-underscore nil) ;leave underscore key alone!

;; tips
;; ----
;; to find C-L, search for C-q C-L
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-time-mode t)
 '(inhibit-startup-screen t))
(put 'set-goal-column 'disabled nil)
