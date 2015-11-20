(TeX-add-style-hook
 "handout"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("tufte-handout" "a4paper")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("roboto" "scaled=0.95") ("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem") ("zi4" "scaled=0.9") ("xcolor" "usenames" "dvipsnames") ("microtype" "protrusion=true" "expansion=alltext" "tracking=true" "kerning=true") ("babel" "frenchle" "frenchb") ("eulervm" "euler-digits")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "tufte-handout"
    "tufte-handout10"
    "roboto"
    "mathpazo"
    "eulervm"
    "xcolor"
    "inputenc"
    "fontenc"
    "graphicx"
    "longtable"
    "float"
    "hyperref"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "textcomp"
    "marvosym"
    "wasysym"
    "amssymb"
    "zi4"
    "microtype"
    "siunitx"
    "babel")
   (TeX-add-symbols
    "baselinestretch")
   (LaTeX-add-labels
    "sec:orgheadline5"
    "sec:orgheadline1"
    "sec:orgheadline2"
    "sec:orgheadline3"
    "sec:orgheadline4"
    "sec:orgheadline8"
    "sec:orgheadline6"
    "figure1"
    "sec:orgheadline7"
    "figure2"
    "figure3"
    "figure7"
    "sec:orgheadline11"
    "sec:orgheadline9"
    "sec:orgheadline10"
    "figvincent")))

