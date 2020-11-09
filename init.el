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


;; Metrics
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))


(require 'package)


;; Sources
;;(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(setq package-enable-at-startup nil)
(package-initialize)

;; Setting up the package manager. Install if missing.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


;; Always ensure installed
(eval-and-compile
  (setq use-package-always-ensure t))


;; General settings
(use-package emacs
  :preface
  (defvar nux/indent-width 2)
  :config
  (setq user-full-name "prim0rdial")
  (setq user-mail "jeremy.pro.lp@gmail.com")
  (setq frame-title-format '("Emacs"))
  (setq ring-bell-function 'ignore)
  (setq default-directory "~/")
  (setq frame-resize-pixelwise t)
  ;; Better scrolling
  (setq scroll-conservatively 101)
  (setq scroll-preserve-screen-position t)
  (setq auto-window-vscroll nil)
  (setq echo-keystrokes 0.02)
  (setq load-prefer-newer t)
  ;; Should be default
  (fset 'yes-or-no-p 'y-or-n-p)
  ;; Open browser stuff with firefox
  (setenv "BROWSER" "firefox" t)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  ;; Increase line spacing for better readability
  (setq-default line-spacing 3)
  (setq-default indent-tabs-mode nil)
  ;; Disable useless gui stuff
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  ;; Remove line between two fringes
  (set-face-attribute 'vertical-border nil :foreground (face-attribute 'fringe :background))
  (setq-default fill-column 79)
  (setq confirm-kill-emacs 'y-or-n-p)
  (setq-default tab-width nux/indent-width))


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


;; UTF-8 encoding
(set-terminal-coding-system  'utf-8)
(set-keyboard-coding-system  'utf-8)
(set-language-environment    'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system   'utf-8)
(prefer-coding-system        'utf-8)
(set-input-method nil)


;; GUI related
;; Fonts
;; Courier Prime, most compatible serif fonts tested. Nice for writing.
;;(set-face-attribute 'default nil :font "Courier Prime 14")
;;(set-face-attribute 'default nil :font "Cascadia Code Regular 14")
(if (condition-case nil
        (x-list-fonts "Hack")
      (error nil))
    (progn
      (add-to-list 'default-frame-alist '(font . "Hack"))
      (set-face-attribute 'default nil :font "Hack")))

;; Welcome screen
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)
;; Open buffer in dired ~/Dropbox/
(setq initial-buffer-choice "~/Dropbox/")

;; Colorscheme madness
;; (use-package flatui-theme
;;   :config
;;   (load-theme 'flatui t))


;; (use-package vscode-dark-plus-theme
;;   :config
;;   (load-theme 'vscode-dark-plus t))


(use-package dracula-theme
  :config (load-theme 'dracula t)
  (set-face-background 'mode-line "#510370")
  (set-face-background 'mode-line-inactive "#212020"))

(custom-set-faces
 '(mode-line ((t (:background "#510370" :foreground "white")))))


;; Mode-line enhancements
;; (use-package smart-mode-line
;;   :config
;;   (setq sml/no-confirm-load-theme t)
;;   (setq sml/modified-char "*")
;;   (sml/setup))


(setq-default mode-line-format '("%e"
                                 mode-line-front-space
                                 " "
                                 mode-line-modified
                                 " "
                                 "%[" mode-line-buffer-identification "%]"
                                 "   "
                                 "L%l"
                                 "  "
                                 mode-line-modes
                                 mode-line-misc-info
                                 projectile-mode-line
                                 " "
                                 (:propertize " " display ((space :align-to (- right 14)))) ;; push to the right side
                                 (vc-mode vc-mode)
                                 mode-line-end-spaces))

;; All the icons pack
(use-package all-the-icons
  :defer 0.5)

;; All the icons ivy
(use-package all-the-icons-ivy
  :after (all-the-icons ivy)
  :custom (all-the-icons-ivy-buffer-commands '(ivy-switch-buffer-other-window ivy-switch-buffer))
  :config
    (add-to-list 'all-the-icons-ivy-file-commands 'counsel-dired-jump)
    (add-to-list 'all-the-icons-ivy-file-commands 'counsel-find-library)
    (all-the-icons-ivy-setup))

;; All the icons dired
(use-package all-the-icons-dired
  :hook
  (dired-mode-hook . all-the-icons-dired-mode))

;; Editing
;; Enable subwords for camel case
(global-subword-mode 1)
;; Disable annoying highlight line
(global-hl-line-mode 0)
;; Autopair wrapper
(electric-pair-mode 1)


;; Actually doesn't use current theme background so it's ugly
;; (use-package whitespace
;;   :config
;;   (global-whitespace-mode))
(require 'whitespace)
(setq-default show-trailing-whitespace t)


(use-package highlight-symbol
  :hook (prog-mode . highlight-symbol-mode)
  :config
  (setq highlight-symbol-idle-delay 0.3))


(use-package highlight-escape-sequences
  :hook (
         (text-mode . hes-mode)
         (prog-mode . hes-mode)))


;; Expand region under the cursor semantically
(use-package expand-region
  :bind
  ("M-z" . 'er/expand-region)
  ("M-Z" . 'er/contract-region))


;; Multiple Cusors
;; Bind like VS Code
(use-package multiple-cursors
  :config
  (setq mc/always-run-for-all 1)
  :bind
  (("M-S-<down>" . 'mc/mark-next-like-this)
   ("M-S-<up>" . 'mc/mark-previous-like-this)))


;; Regular undo-redo
(use-package undo-fu)
(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-z")   'undo-fu-only-undo)
(global-set-key (kbd "C-S-z") 'undo-fu-only-redo)
(global-set-key (kbd "s-z")   'undo-fu-only-undo)
(global-set-key (kbd "s-r")   'undo-fu-only-redo)

;; Bundle of  utilities functions
(use-package crux
  :bind (("C-a" . crux-move-beginning-of-line)
         ("C-o" . crux-smart-open-line)
         ("C-c d" . crux-duplicate-current-line-or-region)
         ("C-x 4 t" . crux-transpose-windows)
         ("C-S-o" . crux-smart-open-line-above)
         ("C-k" . crux-smart-kill-line)
         ("C-c k" . crux-kill-other-buffers)
         ("M-o" . crux-other-window-or-switch-buffer)
         ("C-c o". crux-open-with)
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


;; Windows
(setq
 split-height-threshold 0
 split-width-threshold nil)


;; Better window switching
(use-package ace-window
  :ensure t
  :config
  (setq aw-scope 'frame) ;; was global
  (global-set-key (kbd "C-x o") 'ace-window))


;; Delete trailing spaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)


;; Navigation
;; Avy -- jump to line or to char
(use-package avy
  :bind
  ("M-s" . avy-goto-char-2)
  ("M-g" . avy-goto-line))


(use-package swiper
  :config
  (global-set-key (kbd "C-s") 'swiper))


;; Line-oriented search tool
;; Recursively searchs your current directory
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


(use-package ivy-rich
  :config
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev))


(use-package ivy-prescient
  :after (prescient ivy counsel)
  :config
  (setq ivy-prescient-sort-commands
        '(:not counsel-grep
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
   ("C-x C-f" . counsel-find-file)
   ("M-p" . counsel-git)))


(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1)
  (setq company-selection-wrap-around t)
  (setq company-tooltip-align-annotations t)
  (setq company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
                            company-echo-metadata-frontend))
  (with-eval-after-load 'company
    (define-key company-active-map (kbd "C-j") nil) ; avoid conflict with emmet-mode
    (define-key company-active-map (kbd "C-n") #'company-select-next)
    (define-key company-active-map (kbd "C-p") #'company-select-previous)))


;;(define-key company-active-map [tab] 'company-complete-common-or-cycle)
;;(define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)


(use-package company-prescient
  :after (prescient company)
  :config
  (company-prescient-mode +1))


(use-package prescient
  :config
  (setq prescient-filter-method '(literal regexp initialism fuzzy))
  (prescient-persist-mode +1))


;; Dired Enhancements. Allow tabbing to display sub-directories
(use-package dired-subtree
  :ensure t
  :after dired
  :config
  (setq dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map ("<tab>" . dired-subtree-toggle)))


(use-package dired-single
  :preface
  (defun nux/dired-single-init ()
    (define-key dired-mode-map [return] #'dired-single-buffer)
    (define-key dired-mode-map [remap dired-mouse-find-file-other-window] #'dired-single-buffer-mouse)
    (define-key dired-mode-map [remap dired-up-directory] #'dired-single-up-directory))
  :config
  (if (boundp 'dired-mode-map)
      (nux/dired-single-init)
    (add-hook 'dired-load-hook #'nux/dired-single-init)))


;; Which key
;; Display commands choice when hitting C-x / C-c etc
 (use-package which-key
   :diminish which-key-mode
   :config
   (which-key-mode +1)
   (setq which-key-idle-delay 0.5
         which-key-idle-secondary-delay 0.5))


;; Snippets
(use-package yasnippet
  :diminish yas-minor-mode
  :config (yas-global-mode 1))
(define-key yas-minor-mode-map (kbd "<tab>") nil)
(define-key yas-minor-mode-map (kbd "TAB") nil)
(define-key yas-minor-mode-map (kbd "<backtab>") 'yas-expand)
(use-package yasnippet-snippets)
(use-package yasnippet-classic-snippets)


;; More doc
(use-package eldoc
  :ensure nil
  :config
  (setq eldoc-idle-delay 0.4))


;; Projectile quick file jump in your dir project
;; TODO : needs to read doc fore better integration with win10
;; (use-package projectile
;;   :config
;;   (setq projectile-sort-order 'recentf)
;;   (setq projectile-indexing-method 'hybrid)
;;   (setq projectile-completion-system 'ivy)
;;   (projectile-mode +1)
;;   (define-key projectile-mode-map (kbd "C-c p") #'projectile-command-map)
;;   ;;(define-key projectile-mode-map (kbd "M-p") #'projectile-find-file)
;;   (define-key projectile-mode-map (kbd "M-p") #'projectile-ripgrep))

;; Best git interface
(use-package magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status))


(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (diff-hl-mode . diff-hl-flydiff-mode))
  :config
  (setq diff-hl-flydiff-delay 0.05))


(fringe-mode '(4 . 4))


;; Org mode
;; Set environment
(use-package org
  :config
  (setq
   org-startup-indented t
   org-catch-invisible-edits t
   org-ellipsis " ... "
   org-directory "~/Dropbox/org"
   org-src-tab-acts-natively t
   org-src-preserve-indentation t
   org-src-fontify-natively t))


;; Import languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)
   (shell . t)
   (js . t)
   (org . t)
   (latex . t )))


;;Fancy headers
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))


;; Display tree view in left pane
(use-package org-sidebar)

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


;; Org agenda enhancements
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
(use-package ox
  :ensure nil
  :config
  (setq org-export-with-smart-quotes t))


(require 'ox-md)

;; Pdf Enhancements
(use-package pdf-tools)


;; Buffers
;; Ibuffer
(use-package ibuffer
  :config
  (setq ibuffer-expert t)
  :bind
  ("C-x C-b" . ibuffer))


;; Autorevert buffers and dired
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; Language && Syntax
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
(use-package markdown-mode
  :defer t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :bind (:map markdown-mode-map
              ("s-k" . 'markdown-insert-link)
              ("C-s-<down>" . 'markdown-narrow-to-subtree)
              ("C-s-<up>" . 'widen)
              ("s-O" . 'markdown-export-html-to-clipboard-full)
              ("M-s-O" . 'markdown-export-html-to-clipboard-no-1st-line))
  :init (setq markdown-command '("pandoc" "--no-highlight")))


;; Misc
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

;; Package management
(use-package paradox
  :custom
  (paradox-execute-asynchronously t)
  :config
  (paradox-enable))

;; Colors highlighter
(use-package rainbow-mode)


;; Try packages without hard install
(use-package try)


;; Diminish certain mode
(use-package diminish)


;; Menu for the mode line
(use-package minions
  :config
  (setq minions-mode-line-lighter "")
  (setq minions-mode-line-delimiters '("" . ""))
  (minions-mode +1))


;; Testing zone
(use-package simple
  :ensure nil
  :config
  (column-number-mode +1))


(use-package dabbrev
  :diminish abbrev-mode)
(global-set-key (kbd "M-/") 'hippie-expand)


;; Testing zone ends here

;; Custom functions
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


;; Split vertically and cursor follow new window
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


;; Custom Keybindings
(define-key global-map (kbd "<f5>") 'org-sidebar-tree)
(define-key global-map (kbd "C-c t") 'org-sidebar-tree)


(define-key global-map (kbd "C-c x") 'eval-buffer)
(define-key global-map (kbd "C-c f") 'eval-region)


;; Previous/Next buffer
(global-set-key (kbd "C->") 'next-buffer)
(global-set-key (kbd "C-<") 'previous-buffer)


;; Better than the terrible default
(global-set-key (kbd "<home>") 'beginning-of-buffer)
(global-set-key (kbd "<end>") 'end-of-buffer)


;; Quick buffer switching ma dude!
(global-set-key [mouse-4] 'switch-to-prev-buffer)
(global-set-key [mouse-5] 'switch-to-next-buffer)


;; Aliases
(defalias 'ff 'find-file)
(defalias 'd 'dired)


;; ;; Tree bindings from C-z
;; (define-prefix-command 'z-map)
;; (global-set-key (kbd "C-z") 'z-map)
;; (define-key z-map (kbd "e") 'elfeed)
;; (define-key z-map (kbd "v") 'split-and-follow-vertically)
;; (define-key z-map (kbd "h") 'split-and-follow-horizontally)


(load custom-file 'noerror)

(provide 'init)
;; EOF
