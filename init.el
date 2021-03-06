
;;; Unset these if default not loaded
;;(unload-feature 'tex-site)
;;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/auctex/")
;;(load "/usr/local/share/emacs/site-lisp/tex-site.el" nil t t)

;; (load "auctex.el" nil t t)
;; (load "preview-latex.el" nil t t)
;; (add-hook 'latex-mode-hook 'turn-on-reftex)
;; (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
;; (setq reftex-plug-into-auctex t)
;; (setq reftex-cite-format 'natbib)

;; flyspell mode for spell checking everywhere
;; (add-hook 'org-mode-hook 'turn-off-flyspell 'append)

;; (custom-set-variables
;; ;'(org-modules (quote (org-bbdb org-bibtex org-docview org-gnus org-info org-jsinfo org-irc org-mew org-mhe org-rmail org-special-blocks org-vm org-wl org-w3m)))
;;  '(org-pretty-entities t)
;;  '(org-use-property-inheritance t)
;;  '(org-export-copy-to-kill-ring nil))


(setq vc-handled-backends nil)           ; reduce save time

;; ORG directory
;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/")
;(add-to-list 'load-path "~/elisp/org-mode/contrib/")
;(add-to-list 'load-path "~/elisp/org-mode/contrib/lisp/")
;(add-to-list 'load-path "~/elisp/org-mode/contrib/scripts/")
;(require 'org-install)
;(require 'org)
(require 'cl)
(require 'org-latex)


;; org-babel
;(add-to-list 'load-path "~/elisp/org-mode/contrib/babel/")
;(add-to-list 'load-path "~/elisp/org-mode/contrib/babel/lisp/")
;(add-to-list 'load-path "~/elisp/org-mode/contrib/babel/lisp/langs/")

(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   ;;(R . t)
   (C . t)
   (awk . t)
   ;;     (ditaa . t)
   ;;     (dot . t)
   (emacs-lisp . t)
   (gnuplot . t)
   ;;     (haskell . t)
   (octave . t)
   (latex . t) ; this is the entry to activate LaTeX
   ;;     (ocaml . nil)
   ;;     (perl . t)
        (python . t)
   ;;     (ruby . t)
   ;;     (screen . t)
   (sh . t)))

;(require 'ob)

;; Set default header arguments for the Org-mode blocks 
(setq org-babel-default-header-args:org '((:results . "raw silent")
                                          (:exports . "none")))
;; Set default header arguments for the shell blocks used to
;; evaluate block calls.
;(setq org-babel-default-header-args:sh '((:results . "replace raw")
;					 (:exports . "none")))


(org-babel-lob-ingest "~/elisp/org-mode/doc/library-of-babel.org")


;; don't use the full set of Org-mode latex packages
(setq org-export-latex-default-packages-alist nil)

(setq org-confirm-babel-evaluate nil)

;; (defun org-mode-reftex-setup ()
;;   (load-library "reftex")
;;   (and (buffer-file-name) (file-exists-p (buffer-file-name))
;;        (progn
;; 	 ;enable auto-revert-mode to update reftex when bibtex file changes on disk
;; 	 (global-auto-revert-mode t)
;; 	 (reftex-parse-all)
;; 	 ;add a custom reftex cite format to insert links
;; 	 (reftex-set-cite-format
;; 	  '((?b . "[[bib:%l][%l-bib]]")
;; 	    (?n . "[[notes:%l][%l-notes]]")
;; 	    (?p . "[[papers:%l][%l-paper]]")
;; 	    (?t . "%t")
;; 	    (?h . "** %t\n:PROPERTIES:\n:Custom_ID: %l\n:END:\n[[papers:%l][%l-paper]]")))))
;; )

;; (add-hook 'org-mode-hook 'org-mode-reftex-setup)


;; (defun org-mode-article-modes ()
;;   (reftex-mode t)
;;   (and (buffer-file-name)
;;        (file-exists-p (buffer-file-name))
;;        (reftex-parse-all)))

;; (add-hook 'org-mode-hook
;;           (lambda ()
;;             (if (member "REFTEX" org-todo-keywords-1)
;;                 (org-mode-article-modes))))




;; Add a JSS-specific link type
(org-add-link-type
 "latex" nil
 (lambda (path desc format)
   (cond
    ((eq format 'html)
     (format "<span style=\"color:black;\">%s</span>" desc))
    ((eq format 'latex)
     (format "\\%s{%s}" path desc)))))




;; fix latex output
;; Warnings related to replace-regexp can be ignored until I find a better regex method in lisp or just do it in sed

(setq  org-export-latex-final-hook nil)
(add-hook 'org-export-latex-final-hook
	  (lambda ()
	    (setq case-fold-search nil)
	    (goto-char (point-min))
	    (search-forward "\\begin{document}")
	    (push-mark)

	    ;; Force hard space before references
	    (while (re-search-forward "\\( \\|\n\\)\\\\ref" nil t)
	      (replace-match "~\\\\ref" nil nil))

	    ;; Force space before citation
	    (goto-char (mark))
	    (while (re-search-forward "\\( \\|\n\\)\\\\cite" nil t)
	      (replace-match "\\\\ \\\\cite" nil nil))

	    ;; add shortened section titles
	    (goto-char (mark))
	    (while (re-search-forward "\\\\section{\\(.*\\):" nil t)
	      (replace-match "\\\\section[\\1]{\\1:" nil nil))

	    ;; Correct for citations immediately after an item
	    (goto-char (mark))
	    (while (re-search-forward "item[~\\\\]" nil t)
	      (replace-match "item " nil nil))

	    ;; Force space between double acronyms or acronyms and slashs
	    (goto-char (mark))
	    ;(replace-regexp "\\([A-Zu][A-Zsm]\\) \\([\\\\A-Z]\\)"
;		    "\\1\\\\ \\2")
;	    (while (re-search-forward  "\\([A-Zu][A-Zsm]\\) \\([\\\\A-Z]\\)" nil t)
;	      (replace-match "\\1\\\\ \\2" nil nil))

	    ;; Force \@ between acronyms and period.
	    (goto-char (mark))
	    ;(replace-regexp "\\([A-Zu][A-Zsm]\\) \\([\\\\A-Z]\\)"
;		    "\\1\\\\ \\2")
;	    (while (re-search-forward  "\\([A-Z][A-Z]\\)[\\.] " nil t)
;	      (replace-match "\\1\\\\@. " nil nil))


	    ;; Acronyms or Capitals at the end of a sentence cause poor spacing.
	    ;; White space reproduced for occurance preceeding \item
	    ;; (goto-char (mark))
	    ;; (replace-regexp "\\([A-Z][A-Zs]\\)\\.\\( \\|\n\\)"
	    ;;                 "\\1\\\\@.  \\2")

	    ;; Force space after acronym '\um'
	    (goto-char (mark))
	    (while (re-search-forward "\\(\\\\um\\)\\( \\|\n\\)" nil t)
	      (replace-match "\\1\\\\ \\2" nil nil))

	    ;; Force a space between numbers followed by text or acronym
	    (goto-char (mark))
	    (while (re-search-forward "\\([0-9]\\) \\([\\\\A-Za-z]\\)" nil t)
	      (replace-match "\\1\\\\ \\2" nil nil))

	    ;; Force a space between numbers followed by text or acronym
	    (goto-char (mark))
	    (while (re-search-forward "i\\.e\\. " nil t)
	      (replace-match "i.e.\\\\ " nil nil))

	    ;; Force  floating tables and figures to be at the top
	    (goto-char (mark))
	    (while (re-search-forward "htb" nil t)
	      (replace-match "t!" nil nil))

	    ;; Correct org-babel source block formatted outputs
	    (goto-char (mark))
	    (while (re-search-forward "\\\\texttt{\\\\$\\(.*\\)\\\\$}" nil t)
	      (replace-match "$\\1$" nil nil))

	    (goto-char (mark))
	    ;; Correct for poor tilda conversions
					;                  (goto-char (mark))
					;                  (replace-regexp "\\\\~\\{\\}"
					;                                  "~")
	    ;; double check \{ ... \}
	    (goto-char (mark))
	    (while (re-search-forward "\\\\{\\(.*\\)\\\\}" nil t)
	      (replace-match "{\\1}" nil nil))

	    ))


(setq org-latex-to-pdf-process '("pdfquick %b")) 
;; (setq org-latex-to-pdf-process '("pdflatex -interaction nonstopmode -halt-on-error %f  || exit 0" 
;;                                  "bibtex %b" "makeglossaries %b"  "pdflatex -interaction nonstopmode %f" 
;;                                  "pdflatex -interaction nonstopmode %f" )) 

;; allow for export=>beamer by placing
;; #+LaTeX_CLASS: beamer in org files
(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
(setq org-export-latex-title-command "") 
;; my-latex-export
(add-to-list 'org-export-latex-classes 
	     '("UoM-draft-org-article"
	       "\% -*- mode: latex; mode: visual-line; TeX-master: t; TeX-PDF-mode: t -*-
     \\documentclass[11pt,a4paper,twoside,openright]{book}
       \\usepackage{../org-manuscript/style/uomthesis} 
       \\input{../org-manuscript/misc/user-defined}
       \\usepackage[nonumberlist,acronym]{glossaries}
       \\input{../org-manuscript/misc/glossary} 
       \\makeglossaries
       \\pretolerance=150 \\tolerance=100
       \\setlength{\\emergencystretch}{3em} 
       \\overfullrule=1mm 
     % \\usepackage[notcite]{showkeys} 
       \\lfoot{\\footnotesize\\today\\ at \\thistime}"
; [NO-DEFAULT-PACKAGES]
;       [NO-PACKAGES]" 
	       ("\n\\section{%s}" . "\n\n\\section{%s}")
	       ("\\subsection{%s}"         . "\n\\subsection{%s}") 
	       ("\\subsubsection{%s}"      . "\n\\subsubsection{%s}") 
	       ("\\paragraph{%s}"          . "\n\\paragraph{%s}"))) 

(setq org-entities-user 
      '("ref" "~\\ref" nil "" "" "" ""))
(setq org-entities-user 
      '("space" "\\" nil " " " " " " " ")) 


(setq org-export-latex-title-command
  "{\n\\singlespacing\n\\tableofcontents\n}\n") 
(setq org-export-latex-hyperref-format "\\ref{%s}")


;; Add a JSS-specific link type
(org-add-link-type
 "latex" nil
 (lambda (path desc format)
   (cond
    ((eq format 'html)
     (format "<span style=\"color:black;\">%s</span>" desc))
    ((eq format 'latex)
     (format "\\%s{%s}" path desc)))))

;; JSS has its own code formatting style.
(setq org-export-latex-listings nil)
(setq org-export-latex-verbatim-wrap
      '("\\begin{Code}\n" . "\\end{Code}\n"))

;; don't use the full set of Org-mode latex packages
(setq org-export-latex-default-packages-alist nil)


