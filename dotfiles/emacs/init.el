;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
	   '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

;; Evil
(require 'evil)
(setq evil-want-C-u-scroll t)

;; Enable pdf-tools on-demand (not on startup)
(pdf-loader-install)
(add-hook 'pdf-tools-enabled-hook 'pdf-view-themed-minor-mode) ;; Match current Emacs theme

