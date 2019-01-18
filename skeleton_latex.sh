#!/bin/bash
#
#Create a new file .tex corresponding to the skeleton chosen.

VERSION="0.2"
readonly VERSION

POSSIBLE_TYPES="dm"
readonly POSSIBLE_TYPES

CODE="False"
LANGUAGE="french"
MARGIN="3"
MATH="False"
TYPE=""
FILE=""

err()
{
  echo "Error: $1." >& 1
}


usage()
{
  cat << EOF
Usage: $0 [options] TYPE FILENAME
    TYPE = $POSSIBLE_TYPES

See $0 --help for more informations.
EOF
}

#options: -v, --version
#desplay the version of the script in the standard output
version()
{
  echo "Version: $VERSION"
}

#options: -h, --help
#desplay the help for the script in the standard output
help()
{
  cat <<EOF
Usage:
  $0 [options] TYPE FILENAME

Create a tex file with a skeleton corresponding to the type in the current directory.

The parameter type can be: $POSSIBLE_TYPES.

Options:
  -c, --code
      Listings package included with parameters + one example of usage to add code in the document.

  -g MARGIN, --geometry=MARGIN
      Set the margins of the document at MARGIN cm.

  -h, --help
      Display help.

  -l LANGUAGE, --language=LANGUAGE
      LANGUAGE is selected in babel package.

  -m, --math
      Math packages (amsmath, amssymb, mathtools) included.

  -v, --version
      Display the version of these script.
EOF
}

parseopts()
{
  optspec=":cg:hl:m-:v"
  while getopts "$optspec" optchar; do
      case "${optchar}" in
          -)
              case "${OPTARG}" in
                  code) CODE="True";;
                  geometry) err "--geometry needs one arguments, this option has been ignored";;
                  geometry=*)
                      val=${OPTARG#*=}
                      if [[ ${val} =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
                        MARGIN=${val}
                      else
                        err "Argument of --geometry has to be numbers"
                        exit 65
                      fi ;;
                  language|language=) err "--language needs one arguments, this option has been ignored";;
                  language=*) LANGUAGE=${OPTARG#*=} ;;
                  help) help; exit 0;;
                  math) MATH="True";;
                  version) version;;
              esac;;
          c) CODE="True";;
          g) if [[ ${OPTARG} =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
               MARGIN=${OPTARG}
             else
               err "Argument of -${optchar} has to be numbers"
               exit 65
             fi ;;
          h) help; exit 0 ;;
          l) LANGUAGE="${OPTARG}";;
          m) MATH="True";;
          v) version;;
          :) err "-${optchar} needs one arguments, this option has been ignored";;
      esac
  done

  readonly CODE LANGUAGE MATH MARGIN
}

type_check()
{
  if [ $# -eq 0 ]; then
    err "type selected is not corresponding"
    usage
    exit 65
  fi

  if [[ "$1" != ${TYPE} ]]; then
    shift
    type_check "${@}"
  fi
}


?overwrite()
{
  local answer
  echo "${FILE} exists already, do you want to overwrite it ? (yes/no)"
  read answer

  case "${answer}" in
    yes | y | Yes | Y )
      rm -f ${FILE};;
    no | n | No | N )
      exit 0 ;;
    *)
      ?overwrite
  esac
}

parseargs()
{
  #shift
  shift "$(($OPTIND - 1))"

  #check number of arguments
  if [[ $# -lt 2 ]] ; then
    err "2 arguments needed"
    usage
    exit 2
  fi

  #assignation of arguments
  TYPE="$1"
  FILE=$"$2"

  #add the extension .tex if needed
  [[ "${FILE}" =~ ".+\.tex$" ]] || FILE="${FILE}.tex"

  readonly TYPE FILE

  #check if the type selected is correct
  type_check "${POSSIBLE_TYPES}"

  #check if there already is a file with the name FILE
  # and create the file
  [[ -e "${FILE}" ]] && ?overwrite
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

#option: -m, --math
packages_math()
{
  cat <<EOF
%math
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{mathtools}
EOF
}

#option: -c, --code
packages_listings()
{
  cat <<EOF
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

title_dm()
{
  cat <<EOF

%-------title---------------------------------------

\noindent
\begin{minipage}{0.20\textwidth}
\includegraphics[width=\textwidth]{logo}
\end{minipage}
\hfill
\begin{minipage}{0.71\textwidth}
XXXXX -- Matière \hfill Mois. 2019\\

\begin{center}
{\Large \textbf{Devoir Maison  X -- Titre }}

\vspace{0.5em}
 \large Prénom \bsc{NOM} \quad Prénom \bsc{Nom}
\end{center}\vspace{0.3em}
\end{minipage}\\

\noindent
\rule{\linewidth}{0.5mm}

%---------------------------------------------------

EOF
}

skeleton()
{
  local class
  class="${1}"

  echo "\documentclass[a4paper,10pt]{${class}}"
  packages_base
  [[ "${MATH}" = "True" ]] && packages_math
  [[ "${CODE}" = "True" ]] && packages_listings; echo "code" || echo "no code"

  echo ""
  echo "\begin{document}"
  title_${TYPE}

  #body
  local level
  case "${class}" in
    article )
      level="section";;
    * )
      level="chapter";;
  esac

  cat <<EOF
\tableofcontents
%\newpage

\phantomsection
\addcontentsline{toc}{${level}}{Introduction}
\\$level*{Introduction}

\\$level{Titre}

$([[ "${CODE}" = "True" ]] && example_listings)

\phantomsection
\addcontentsline{toc}{${level}}{Conclusion}
\section*{${level}}

\end{document}
EOF
}

main()
{
  #gestion + verification of the options and arguments
  parseopts "$@"
  parseargs "$@"

  case "${TYPE}" in
    dm )
      skeleton article > ${FILE} ;;
  esac
  exit 0
}
main "$@"
