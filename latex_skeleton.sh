#!/usr/bin/env bash
#
#Create a new file .tex corresponding to the skeleton chosen.

VERSION="0.4"
readonly VERSION

POSSIBLE_TYPES="homework short_report"
readonly POSSIBLE_TYPES

CODE="False"
LANGUAGE="french"
MARGIN="3"
MATH="False"
SPLIT="False"
PICTURE="False"
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
      Listings package included with parameters + one example of a listings figure (some code) in the document.

  -g MARGIN, --geometry=MARGIN
      Set the margins of the document at MARGIN cm.

  -h, --help
      Display help.

  -l LANGUAGE, --language=LANGUAGE
      LANGUAGE is selected in babel package.

  -m, --math
      Math packages (amsmath, amssymb, mathtools) included.

  -p, --picture
      There is a picture on the titlepage.

  -s, --split
      The document is modular : one file per section/chapter.

  -v, --version
      Display the version of these script.
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

title_homework()
{
  cat <<EOF

%-------title---------------------------------------

\noindent
EOF

if [[ "$PICTURE" = "True" ]]; then
  cat <<EOF
\begin{minipage}{0.20\textwidth}
\includegraphics[width=\textwidth]{logo}
\end{minipage}
\hfill
\begin{minipage}{0.71\textwidth}
EOF
fi
cat <<EOF
XXXXX -- Subject \hfill Mois. 2019\\\\

\begin{center}
{\Large \textbf{Homework  X -- Title }}

\vspace{0.5em}
 \large Xxxxx \bsc{Name} \quad Xxxxxx \bsc{Name}
\end{center}\vspace{0.3em}
$( [[ "$PICTURE" = "True" ]] && echo "\end{minipage}\\\\" )

\noindent
\rule{\linewidth}{0.5mm}

%---------------------------------------------------

\tableofcontents
EOF
}

title_short_report()
{
  cat <<EOF

%-------title---------------------------------------

\thispagestyle{empty}
~
\vfill
\begin{center}
$( [[ "$PICTURE" = "True" ]] && echo " \includegraphics[width=0.3\textwidth]{logo}\\\\[0.5cm]")

    {\LARGE Field, Year}\\\\[0.1cm]
    {\LARGE \bsc{School}}\\\\[1.5cm]
    {\Large \bfseries \bsc{--- Subject ---}}\\\\[0.5cm]
    \rule{\linewidth}{0.5mm}\\\\[0.4cm]
    {\Huge \bfseries Tittle\\\\[0.4cm]}
    \rule{\linewidth}{0.5mm}\\\\[1.5cm]
    {\Large Xxxxxx \bsc{Yyyyyyy} \quad Xxxxxx \bsc{Yyyyy}}\\\[0.5cm]
    {\large Supervised by Xxxxxx \bsc{Name}}\\\\
    \vfill
    {\large Semester ?}\\\\[0.5cm]
    {\large 20??}
    \vfill
    ~
\end{center}
\newpage

%---------------------------------------------------

\tableofcontents
\newpage
EOF
}

body_introduction()
{
  cat <<EOF
\phantomsection
\addcontentsline{toc}{$1}{Introduction}
\\$level*{Introduction}

EOF
}

body_CH01()
{
  cat <<EOF
\\$1{Titre}

$([[ "${CODE}" = "True" ]] && example_listings)

EOF
}

body_conclusion()
{
  cat <<EOF
\phantomsection
\addcontentsline{toc}{${level}}{Conclusion}
\section*{${level}}

EOF
}

parseopts()
{
  optspec=":cg:hl:mpsv-:"
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
        picture) PICTURE="True";;
        split) SPLIT="True";;
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
      p) PICTURE="True";;
      s) SPLIT="True";;
      v) version;;
      :) err "-${optchar} needs one arguments, this option has been ignored";;
    esac
  done

  readonly CODE LANGUAGE MATH MARGIN PICTURE SPLIT
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
  type_check ${POSSIBLE_TYPES}

  #check if there already is a file with the name FILE
  # and create the file
  [[ -e "${FILE}" ]] && ?overwrite
}


skeleton()
{
  local class
  class="${1}"

  echo "\documentclass[a4paper,10pt]{${class}}"

  #packages
  packages_base
  [[ "${MATH}" = "True" ]] && packages_math
  [[ "${CODE}" = "True" ]] && packages_listings

  #document
  echo ""
  echo "\begin{document}"
  echo ""

  title_${TYPE}

  #body
  local level
  case "${class}" in
    article )
      level="section";;
    * )
      level="chapter";;
  esac

  if [[ "${SPLIT}" = "True" ]]; then
    #ligne compil
    local inclusion
    [[ "${level}" = "section" ]] && inclusion="input" || inclusion="include"
    for f in 'introduction' 'CH01' 'conclusion'; do
      mkdir -p $f
      echo "% !TEX root = $(pwd)/${FILE}" > $f/$f.tex
      body_$f "${level}" >> $f/$f.tex
      echo "${inclusion}{./$f/$f}"
    done
  else
    body_introduction "${level}"
    body_section "${level}"
  fi

  echo "\end{document}"
}

main()
{
  #gestion + verification of the options and arguments
  parseopts "$@"
  parseargs "$@"

  case "${TYPE}" in
    homework | short_report)
      skeleton article > ${FILE} ;;
  esac

  #copy logo
  exit 0
}
main "$@"
