;;; Package -- Summary
;;; Commentary: config primarly used for writing notes/papers. Also for web dev (no completion framework)
;; -*- lexical-binding: t -*-
(defvar file-name-handler-alist-original file-name-handler-alist)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      file-name-handler-alist nil
      site-run-file nil)

(defvar nux/gc-cons-threshold 100000000)

(add-hook 'emacs-startup-hook ; hook run after loading init files
          #'(lambda ()
              (setq gc-cons-threshold nux/gc-cons-threshold
                    gc-cons-percentage 0.1
                    file-name-handler-alist file-name-handler-alist-original)))
(add-hook 'minibuffer-setup-hook #'(lambda ()
                                     (setq gc-cons-threshold most-positive-fixnum)))
(add-hook 'minibuffer-exit-hook #'(lambda ()
                                    (garbage-collect)
                                    (setq gc-cons-threshold nux/gc-cons-threshold)))
(require 'package)

;;(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(setq package-enable-at-startup nil)
(package-initialize)

;; Setting up the package manager. Install if missing.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Always ensure t
(eval-and-compile
  (setq use-package-always-ensure t))

;; General settings
(use-package emacs
  :preface
  (defvar nux/indent-width 2)
  :config
  (setq user-full-name "Jeremy LP")
  (setq user-mail "jeremy.pro.lp@gmail.com")
  (setq frame-title-format '("Emacs"))
  (setq ring-bell-function 'ignore)
  (setq default-directory "~/")
  (setq frame-resize-pixelwise t)
  (setq scroll-conservatively 100)
  (setq scroll-preserve-screen-position t)
  (setq auto-window-vscroll nil)
  (setq load-prefer-newer t)
  (fset 'yes-or-no-p 'y-or-n-p)
  (setenv "BROWSER" "firefox" t)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (setq-default line-spacing 0)
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width nux/indent-width))

;; GUI
;; Remove unused features
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(display-time-mode 1)
;; Enable subwords for camel case
(global-subword-mode 1)

;; Dump custom-set-variables to a garbage file and don't load it
(use-package cus-edit
  :ensure nil
  :config
  (setq custom-file "~/.emacs.d/to-be-dumped.el"))

(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

;; I don't care about auto save and backup files.
(setq
 make-backup-files nil
 auto-save-default nil
 create-lockfiles nil)

;; Graphicals tweaks
;; Remove ugly startup screen
(use-package "startup"
  :ensure nil
  :config (setq inhibit-startup-screen t))

;; Colorschemes
(use-package doom-themes) ;; Cool bundle
(use-package faff-theme)  ;; Relaxing theme but lacking in certain aspect
(use-package dracula-theme) ;; Well it's Dracula
(use-package acme-theme) ;; Acme is good and relaxing same as faff
(use-package moe-theme) ;; Like acme more colorfull
;;(load-theme 'tsdh-light t) ;; Best default theme available

;; Load theme
(load-theme 'tsdh-light t)

;; Fonts
(set-face-attribute 'default nil :font "Courier Prime 14")

;; UTF-8 encoding
(set-terminal-coding-system  'utf-8)
(set-keyboard-coding-system  'utf-8)
(set-language-environment    'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system   'utf-8)
(prefer-coding-system        'utf-8)
(set-input-method nil)

;; Editing
(electric-pair-mode 1)

;; Crux :testing:
;; Bundle of  utilities functions
(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)
         ("C-o" . crux-smart-open-line)
         ("C-S-o" . crux-smart-open-line-above)
         ("C-k" . crux-smart-kill-line)
         ("s-R" . crux-rename-file-and-buffer)))

;; Move-text VS Code like
(use-package move-text
  :config
  (move-text-default-bindings))

;; Actually pretty good
(use-package hungry-delete
  :config
  (global-hungry-delete-mode))

;; Modern delete
(use-package delsel
  :ensure nil
  :config (delete-selection-mode +1))

;; Matching parent
(use-package paren
  :ensure nil
  :init (setq show-paren-delay 0)
  :config (show-paren-mode +1))

;; Expand region under the cursor semantically
(use-package expand-region
  :bind
  ("M-z" . 'er/expand-region)
  ("M-Z" . 'er/contract-region))

;; Delete trailing spaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; Multiple Cusors
;; Bind like VS Code
(use-package multiple-cursors
  :config
  (setq mc/always-run-for-all 1)
  :bind
  (("M-S-<down>" . 'mc/mark-next-like-this)
   ("M-S-<up>" . 'mc/mark-previous-like-this)))

;; Navigation
;; Avy -- jump to line or to char
(use-package avy
  :bind
  ("M-s" . avy-goto-char-2)
  ("M-g" . avy-goto-line))

;; Globally search with swipper -- results the minibuffer
(use-package swiper
  :bind
  ("C-s" . swiper))

(use-package ripgrep)

;; Completion framework
;;Ivy lightweight completion
(use-package ivy
  :config
  (ivy-mode 1)
  (setq
    ivy-use-virtual-buffers t
    ivy-count-format "(%d/%d) "
    enable-recursive-minibuffers t
    ivy-initial-inputs-alist nil))

(use-package prescient
  :config
  (setq prescient-filter-method '(literal regexp initialism fuzzy))
  (prescient-persist-mode +1))

(use-package ivy-prescient
  :after (prescient ivy)
  :config
  (setq ivy-prescient-sort-commands
        '(:not swiper
               counsel-grep
               counsel-rg
               counsel-projectile-rg
               ivy-switch-buffer
               counsel-switch-buffer))
  (setq ivy-prescient-retain-classic-highlighting t)
  (ivy-prescient-mode +1))

;; Framework on top of ivy
(use-package counsel
  :config
  ;; When using git ls (via counsel-git), include unstaged files
  (setq counsel-git-cmd "git ls-files -z --full-name --exclude-standard --others --cached --")
  (setq ivy-initial-inputs-alist nil)
  :bind
   (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   ("C-x C-f" . counsel-find-file)))

;; Company -- autocompletion backend
(use-package company
  :hook
  (prog-mode . company-mode)
  ;;(text-mode . company-mode)
  (org-mode . company-mode)
  :bind
  ;;("TAB" . company-complete)
  :config
  (setq company-minimum-prefix-length 1)
  (setq company-idle-delay 0)
  (setq company-selection-wrap-around t)
  (setq company-tooltip-align-annotations t)
  (setq company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
                            company-echo-metadata-frontend))
  (with-eval-after-load 'company
    (define-key company-active-map (kbd "C-j") nil) ; avoid conflict with emmet-mode
    (define-key company-active-map (kbd "C-n") #'company-select-next)
    (define-key company-active-map (kbd "C-p") #'company-select-previous)))

;; Which key
;; Display commands choice when hitting C-x / C-c etc.
 (use-package which-key
   :diminish which-key-mode
   :config
   (which-key-mode +1)
   (setq which-key-idle-delay 0.4
         which-key-idle-secondary-delay 0.4))

;; Snippets
(use-package yasnippet
  :diminish yas-minor-mode
  :config (yas-global-mode 1))

(use-package yasnippet-snippets)

(use-package yasnippet-classic-snippets)

;; More doc
(use-package eldoc
  :ensure nil
  :config
  (setq eldoc-idle-delay 0.4))

;; Projectile quick file jump in your dir project
(use-package projectile
  :config
  (setq projectile-sort-order 'recentf)
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") #'projectile-command-map)
  (define-key projectile-mode-map (kbd "M-p") #'projectile-find-file)
  (define-key projectile-mode-map (kbd "s-F") #'projectile-ripgrep))

;; Some functions
;; Reload config
(defun my/reload-config ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))
(global-set-key (kbd "C-c r") 'my/reload-config)
;; Load config from anywhere
(defun my/config ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(global-set-key (kbd "C-c i") 'my/config)

;; Refresh packages
(defun my/refresh ()
  (interactive)
  (package-refresh-contents))

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

;; Kill buffer without warning
(defun insta-kill-buffer ()
  (interactive)
  (kill-buffer))
(global-set-key (kbd "s-K") 'insta-kill-buffer)

;; Org mode
;; Set environment
(use-package org
  :config
  (setq
   org-startup-indented t
   ;;org-catch-invisible-edits t
   org-ellipsis " ... "
   ;;org-bullets-bullet-list '("⁖")
   org-directory "~/Dropbox/org"
   org-src-tab-acts-natively t
   org-src-preserve-indentation t
   org-src-fontify-natively t)
  )

;; Org agenda
(setq org-agenda-files (quote ("~/Dropbox/org" "~/Dropbox/org/archive" "~/Dropbox/Drafts")))
(setq calendar-week-start-day 1)
(setq org-agenda-tags-column t)
(setq org-tags-column t)
(setq org-agenda-sticky t)
(setq org-deadline-warning-days 7)
(setq org-agenda-compact-blocks nil)
(setq org-agenda-time-grid
      (quote
       ((daily today remove-match)
        (800 1200 1600 2000)
        "......" "----------------")))
(global-set-key (kbd "C-c a") 'org-agenda)

(use-package org-super-agenda
  :config
  (setq org-super-agenda-groups '((:name "Today"
                                  :time-grid t
                                  :scheduled today)
                           (:name "Due today"
                                  :deadline today)
                           (:name "Important"
                                  :priority "A")
                           (:name "Overdue"
                                  :deadline past)
                           (:name "Due soon"
                                  :deadline future)
                           (:name "Big Outcomes"
                                  :tag "bo"))))

;;Fancy headers
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))


;; Add more states to todos
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "green" :weight bold))
        ("DONE" . (:foreground "cyan" :weight bold))
        ("WAITING" . (:foreground "green" :weight bold))
        ("URGENT" . (:foreground "red" :weight bold))
        ("SOMEDAY" . (:foreground "gray" :weight bold))))

;; Todos states
(setq org-todo-keywords
 '((sequence
    "STARTED(s)"
    "TODO(t)"  ; next action
    "WAITING(w@/!)"
    "SOMEDAY(.)" "|" "DONE(x!)" "CANCELLED(c)")
   (sequence "URGENT(!)" "HIGH(h)" "|" "MEDIUM(m)" "Low(l)")))

;; Org capture
;; Some tweaks to make here
(setq org-capture-templates
      '(("l" "Link" entry (file+headline "~/Dropbox/org/links.org" "Links")
         "* %a %^g\n %?\n %T\n %i")
        ("b" "Idea" entry (file+headline "~/Dropbox/org/ideas.org" "IDEA:")
         "* %?\n%T" :prepend t)
        ("b" "Project" entry (file+headline "~/Dropbox/org/projects.org" "IDEA:")
         "* %?\n%T" :prepend t)
        ("t" "Todo" entry (file+headline "~/Dropbox/org/todos.org" "Todo")
         "* TODO %?\n%u" :prepend t)
        ("n" "Note" entry (file+olp "~/Dropbox/org/notes.org" "Notes")
          "* %u %? " :prepend t)
        ("r" "RSS" entry (file+headline "~/Dropbox/elfeed.org" "Feeds")
           "** %^g\n" :prepend t)))

(global-set-key (kbd "C-c c") 'org-capture)

;;Register more exports
(require 'ox-md)

;; Ibuffer
(use-package ibuffer
  :config
  (setq ibuffer-expert t)
  :bind
  ("C-x C-b" . ibuffer))

;; Code and language
;; Template engine
(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.jsx?\\'"  . web-mode)
         ("\\.tsx?\\'"  . web-mode)
         ("\\.json\\'"  . web-mode))
  :config
  (setq web-mode-markup-indent-offset nux/indent-width)
  (setq web-mode-code-indent-offset nux/indent-width)
  (setq web-mode-css-indent-offset nux/indent-width)
  (setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'")))
  :hook
  (web-mode . rainbow-mode))

;; Fast code with Emmet
(use-package emmet-mode
  :hook ((html-mode   . emmet-mode)
         (css-mode    . emmet-mode)
         (js-mode     . emmet-mode)
         (js-jsx-mode . emmet-mode)
         (web-mode    . emmet-mode))
  :config
  (setq emmet-insert-flash-time 0.001) ; basically disabling it
  (add-hook 'js-jsx-mode-hook #'(lambda ()
                                  (setq-local emmet-expand-jsx-className? t)))
  (add-hook 'web-mode-hook #'(lambda ()
                               (setq-local emmet-expand-jsx-className? t))))

;; Markdown
(use-package markdown-mode)

;; RSS feed in Emacs
(use-package elfeed
  :init
  (setq elfeed-sort-order 'descending)
  :bind
  ("C-c u" . elfeed-update)
  ("C-c e" . elfeed))

;; Store links in an org file
(use-package elfeed-org
  :config
  (setq rmh-elfeed-org-files (list "~/Dropbox/elfeed.org"))
  (elfeed-org))

;; Highlight colors
(use-package rainbow-mode)

;; Try packages without installing themes
(use-package try)

;; Diminish certains mode
(use-package diminish)

;; Custom kbd
(define-key global-map (kbd "<f5>") 'revert-buffer)
(define-key global-map (kbd "C-c x") 'eval-buffer)
(define-key global-map (kbd "C-c f") 'eval-region)

;; Previous/Next buffer
(global-set-key (kbd "C->") 'next-buffer)
(global-set-key (kbd "C-<") 'previous-buffer)

;; Load / Disable theme
(define-prefix-command 'z-map)
(global-set-key (kbd "C-z") 'z-map)
(define-key z-map (kbd "e") 'elfeed)
(define-key z-map (kbd "v") 'split-and-follow-vertically)
(define-key z-map (kbd "h") 'split-and-follow-horizontally)

(load custom-file 'noerror)

(provide 'init)
