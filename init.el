;;; init.el --- savelichalex configuration entry point.
;;
;; Copyright (c) 2011-2016 Alexey Savelev
;;
;; Author: Alexey Savelev <savelichalex93@gmail.com>
;; URL: http://batsov.com/prelude
;; Version: 1.0.0
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This file simply sets up the default load path and requires
;; the various modules defined within Emacs Prelude.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(require 'package)

(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))

(package-initialize)

;; install fonts if wasn't installed yet
(shell-command "~/.emacs.d/install_fonts.sh")

;; update the package metadata is the local cache is missing
(unless package-archive-contents
  (package-refresh-contents))

(setq user-full-name "Alexey Savelev"
      user-mail-address "savelichalex93@gmail.com")

(defconst savelichalex-savefile-dir (expand-file-name "savefile" user-emacs-directory))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p savelichalex-savefile-dir)
  (make-directory savelichalex-savefile-dir))

;; Always load newest byte code
(setq load-prefer-newer t)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; disable startup screen
(setq inhibit-startup-screen t)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; the toolbar is just a waste of valuable screen estate
;; in a tty tool-bar-mode does not properly auto-load, and is
;; already disabled anyway
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

;; the blinking cursor is nothing, but an annoyance
(blink-cursor-mode -1)

;; disable the annoying bell ring
(setq ring-bell-function 'ignore)

;; disable startup screen
(setq inhibit-startup-screen t)

;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

;; Emacs modes typically provide a standard means to change the
;; indentation width -- eg. c-basic-offset: use that to adjust your
;; personal indentation width, while maintaining the style (and
;; meaning) of any files you load.
(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 2)            ;; but maintain correct appearance

;; Newline at end of file
(setq require-final-newline t)

;; delete the selection with a keypress
(delete-selection-mode t)

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; misc useful keybindings
(global-set-key (kbd "s-<") #'beginning-of-buffer)
(global-set-key (kbd "s->") #'end-of-buffer)
(global-set-key (kbd "C-a") #'back-to-indentation)


;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-verbose t)
(setq use-package-always-ensure t)

(use-package paradox
  :config
  (paradox-enable))

(use-package expand-region
  :bind
  ("C-=" . er/expand-region))

(use-package which-key
  :config
  (which-key-mode +1))

(use-package recentf
  :config
  (setq recentf-save-file (expand-file-name "recentf" savelichalex-savefile-dir)
        recentf-max-saved-items 500
        recentf-max-menu-items 15)
  (recentf-mode +1)
  :bind
  (("s-r" . recentf-open-files)))

(use-package windmove
  :config
  (windmove-default-keybindings))

(use-package paren
  :config
  (show-paren-mode +1))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

(use-package move-text
  :ensure t
  :bind
  (([(meta shift up)] . move-text-up)
   ([(meta shift down)] . move-text-down)))

(use-package magit
  :bind
  (("C-x g" . magit-status)))

(use-package diff-hl
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (add-hook 'prog-mode-hook #'diff-hl-mode)
  (add-hook 'dired-mode-hook #'diff-hl-dired-mode))

(use-package swiper
  :bind
  (("C-s" . swiper)))

(use-package ivy
  :config
  (ivy-mode t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-re-builders-alist '((read-file-name-internal . ivy--regex-fuzzy) (t . ivy--regex-plus)))
  :bind
  (("C-c C-r" . ivy-resume)))

(use-package counsel
  :bind
  (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   :prefix-map counsel-prefix-map
   :prefix "C-c c"
   ("f" . counsel-find-file)
   ("g" . counsel-git)
   ("j" . counsel-git-grep)
   ("r" . counsel-recentf)
   ("s g" . counsel-grep)
   ("s r" . counsel-rg)
   ("s s" . counsel-ag)
   ("h f" . counsel-describe-function)
   ("h v" . counsel-describe-variable)
   ("h b" . counsel-descbinds)
   ))

(use-package projectile
  :custom
  (projectile-completin-system 'ivy)
  :config
  (projectile-mode))

(use-package counsel-projectile
  :after counsel projectile
  :config
  (counsel-projectile-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package flycheck
  :config
  (add-hook 'prog-mode-hook #'flycheck-mode))

(use-package yasnippet
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode))

(use-package dumb-jump
  :bind
  (("M-g o" . dumb-jump-go-other-window)
   ("M-g j" . dumb-jump-go)
   ("M-g i" . dumb-jump-go-prompt)
   ("M-g x" . dumb-jump-go-prefer-external)
   ("M-g z" . dumb-jump-go-prefer-external-other-window))
  :config
  (setq dumb-jump-selector 'ivy))

(use-package emmet-mode)

;; autocomplete
(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode)
	(setq company-dabbrev-downcase nil))

(use-package company-quickhelp
  :config
  (company-quickhelp-mode 1)
  (setq company-quickhelp-delay 3))

(use-package reverse-im
  :config
  (reverse-im-activate "russian-computer"))

(use-package smartparens
	:after (:all rjsx-mode typescript-mode)
  :config
  (add-hook 'rjsx-mode #'smartparens-mode)
	(add-hook 'typescript-mode #'smartparens-mode))

;; languages
(use-package rjsx-mode
  :mode "\\.js\\'"
  :config
  (defun setup-js-mode-hook ()
    (setq js2-basic-offset 2)
    (require 'flycheck)
    (require 'projectile)
    (setq-default flycheck-disabled-checkers
                  (append flycheck-disabled-checkers
                          '(javascript-standard javascript-jshint json-jsonlint)))
    (add-to-list 'flycheck-enabled-checkers 'javascript-eslint)
    (let ((project-root (projectile-project-root))
          (project-name (projectile-project-name)))
      (if (equal "fpn_portal" project-name)
          (setq-default flycheck-javascript-eslint-executable
                        (concat project-root "frontend/node_modules/.bin/eslint"))
        (setq-default flycheck-javascript-eslint-executable
                      (concat project-root "node_modules/.bin/eslint"))))
    (setq emmet-expand-jsx-className? t)
    (subword-mode 1))
  (add-hook 'rjsx-mode-hook 'setup-js-mode-hook)
  (add-hook 'rjsx-mode-hook 'emmet-mode)
  (setq-default indent-tabs-mode t))

(use-package css-mode
  :config
  (setq css-indent-offset 2))

(use-package stylus-mode
  :config
  (defun my-stylus-mode ()
    (setq emmet-indentation 2)
    (add-to-list 'emmet-css-major-modes 'stylus-mode))
  (add-hook 'stylus-mode 'my-stylus-mode)
  (add-hook 'stylus-mode 'emmet-mode))

;; Ocaml
(use-package tuareg
  :pin melpa-stable
  :mode (("\\.ml[ily]?$" . tuareg-mode)
           ("\\.topml$" . tuareg-mode))
  :config
  ;; Make OCaml-generated files invisible to filename completion
  (dolist (ext '(".cmo" ".cmx" ".cma" ".cmxa" ".cmi" ".cmxs" ".cmt" ".cmti" ".annot"))
    (add-to-list 'completion-ignored-extensions ext)))

(use-package reason-mode
	:pin melpa-stable
	:mode "\\.rei?$"
	:config
	(setq merlin-command "/Users/admin/.nvm/versions/node/v8.4.0/lib/node_modules/reason-cli/bin/ocamlmerlin"))

(use-package ocp-indent
  :config
  (add-hook 'tuareg-mode-hook 'ocp-indent-caml-mode-setup))

(use-package merlin
  :config
  (add-hook 'tuareg-mode-hook 'merlin-mode)
	(add-hook 'reason-mode-hook 'merlin-mode)
  (setq merlin-completion-with-doc t)
  (add-to-list 'company-backends 'merlin-company-backend)
  (setq merlin-error-after-save nil))

(use-package flycheck-ocaml
  :config
  (defun setup-ocaml-checker ()
    (flycheck-ocaml-setup))
  (add-hook 'tuareg-mode-hook 'setup-ocaml-checker))

(defun setup-tide-mode ()
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(use-package tide)

(defun setup-tslint ()
	"Setup tslint for current mode."
	(let ((project-root (projectile-project-root))
        (project-name (projectile-project-name)))
		(message "executable: %s" (concat project-root "node_modules/.bin/tslint"))
		(setq flycheck-checker 'typescript-tslint)
		(setq flycheck-disabled-checkers '())
		(setq flycheck-typescript-tslint-executable (concat project-root "node_modules/.bin/tslint"))
		(setq flycheck-typescript-tslint-config (concat project-root "tslint.json"))
		(add-to-list 'flycheck-enabled-checkers 'typescript-tslint)))

(use-package typescript-mode
  :mode "\\.ts\\'"
	:after (tide)
  :config
  ;; (add-hook 'before-save-hook 'tide-format-before-save)
	(add-hook 'typescript-mode-hook (lambda ()
																		(setup-tide-mode)
																		(setq-default indent-tabs-mode t)
																		(setq typescript-auto-indent-flag nil)
																		(setq typescript-indent-level 2)
																		(subword-mode 1)
																		(smartparens-mode 1)
																		(setup-tslint))))

(use-package web-mode
  :mode "\\.tsx\\'"
  :config
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-tide-mode)
								(setq indent-tabs-mode t)
								(setq web-mode-code-indent-offset 2)
								(setq web-mode-markup-indent-offset 2)
								(setq typescript-auto-indent-flag nil)
								(setq typescript-indent-level 2)
								(subword-mode 1)
								(smartparens-mode 1)
								(setq emmet-expand-jsx-className? t)
								(setup-tslint)
								(flycheck-add-mode 'typescript-tslint 'web-mode))))
	(add-hook 'web-mode-hook 'emmet-mode))

(use-package prettier-js
  :config
  (defun setup-plain-js-ft ()
		(setq prettier-js-args '(
                           "--print-width" "100"
                           "--tab-width" "2"
                           "--semi" "true"
                           "--single-quote" "false"
                           "--trailing-comma" "es5"
                           "--bracket-spacing" "true"
                           "--jsx-bracket-same-line" "false"
                           ))
		
		(prettier-js-mode))
  ;; (add-hook 'rjsx-mode-hook 'prettier-js-mode)
	(defun setup-ts-ft ()
		(setq prettier-js-args '(
														 "--print-width" "100"
														 "--use-tabs" "true"
														 "--single-quote" "true"
														 "--bracket-spacing" "true"
														 "--jsx-bracket-same-line" "true"
														 "--trailing-comma" "es5"
														 ))
		(setq prettier-js-command (concat (projectile-project-root) "node_modules/.bin/prettier"))
		(prettier-js-mode))
	(add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-ts-ft))))
	(add-hook 'typescript-mode-hook 'setup-ts-ft)
	)

(use-package ruby-mode
	:mode ("\\.rb\\'" "\\(Gemfile\\|Brewfile\\|Appfile\\|Fastfile\\)\\'"))

;; YAML
(use-package yaml-mode
  :mode ("\\.yml\\'" . yaml-mode))

;; Java/Kotlin stack

(use-package groovy-mode
	:pin melpa-stable
	:mode "\\.gradle\\'"
	:config
	(setq groovy-indent-offset 2))

(use-package kotlin-mode
	:mode "\\.kt[s]?\\'"
	:config
	(setq kotlin-tab-width 2))

;; Objective-C
(defun use-objc ()
	(add-to-list 'magic-mode-alist
               `(,(lambda ()
                    (and (string= (file-name-extension buffer-file-name) "h")
                         (re-search-forward "@\\<interface\\>" 
																						magic-mode-regexp-match-limit t)))
                 . objc-mode))
	(defun setup-objc-mode ()
		(require 'find-file) ;; for the "cc-other-file-alist" variable
		(nconc (cadr (assoc "\\.h\\'" cc-other-file-alist)) '(".m" ".mm"))
		(defadvice ff-get-file-name (around ff-get-file-name-framework
																				(search-dirs 
																				 fname-stub 
																				 &optional suffix-list))
			"Search for Mac framework headers as well as POSIX headers."
			(or
			 (if (string-match "\\(.*?\\)/\\(.*\\)" fname-stub)
					 (let* ((framework (match-string 1 fname-stub))
									(header (match-string 2 fname-stub))
									(fname-stub (concat framework ".framework/Headers/" header)))
						 ad-do-it))
       ad-do-it))
		(ad-enable-advice 'ff-get-file-name 'around 'ff-get-file-name-framework)
		(ad-activate 'ff-get-file-name)
		(setq cc-search-directories
					'("." "../include" "/usr/include" "/usr/local/include/*"
						"/System/Library/Frameworks" "/Library/Frameworks"))
		)
	(add-hook 'objc-mode-hook 'setup-objc-mode))
(use-objc)

(use-package flycheck-objc-clang
	:after flycheck
	:config
	(add-hook 'objc-mode-hook #'flycheck-objc-clang-setup)
	(custom-set-variables
	 '(flycheck-objc-clang-modules t)
	 '(flycheck-objc-clang-arc t)))

;; UI

(use-package frame
  :ensure nil
  :config
  (set-frame-font "Fira Code"))

(use-package dracula-theme
  :config
  (load-theme 'dracula t))

(use-package all-the-icons)

(use-package all-the-icons-ivy
  :after ivy projectile
  :custom
  (all-the-icons-ivy-buffer-commands '() "Don't use for buffers.")
  (all-the-icons-ivy-file-commands
   '(counsel-find-file
     counsel-file-jump
     counsel-recentf
     counsel-projectile-find-file
     counsel-projectile-find-dir) "Prettify more commands.")
  :config
  (all-the-icons-ivy-setup))

(use-package spaceline
  :config
  (setq ns-use-srgb-colorspace nil))

(use-package spaceline-all-the-icons
  :after spaceline
  :config
  (setq powerline-height 30)
  (setq powerline-text-scale-factor 0.9)
  (setq spaceline-all-the-icons-primary-separator "")
  (setq spaceline-all-the-icons-separator-type 'none)
  (spaceline-all-the-icons-theme)
  (spaceline-toggle-all-the-icons-git-status-on)
  (spaceline-toggle-all-the-icons-sunrise-off)
  (spaceline-toggle-all-the-icons-sunset-off)
  )

;; My functions
(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

;; Org
(use-package org
	:config
	(org-babel-do-load-languages
	 'org-babel-load-languages '((js . t))))

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flycheck-objc-clang-arc t)
 '(flycheck-objc-clang-modules t)
 '(package-selected-packages
   (quote
    (flycheck-objc-clang objc-mode reason-mode kotlin-mode groovy-mode ob-javascript tide web-mode typescript-mode typescript yaml-mode caml flycheck-ocaml merlin ocp-indent tuareg emmet-mode dumb-jump smartparens exec-path-from-shell spaceline-all-the-icons spaceline all-the-icons dracula-theme reverse-im company-quickhelp company emmet stylus-mode prettier-js rjsx-mode yasnippet flycheck counsel-projectile projectile counsel swiper diff-hl magit move-text which-key expand-region paradox use-package)))
 '(projectile-completin-system (quote ivy) t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
