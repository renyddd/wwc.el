;;; wwc.el --- English In Context

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

(require 'cl-lib)
(require 'json)
(require 'youdao-dictionary)

(defgroup wwc/ nil
  "WWC group."
  :group 'wwc/
  :prefix 'wwc/)

(defvar wwc/buffer-name "*wwc*"
  "The name of wwc buffer.")

(define-namespace wwc/

(defun check-path ()
  "Check file with saved words."
  (let ((words-file (expand-file-name ".wwc-words.json" "~")
								  "Default wwc-words file."))
	(when (not (file-exists-p words-file))
	  (f-write "{}" 'utf-8 words-file))
	words-file))

(defun get-context ()
  "Get a sentence as context."
  (interactive)
  ;; TODO split '\n'.
  (let* ((word-context-start (backward-sentence))
		 (word-context-end (forward-sentence)))
	;; TODO more context body with date, times
	(buffer-substring-no-properties
	 word-context-start word-context-end)))

(defun capture-word (&optional word)
  "Capture word WORD and save it."
  (interactive)
  ;; TODO dispatch to different dictionary
  (let* ((words-cache-file (wwc/check-path))
		 (words-cache-list (json-read-file words-cache-file))
		 (all-words-cache (make-hash-table))

		 (word-yd-info (youdao-dictionary--request (if (null word)
													   (thing-at-point 'word)
													 word)))
		 (word-yd-eng (downcase (cdr (assoc 'query word-yd-info))))
		 (word-yd-basic (cdr (assoc 'basic word-yd-info)))
		 (word-yd-phonetic (cdr (assoc 'us-phonetic word-yd-basic)))
		 (word-yd-explains (cdr (assoc 'explains word-yd-basic)))
		 (word-context (get-context)))

	(cl-block nil
	  (when (null word-yd-explains)
		(message "%s is not a word" word-yd-eng)
		(cl-return t))

	  (message "%s: %s\n" word-yd-eng word-yd-explains)

	  (mapc
	   ;; convert exist words list to hashtable
	   (lambda (item)
		 (puthash (car item) (cdr item) all-words-cache))
	   words-cache-list)

	  ;; TODO check exists
	  (puthash word-yd-eng (list (cons "explains" word-yd-explains)
								 (cons "phonetic" word-yd-phonetic)
								 (cons "capture-context" word-context))
			   all-words-cache)
 
	  (let ((tmp-json-string (json-encode all-words-cache)))
		(progn
		  ;;		  (message "DEBUG tmp-json-string: %s" tmp-json-string)
		  (f-write-text tmp-json-string 'utf-8 words-cache-file)))
	  )))
)

(provide 'wwc)
;;; wwc.el ends here
