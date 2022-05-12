;;; init.el -*- lexical-binding: t; -*-
;;
;; Author:  Henrik Lissner <contact@henrik.io>
;; URL:     https://github.com/hlissner/doom-emacs
;;
;;   =================     ===============     ===============   ========  ========
;;   \\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //
;;   ||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||
;;   || . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||
;;   ||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||
;;   || . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||
;;   ||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||
;;   || . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||
;;   ||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||
;;   ||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||
;;   ||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||
;;   ||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||
;;   ||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||
;;   ||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||
;;   ||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||
;;   ||.=='    _-'                                                     `' |  /==.||
;;   =='    _-'                                                            \/   `==
;;   \   _-'                                                                `-_   /
;;    `''                                                                      ``'
;;
;; These demons are not part of GNU Emacs.
;;
;;; License: MIT

;; In the strange case that early-init.el wasn't loaded (e.g. you're using
;; Chemacs 1? Or you're loading this file directly?), we do it explicitly:
(unless (boundp 'doom-version)
  (load (concat (file-name-directory load-file-name) "early-init")
        nil t))

;; Ensure Doom's core libraries are properly initialized, autoloads file is
;; loaded, and hooks set up for an interactive session.
(doom-initialize)

;; Now we load all enabled modules in the order dictated by your `doom!' block
;; in $DOOMDIR/init.el. `doom-initialize-modules' loads them (and hooks) in the
;; given order:
;;
;;   $DOOMDIR/init.el
;;   {$DOOMDIR,~/.emacs.d}/modules/*/*/init.el
;;   `doom-before-init-modules-hook'
;;   {$DOOMDIR,~/.emacs.d}/modules/*/*/config.el
;;   `doom-init-modules-hook'
;;   $DOOMDIR/config.el
;;   `doom-after-init-modules-hook'
;;   `after-init-hook'
;;   `emacs-startup-hook'
;;   `doom-init-ui-hook'
;;   `window-setup-hook'
;;
;; And then we're good to go!
(doom-initialize-modules)

;; remove existing keymap and make sure keymap works on macos
(setq global-map (make-keymap))
(setq mac-command-modifier 'meta) ;; map the command key to the meta key
(global-set-key (kbd "M-v") 'scroll-down-command) ;; command-v (mac) should page up
(global-set-key (kbd "A-v") 'scroll-down-command) ;; A is the right Alt (mac keyboards)
(global-set-key (kbd "C-x C-z") 'toggle-frame-fullscreen) ;; something like vscode

;; neotree (tree file browser)
(global-set-key (kbd "C-c C-SPC") 'neotree-toggle) ;; something like vscode

;; doxygen / documentation generation
;; (require 'docstr)
(setq smartparens-global-mode 0) ;; need to disable smartparens to enable docstr
;; Enable `docstr' inside these major modes.
(add-hook 'c++-mode-hook (lambda () (docstr-mode 1)))
(add-hook 'c-mode-hook (lambda () (docstr-mode 1)))
(add-hook 'swift-mode-hook (lambda () (docstr-mode 1)))
(add-hook 'typescript-mode-hook (lambda () (docstr-mode 1)))
(setq global-docstr-mode 1)
(setq docstr-key-support t)

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; Custom functions/hooks for persisting/loading frame geometry upon save/load
(defun save-frameg ()
"Gets the current frame's geometry and saves to ~/.emacs.frameg."
(let ((frameg-font (frame-parameter (selected-frame) 'font))
(frameg-left (frame-parameter (selected-frame) 'left))
(frameg-top (frame-parameter (selected-frame) 'top))
(frameg-width (frame-parameter (selected-frame) 'width))
(frameg-height (frame-parameter (selected-frame) 'height))
(frameg-file (expand-file-name "~/.emacs.frameg")))
(with-temp-buffer
;; Turn off backup for this file
(make-local-variable 'make-backup-files)
(setq make-backup-files nil)
(insert
";;; This file stores the previous emacs frame's geometry.\n"
";;; Last generated " (current-time-string) ".\n"
"(setq initial-frame-alist\n"
;; " '((font . \"" frameg-font "\")\n"
" '("
(format " (top . %d)\n" (max frameg-top 0))
(format " (left . %d)\n" (max frameg-left 0))
(format " (width . %d)\n" (max frameg-width 0))
(format " (height . %d)))\n" (max frameg-height 0)))
(when (file-writable-p frameg-file)
(write-file frameg-file)))))

(defun load-frameg ()
"Loads ~/.emacs.frameg which should load the previous frame's geometry."
(let ((frameg-file (expand-file-name "~/.emacs.frameg")))
(when (file-readable-p frameg-file)
(load-file frameg-file))))

;; Special work to do ONLY when there is a window system being used
(if window-system
(progn
(add-hook 'after-init-hook 'load-frameg)
(add-hook 'kill-emacs-hook 'save-frameg)))
