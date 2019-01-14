#!/usr/bin/bash
#
#Create a new file .tex corresponding to the skeleton chosen.

TYPE="short_report"
LANGUAGE="french"
MARGIN="3"


usage()
{
  echo "Usage: $0 [options] <type> <filename>\n   Type = ${TYPE}\n\nSee $0 --help for more informations."
}

#options: -h, --help
#print the help for the script in the standard output
help()
{
  cat <<EOF
Usage:
  $0 [options] <type> <filename>\n\n

Create a tex file with a skeleton corresponding to the type.

The parameter type can be: ${TYPE}.

Options:
  -l Listings package included with parameters + one example of usage.
  -m Math packages (amsmath, amssymb, mathtools) included.
EOF
}

packages_base()
{
  cat <<EOF
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[${LANGUAGE}]{babel}
\usepackage[top=${MARGIN}cm, bottom=${MARGIN}cm, left=${MARGIN}cm, right=${MARGIN}cm]{geometry}

%pictures
\usepackage{graphicx}

%links in the document
\usepackage{hyperref}
EOF
}

#option: -m
packages_math()
{
  cat <<EOF
%math
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{mathtools}
EOF
}

#option: -l
packages_listings()
{
  echo <<EOF
%listings (for code)
\usepackage{listings}
\lstset{numbers=left,
basicstyle=\small,
    frame=single,
    tabsize=4,
    showstringspaces=false,
    breaklines=true,
    aboveskip=0.5cm,
    %belowskip=0.5cm,
    captionpos=b,
    inputencoding=utf8,
    extendedchars=true,
    showstringspaces=false,
    keywordstyle=\bfseries\color{green!60!black},
    commentstyle=\itshape\color{black!20!red!60!magenta},
    identifierstyle=\ttfamily\color{blue},
    stringstyle=\color{orange},
    literate=%
{é}{{\'{e}}}1
{è}{{\`{e}}}1
{ê}{{\^{e}}}1
{ë}{{\"{e}}}1
{ï}{{\"{i}}}1
{û}{{\^{u}}}1
{ù}{{\`{u}}}1
{â}{{\^{a}}}1
{à}{{\`{a}}}1
{î}{{\^{i}}}1
{ô}{{\^{o}}}1
{ç}{{\c{c}}}1
{Ç}{{\c{C}}}1
{É}{{\'{E}}}1
{È}{{\`{E}}}1
{Ê}{{\^{E}}}1
{À}{{\`{A}}}1
{Â}{{\^{A}}}1
{Î}{{\^{I}}}1
}
EOF
}

example_listings()
{
  cat <<EOF
\begin{figure}[h]
\begin{lstlisting}[caption={Exemple.}, label={list:example}]
code
\end{lstlisting}
\end{figure}
EOF
}


main()
{
  #TODO
}
main "$@"
