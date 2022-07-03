;;; eic.el --- English In Context

;; Version: 0.0.1

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

;; Learn English In Context helps you capture unfamiliar words you
;; encounter while reading English and store their context for you.

;;; Code:

(require 'youdao-dictionary)

(define-namespace eic/

(defun get-context ()
  "Get a sentence as context."
  (interactive)
  (let* ((word-context-start (backward-sentence))
		 (word-context-end (forward-sentence)))
	(buffer-substring-no-properties
	 word-context-start word-context-end)))

(defun capture-word (&optional word)
  "Capture word WORD and save it."
  (interactive)
  (let* ((word-yd-info (youdao-dictionary--request (if (null word)
													   (thing-at-point 'word)
													 word)))
		 (word-context (get-context)))

	;; DEBUG
	(message "DEBUG: %s\n%s\n"
			 word-yd-info
			 word-context)

	))
)

(provide 'eic)
;;; eic.el ends here
