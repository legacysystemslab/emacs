;;; init.el --- Emacs Configuration.                         -*- lexical-binding: t; -*-

;; Author:  Legacy Systems Lab
;; Keywords: init config emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This code contains my personalized Emacs configuration.

;;; Code:

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(setq gnutls-alogrithm-priority "NORMAL:-VERS-TLS1.3")

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(dolist (package '(use-package))
   (unless (package-installed-p package)
     (package-install package)))

(require 'use-package)
(setq use-package-always-ensure t)

;;; Themes
(use-package doom-themes)

;;; Garbage Collector
(use-package gcmh
  :diminish gcmh-mode
  :config
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 16 1024 1024))  ; 16mb
  (gcmh-mode 1))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-percentage 0.1)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;;; Emacs Configuration
(use-package emacs
  :init
  ;; User Profile
  (setq user-full-name "Legacy Systems Lab"
        user-mail-address "legacysystemslab@gmail.com")
  ;; General Settings
  (setq inhibit-startup-screen t
        initial-scratch-message nil
        sentence-end-double-space nil
        ring-bell-function 'ignore
        frame-resize-pixelwise t)
  (setq use-short-answers t)
  (setq confirm-kill-emacs 'yes-or-no-p)
  (setq-default tab-width 4)
  (setq-default fill-column 80)
  (setq line-move-visual t)
  (when (window-system)
    (tool-bar-mode 0)
    (menu-bar-mode 0))
  (global-display-line-numbers-mode)
  (setq indent-tabs-mode 'nil)
  (setq read-process-output-max (* 1024 1024))
  (delete-selection-mode t)
  (recentf-mode)
  (setq custom-safe-themes t)
  (winner-mode t)
  ;; Zoom
  (global-set-key (kbd "C-=") 'text-scale-increase)
  (global-set-key (kbd "C--") 'text-scale-decrease)
  ;; Unicode
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
  ;;; File Backups
  (setq create-lockfiles nil
        make-backup-files nil
        version-control t     ; number each backup file
        backup-by-copying t   ; instead of renaming current file (clobbers links)
        delete-old-versions t ; clean up after itself
        kept-old-versions 5
        kept-new-versions 5
        backup-directory-alist (list (cons "." (concat user-emacs-directory ".backup/"))))
  ;;; Theme
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'doom-one t)
  ;;; Trash
  (setq trash-directory "~/.trash")
  (setq delete-by-moving-to-trash t)
  ;;; Font
  (set-frame-font "Terminus-12:antialias=none:spacing=m" nil t))

;;; Editor Config
(use-package editorconfig
  :config
  (editorconfig-mode 1))

;;; Which Key
(use-package which-key
  :diminish which-key-mode
  :init
  (which-key-mode)
  (which-key-setup-minibuffer)
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-sort-order 'which-key-key-order-alpha
        which-key-min-display-lines 3
        which-key-max-display-columns nil))

;;; Company
(use-package company
  :config
  (setq company-idle-delay
	(lambda () (if (company-in-string-or-comment) nil 0.3)))
  (setq company-require-match nil)
  (setq company-frontends '(company-pseudo-tooltip-unless-just-one-frontend-with-delay
			    company-preview-frontend
			    company-echo-metadata-frontend))
  (setq company-backends '(company-capf
			   company-dabbrev-code
			   company-keywords))
  (setq company-tooltip-align-annotations t)
  (setq company-tooltip-limit 5)
  (setq company-tooltip-flip-when-above t)
  (setq company-files-exclusions '(".git/"))
  (global-company-mode 1))

(global-set-key (kbd "<backtab>")
		(lambda ()
		  (interactive)
		  (let ((company-tooltip-idle-delay 0.0))
		    (company-complete)
		    (and company-candidates
			 (company-call-frontends 'post-command)))))

;;; Flycheck
(use-package flycheck
  :init (global-flycheck-mode))

;;; LSP Mode
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  ((php-mode . lsp)
   (js2-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)
(use-package lsp-ui
  :hook
  (lsp-mode .lsp-ui-mode)
  :commands lsp-ui-mode)
(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)
(use-package dap-mode)

;;; Ivy
(use-package ivy
  :diminish ivy-mode
  :config
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq-default ivy-height 10)
  (ivy-mode 1))
(use-package ivy-rich
  :after ivy
  :init
  (setq ivy-rich-path-style 'abbrev)
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
  :config
  (ivy-rich-mode 1))

;;; Counsel
(use-package counsel
  :config
  (counsel-mode 1)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x b") 'counsel-buffer-or-recentf)
  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
  (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
  (global-set-key (kbd "<f1> l") 'counsel-find-library)
  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
  (global-set-key (kbd "C-x l") 'counsel-locate)
  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))

;;; Swiper
(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  (global-set-key (kbd "<f6>") 'ivy-resume))

;;; Magit
(use-package magit)

;;; Org Mode
(use-package org
  :pin gnu)

;;; COBOL-Mode
(use-package cobol-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.cob\\'" . cobol-mode))
  (add-to-list 'auto-mode-alist '("\\.cbl\\'" . cobol-mode))
  (add-to-list 'auto-mode-alist '("\\.cpy\\'" . cobol-mode)))

;;; init.el ends here
