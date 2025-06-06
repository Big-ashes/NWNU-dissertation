%
% Copyright (C) 2025 by Big-ashes <https://github.com/Big-ashes/NWNU-dissertation>
%
% This file may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
%    https://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2008 or later.
%
% 本文件由 Big-ashes 于 2025 年在 USTC TeX 用户组模板基础上独立开发。

\NeedsTeXFormat{LaTeX2e}[2017/04/15]
\newcommand\bigashversion{1.0.0}
\ProvidesClass{bigash}[2025/2/12 v\bigashversion\space NWNU thesis template]

% 报错和警告
\newcommand\ash@error[1]{%
  \ClassError{bigash}{#1}{}%
}
\newcommand\ash@warning[1]{%
  \ClassWarning{bigash}{#1}%
}

\newcommand\ash@deprecated[3]{%
  \ash@warning{The #1 is deprecated since #2. Use #3 instead.}%
}

% 检查 \LaTeXe{} kernel 版本
\@ifl@t@r\fmtversion{2017/04/15}{}{
  \ash@error{%
    TeX Live 2017 or later version is required to compile this document%
  }
}

% 检查编译引擎，要求使用 XeLaTeX 或 LuaLaTeX。
\RequirePackage{iftex}
\ifXeTeX\else
  \ifLuaTeX\else
    \ash@error{XeLaTeX or LuaLaTeX is required to compile this document}
  \fi
\fi


% \subsection{处理选项}

\RequirePackage{kvdefinekeys}
\RequirePackage{kvsetkeys}
\RequirePackage{kvoptions}

% 提供一个 \cs{ashsetup} 命令支持 \emph{key-value} 的方式来设置。
\let\ash@setup@hook\@empty
\newcommand\ashsetup[1]{%
  \let\ash@setup@hook\@empty
  \kvsetkeys{ash}{#1}%
  \ash@setup@hook
}

% 同时用 \emph{key-value} 的方式来定义这些接口：
% \begin{latex}
%   \ash@define@key{
%     <key> = {
%       name = <name>,
%       choices = {
%         <choice1>,
%         <choice2>,
%       },
%       default = <default>,
%       code = <code>,
%     },
%   }
% \end{latex}

% 其中 |choices| 设置允许使用的值，默认为第一个（或者 \meta{default}）；
% \meta{code} 是相应的内容被设置时执行的代码。

\newcommand\ash@define@key[1]{%
  \kvsetkeys{ash@key}{#1}%
}
\kv@set@family@handler{ash@key}{%
%
% \cs{ashsetup} 会将 \meta{value} 存到 \cs{ash@\meta{key}}，
% 但是宏的名字包含 “-” 这样的特殊字符时不方便直接调用，比如 |key = math-style|，
% 这时可以用 |name| 设置 \meta{key} 的别称，比如 |key = math@style|，
% 这样就可以通过 \cs{ash@math@style} 来引用。
% |default| 是定义该 \meta{key} 时默认的值，缺省为空。
%
  \@namedef{ash@#1@@name}{#1}%
  \def\ash@@default{}%
  \def\ash@@choices{}%
  \kv@define@key{ash@value}{name}{%
    \@namedef{ash@#1@@name}{##1}%
  }%
  %
  % 由于在定义接口时，\cs{ash@\meta{key}@@code} 不一定有定义，
  % 而且在文档类/宏包中还有可能对该 |key| 的 |code| 进行添加。
  % 所以 \cs{ash@\meta{key}@@code} 会检查如果在定义文档类/宏包时则推迟执行，否则立即执行。
  %
  \@namedef{ash@#1@@check}{}%
  \@namedef{ash@#1@@code}{}%
  %
  % 保存下 |choices = {}| 定义的内容，在定义 \cs{ash@\meta{name}} 后再执行。
  %
  \kv@define@key{ash@value}{choices}{%
    \def\ash@@choices{##1}%
    \@namedef{ash@#1@@reset}{}%
    %
    % \cs{ash@\meta{key}@check} 检查 |value| 是否有效，
    % 并设置 \cs{ifash@\meta{name}@\meta{value}}。
    %
    \@namedef{ash@#1@@check}{%
      \@ifundefined{%
        ifash@\@nameuse{ash@#1@@name}@\@nameuse{ash@\@nameuse{ash@#1@@name}}%
      }{%
        \ash@error{Invalid value "#1 = \@nameuse{ash@\@nameuse{ash@#1@@name}}"}%
      }%
      \@nameuse{ash@#1@@reset}%
      \@nameuse{ash@\@nameuse{ash@#1@@name}@\@nameuse{ash@\@nameuse{ash@#1@@name}}true}%
    }%
  }%
  \kv@define@key{ash@value}{default}{%
    \def\ash@@default{##1}%
  }%
  \kvsetkeys{ash@value}{#2}%
  \@namedef{ash@\@nameuse{ash@#1@@name}}{}%
  %
  % 第一个 \meta{choice} 设为 \meta{default}，
  % 并且对每个 \meta{choice} 定义 \cs{ifash@\meta{name}@\meta{choice}}。
  %
  \kv@set@family@handler{ash@choice}{%
    \ifx\ash@@default\@empty
      \def\ash@@default{##1}%
    \fi
    \expandafter\newif\csname ifash@\@nameuse{ash@#1@@name}@##1\endcsname
    \expandafter\g@addto@macro\csname ash@#1@@reset\endcsname{%
      \@nameuse{ash@\@nameuse{ash@#1@@name}@##1false}%
    }%
  }%
  \kvsetkeys@expandafter{ash@choice}{\ash@@choices}%
  %
  % 将 \meta{default} 赋值到 \cs{ash@\meta{name}}，如果非空则执行相应的代码。
  %
  \expandafter\let\csname ash@\@nameuse{ash@#1@@name}\endcsname\ash@@default
  \expandafter\ifx\csname ash@\@nameuse{ash@#1@@name}\endcsname\@empty\else
    \@nameuse{ash@#1@@check}%
  \fi
  %
  % 定义 \cs{ashsetup} 接口。
  %
  \kv@define@key{ash}{#1}{%
    \@namedef{ash@\@nameuse{ash@#1@@name}}{##1}%
    \@nameuse{ash@#1@@check}%
    \@nameuse{ash@#1@@code}%
  }%
}

% 定义接口向 |key| 添加 |code|：

\newcommand\ash@option@hook[2]{%
  \expandafter\g@addto@macro\csname ash@#1@@code\endcsname{#2}%
}

\ash@define@key{
  degree = {
    choices = {
      doctor,
      master,
      bachelor,
    },
    default = master,
  },
  degree-type = {
    name = degree@type,
    choices = {
      academic,
      professional,
    },
    default = academic,
  },
  main-language = {
    name = main@language,
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  language = {
    choices = {
      chinese,
      english,
    },
    default = chinese,
  },
  system = {
    choices = {
      auto,
      mac,
      unix,
      windows,
    },
    default = auto,
  },
  fontset = {
    choices = {
      auto,
      windows,
      mac,
      ubuntu,
      fandol,
      none,
    },
    default = auto,
  },
  font = {
    choices = {
      auto,
      times,
      termes,
      stix,
      xits,
      libertinus,
      newcm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  cjk-font = {
    name = cjk@font,
    choices = {
      auto,
      windows,
      mac,
      noto,
      fandol,
      none,
    },
    default = auto,
  },
  math-font = {
    name = math@font,
    choices = {
      auto,
      stix,
      xits,
      libertinus,
      newcm,
      cm,
      lm,
      newtx,
      none,
    },
    default = auto,
  },
  math-style = {
    name = math@style,
    choices = {
      GB,
      ISO,
      TeX,
    },
  },
  uppercase-greek = {
    name = uppercase@greek,
    choices = {
      italic,
      upright,
    },
  },
  less-than-or-equal = {
    name = leq,
    choices = {
      slanted,
      horizontal,
    },
  },
  integral = {
    choices = {
      upright,
      slanted,
    },
  },
  integral-limits = {
    name = integral@limits,
    choices = {
      true,
      false,
    },
  },
  partial = {
    choices = {
      upright,
      italic,
    },
  },
  math-ellipsis = {
    name = math@ellipsis,
    choices = {
      centered,
      lower,
      AMS,
    },
  },
  real-part = {
    name = real@part,
    choices = {
      roman,
      fraktur,
    },
  },
  cite-style = {
    name = cite@style,
    choices = {
      super,
      inline,
      authoryear,
    },
  },
  output = {
    choices = {
      print,
      electronic,
    },
    default = print,
  },
  section-style = {
    name = section@style,
    choices = {
      chinese,
      arabic,
    },
    default = chinese,
  },
  badge-color = {
    name = badge@color,
    choices = {
      blue,
      black,
    },
    default = blue,
  },
  reviewer = {
    choices = {
      true,
      false,
    },
    default = false,
  },
}

% 将 \ash@cite@style 置空方便后续进行判断。
\def\ash@cite@style{}

\newif\ifash@degree@graduate
\newcommand\ash@set@graduate{%
  \ifash@degree@bachelor
    \ash@degree@graduatefalse
  \else
    \ash@degree@graduatetrue
  \fi
}
\ash@set@graduate
\ash@option@hook{degree}{%
  \ash@set@graduate
}

% 使用 \pkg{kvoptions} 提供的 key-value 接口，
\SetupKeyvalOptions{
  family  = ash,
  prefix  = ash@,
  setkeys = \kvsetkeys,
}

% 设置默认 \option{openany}。
\DeclareBoolOption[false]{openright}
\DeclareComplementaryOption{openany}{openright}

% 兼容旧版本的文档类选项。
% Reserved for compatibility until 2020-07-01.
\DeclareVoidOption{doctor}{\ashsetup{degree=doctor}}
\DeclareVoidOption{master}{\ashsetup{degree=master}}
\DeclareVoidOption{bachelor}{\ashsetup{degree=bachelor}}
\DeclareVoidOption{chinese}{\ashsetup{language=chinese}}
\DeclareVoidOption{english}{\ashsetup{language=english}}
\DeclareVoidOption{academic}{\ashsetup{degree-type=academic}}
\DeclareVoidOption{professional}{\ashsetup{degree-type=professional}}
\DeclareVoidOption{print}{\ashsetup{output=print}}
\DeclareVoidOption{pdf}{\ashsetup{output=electronic}}
\newif\ifash@legacy@cite@style
\DeclareVoidOption{super}{\ashsetup{cite-style=super}\ash@legacy@cite@styletrue}
\DeclareVoidOption{numbers}{\ashsetup{cite-style=inline}\ash@legacy@cite@styletrue}
\DeclareVoidOption{authoryear}{\ashsetup{cite-style=authoryear}\ash@legacy@cite@styletrue}
\DeclareVoidOption{arabic}{\ashsetup{section-style=arabic}}
\DeclareVoidOption{colorlogo}{\ashsetup{badge-color=blue}}
\DeclareVoidOption{bwlogo}{\ashsetup{badge-color=black}}

% 载入 \cls{ctexbook}。
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}}
\ProcessKeyvalOptions*


% \subsection{加载文档类和宏包}

\ifash@openright
  \PassOptionsToClass{openright}{book}
\else
  \PassOptionsToClass{openany}{book}
\fi

\ifash@output@electronic
  \PassOptionsToClass{oneside}{book}
\fi
\PassOptionsToPackage{no-math}{fontspec}

% 载入 \cls{ctexbook} 文档类，注意要求为 2.4.9 或更高的版本。
\LoadClass[UTF8,a4paper,scheme=plain,zihao=-4,fontset=none]{ctexbook}[2017/04/01]

% 建议在模板开始处载入全部宏包，不要轻易改变加载顺序。
% \pkg{hyperref} 一般在最后加载。
\RequirePackage{etoolbox}
\RequirePackage{amsmath}
% \RequirePackage{fontspec}[2017/03/31]
\RequirePackage{fontspec}
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage{titletoc}
\RequirePackage{caption}
\RequirePackage[perpage]{footmisc}
\RequirePackage{url}
\RequirePackage{notoccite}
\RequirePackage{multirow}

% 如果用户在导言区未调用 \pkg{biblatex}，则自动调用 \pkg{natbib}。
\AtEndPreamble{
  \@ifpackageloaded{biblatex}{}{
    \RequirePackage{natbib}
  }
}

% 对冲突的宏包报错。
\RequirePackage{filehook}
\newcommand\ash@package@conflict[2]{
  \AtEndOfPackageFile*{#1}{%
    \AtBeginOfPackageFile*{#2}{%
      \ash@error{The "#2" package is incompatible with "#1"}%
    }%
  }%
}

\ash@package@conflict{biblatex}{bibunits}
\ash@package@conflict{biblatex}{chapterbib}
\ash@package@conflict{biblatex}{cite}
\ash@package@conflict{biblatex}{multibib}
\ash@package@conflict{biblatex}{natbib}

\ash@package@conflict{bibunits}{biblatex}
\ash@package@conflict{bibunits}{chapterbib}
\ash@package@conflict{bibunits}{multibib}

\ash@package@conflict{unicode-math}{amscd}
\ash@package@conflict{unicode-math}{amsfonts}
\ash@package@conflict{unicode-math}{amssymb}
\ash@package@conflict{unicode-math}{bbm}
\ash@package@conflict{unicode-math}{bm}
\ash@package@conflict{unicode-math}{eucal}
\ash@package@conflict{unicode-math}{eufrak}
\ash@package@conflict{unicode-math}{mathrsfs}
\ash@package@conflict{unicode-math}{newtxmath}
\ash@package@conflict{unicode-math}{upgreek}

\ash@package@conflict{natbib}{biblatex}
\ash@package@conflict{natbib}{cite}

\ash@package@conflict{newtxmath}{amsfonts}
\ash@package@conflict{newtxmath}{amssymb}
\ash@package@conflict{newtxmath}{unicode-math}
\ash@package@conflict{newtxmath}{upgreek}


% \pkg{amsthm} 需要在 \pkg{newtx} 前载入，参考 \pkg{newtx} 的文档。
\AtBeginOfPackageFile*{amsthm}{
  \@ifpackageloaded{newtxmath}{
    \ash@error{The "amsthm" package should be loaded before setting "newtxmath"}
  }{}
}%



% \subsection{处理语言}

% 定义 \cs{ash@main@language}，当在导言区修改 \option{language} 时，
% 保存为论文的主要语言；
% \cs{ash@reset@main@language} 则用于正文中恢复为主要语言。
%    \begin{macrocode}
\ashsetup{main-language=\ash@language}%
\let\ash@main@language\ash@language

\ash@option@hook{language}{%
  \ifx\@begindocumenthook\@undefined\else
    \ashsetup{main-language=\ash@language}%
    \let\ash@main@language\ash@language
  \fi
}
\newcommand\ash@reset@main@language{%
  \ashsetup{language = \ash@main@language}%
  \let\ash@language\ash@main@language
}

% 带圈数字和星号使用中文字体。
\ifLuaTeX
  % ctex 将带圈数字 U+2460–U+24FF 归入字符范围 3（ALchar），这里改回范围 6（JAchar）
  \ltjdefcharrange{3}{%
    "2000-"243F, "2500-"27BF, "2900-"29FF, "2B00-"2BFF}
  \ltjdefcharrange{6}{%
    "2460-"24FF, "2E80-"2EFF, "3000-"30FF, "3190-"319F, "31F0-"4DBF,
    "4E00-"9FFF, "F900-"FAFF, "FE10-"FE1F, "FE30-"FE6F, "FF00-"FFEF,
    "1B000-"1B16F, "1F100-"1F2FF, "20000-"3FFFF, "E0100-"E01EF}
\else
  \ifXeTeX
    \xeCJKDeclareCharClass{CJK}{"2460 -> "2473}
    \xeCJKDeclareCharClass{CJK}{"2605}
  \fi
\fi

% 由于 Unicode 的一些标点符号是中西文混用的：
% U+00B7、U+2013、U+2014、U+2018、U+2019、
% U+201C、U+201D、U+2025、U+2026、U+2E3A，
% 所以要根据语言设置正确的字体。
% https://github.com/CTeX-org/ctex-kit/issues/389
\newcommand\ash@set@punctuations{%
  \ifash@language@chinese
    \ifLuaTeX
      \ltjsetparameter{jacharrange={+9}}
    \else
      \ifXeTeX
        \xeCJKDeclareCharClass{FullLeft}{"2018, "201C}%
        \xeCJKDeclareCharClass{FullRight}{
          "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
        }%
      \fi
    \fi
  \else
    \ifLuaTeX
      \ltjsetparameter{jacharrange={-9}}
    \else
      \ifXeTeX
        \xeCJKDeclareCharClass{HalfLeft}{"2018, "201C}%
        \xeCJKDeclareCharClass{HalfRight}{
          "00B7, "2019, "201D, "2013, "2014, "2025, "2026, "2E3A,
        }%
      \fi
    \fi
  \fi
}
\ash@set@punctuations
\ash@option@hook{language}{\ash@set@punctuations}

% 根据语言设置各章节的名称，只有在导言区设置 \option{language} 时会修改，
% 而在正文局部切换语言时则不变。

% 由于《撰写手册》中的“speciality”一词使用的是英式拼法，
% 所以“acknowledgements”也保持一致。
\newcommand\ash@set@chapter@names{%
  \ifash@main@language@chinese
    \def\contentsname{目\hspace{1em} 录}%
    \def\listfigurename{图片索引}%
    \def\listtablename{表格索引}%
    \def\ash@list@figure@table@name{图片和表格索引}%
    \ctexset{
      chapter/name   = {第,章},
    }%
    \def\bibname{参考文献}%
    \def\appendixname{附录}%
    \def\ash@conclusion@name{结\hspace{1em} 论}%
    \def\ash@acknowledgements@name{致\hspace{1em} 谢}%
    \def\ash@achievements@name{个人简历、在学期间发表的学术论文及研究成果}%
    \newcommand\ash@notation@name{符号说明}%
  \else
    \def\contentsname{Contents}%
    \def\listfigurename{List of Figures}%
    \def\listtablename{List of Tables}%
    \def\ash@list@figure@table@name{List of Figures and Tables}%
    \ctexset{
      chapter/name   = {\chaptername\space},
    }%
    \def\bibname{Bibliography}%
    \def\appendixname{Appendix}%
    \def\ash@conclusion@name{Conclusion}%
    \def\ash@acknowledgements@name{Acknowledgements}%
    \def\ash@achievements@name{Research Achievements}%
    \def\ash@notation@name{Notation}%
  \fi
}
\ash@set@chapter@names
\ash@option@hook{main-language}{\ash@set@chapter@names}

% 这部分名称在正文中局部地修改语言时会发生变化。
\newcommand\ash@set@names{%
  \ifash@language@chinese
    \def\figurename{图}%
    \def\tablename{表}%
  \else
    \def\figurename{Figure}%
    \def\tablename{Table}%
  \fi
}
\ash@set@names
\ash@option@hook{language}{\ash@set@names}


% \subsection{字体}

% 字号

% 正文字号12bp，研究生行距20bp，本科生行距22bp；
% 其他命令的行距按照相同的的比例设置，如表~\ref{tab:fontsize}。
% \begin{table}[htb]
%   \centering
%   \caption{标准字体命令与字号、行距的对应}
%   \label{tab:fontsize}
%   \begin{tabular}{lllll}
%     \toprule
%     字体命令          & 字号 & bp   & 研究生行距 & 本科生行距 \\
%     \midrule
%     \cs{tiny}         & 小六 & 6.5  & 10.83      & 11.92      \\
%     \cs{scriptsize}   & 六号 & 7.5  & 12.5       & 13.75      \\
%     \cs{footnotesize} & 小五 & 9    & 15         & 16.5       \\
%     \cs{small}        & 五号 & 10.5 & 17.5       & 19.25      \\
%     \cs{normalsize}   & 小四 & 12   & 20         & 22         \\
%     \cs{large}        & 小三 & 15   & 25         & 27.5       \\
%     \cs{Large}        & 小二 & 18   & 30         & 33         \\
%     \cs{LARGE}        & 二号 & 22   & 36.67      & 40.33      \\
%     \cs{huge}         & 小一 & 24   & 40         & 44         \\
%     \cs{Huge}         & 一号 & 26   & 43.33      & 47.67      \\
%     \bottomrule
%   \end{tabular}
% \end{table}
%
% 注意重定义 \normalsize 应在 \pkg{unicode-math} 的 \cs{setmathfont} 前。
\newcommand\ash@set@font@size{%
  \ifash@degree@graduate
    \renewcommand\normalsize{%
      \@setfontsize\normalsize{12bp}{20bp}%
      \abovedisplayskip 12bp \@plus3bp \@minus7bp%
      \abovedisplayshortskip 0bp \@plus3bp%
      \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
      \belowdisplayskip \abovedisplayskip
      \let\@listi\@listI}%
    %
    % 注意第~\ref{sec:list} 节去掉了列表的间距，所以不再修改 \cs{@listi}。
  \else
    \renewcommand\normalsize{%
      \@setfontsize\normalsize{12bp}{22bp}%
      \abovedisplayskip 12bp \@plus3bp \@minus7bp%
      \abovedisplayshortskip 0bp \@plus3bp%
      \belowdisplayshortskip 6.5bp \@plus3.5bp \@minus3bp%
      \belowdisplayskip \abovedisplayskip
      \let\@listi\@listI}%
  \fi
  \normalsize
  \ifx\MakeRobust\@undefined \else
      \MakeRobust\normalsize
  \fi
}
\ash@set@font@size
\ash@option@hook{degree}{\ash@set@font@size}

% 设置行距的倍数为 1。
\linespread{1}\selectfont


% 检测系统
\ifash@system@auto
  \IfFileExists{/System/Library/Fonts/Menlo.ttc}{
    \ashsetup{system = mac}
  }{
    \IfFileExists{/dev/null}{
      \IfFileExists{null:}{
        \ashsetup{system = windows}
      }{
        \ashsetup{system = unix}
      }
    }{
      \ashsetup{system = windows}
    }
  }
\fi

% 处理 \opt{fontset}
\ifash@fontset@auto
  \ifash@system@windows
    \ashsetup{fontset = windows}
  \else
    \IfFontExistsTF{SimSun}{
      \ashsetup{fontset = windows}
    }{
      \ifash@system@mac
        \ashsetup{fontset = mac}
      \else
        \IfFontExistsTF{Noto Serif CJK SC}{
          \ashsetup{fontset = ubuntu}
        }{
          \ashsetup{fontset = fandol}
        }
      \fi
    }
  \fi
\fi

% 《撰写手册》要求西文字体使用 Times New Roman 和 Arial，
% 但是在 Linux 下没有这两个字体，所以使用它们的克隆版 TeX Gyre Termes 和
% TeX Gyre Heros。
\ifash@font@auto
  \ifash@fontset@windows
    \ashsetup{font=times}
  \else
    \ifash@fontset@mac
      \ashsetup{font=times}
    \else
      \ashsetup{font=termes}
    \fi
  \fi
\fi

% Times New Roman + Arial
\newcommand\ash@set@font@times{%
  \setmainfont{Times New Roman}%
  \setsansfont{Arial}%
  \ifash@system@mac
    \setmonofont{Menlo}[Scale = MatchLowercase]%
  \else
    \setmonofont{Courier New}[Scale = MatchLowercase]%
  \fi
}

% TeX Gyre Termes
\newcommand\ash@set@font@termes{%
  \setmainfont{texgyretermes}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \ash@set@texgyre@sans@mono
}

\newcommand\ash@set@texgyre@sans@mono{%
  \setsansfont{texgyreheros}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmonofont{texgyrecursor}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
    Scale          = MatchLowercase,
    Ligatures      = CommonOff,
  ]%
}

% STIX Two 字体。
% STIX 文件名在 v2.10 2020-12-19 从
% \file{STIX2Text-Regular.otf}、\file{STIX2Math.otf} 分别改为
% \file{STIXTwoText-Regular.otf}、\file{STIXTwoMath-Regular.otf}。
\let\ash@font@family@stix\@empty
\newcommand\ash@set@stix@names{%
  \ifx\ash@font@family@stix\@empty
    \IfFontExistsTF{STIXTwoText-Regular.otf}{%
      \gdef\ash@font@family@stix{STIXTwoText}%
      \gdef\ash@font@name@stix@math{STIXTwoMath-Regular}%
    }{%
      \gdef\ash@font@family@stix{STIX2Text}%
      \gdef\ash@font@name@stix@math{STIX2Math}%
    }%
  \fi
}

\newcommand\ash@set@font@stix{%
  \ash@set@stix@names
  \setmainfont{\ash@font@family@stix}[
    Extension      = .otf,
    UprightFont    = *-Regular,
    BoldFont       = *-Bold,
    ItalicFont     = *-Italic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \ash@set@texgyre@sans@mono
}

% XITS 字体。
% XITS 的文件名在 v1.109 2018-09-30
% 从 \file{xits-regular.otf}、\file{xits-math.otf} 分别改为
% \file{XITS-Regular.otf}、\file{XITSMath-Regular.otf}。
\let\ash@font@family@xits\@empty
\newcommand\ash@set@xits@names{%
  \ifx\ash@font@family@xits\@empty
    \IfFontExistsTF{XITSMath-Regular.otf}{%
      \gdef\ash@font@family@xits{XITS}%
      \gdef\ash@font@style@xits@rm{Regular}%
      \gdef\ash@font@style@xits@bf{Bold}%
      \gdef\ash@font@style@xits@it{Italic}%
      \gdef\ash@font@style@xits@bfit{BoldItalic}%
      \gdef\ash@font@name@xits@math{XITSMath-Regular}%
    }{%
      \gdef\ash@font@family@xits{xits}%
      \gdef\ash@font@style@xits@rm{regular}%
      \gdef\ash@font@style@xits@bf{bold}%
      \gdef\ash@font@style@xits@it{italic}%
      \gdef\ash@font@style@xits@bfit{bolditalic}%
      \gdef\ash@font@name@xits@math{xits-math}%
    }%
  \fi
}

\newcommand\ash@set@font@xits{%
  \ash@set@xits@names
  \setmainfont{\ash@font@family@xits}[
    Extension      = .otf,
    UprightFont    = *-\ash@font@style@xits@rm,
    BoldFont       = *-\ash@font@style@xits@bf,
    ItalicFont     = *-\ash@font@style@xits@it,
    BoldItalicFont = *-\ash@font@style@xits@bfit,
  ]%
  \ash@set@texgyre@sans@mono
}

% Libertinus 的文件名在 v6.7 2019-04-03 从小写改为驼峰式，
% 在大小写敏感的平台上需要进行判断。
\let\ash@font@family@libertinus\@empty
\newcommand\ash@set@libertinus@names{%
  \ifx\ash@font@family@libertinus\@empty
    \IfFontExistsTF{LibertinusSerif-Regular.otf}{%
      \gdef\ash@font@family@libertinus@serif{LibertinusSerif}%
      \gdef\ash@font@family@libertinus@sans{LibertinusSans}%
      \gdef\ash@font@name@libertinus@math{LibertinusMath-Regular}%
      \gdef\ash@font@style@libertinus@rm{Regular}%
      \gdef\ash@font@style@libertinus@bf{Bold}%
      \gdef\ash@font@style@libertinus@it{Italic}%
      \gdef\ash@font@style@libertinus@bfit{BoldItalic}%
    }{%
      \gdef\ash@font@family@libertinus@serif{libertinusserif}%
      \gdef\ash@font@family@libertinus@sans{libertinussans}%
      \gdef\ash@font@name@libertinus@math{libertinusmath-regular}%
      \gdef\ash@font@style@libertinus@rm{regular}%
      \gdef\ash@font@style@libertinus@bf{bold}%
      \gdef\ash@font@style@libertinus@it{italic}%
      \gdef\ash@font@style@libertinus@bfit{bolditalic}%
    }%
  \fi
}

\newcommand\ash@set@font@libertinus{%
  \ash@set@libertinus@names
  \setmainfont{\ash@font@family@libertinus@serif}[
    Extension      = .otf,
    UprightFont    = *-\ash@font@style@libertinus@rm,
    BoldFont       = *-\ash@font@style@libertinus@bf,
    ItalicFont     = *-\ash@font@style@libertinus@it,
    BoldItalicFont = *-\ash@font@style@libertinus@bfit,
  ]%
  \setsansfont{\ash@font@family@libertinus@sans}[
    Extension      = .otf,
    UprightFont    = *-\ash@font@style@libertinus@rm,
    BoldFont       = *-\ash@font@style@libertinus@bf,
    ItalicFont     = *-\ash@font@style@libertinus@it,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% New Computer Modern
\newcommand\ash@set@font@newcm{%
  \setmainfont{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setsansfont{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmonofont{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern
\newcommand\ash@set@font@lm{%
  \setmainfont{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setsansfont{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmonofont{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

\newcommand\ash@set@font@newtx{%
  \RequirePackage{newtxtext}%
}

\newcommand\ash@set@font{%
  \@nameuse{ash@set@font@\ash@font}%
}
\ash@set@font
\ash@option@hook{font}{\ash@set@font}

% 中文字体
\ifash@cjk@font@auto
  \ifash@fontset@mac
    \ashsetup{cjk-font = mac}
  \else
    \ifash@fontset@windows
      \ashsetup{cjk-font = windows}
    \else
      \ifash@fontset@ubuntu
        \ashsetup{cjk-font = noto}
      \else
        \ashsetup{cjk-font = fandol}
      \fi
    \fi
  \fi
\fi

% 楷体GB2312
\newcommand{\kai}{\CJKfamily{kai}} 
\newfontface\kaiti{SimKai}[Path=C:/Windows/Fonts/]
\newcommand{\leftitem}[2][7em]{\makebox[#1][s]{\hfill#2\hfill}\hspace{0.5em}:}

% Windows 的中易字体。
\newcommand\ash@set@cjk@font@windows{%
  \setCJKmainfont{SimSun}[
    AutoFakeBold = 3,
    ItalicFont   = KaiTi,
  ]%
  \setCJKsansfont{SimHei}[AutoFakeBold = 3]%
  \setCJKmonofont{FangSong}%
  \setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold = 3]%
  \setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold = 3]%
  \setCJKfamilyfont{zhkai}{KaiTi}%
  \setCJKfamilyfont{zhfs}{FangSong}%
}

% macOS 的华文字体。
\newcommand\ash@set@cjk@font@mac{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = Kaiti SC Regular,
    BoldItalicFont = Kaiti SC Bold,
  ]%
  \setCJKsansfont{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKmonofont{STFangsong}
  \setCJKfamilyfont{zhsong}{Songti SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhhei}{Heiti SC}[
    UprightFont    = * Light,
    BoldFont       = * Medium,
  ]%
  \setCJKfamilyfont{zhfs}{STFangsong}%
  \setCJKfamilyfont{zhkai}{Kaiti SC}[
    UprightFont    = * Regular,
    BoldFont       = * Bold,
  ]%
  \setCJKfamilyfont{zhli}{Baoli SC}%
  \setCJKfamilyfont{zhyuan}{Yuanyi SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
  ]%
}


% 思源字体。
% 注意 Noto CJK 的 regular 字重名字不带“Regular”。
\newcommand\ash@set@cjk@font@noto{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{Noto Serif CJK SC}[
    UprightFont    = * Light,
    BoldFont       = * Bold,
    ItalicFont     = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
    Script         = CJK,
  ]%
  \setCJKsansfont{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKmonofont{Noto Sans Mono CJK SC}[
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhsong}{Noto Serif CJK SC}[
    UprightFont    = * Light,
    UprightFont    = * Bold,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhhei}{Noto Sans CJK SC}[
    BoldFont       = * Medium,
    Script         = CJK,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension      = .otf,
    UprightFont    = *-Regular,
  ]%
}

% Fandol 字体。
\newcommand\ash@set@cjk@font@fandol{%
  \defaultCJKfontfeatures{}%
  \setCJKmainfont{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
    ItalicFont  = FandolKai-Regular,
    ItalicFeatures = {Extension = .otf},
  ]%
  \setCJKsansfont{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKmonofont{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhsong}{FandolSong}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhhei}{FandolHei}[
    Extension   = .otf,
    UprightFont = *-Regular,
    BoldFont    = *-Bold,
  ]%
  \setCJKfamilyfont{zhfs}{FandolFang}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
  \setCJKfamilyfont{zhkai}{FandolKai}[
    Extension   = .otf,
    UprightFont = *-Regular,
  ]%
}

\ifash@cjk@font@none\else
  \providecommand\songti{\CJKfamily{zhsong}}
  \providecommand\heiti{\CJKfamily{zhhei}}
  \providecommand\fangsong{\CJKfamily{zhfs}}
  \providecommand\kaishu{\CJKfamily{zhkai}}
\fi

\newcommand\ash@set@cjk@font{%
  \@nameuse{ash@set@cjk@font@\ash@cjk@font}%
}
\ash@set@cjk@font
\ash@option@hook{cjk-font}{\ash@set@cjk@font}

% 数学字体

% 设置数学符号风格。
\newcommand\ash@set@math@style{%
  \ifash@math@style@TeX
    \ashsetup{
      uppercase-greek    = upright,
      less-than-or-equal = horizontal,
      integral           = slanted,
      integral-limits    = false,
      partial            = italic,
      math-ellipsis      = AMS,
      real-part          = fraktur,
    }%
  \else
    \ashsetup{
      uppercase-greek = italic,
      integral        = upright,
      partial         = upright,
      real-part       = roman,
    }%
    \ifash@math@style@ISO
      \ashsetup{
        less-than-or-equal = horizontal,
        integral-limits    = true,
        math-ellipsis      = lower,
      }%
    \else
      \ifash@math@style@GB
        \ashsetup{
          less-than-or-equal = slanted,
          integral-limits    = false,
          math-ellipsis      = centered,
        }%
      \fi
    \fi
  \fi
}

\ifash@main@language@chinese
  \ashsetup{math-style = GB}%
\else
  \ashsetup{math-style = TeX}%
\fi

\ash@set@math@style
\ash@option@hook{math-style}{\ash@set@math@style}
\ash@option@hook{main-language}{%
  \ifash@main@language@chinese
    \ashsetup{math-style = GB}%
  \else
    \ashsetup{math-style = TeX}%
  \fi
}

% 针对 \pkg{unicode-math} 逐项配置数学符号。

\newcommand\ash@set@unimath@leq{%
  \ifash@leq@horizontal
    \ifx\@begindocumenthook\@undefined
      \let\le\ash@save@leq
      \let\ge\ash@save@geq
      \let\leq\ash@save@leq
      \let\geq\ash@save@geq
    \else
      \AtBeginDocument{%
        \let\le\ash@save@leq
        \let\ge\ash@save@geq
        \let\leq\ash@save@leq
        \let\geq\ash@save@geq
      }%
    \fi
  \else
    \ifash@leq@slanted
      \ifx\@begindocumenthook\@undefined
        \let\le\leqslant
        \let\ge\geqslant
        \let\leq\leqslant
        \let\geq\geqslant
      \else
        \AtBeginDocument{%
          \let\le\leqslant
          \let\ge\geqslant
          \let\leq\leqslant
          \let\geq\geqslant
        }%
      \fi
    \fi
  \fi
}
\newcommand\ash@set@unimath@integral@limits{%
  \ifash@integral@limits@true
    \removenolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \else
    \addnolimits{%
      \int\iint\iiint\iiiint\oint\oiint\oiiint
      \intclockwise\varointclockwise\ointctrclockwise\sumint
      \intbar\intBar\fint\cirfnint\awint\rppolint
      \scpolint\npolint\pointint\sqint\intlarhk\intx
      \intcap\intcup\upint\lowint
    }%
  \fi
}
\newcommand\ash@set@unimath@ellipsis{%
  \ifash@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodecdots}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\unicodeellipsis}}%
  \fi
}
\newcommand\ash@set@unimath@real@part{%
  \ifash@real@part@roman
    \AtBeginDocument{%
      \def\Re{\operatorname{Re}}%
      \def\Im{\operatorname{Im}}%
    }%
  \else
    \AtBeginDocument{%
      \let\Re\ash@save@Re
      \let\Im\ash@save@Im
    }%
  \fi
}

\newcommand\ash@set@unimath@style{%
  \ifash@uppercase@greek@upright
    \unimathsetup{math-style = TeX}%
  \else
    \ifash@uppercase@greek@italic
      \unimathsetup{math-style = ISO}%
    \fi
  \fi
  \ifash@math@style@TeX
    \unimathsetup{bold-style = TeX}%
  \else
    \unimathsetup{bold-style = ISO}%
  \fi
  \ash@set@unimath@leq
  \ash@set@unimath@integral@limits
  \ifash@partial@upright
    \unimathsetup{partial = upright}%
  \else
    \ifash@partial@italic
      \unimathsetup{partial = italic}%
    \fi
  \fi
  \ash@set@unimath@ellipsis
  \ash@set@unimath@real@part
}

\newcommand\ash@qed{\rule{1ex}{1ex}}
\newcommand\ash@load@unimath{%
  \@ifpackageloaded{unicode-math}{}{%
    \RequirePackage{unicode-math}%
    \AtBeginDocument{%
      \let\ash@save@leq\leq
      \let\ash@save@geq\geq
      \let\ash@save@Re\Re
      \let\ash@save@Im\Im
    }%
    %
    % 兼容旧的粗体命令：\pkg{bm} 的 \cs{bm} 和 \pkg{amsmath} 的 \cs{boldsymbol}。
    \DeclareRobustCommand\bm[1]{{\symbfit{##1}}}%
    \DeclareRobustCommand\boldsymbol[1]{{\symbfit{##1}}}%
    %
    % 兼容 \pkg{amsfonts} 和 \pkg{amssymb} 中的一些命令。
    \newcommand\square{\mdlgwhtsquare}%
    \newcommand\blacksquare{\mdlgblksquare}%
    \AtBeginDocument{%
      \renewcommand\checkmark{\ensuremath{✓}}%
    }%
    %
    % 兼容 \pkg{amsthm} 的 \cs{qedsymbol}。
    \renewcommand\ash@qed{\ensuremath{\QED}}%
  }%
}

% STIX Two Math
\newcommand\ash@set@math@font@stix{%
  \ash@load@unimath
  \ash@set@unimath@style
  \ash@set@stix@names
  \setmathfont{\ash@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = \ash@xits@integral@stylistic@set,
  ]%
  \setmathfont{\ash@font@name@stix@math}[
    Extension    = .otf,
    Scale        = MatchLowercase,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
}

% XITS Math
\newcommand\ash@xits@integral@stylistic@set{%
  \ifash@integral@upright
    8%
  \fi
}
\newcommand\ash@set@math@font@xits{%
  \ash@load@unimath
  \ash@set@unimath@style
  \ash@set@xits@names
  \setmathfont{\ash@font@name@xits@math}[
    Extension    = .otf,
    StylisticSet = \ash@xits@integral@stylistic@set,
  ]%
  \setmathfont{\ash@font@name@xits@math}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {cal,bfcal},
  ]%
}

% Libertinus Math
\newcommand\ash@libertinus@integral@stylistic@set{%
  \ifash@integral@slanted
    8%
  \fi
}
\newcommand\ash@set@math@font@libertinus{%
  \ash@load@unimath
  \ash@set@unimath@style
  \ash@set@libertinus@names
  \ash@set@xits@names
  \setmathfont{\ash@font@name@libertinus@math}[
    Extension    = .otf,
    StylisticSet = \ash@libertinus@integral@stylistic@set,
  ]%
  \setmathfont{\ash@font@name@xits@math}[
    Extension    = .otf,
    range        = {\checkmark},
  ]%
}

% New Computer Modern Math
\newcommand\ash@newcm@integral@stylistic@set{%
  \ifash@integral@upright
    2%
  \fi
}
\newcommand\ash@set@math@font@newcm{%
  \ash@load@unimath
  \ash@set@unimath@style
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = \ash@newcm@integral@stylistic@set,
  ]%
  \setmathfont{NewCMMath-Book}[
    Extension    = .otf,
    StylisticSet = 1,
    range        = {scr,bfscr},
  ]%
  \setmathrm{NewCM10}[
    Extension      = .otf,
    UprightFont    = *-Book,
    BoldFont       = *-Bold,
    ItalicFont     = *-BookItalic,
    BoldItalicFont = *-BoldItalic,
  ]%
  \setmathsf{NewCMSans10}[
    Extension         = .otf,
    UprightFont       = *-Book,
    BoldFont          = *-Bold,
    ItalicFont        = *-BookOblique,
    BoldItalicFont    = *-BoldOblique,
  ]%
  \setmathtt{NewCMMono10}[
    Extension           = .otf,
    UprightFont         = *-Book,
    ItalicFont          = *-BookItalic,
    BoldFont            = *-Bold,
    BoldItalicFont      = *-BoldOblique,
  ]%
}

% Latin Modern Math
\newcommand\ash@set@math@font@lm{%
  \ash@load@unimath
  \ash@set@unimath@style
  \setmathfont{latinmodern-math}[Extension=.otf]%
  \setmathrm{lmroman10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-italic,
    BoldItalicFont = *-bolditalic,
  ]%
  \setmathsf{lmsans10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
  \setmathtt{lmmonolt10}[
    Extension      = .otf,
    UprightFont    = *-regular,
    BoldFont       = *-bold,
    ItalicFont     = *-oblique,
    BoldItalicFont = *-boldoblique,
  ]%
}

% NewTX Math
% 注意 NewTX Math 是 Type 1 字体，如果正文西文使用了 OpenType 字体时需要小心处理。
\newcommand\ash@set@math@font@newtx{%
  \ifash@font@newtx\else
    \let\ash@save@encodingdefault\encodingdefault
    \let\ash@save@rmdefault\rmdefault
    \let\ash@save@sfdefault\sfdefault
    \let\ash@save@ttdefault\ttdefault
    \RequirePackage[T1]{fontenc}%
    \renewcommand{\rmdefault}{ntxtlf}%
    \renewcommand{\sfdefault}{qhv}%
    \renewcommand{\ttdefault}{ntxtt}%
  \fi
  \ifash@uppercase@greek@italic
    \PassOptionsToPackage{slantedGreek}{newtxmath}%
  \fi
  \ifash@integral@upright
    \PassOptionsToPackage{upint}{newtxmath}%
  \fi
  \RequirePackage{newtxmath}
  \let\ash@save@leq\leq
  \let\ash@save@geq\geq
  \ifash@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifash@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \let\ash@save@partial\partial
  \ifash@partial@upright
    \let\partial\uppartial
  \fi
  \ifash@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\ash@save@Re\Re
  \let\ash@save@Im\Im
  \ifash@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \ifash@font@newtx\else
    \let\encodingdefault\ash@save@encodingdefault
    \let\rmdefault\ash@save@rmdefault
    \let\sfdefault\ash@save@sfdefault
    \let\ttdefault\ash@save@ttdefault
  \fi
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\upDelta%
  \renewcommand\ash@qed{\openbox}%
}

% Computer Modern
% 使用 LaTeX 默认的 cm 字体
\newcommand\ash@set@math@font@cm{%
  \RequirePackage{amssymb}
  \let\ash@save@leq\leq
  \let\ash@save@geq\geq
  \ifash@leq@slanted
    \let\le\leqslant
    \let\ge\geqslant
    \let\leq\leqslant
    \let\geq\geqslant
  \fi
  \ifash@integral@limits@true
    \let\ilimits@\displaylimits
  \fi
  \ifash@math@ellipsis@centered
    \DeclareRobustCommand\mathellipsis{\mathinner{\cdotp\cdotp\cdotp}}%
  \else
    \DeclareRobustCommand\mathellipsis{\mathinner{\ldotp\ldotp\ldotp}}%
  \fi
  \let\ash@save@Re\Re
  \let\ash@save@Im\Im
  \ifash@real@part@roman
    \def\Re{\operatorname{Re}}%
    \def\Im{\operatorname{Im}}%
  \fi
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\ash@qed{\openbox}%
  \let\uppi\pi
}

% 不设置数学字体，仅提供兼容支持。
\newcommand\ash@set@math@font@none{%
  \RequirePackage{amssymb}
  \RequirePackage{bm}%
  \DeclareRobustCommand\symup[1]{{\mathrm{##1}}}%
  \DeclareRobustCommand\symbf[1]{{\bm{##1}}}%
  \DeclareRobustCommand\symbfsf[1]{{\bm{##1}}}%
  \let\increment\Delta
  \renewcommand\ash@qed{\openbox}%
  \let\uppi\pi
}

\newcommand\ash@set@math@font{%
  \@nameuse{ash@set@math@font@\ash@math@font}%
}
\ash@option@hook{math-font}{\g@addto@macro\ash@setup@hook{\ash@set@math@font}}
\newcommand\ash@set@math@font@auto{%
  \ifash@math@font@auto
    \ashsetup{math-font=xits}%
  \fi
}
\AtBeginOfPackageFile*{siunitx}{\ash@set@math@font@auto}
\AtEndPreamble{%
  \ash@set@math@font@auto
  \ifx\square\@undefined
    \RequirePackage{amssymb}%
  \fi
}



% \subsection{纸张和页面}
% 使用 \pkg{geometry} 宏包设置纸张和页面。

% 纸张：A4；

% 页面设置：上、下 2.54 cm，左、右 3.17 cm，页眉 1.5 cm，页脚 1.75 cm。

% 注意这里指的是页眉顶部到纸张顶部的距离为 1.5 cm，
% 所以应该是 2.54cm - 0.8cm - 0.24cm = 1.5cm

\geometry{
  paper      = a4paper,
  vmargin    = 2.54cm,
  hmargin    = 3.17cm,
  headheight = 0.75cm,
  headsep    = 0.29cm,
  footskip   = 0.79cm,
}


% 使用 \pkg{fancy} 需要先调用 |\pagestyle{fancy}| 再修改 \cs{chaptermark} 和
% \cs{sectionmark}。
\pagestyle{fancy}
\let\sectionmark\@gobble
\renewcommand\headrulewidth{0.4\p@}

% 重定义默认的 |plain| page style，会显示页眉和页脚。
\fancypagestyle{plain}{%
  \fancyhf{}%
  %
  % 页眉与该部分的章标题相同，宋体 10.5 磅（五号）居中。
  % 页码：宋体 10.5 磅、页面下脚居中。
  \ifash@degree@graduate
    \def\ash@hf@font{\fontsize{10.5bp}{12bp}\selectfont}
    \fancyhead[C]{\ash@hf@font%
    \ifodd\value{page}%
    \leftmark% 奇数页显示章节标题
    \else%
    西北师范大学硕士学位论文% 偶数页显示固定文本
    \fi}%
    \fancyfoot[C]{\ash@hf@font\thepage}%
    \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markboth{\CTEXifname{\CTEXthechapter\quad}{}##1}{}%
    }%
    \let\sectionmark\@gobble
  \else
    %
    % 本科生要求除封面、扉页外，每面上部加页眉，
    % 用小 5 号字（9 bp）标注“中国科学技术大学本科毕业论文”，居中；
    % 从目录页开始在每面底部居中用小五宋体（9 bp）连续编页码。
    \def\ash@hf@font{\fontsize{9bp}{12bp}\selectfont}
    \fancyhead[C]{\ash@hf@font 中国科学技术大学本科毕业论文}%
    \fancyfoot[C]{\ash@hf@font\thepage}%
    \let\@mkboth\@gobbletwo
    \let\chaptermark\@gobble
    \let\sectionmark\@gobble
  \fi
}
\pagestyle{plain}

% |headings| 只有页眉，没有页脚，用于研究生的符号说明和本科生的 front matter。
\fancypagestyle{headings}{\fancyfoot{}}

% 设置特殊的 page style 不改变任何内容，用于每章首页。
\def\ps@chapter{}
\ctexset{chapter/pagestyle=chapter}

% 空白页不加页眉和页码。
\def\cleardoublepage{%
  \clearpage
  \if@twoside
    \ifodd\c@page\else
      \hbox{}%
      \thispagestyle{empty}%
      \newpage
      \if@twocolumn
        \hbox{}%
        \newpage
      \fi
    \fi
  \fi
}

%
% 研究生要求从“中文摘要”开始页码用大写罗马数字，
% 而本科生的 frontmatter（只有致谢）不编页码，从目录开始页码用阿拉伯数字。
\renewcommand\frontmatter{%
  \cleardoublepage
  \@mainmatterfalse
  \pagenumbering{Roman}%
  \ifash@degree@graduate
    \pagestyle{plain}%
  \else
    \pagestyle{headings}%
  \fi
}

% 研究生要求“第 1 章”要另页起，但是本科生要求另面起。
\renewcommand\mainmatter{%
  \ifash@degree@graduate
    \cleardoublepage
    \pagenumbering{arabic}%
  \else
    \clearpage
  \fi
  \pagestyle{plain}%
  \@mainmattertrue
}

\g@addto@macro\appendix{\@mainmattertrue}%


% \subsection{封面}


% 定义用户接口：
\ash@define@key{
  title = {
    default = {论文题目},
  },
  title* = {
    default = {Title},
    name    = title@en,
  },
  author = {
    default = {作者姓名},
  },
  author* = {
    default = {Author Name},
    name    = author@en,
  },
  search = {
    default = {研究方向},
  },
  search* = {
    default = {作者姓名},
  },
  xuemajor = {
    default = {学硕专业大类},
    name    = xuemajor@en,
  },
  speciality = {
    default = {专业},
  },
  speciality* = {
    default = {Speciality},
    name    = speciality@en,
  },
  supervisor = {
    default = {导师},
  },
  supervisor* = {
    default = {Supervisor Name},
    name    = supervisor@en,
  },
  practice-supervisor = {
    default = {企业导师~职称},
    name    = practice@supervisor,
  },
  practice-supervisor* = {
    default = {},
    name    = practice@supervisor@en,
  },
  advisor = {
    name    = practice@supervisor,
  },
  advisor* = {
    name    = practice@supervisor@en,
  },
  date = {
    default = {\the\year-\two@digits{\month}-\two@digits{\day}},
  },
  professional-type = {
    name = professional@type,
  },
  professional-type* = {
    name = professional@type@en,
  },
  secret-level = {
    name    = secret@level,
  },
  secret-level* = {
    name    = secret@level@en,
  },
  keywords,
  keywords* = {
    name    = keywords@en,
  },
}

% 导师一栏可能有多个姓名，所以用 \opt{supervisor} 进行收集，
% 然后使用本命令来输出要求的格式，
% 类似于 \LaTeX3 的 \cs{clist\_use:Nn}。
\newcommand\ash@clist@count[1]{%
  \csname clist_count:N\endcsname{#1}%
}
\newcommand\ash@clist@use[2]{%
  \csname clist_use:Nn\endcsname{#1}{#2}%
}
\newcommand\ash@supervisor@names{%
  \ash@clist@use{\ash@supervisor}{\quad}
}
\newcommand\ash@practice@supervisor@names{%
  \ash@clist@use{\ash@practice@supervisor}{\quad}
}
\newcounter{ash@count}
\newcommand\ash@supervisor@en@line{%
  \setcounter{ash@count}{\ash@clist@count{\ash@supervisor@en}}%
  \ifnum\c@ash@count>1\relax
    Supervisors:（Associate）%
  \else
    Supervisor:（Associate）%
  \fi
  \space\ash@clist@use{\ash@supervisor@en}{, }%
}
\newcommand\ash@practice@supervisor@en@line{%
  \setcounter{ash@count}{\ash@clist@count{\ash@practice@supervisor@en}}%
  \ifnum\c@ash@count>1\relax
    Supervisor for Practice Guiding:%
  \else
    Supervisor for Practice Guiding:%
  \fi
  \space\ash@clist@use{\ash@practice@supervisor@en}{, }%
}

% 输出日期的给定格式：\cs{ash@format@date}\marg{format}\marg{date}，
% 其中格式 \meta{format} 接受三个参数分别对应年、月、日，
% \meta{date} 是 ISO 格式的日期（yyyy-mm-dd）。
\newcommand\ash@format@date[2]{%
  \edef\ash@@date{#2}%
  \def\ash@@process@date##1-##2-##3\@nil{%
    #1{##1}{##2}{##3}%
  }%
  \expandafter\ash@@process@date\ash@@date\@nil
}
% NWNU的设置，只接受年和月
\newcommand\ash@format@date@mo[2]{%
  \edef\ash@@date{#2}%  % 保存日期字符串
  \def\ash@@process@date##1-##2-##3\@nil{%
    #1{##1}{##2}%  % 只传递年（##1）和月（##2），忽略日（##3）
  }%
  \expandafter\ash@@process@date\ash@@date\@nil
}

\newcommand\ash@date@format@zh@small[3]{\number#1 年 \number#2 月 \number#3 日}
\newcommand\ash@date@format@zh@big[3]{\zhdigits{#1}年\zhnumber{#2}月\zhnumber{#3}日}
\newcommand\ash@date@format@zh@big@monthonly[2]{\zhdigits{#1}年\zhnumber{#2}月}
\newcommand\ash@date@month[1]{%
  \ifcase\number#1\or
    January\or February\or March\or April\or May\or June\or
    July\or August\or September\or October\or November\or December%
  \fi
}
\newcommand\ash@date@format@zh@short[3]{\number#1 年 \number#2 月} 
% \newcommand\ash@date@format@en[3]{\ash@date@month{#2} \number#3, #1}
\newcommand\ash@date@format@en[2]{\ash@date@month{#2}, #1}
\newcommand\ash@date@zh@small{\ash@format@date{\ash@date@format@zh@small}{\ash@date}}
\newcommand\ash@date@zh@big{\ash@format@date{\ash@date@format@zh@big}{\ash@date}}
\newcommand\ash@date@zh@big@monthonly{\ash@format@date@mo{\ash@date@format@zh@big@monthonly}{\ash@date}}
\newcommand\ash@date@zh@short{\ash@format@date{\ash@date@format@zh@short}{\ash@date}}
\newcommand\ash@date@en{\ash@format@date@mo{\ash@date@format@en}{\ash@date}}


% 定义一些常量。
\ifash@degree@master
  \newcommand\ash@thesis@name{硕士学位论文}
  \newcommand\ash@thesis@name@en{A dissertation for doctor's degree}
  \ifash@degree@type@academic
    \newcommand\ash@thesis@name@type{学\hspace{1pt}术\hspace{1pt}学\hspace{1pt}位}
    \newcommand\ash@thesis@name@type@en{A dissertation for doctor's degree}
  \else
    \newcommand\ash@thesis@name@type{专\hspace{1pt}业\hspace{1pt}学\hspace{1pt}位}
    \newcommand\ash@thesis@name@type@en{A dissertation for doctor's degree}
  \fi
\fi
  \ifash@cjk@font@mac
    \providecommand\lishu{\CJKfamily{zhli}}
  \else
    \ifash@cjk@font@windows
      \setCJKfamilyfont{zhli}{LiSu}
      \providecommand\lishu{\CJKfamily{zhli}}
    \else
      \ash@warning{LiShu font is required}
      \providecommand\lishu{\sffamily}
    \fi
  \fi
  \newcommand\ash@speciality@name{专业领域}

% 定义校徽颜色
%
% 推迟定义颜色以避免调用 \pkg{xcolor} 时的警告
\AtBeginDocument{
  \definecolor{ashblue}{cmyk}{1,0.8,0,0}
}

% 添加 PDF 书签，在 \pkg{hyperref} 载入后才有效。
\newcommand\ash@pdfbookmark{\@gobble}

% 重定义 \env{titlepage} 环境，不修改页码。
\renewenvironment{titlepage}{%
  \cleardoublepage
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
}{%
  \if@restonecol\twocolumn \else \newpage \fi
}

% 中文封面：
% 密级仿宋 14 磅；
% 论文类型黑体 56 磅；
% 论文题目黑体 26 磅加粗居中，单倍行距；
% 作者姓名宋体 16 磅，单倍行距；
% 注意这里的“单倍行距”的地方开启了“对齐到网格”，所以实际行距有所偏差，
% 所以只能使用直尺测量。

\newcommand\ash@title@page@graduate@zh{%
  \ashsetup{language=chinese}%
  \begin{titlepage}%
    \ash@pdfbookmark{封面}%
    \centering
    \parbox[t][0.6cm][t]{\textwidth}{%
    \begin{minipage}[t]{0.45\textwidth} % 左侧占 45% 宽度
            \raggedright % 左对齐
            \fangsong % 仿宋字体
            \fontsize{14bp}{22bp}\selectfont % 字体大小
            分类号\underline{\hspace{2.0cm}}\\
            U D C\underline{\hspace{2.0cm}} \\
            % \null\ash@secret@level\par % 第一行
            % \null\ash@secret@level\par % 第二行
        \end{minipage}%
        \hfill % 左右部分分隔
        \begin{minipage}[t]{0.45\textwidth} % 右侧占 45% 宽度
            \raggedleft % 右对齐
            \fangsong % 仿宋字体
            \fontsize{14bp}{22bp}\selectfont % 字体大小
            密级\underline{\hspace{2.0cm}}\\
            编号\underline{\makebox[2cm][c]{10736}} \\
            % \null\ash@secret@level\par % 第一行
            % \null\ash@secret@level\par % 第二行
        \end{minipage}%
    }\par
    % \parbox[t][0.6cm][t]{\textwidth}{%
    %   \raggedleft\fangsong\fontsize{14bp}{14bp}\selectfont
    %   \null\ash@secret@level\par}\par
    \vskip 3.0cm%
    \includegraphics[height=1.03cm, width=6.3cm]{figures/nwnulog.png}\par
    \vskip 1.0cm%
    {\rmfamily\fontsize{22bp}{22bp}\selectfont
      \ash@thesis@name\par}%
      \vskip 0.5cm%
      \ifx\degree@type\academic
        \rmfamily\fontsize{16bp}{16bp}\selectfont （\ash@thesis@name@type）\par
      \else 
        \rmfamily\fontsize{16bp}{16bp}\selectfont （\ash@thesis@name@type）\par
      \fi
      \vskip 2.0cm%
    % {\rmfamily\fontsize{26bp}{26bp}\selectfont
    %   \ash@thesis@name\par}%
    % \ifash@degree@type@academic
    %   % \vskip 1.0cm%
    % \else
    %   \vskip 0.8cm%
    %   \begingroup
    %     \fontsize{26bp}{26bp}\selectfont
    %     \ifx\ash@professional@type\@empty
    %       \null
    %     \else
    %       \lishu （\ash@professional@type ）%
    %     \fi
    %     \par
    %   \endgroup
    %   \vskip 1.0cm%
    % \fi
    % \vskip 0.9cm%

    \parbox[t][3.5cm][c]{\textwidth}{%
      \centering
      % \bfseries\fontsize{26bp}{50bp}\selectfont
      \fontsize{26bp}{50bp}\selectfont
      \kaishu{\ash@title}\par}\par
    \vskip 2.0cm%
    {\fontsize{16bp}{31bp}\selectfont
    % \begin{tabbing}
    %   \hspace{8cm} \= \hspace{6cm} \= \hspace{3cm} \= \kill % Set up tab positions
    %   研究生姓名\>：  \underline{\hspace{6cm}} \\
    %   指导教师姓名、职称\>：  \underline{\hspace{6cm}} \\
    %   一级学科、专业名称\>：  \underline{\hspace{6cm}} \\
    %   研究方向\>：  \underline{\hspace{6cm}} \\
    %   专项计划\>：  \underline{\hspace{6cm}} \\
    %   \end{tabbing}\par}
    

    % \begin{center}
    %   \fontsize{10bp}{31bp}\selectfont
    %   \begin{tabular}{@{}>{\raggedright\arraybackslash}p{7.5em}@{\hspace{1em}}l@{}}
    %     \leftitem{研\hfill 究\hfill 生\hfill 姓\hfill 名}      & \underline{\makebox[8cm][l]{}} \\
    %     \leftitem{指\hfill 导\hfill 教\hfill 师\hfill 姓\hfill 名、职\hfill 称} & \underline{\makebox[8cm][l]{}} \\
    %     \leftitem{一\hfill 级\hfill 学\hfill 科、专\hfill 业\hfill 名\hfill 称} & \underline{\makebox[8cm][l]{}} \\
    %     \leftitem{研\hfill 究\hfill 方\hfill 向}               & \underline{\makebox[8cm][l]{}} \\
    %     \leftitem{专\hfill 项\hfill 计\hfill 划}               & \underline{\makebox[8cm][l]{}} 
    %   \end{tabular}
    %   \end{center}\par}

    % \begin{tabular}{@{}l@{\quad}l@{}}
    % \begin{tabular}{@{}l@{\hskip 0.5cm}l@{}}
    \ifash@degree@type@academic
      \begin{tabular}{@{}p{5cm}@{\hskip 0.1cm}l@{}}
    \else
      \begin{tabular}{@{}p{6cm}@{\hskip 0.1cm}l@{}}
    \fi
      % \multicolumn{2}{c}{\textsf{\rmfamily 研 究 生 姓 名}} & \underline{\makebox[5cm][c]{\ash@author}} \\
      \textsf{\rmfamily 研\hfill 究\hfill 生\hfill 姓\hfill 名} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@author}} \\
      \textsf{\rmfamily 指导教师姓名、职称} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@supervisor@names}} \\
      % \ifx\ash@practice@supervisor\@empty
      % \ifx \degree@type \academic
      \ifash@degree@type@academic
        \textsf{\rmfamily 一级学科、专业名称} &\textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@speciality}}\\
        \textsf{\rmfamily 研\hfill 究\hfill 方\hfill 向} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@search}}\\
      \else
        \textsf{\rmfamily 实践指导教师姓名、职称} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@practice@supervisor@names}} \\
        \textsf{\rmfamily 专\hfill 业\hfill 学\hfill 位\hfill 类\hfill 别} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@professional@type}} \\
        \textsf{\rmfamily 专\hfill 业\hfill 学\hfill 位\hfill 领\hfill 域} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{\ash@speciality}} \\
      \fi
      \textsf{\rmfamily 专\hfill 项\hfill 计\hfill 划} & \textsf{\rmfamily：} \underline{\makebox[6.7cm][c]{~}}\\
    \end{tabular}\par}

    \vfill
    \begin{center}
      {\heiti\fontsize{16bp}{20bp}\selectfont \ash@date@zh@big@monthonly}
    \end{center}
  \end{titlepage}%
  \ash@reset@main@language
}

% 英文封面
\newcommand\ash@title@page@graduate@en{%
  \ashsetup{language=english}%
  \begin{titlepage}%
    \ash@pdfbookmark{Title page}%
    \centering
    \parbox[t][0.4cm][t]{\textwidth}{%
      \raggedleft\fontsize{14bp}{14bp}\selectfont
      \null\ash@secret@level@en\par}\par
    \vskip 0.5cm%
    \parbox[t][][c]{\textwidth}{%
      \centering\bfseries\fontspec{Times New Roman}\fontsize{20bp}{24bp}\selectfont
      \ash@title@en\par}\par
    \vskip 3.5cm%
    {\fontsize{20bp}{30bp}\selectfont
    A Thesis Submitted to\par
    Northwest Normal University\par
    in partial fulfillment of the requirement\par
    for the degree of\par
    % Master of \ash@major@en \par
    % in\par
    % \ash@speciality@en \par
    % by \par
    % \ash@author@en \par
    % % \null\par}%
    % \ifash@degree@type@academic
    %   \ash@supervisor@en@line \\
    %   \else
    %   \ash@supervisor@en@line \\
    %   \ash@practice@supervisor@en@line \\
    %   \fi
    % }%
    % \null\par}%
    \ifash@degree@type@academic
      Master of \ash@xuemajor@en \par
      in\par
      \ash@speciality@en \par
      by \par
      \ash@author@en \par
      \ash@supervisor@en@line \\
      \else
      Master of \ash@speciality@en \par
      in\par
      \ash@speciality@en \par
      by \par
      \ash@author@en \par
      \ash@supervisor@en@line \\
      \ash@practice@supervisor@en@line \\
      \fi
    }%
    \vskip 2.5cm%
    
    % {\fontsize{16bp}{30bp}\selectfont
    %   \begin{tabular}{@{}l@{}}%
    %     Author:        \ash@author@en \\
    %     Speciality:    \ash@speciality@en \\
    %     \ash@supervisor@en@line \\
    %     \ifx\ash@practice@supervisor@en\@empty
    %     \else
    %       \ash@practice@supervisor@en@line \\
    %     \fi
    %   \end{tabular}\par}%
    \vfill
      \begin{center}
        {\heiti\fontsize{16bp}{20bp}\selectfont \ash@date@en}
      \end{center}
  \end{titlepage}%
  \ash@reset@main@language
}

\newbox\ash@title@box
\newlength\ash@title@page@item@width

% 重新定义 \cs{maketitle}，调用 \cs{ash@makezhtitle}, \cs{ash@makeentitle}
% 上下边距2.5cm，左右边距3.17cm  默认即正确
% 分别生成中、英文封面。
\renewcommand\maketitle{%
  % \newgeometry{margin=2.54cm}%
  % \newgeometry{top=2.54cm, bottom=2.54cm, left=3.17cm, right=3.17cm}%
  \pagenumbering{Alph}%
  \pagestyle{empty}%
  \ifash@degree@graduate
    \ash@title@page@graduate@zh
    \ash@title@page@graduate@en
  \else
    \ash@title@page@bachelor
  \fi
  \cleardoublepage
  \restoregeometry
  \pagestyle{plain}%
}


% \subsection{原创性声明}

% 定义原创性声明
\newcommand\ash@originality{%
  本人郑重声明：所呈交的学位论文是本人在导师的指导下独立进行研究工作所取得的成果。
  除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品成果。
  对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。
  因本学位论文引起的法律后果完全由本人承担。
}
\newcommand\ash@authorization{%
  本学位论文作者完全了解西北师范大学有关保留、使用学位论文的规定，
  有权保留并向国家有关部门或机构送交论文的纸质版和电子版，允许论文被查阅和借阅。
  本人授权西北师范大学可以将学位论文的全部或部分内容编入有关数据库进行检索，
  可以采用影印、缩印或扫描等复制手段保存、汇编学位论文，可以公开学位论文的全部或部分内容。\par
  (保密的学位论文在解密后适用本授权书)}
 
% \newcommand\ash@underline[2][3.2cm]{\underline{\hb@xt@ #1{\hss#2\hss}}}

\newcommand\ash@checkbox{%
  \makebox[0bp][l]{$\square$}%
  \raisebox{-0.2ex}{\hspace{0.1em}$\checkmark$}%
}

\newcommand\copyrightpage{%
  \newgeometry{top=2.5cm, bottom=2.5cm, left=4.17cm, right=4.17cm}%

  \begin{titlepage}%
    \ash@pdfbookmark{原创性和授权使用声明}%
    \null
    \vskip 0.3cm%
    {\centering\fontsize{16pt}{24pt}\selectfont\baselineskip=1.5\baselineskip
    \heiti{西北师范大学学位论文原创性声明}\par}
    \vskip 0.7cm%
    {\selectfont\fontsize{12pt}{18pt}\selectfont\baselineskip=1.5\baselineskip
    \ash@originality\par}

    \vskip 1.3cm%
    \parbox[t]{\textwidth}{%
    % \raggedleft % 整体右对齐
    {\selectfont\fontsize{12pt}{18pt}\selectfont\baselineskip=1.5\baselineskip
    \hspace{8cm}学位论文作者签名：\par
    \hspace{8cm}导师签名：\par
    \hspace{8cm}签字日期：\hfill 年\hfill 月\hfill 日\par}
  }
  \end{titlepage}%


  \begin{titlepage}%
    \vskip 0.3cm%
    {\centering\fontsize{16pt}{24pt}\selectfont\baselineskip=1.5\baselineskip
    \heiti{西北师范大学学位论文版权使用授权书}\par}
    \vskip 0.7cm%
    {\selectfont\fontsize{12pt}{18pt}\selectfont\baselineskip=1.5\baselineskip
    \ash@authorization\par}
    \vskip 0.6cm%
    {\selectfont\fontsize{12pt}{18pt}\selectfont\baselineskip=1.5\baselineskip
    \hspace{8cm}学位论文作者签名：\par
    \hspace{8cm}签字日期：\hfill 年\hfill 月\hfill 日\par}
    \vskip 0.5cm%
  \end{titlepage}%


  \restoregeometry
}
\ifash@degree@bachelor
  \let\copyrightpage\relax
\fi


% \subsection{章节标题}

% 标题最多允许使用五级。
\setcounter{secnumdepth}{5}

% 本科生章题为两字时中间空一字，三字时空半字，四字及以上不空。
% 这里用 \LaTeX3 的 \cs{\str_count:N} 判断字数。
% 注意，\pkg{stringstrings} 宏包会导致范数命令 \verb+\|+ 被修改。
\newcount\ash@titlelength
\DeclareRobustCommand\ash@spaced@title[1]{%
  \ash@titlelength=\csname str_count:N\endcsname{#1}%
  \begingroup
    \if@mainmatter\else
      \ifcase\ash@titlelength
      \or\or
        \ziju{1}%
      \or\or
        \ziju{0.5}%
      \fi
    \fi
    #1%
  \endgroup
}

% 五级节标题和脚注需要使用带圈的数字，这里使用 \cs{ash@circlefont} ：
\newcommand\ash@textcircled[1]{%
  \ifnum\value{#1}<21\relax
    {\symbol{\numexpr\value{#1} + "245F\relax}}%
  \else
    \ash@error{Cannot display more than 20 footnotes}%
  \fi
}

% 用 \pkg{ctex} 的接口设置全部章节标题格式。

% 各章标题：黑体 16 磅加粗居中，单倍行距，段前 24 磅，段后 18 磅，
% 章序号与章名间空一字。

% 由于 Word 模板中使用“单倍行距”，还“对齐到网格”，这在 TeX 中不容易实现。
% 所以目前按照默认的行距。

% 注意 \pkg{ctex} v2.4.3 以下版本的bug会导致章节标题前后的距离的实际值偏大。
% 另外 \pkg{ctex} v2.2 前的beforeskip的符号有特殊意义。
% \ctexset{
%   chapter = {
%     format      = \centering\heiti\bfseries\fontsize{16bp}{26.67bp}\selectfont,
%     nameformat  = {},
%     titleformat = {},
%     number      = \thechapter,
%     aftername   = \quad,
%     beforeskip  = 24bp,
%     afterskip   = 18bp,
%     fixskip     = true,
%   },
% }


%NWNU各章标题：黑体 15 磅 (三号)，单倍行距，单倍行距，段前 24 磅，段后 18 磅，
% 章序号与章名间空一字。
\ctexset{
  chapter = {
    format      = \centering\heiti\fontsize{15pt}{15pt}\selectfont,
    nameformat  = {},
    titleformat = {},
    number      = \thechapter,
    aftername   = \quad,
    beforeskip  = 24pt,
    afterskip   = 18pt,
    fixskip     = true,
  },
}


% NWNU一级节标题: 黑体 14 磅(四号) 左顶格，固定值行距 20 磅，段前 24 磅，段后 6 磅，
% 序号与题名间空一字。

% 保持新页的布局，标题与新页的距离
\usepackage{titlesec}
\titleformat{\section}
  {\heiti\fontsize{14bp}{20bp}\selectfont}
  {\thesection\quad}
  {0pt}
  {}
\titlespacing{\section}
  {0pt}    % 左缩进
  {24bp}   % 标题前间距
  {6bp}    % 标题后间距

\ctexset{
  % section = {
  %   format     = \heiti\fontsize{14bp}{20bp}\selectfont,
  %   aftername  = \quad,
  %   beforeskip = 24bp,
  %   afterskip  = 6bp,
  % },
  %
  % 二级节标题：黑体 13 磅，左缩进两字，单倍行距，段前 12 磅，段后 6 磅，
  % 序号与题名间空一字。
  subsection = {
    format     = \heiti\fontsize{13bp}{21.67bp}\selectfont,
    aftername  = \quad,
    beforeskip = 12bp,
    afterskip  = 6bp,
  },
  %
  % 三级及以下节标题的格式没有具体规定，按照 Word 模板的格式：
  % 使用黑体 12 磅，左缩进两字，行距 20 磅，段前段后 0 磅，序号与题名间空半字宽。
  subsubsection = {
    format     = \heiti\fontsize{12bp}{20bp}\selectfont,
    number     = \arabic{subsubsection},
    aftername  = .\hspace{0.5em},
    indent     = 2em,
    beforeskip = 0bp,
    afterskip  = 0bp,
  },
  %
  % 按照 Word 模板的格式，四级节标题：宋体 12 磅，左缩进两字，行距 20 磅，
  % 段前段后 0 磅，序号使用全宽括号，与题名间空半字宽。
  paragraph = {
    format     = \rmfamily\fontsize{12bp}{20bp}\selectfont,
    number     = （\arabic{paragraph}）,
    aftername  = \hspace{0.5em},
    indent     = 2em,
    beforeskip = 0bp,
    afterskip  = 0bp,
    runin      = false,
  },
  %
  % 按照 Word 模板的格式，五级节标题：宋体 12 磅，左缩进两字，行距 20 磅，
  % 段前段后 0 磅，序号使用全宽括号，与题名间空半字宽。
  subparagraph = {
    format     = \rmfamily\fontsize{12bp}{20bp}\selectfont,
    number     = \ash@textcircled{subparagraph},
    aftername  = \hspace{0.5em},
    indent     = 2em,
    beforeskip = 0bp,
    afterskip  = 0bp,
    runin      = false,
  },
}


\ifash@degree@bachelor
  \ifash@main@language@english
    \ashsetup{section-style = arabic}
  \fi
\fi
\ash@option@hook{main-language}{%
  \ifash@degree@bachelor
    \ifash@main@language@english
      \ashsetup{section-style = arabic}%
    \fi
  \fi
}

% 在研究生格式的基础上再设置本科生的章节标题格式。
\ifash@degree@bachelor
  \setcounter{secnumdepth}{4}
  \ctexset{
  %
  % 论文的致谢、目录、摘要和参考文献等标题用小二号（18 bp）黑体字，居中，
  % 这通过 \cs{if@mainmatter} 区分。
  % 正文中的标题分章、节、段三级；章、节标题居中，段标题居左，
  % 分别用三号（16 bp）黑体、小三（15 bp）黑体、四号（14 bp）黑体。
    chapter = {
      format = {
        \centering\sffamily
        \if@mainmatter
          \fontsize{16bp}{29.33bp}\selectfont
        \else
          \fontsize{18bp}{33bp}\selectfont
        \fi
      },
      titleformat = \ash@spaced@title,
    },
    section = {
      format = \centering\sffamily\fontsize{15bp}{27.5bp}\selectfont,
    },
    subsection = {
      format    = \sffamily\fontsize{14bp}{25.67bp}\selectfont,
      indent    = 0bp,
    },
    subsubsection = {
      format    = \rmfamily\fontsize{12bp}{22bp}\selectfont,
      indent    = 1em,
    },
    paragraph = {
      format    = \rmfamily\fontsize{12bp}{22bp}\selectfont,
      aftername = {},
      indent    = 1em,
    },
  }
  %
  % 本科生的阿拉伯数字式标题的格式与研究生几乎一致，只有中文数字式需要修改。
  \ifash@section@style@arabic\else
    \ctexset{
      chapter = {
        number = \chinese{chapter},
      },
      section = {
        name   = {第,节},
        number = \chinese{section},
      },
      subsection = {
        number    = \chinese{subsection},
        aftername = {、},
      },
    }
  \fi
\fi

% 默认的 \cs{chapter*} 生成的章标题没有编号、不更改页眉，
% 也不添加进目录或 PDF 书签。
% 然而像摘要、目录、符号说明这样的章节，它们不需要编号、不加入目录，
% 但是需要修改页眉，并且加入 PDF 标签。
% 所以我们新定义 \cs{ash@chapter} 用于处理这些章节。%
\NewDocumentCommand\ash@chapter{o m}{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \IfValueTF{#1}{%
    \ash@pdfbookmark{#1}%
    \chaptermark{#1}%
  }{%
    \ash@pdfbookmark{#2}%
    \chaptermark{#2}%
  }%
  \chapter*{#2}}


% \subsection{摘要}

% 中文摘要环境。
\newcommand\ash@keywords@text{%
  \ash@clist@use{\ash@keywords}{；}%
}
\newcommand\ash@keywords@en@text{%
  \ifash@degree@graduate
    \ash@clist@use{\ash@keywords@en}{; }%
  \else
    \ash@clist@use{\ash@keywords@en}{, }%
  \fi
}
\newenvironment{abstract}{%
  \ashsetup{language=chinese}%
  {\heiti\ash@chapter{摘\hspace{1em}要}}
  % {\heiti\fontsize{16pt}{24pt}\selectfont{摘\hspace{2em}要}\par}% % 黑体三号并空两个空格
}{
  \par\null\par\noindent\hangindent=4em\relax
  \textbf{关键词}：\ash@keywords@text\par
  \ash@reset@main@language
}

\newbox\ash@keywords@box
\newlength\ash@keywords@width


% 英文摘要环境
\newcommand\ash@keywords@label{Keywords}%

\newenvironment{abstract*}{%
  \ashsetup{language=english}%
  \ifash@degree@graduate
    \ash@chapter{Abstract}%
  \else
    \begingroup
      % 本科生的英文摘要使用小二号衬线体
      \ctexset{chapter/format=\centering\fontsize{18bp}{33bp}\selectfont}%
      \ash@chapter{ABSTRACT}%
    \endgroup
  \fi
}{
  \par\null\par\noindent
  \ifash@degree@bachelor
    \renewcommand\ash@keywords@label{Key Words}%
  \fi
  \savebox\ash@keywords@box{\textbf{\ash@keywords@label}: }%
  \ash@keywords@width=\linewidth
  \advance\ash@keywords@width-\wd\ash@keywords@box
  \textbf{\ash@keywords@label}: \parbox[t]{\ash@keywords@width}{\ash@keywords@en@text\par}\par
  \ifash@degree@graduate
    \cleardoublepage
  \fi
  \ash@reset@main@language
}

% Reserved for compatibility until 2020-07-01.
\newenvironment{enabstract}{%
  \ash@deprecated{'enabsctract' environment}{2020-07-01}{'abstract*'}%
  \begin{abstract*}%
}{%
  \end{abstract*}%
}


% \subsection{目录}

% 研究生规定目录另面起；
% 本科生规定从目录开始编页码，所以必须另页起。
\renewcommand\tableofcontents{%
  \ifash@degree@bachelor
    \cleardoublepage
    \pagenumbering{arabic}%
    \pagestyle{plain}%
  \fi
  \ash@chapter{\contentsname}%
  \@starttoc{toc}%
}

% 下面用 \pkg{titletoc} 宏包设置目录内容的格式。
% 先定义目录线：
\newcommand\ash@leaders{%
  \hspace{2bp}%
  \titlerule*[4bp]{.}%
  \hspace{2bp}%
}

\contentsmargin{0bp}

% 目录中的章标题行采用宋体小四号字，固定行距 20 磅，段前 6 磅，段后 0 磅；
% 其他内容采用宋体小四号字，行距 20 磅，段前、段后均为 0 磅。
% 章标题行居左书写，一级节标题行缩进 1 个汉字符，二级节标题行缩进 2 个汉字符。
% 带有序号的各级标题，其序号与题名之间均空一字符，行末右顶格。
\ifash@degree@graduate
  \titlecontents{chapter}
    [0bp]{\addvspace{3bp}\bfseries\normalsize}
    {\contentspush{\thecontentslabel\hspace{\ccwd}}}{}
    {\normalsize\ash@leaders\thecontentspage}
    %
  \titlecontents{section}
    [1em]{\normalsize}
    {\contentspush{\thecontentslabel\quad}}{}
    {\ash@leaders\thecontentspage}
    %
  \titlecontents{subsection}
    [2em]{\normalsize}
    {\contentspush{\thecontentslabel\quad}}{}
    {\ash@leaders\thecontentspage}
\else
  % 本科生的目录使用小四宋体（同正文字体），其他同研究生的格式相近。
  \titlecontents{chapter}
    [0bp]{\normalsize}
    {\contentspush{\thecontentslabel\unskip\quad}}{}
    {\ash@leaders\thecontentspage}
  \titlecontents{section}
    [1em]{\normalsize}
    {\contentspush{\thecontentslabel\quad}}{}
    {\ash@leaders\thecontentspage}
  \titlecontents{subsection}
    [2em]{\normalsize}
    {\contentspush{\thecontentslabel
      \ifash@section@style@arabic\quad\else 、\fi}}{}
    {\ash@leaders\thecontentspage}
\fi

% 本科生要求目录中正文每章前多空一行，而目录、附录等章则不需要空行，
% 所以不能简单判断 \cs{if@mainmatter}，需要重新定义 \cs{mainmatter} 等命令。
\newif\ifash@addtocspace
\ifash@degree@bachelor
  \ash@addtocspacetrue
  \g@addto@macro\frontmatter{\ash@addtocspacefalse}%
  \g@addto@macro\mainmatter{\ash@addtocspacetrue}%
  \g@addto@macro\backmatter{\ash@addtocspacefalse}%
  \g@addto@macro\appendix{\ash@addtocspacefalse}%
\fi

% 处理本科生在目录中添加空行。
\renewcommand\chapter{%
  \if@openright\cleardoublepage\else\clearpage\fi
  \thispagestyle{\CTEX@chapter@pagestyle}%
  \global\@topnum\z@
  \@afterindenttrue
  \ifash@degree@bachelor
    \ifash@addtocspace
      \addtocontents{toc}{\protect\addvspace{12bp}}%
    \fi
  \fi
  \secdef\@chapter\@schapter
}

% 图标设置章节-序号 格式
\renewcommand{\thefigure}{\thechapter-\arabic{figure}}
\renewcommand{\thetable}{\thechapter-\arabic{table}}

% 研究生要求图、表的清单须另页起。
\newlength{\ash@lof@label@width}
\newcommand\ash@set@lof@format{%
  \settowidth{\ash@lof@label@width}{\figurename~9.99}%
  \addtolength{\ash@lof@label@width}{1em}%
  \titlecontents{figure}%
    [\ash@lof@label@width]{\normalsize}%
    {\contentslabel[\figurename~\thecontentslabel]{\ash@lof@label@width}}{}%
    {\ash@leaders\thecontentspage}%
  \titlecontents{table}%
    [\ash@lof@label@width]{\normalsize}%
    {\contentslabel[\tablename~\thecontentslabel]{\ash@lof@label@width}}{}%
    {\ash@leaders\thecontentspage}%
}
\ash@set@lof@format
\ash@option@hook{main-language}{\ash@set@lof@format}
\renewcommand\listoffigures{%
  \ifash@degree@graduate
    \cleardoublepage
  \fi
  \ash@chapter{\listfigurename}%
  \@starttoc{lof}%
}
\renewcommand\listoftables{%
  \ifash@degree@graduate
    \cleardoublepage
  \fi
  \ash@chapter{\listtablename}%
  \@starttoc{lot}%
}

\newcommand\listoffiguresandtables{%
  \ifash@degree@graduate
    \cleardoublepage
  \fi
  \ash@chapter{\ash@list@figure@table@name}%
  \@starttoc{lof}%
  \@starttoc{lot}%
}


% \subsection{符号说明}

% 研究生规定符号说明另页起，标题字体字号等同论文正文，
% 《撰写手册》第 9 页 1.10(2) 还规定“符号说明不加页码”。
\newenvironment{notation}{%
  \ifash@degree@graduate
    \cleardoublepage
    \pagestyle{headings}%
  \fi
  \ash@chapter{\ash@notation@name}%
}{%
  \ifash@degree@graduate
    \clearpage
    \pagestyle{plain}%
  \fi
}%
\newcommand*\notationlabel[1]{#1\hfil}%
\newenvironment{notationlist}[1]{%
  \list{}{%
    \itemsep 3bp%
    \labelwidth #1\relax%
    \labelsep 1em%
    \leftmargin\labelwidth
    \advance\leftmargin\labelsep
    \advance\leftmargin 3em%
    \rightmargin 3em%
    \let\makelabel\notationlabel
  }%
}{%
  \endlist
}


% \subsection{正文}

% \cs{sloppy} 可以减少“overfull boxes”。
\sloppy

% 禁止扩大段间距。（\href{https://github.com/ashtug/bigash/issues/209}{
%   ashtug/bigash\#209}）
\raggedbottom

% 段间距 0 磅。
\setlength{\parskip}{0bp}

% 首段缩进。
\ctexset{autoindent=2}

% 首段缩进。
\let\@afterindentfalse\@afterindenttrue
\@afterindenttrue

% URL 的字体设为保持原样。
\urlstyle{same}

% 使用 \pkg{xurl} 宏包的方法，增加 URL 可断行的位置。
\def\UrlBreaks{%
  \do\/%
  \do\a\do\b\do\c\do\d\do\e\do\f\do\g\do\h\do\i\do\j\do\k\do\l%
     \do\m\do\n\do\o\do\p\do\q\do\r\do\s\do\t\do\u\do\v\do\w\do\x\do\y\do\z%
  \do\A\do\B\do\C\do\D\do\E\do\F\do\G\do\H\do\I\do\J\do\K\do\L%
     \do\M\do\N\do\O\do\P\do\Q\do\R\do\S\do\T\do\U\do\V\do\W\do\X\do\Y\do\Z%
  \do0\do1\do2\do3\do4\do5\do6\do7\do8\do9\do=\do/\do.\do:%
  \do\*\do\-\do\~\do\'\do\"\do\-}
\Urlmuskip=0mu plus 0.1mu

% 脚注用带圈的数字：
\renewcommand\thefootnote{\ash@textcircled{footnote}}

% LaTeX 默认脚注按章计数，即每章的开始才重置脚注计数器；我们修改为按页计数。
% 简单的|\@addtoreset{footnote}{page}|并不可靠，
% \footnote{\url{https://texfaq.org/FAQ-footnpp.html}}
% 所以我们使用 \pkg{footmisc} 宏包。

% 脚注线长为版心宽度的四分之一：
\renewcommand\footnoterule{%
  \kern-3\p@
  \hrule\@width.25\textwidth
  \kern2.6\p@}
  %
  % 注文缩进两字：
\renewcommand\@makefntext[1]{%
  \parindent=2em\relax
  \noindent
  \hb@xt@ 2em{\hss\@makefnmark}#1}


% \subsection{列表}
% \label{sec:list}

% 调整列表中各项之间过大的间距。
\setlength\partopsep{0bp}
\newcommand\ash@nolistsep{%
  \parsep 0\p@ \@plus.2\p@
  \topsep 0\p@ \@plus.2\p@
  \itemsep0\p@ \@plus.2\p@
}
\def\@listi{\leftmargin\leftmargini
            \ash@nolistsep}
\let\@listI\@listi
\@listi
\def\@listii {\leftmargin\leftmarginii
              \labelwidth\leftmarginii
              \advance\labelwidth-\labelsep
              \ash@nolistsep}
\def\@listiii{\leftmargin\leftmarginiii
              \labelwidth\leftmarginiii
              \advance\labelwidth-\labelsep
              \ash@nolistsep}


% \subsection{浮动体}

% \LaTeX{} 对放置浮动体的要求比较强，这里按照 UK TeX FAQ 的建议
% \footnote{\url{https://texfaq.org/FAQ-floats}} 对其适当放宽。
\renewcommand\topfraction{.85}
\renewcommand\bottomfraction{.7}
\renewcommand\textfraction{.15}
\renewcommand\floatpagefraction{.66}
\renewcommand\dbltopfraction{.66}
\renewcommand\dblfloatpagefraction{.66}
\setcounter{topnumber}{9}
\setcounter{bottomnumber}{9}
\setcounter{totalnumber}{20}
\setcounter{dbltopnumber}{9}

% 修改默认的浮动体描述符为 |h|。
\def\fps@figure{h}
\def\fps@table{h}

% 用 \pkg{caption} 宏包设置图、表的格式：

% 图号、图题置于图的下方，宋体 10.5 磅居中，单倍行距，段前 6 磅，段后 12 磅，
% 图号与图题文字之间空一字，图号、图题加粗。
% 图注位于图的下方，左缩进两字，续行悬挂缩进左对齐，两端对齐。

% 表号、表题置于表的上方，黑体 10.5 磅居中，单倍行距，段前 6 磅，段后 6 磅，
% 表号与表题文字之间空一字，表号、表题加粗。
% 表注左缩进两字，续行悬挂缩进左对齐，两端对齐。
\setlength{\floatsep}{6bp}
\setlength{\textfloatsep}{6bp}
\setlength{\intextsep}{6bp}

\DeclareCaptionFont{ash}{%
  \ifash@language@chinese
    \fontsize{10.5bp}{13.65bp}\selectfont
  \else
    \fontsize{10.5bp}{12.075bp}\selectfont
  \fi
}

\captionsetup{
  font           = ash,
  labelsep       = quad,
  skip           = 6bp,
  figureposition = bottom,
  tableposition  = top,
}
\ifash@degree@graduate
  \captionsetup{font+=bf}
  \captionsetup[table]{font+=sf}
\fi
\captionsetup[figure]{
  belowskip = 6bp,
}

% 由于 LaTeX2e kernel 的问题，图表等浮动体与文字前后的距离不一致，需要进行 patch。
% 参考 \href{https://github.com/tuna/thuthesis/issues/614}{tuna/thuthesis/issues\#614}、
% \url{https://www.zhihu.com/question/46618031} 和
% \url{https://tex.stackexchange.com/a/40363/82731}。
%    \begin{macrocode}
\patchcmd{\@addtocurcol}%
  {\vskip \intextsep}%
  {\edef\save@first@penalty{\the\lastpenalty}\unpenalty
   \ifnum \lastpenalty = \@M  % hopefully the OR penalty
     \unpenalty
   \else
     \penalty \save@first@penalty \relax % put it back
   \fi
   \ifnum\outputpenalty <-\@Mii
     \addvspace\intextsep
     \vskip\parskip
   \else
     \addvspace\intextsep
   \fi}%
  {}{\ash@patch@error{\@addtocurcol}}
\patchcmd{\@addtocurcol}%
  {\vskip\intextsep \ifnum\outputpenalty <-\@Mii \vskip -\parskip\fi}%
  {\ifnum\outputpenalty <-\@Mii
     \aftergroup\vskip\aftergroup\intextsep
     \aftergroup\nointerlineskip
   \else
     \vskip\intextsep
   \fi}%
  {}{\ash@patch@error{\@addtocurcol}}
\patchcmd{\@getpen}{\@M}{\@Mi}
  {}{\ash@patch@error{\@getpen}}

% 新定义了 \cs{note} 来生成图表的附注。
% 如果用 \cs{caption} 生成图表的附注会导致图表的序号有误；
% 如果用 \cs{bicaption} 会导致表注无法置于表后，而且对齐方式不对。
\newcommand\note[1]{%
  \begingroup
    \captionsetup{
      font          = ash,
      margin        = 2em,
      position      = bottom,
    }%
    \caption*{#1}%
  \endgroup
}

% 表格默认字号略小
\patchcmd\@floatboxreset{%
  \normalsize
}{%
  \small
}{}{\ash@patch@error{\@floatboxreset}}

% 对 \pkg{longtable} 跨页表格进行相同的设置。
%
% 在 Word 模板中按照正确的设置（需要去掉文档网格），
% 中文模板每页能装下 1 行标题、1 行表头、30 行表身，
% 英文模板每页能装下 1 行标题、1 行表头、33 行表身。
%    \begin{macrocode}
\AtEndOfPackageFile*{longtable}{
  \AtBeginEnvironment{longtable}{%
    \ifdim\f@size pt > 12pt\relax
      \small
    \fi
  }
}


% \subsection{参考文献}

\PassOptionsToPackage{compress}{natbib}
\AtEndOfPackageFile*{natbib}{
  % 定义上标带方括号的引用样式
  \newcommand{\supercite}[1]{\textsuperscript{\cite{#1}}}
%   % 定义几种引用文献的标注样式。
  % \newcommand\bibstyle@super{\bibpunct{[}{]}{,}{s}{,}{\textsuperscript{,}}}
  % \newcommand\bibstyle@inline{\bibpunct{[}{]}{,}{n}{,}{,}}
  % \newcommand\bibstyle@authoryear{\bibpunct{(}{)}{;}{a}{,}{,}}
  % \@namedef{bibstyle@author-year}{\bibstyle@authoryear}
%   %
%   % 几种种引用样式，与 \file{bst} 文件名保持一致，
%   % 这样在使用 \cs{bibliographystyle} 选择参考文献表的样式时也会设置对应的引用样式。
%   \@namedef{bibstyle@bigash-numerical}{\bibstyle@super}
%   \@namedef{bibstyle@bigash-authoryear}{\bibstyle@authoryear}
%   \@namedef{bibstyle@bigash-bachelor}{\bibstyle@super}
%   %
%   % 如果载入 `natbib` 前设置了 `cite-style`，这里先进行配置。
%   % 
%   \ifx\ash@cite@style\@empty\else
%     \citestyle{\ash@cite@style}%
%   \fi
%   %
%   % 定义接口 cite-style 切换引用样式。
%   \ash@option@hook{cite-style}{%
%     \citestyle{\ash@cite@style}%
%   }
%   %
%   % 如果文献序号作为叙述文字的一部分，需要临时将文献序号与正文平排
%   \DeclareRobustCommand\inlinecite{\@inlinecite}
%   \def\@inlinecite#1{\begingroup\let\@cite\NAT@citenum\citep{#1}\endgroup}
%   %
%   % 修改引用的样式。
%   % 这里在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
%   %
  % 将 super 式 \cs{citep} 引用的页码置于括号外。
  % \renewcommand\NAT@citesuper[3]{%
  %   \ifNAT@swa
  %     \if*#2*\else
  %       #2\NAT@spacechar
  %     \fi
  %     % \unskip\kern\p@\textsuperscript{\NAT@@open#1\NAT@@close}%
  %     %  \if*#3*\else\NAT@spacechar#3\fi\else #1\fi\endgroup}
  %     \unskip\kern\p@
  %     \textsuperscript{%
  %       \NAT@@open#1\NAT@@close
  %       \if*#3*\else#3\fi
  %     }%
  %     \kern\p@
  %   \else
  %     #1%
  %   \fi
  %   \endgroup
  % }
  % %
  % 将 numbers 式 \cs{citep} 引用的页码置于括号外并改为上标。
  % \renewcommand\NAT@citenum[3]{%
  %   \ifNAT@swa
  %     \NAT@@open
  %     \if*#2*\else
  %       #2\NAT@spacechar
  %     \fi
  %     % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close
  %     #1\NAT@@close
  %     \if*#3*\else
  %       \textsuperscript{#3}%
  %     \fi
  %   \else
  %     #1%
  %   \fi
  %   \endgroup
  % }
  
%   % 在 filehook 中无法使用 \cs{patchcmd}，所以只能手动重定义。
%   \def\NAT@citexnum[#1][#2]#3{%
%     \NAT@reset@parser
%     \NAT@sort@cites{#3}%
%     \NAT@reset@citea
%     \@cite{\def\NAT@num{-1}\let\NAT@last@yr\relax\let\NAT@nm\@empty
%       \@for\@citeb:=\NAT@cite@list\do
%       {\@safe@activestrue
%       \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
%       \@safe@activesfalse
%       \@ifundefined{b@\@citeb\@extra@b@citeb}{%
%         {\reset@font\bfseries?}
%           \NAT@citeundefined\PackageWarning{natbib}%
%         {Citation `\@citeb' on page \thepage \space undefined}}%
%       {\let\NAT@last@num\NAT@num\let\NAT@last@nm\NAT@nm
%         \NAT@parse{\@citeb}%
%         \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
%           \let\NAT@name=\NAT@all@names
%           \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
%         \fi
%         \ifNAT@full\let\NAT@nm\NAT@all@names\else
%           \let\NAT@nm\NAT@name\fi
%         \ifNAT@swa
%         \@ifnum{\NAT@ctype>\@ne}{%
%           \@citea
%           \NAT@hyper@{\@ifnum{\NAT@ctype=\tw@}{\NAT@test{\NAT@ctype}}{\NAT@alias}}%
%         }{%
%           \@ifnum{\NAT@cmprs>\z@}{%
%           \NAT@ifcat@num\NAT@num
%             {\let\NAT@nm=\NAT@num}%
%             {\def\NAT@nm{-2}}%
%           \NAT@ifcat@num\NAT@last@num
%             {\@tempcnta=\NAT@last@num\relax}%
%             {\@tempcnta\m@ne}%
%           \@ifnum{\NAT@nm=\@tempcnta}{%
%             \@ifnum{\NAT@merge>\@ne}{}{\NAT@last@yr@mbox}%
%           }{%
%             \advance\@tempcnta by\@ne
%             \@ifnum{\NAT@nm=\@tempcnta}{%
%               % 在顺序编码制下，\pkg{natbib} 只有在三个以上连续文献引用才会使用连接号，
%               % 这里修改为允许两个引用使用连接号。
%               % 参考 https://tex.stackexchange.com/a/86991/82731 。
%               %
%               % \ifx\NAT@last@yr\relax
%               %   \def@NAT@last@yr{\@citea}%
%               % \else
%               %   \def@NAT@last@yr{--\NAT@penalty}%
%               % \fi
%               \def@NAT@last@yr{-\NAT@penalty}%
%             }{%
%               \NAT@last@yr@mbox
%             }%
%           }%
%           }{%
%           \@tempswatrue
%           \@ifnum{\NAT@merge>\@ne}{\@ifnum{\NAT@last@num=\NAT@num\relax}{\@tempswafalse}{}}{}%
%           \if@tempswa\NAT@citea@mbox\fi
%           }%
%         }%
%         \NAT@def@citea
%         \else
%           \ifcase\NAT@ctype
%             \ifx\NAT@last@nm\NAT@nm \NAT@yrsep\NAT@penalty\NAT@space\else
%               \@citea \NAT@test{\@ne}\NAT@spacechar\NAT@mbox{\NAT@super@kern\NAT@@open}%
%             \fi
%             \if*#1*\else#1\NAT@spacechar\fi
%             \NAT@mbox{\NAT@hyper@{{\citenumfont{\NAT@num}}}}%
%             \NAT@def@citea@box
%           \or
%             \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
%           \or
%             \NAT@hyper@citea@space{\NAT@test{\NAT@ctype}}%
%           \or
%             \NAT@hyper@citea@space\NAT@alias
%           \fi
%         \fi
%       }%
%       }%
%         \@ifnum{\NAT@cmprs>\z@}{\NAT@last@yr}{}%
%         \ifNAT@swa\else
%           % 将 numerical 式 \cs{citet} 引用的页码置于括号外并改为上标。
%           %
%           % \@ifnum{\NAT@ctype=\z@}{%
%           %   \if*#2*\else\NAT@cmt#2\fi
%           % }{}%
%           \NAT@mbox{\NAT@@close}%
%           \@ifnum{\NAT@ctype=\z@}{%
%             \if*#2*\else
%               \textsuperscript{#2}%
%             \fi
%           }{}%
%           \NAT@super@kern
%         \fi
%     }{#1}{#2}%
%   }%
%   %
%   % 将 author-year 式 \cs{citep} 引用的页码置于括号外并改为上标：
%   \renewcommand\NAT@cite%
%       [3]{\ifNAT@swa\NAT@@open\if*#2*\else#2\NAT@spacechar\fi
%           % #1\if*#3*\else\NAT@cmt#3\fi\NAT@@close\else#1\fi\endgroup}
%           #1\NAT@@close\if*#3*\else\textsuperscript{#3}\fi\else#1\fi\endgroup}
%   %
%   % 调整 author-year 式 \cs{citet} 引用的页码。
%   \def\NAT@citex%
%     [#1][#2]#3{%
%     \NAT@reset@parser
%     \NAT@sort@cites{#3}%
%     \NAT@reset@citea
%     \@cite{\let\NAT@nm\@empty\let\NAT@year\@empty
%       \@for\@citeb:=\NAT@cite@list\do
%       {\@safe@activestrue
%       \edef\@citeb{\expandafter\@firstofone\@citeb\@empty}%
%       \@safe@activesfalse
%       \@ifundefined{b@\@citeb\@extra@b@citeb}{\@citea%
%         {\reset@font\bfseries ?}\NAT@citeundefined
%                   \PackageWarning{natbib}%
%         {Citation `\@citeb' on page \thepage \space undefined}\def\NAT@date{}}%
%       {\let\NAT@last@nm=\NAT@nm\let\NAT@last@yr=\NAT@year
%         \NAT@parse{\@citeb}%
%         \ifNAT@longnames\@ifundefined{bv@\@citeb\@extra@b@citeb}{%
%           \let\NAT@name=\NAT@all@names
%           \global\@namedef{bv@\@citeb\@extra@b@citeb}{}}{}%
%         \fi
%       \ifNAT@full\let\NAT@nm\NAT@all@names\else
%         \let\NAT@nm\NAT@name\fi
%       \ifNAT@swa\ifcase\NAT@ctype
%         \if\relax\NAT@date\relax
%           \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}\NAT@date}%
%         \else
%           \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
%               \ifx\NAT@last@yr\NAT@year
%                 \def\NAT@temp{{?}}%
%                 \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
%                 {Multiple citation on page \thepage: same authors and
%                 year\MessageBreak without distinguishing extra
%                 letter,\MessageBreak appears as question mark}\fi
%                 \NAT@hyper@{\NAT@exlab}%
%               \else\unskip\NAT@spacechar
%                 \NAT@hyper@{\NAT@date}%
%               \fi
%           \else
%             \@citea\NAT@hyper@{%
%               \NAT@nmfmt{\NAT@nm}%
%               \hyper@natlinkbreak{%
%                 \NAT@aysep\NAT@spacechar}{\@citeb\@extra@b@citeb
%               }%
%               \NAT@date
%             }%
%           \fi
%         \fi
%       \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
%       \or\@citea\NAT@hyper@{\NAT@date}%
%       \or\@citea\NAT@hyper@{\NAT@alias}%
%       \fi \NAT@def@citea
%       \else
%         \ifcase\NAT@ctype
%           \if\relax\NAT@date\relax
%             \@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
%           \else
%           \ifx\NAT@last@nm\NAT@nm\NAT@yrsep
%               \ifx\NAT@last@yr\NAT@year
%                 \def\NAT@temp{{?}}%
%                 \ifx\NAT@temp\NAT@exlab\PackageWarningNoLine{natbib}%
%                 {Multiple citation on page \thepage: same authors and
%                 year\MessageBreak without distinguishing extra
%                 letter,\MessageBreak appears as question mark}\fi
%                 \NAT@hyper@{\NAT@exlab}%
%               \else
%                 \unskip\NAT@spacechar
%                 \NAT@hyper@{\NAT@date}%
%               \fi
%           \else
%             \@citea\NAT@hyper@{%
%               \NAT@nmfmt{\NAT@nm}%
%               \hyper@natlinkbreak{\NAT@spacechar\NAT@@open\if*#1*\else#1\NAT@spacechar\fi}%
%                 {\@citeb\@extra@b@citeb}%
%               \NAT@date
%             }%
%           \fi
%           \fi
%         \or\@citea\NAT@hyper@{\NAT@nmfmt{\NAT@nm}}%
%         \or\@citea\NAT@hyper@{\NAT@date}%
%         \or\@citea\NAT@hyper@{\NAT@alias}%
%         \fi
%         \if\relax\NAT@date\relax
%           \NAT@def@citea
%         \else
%           \NAT@def@citea@close
%         \fi
%       \fi
%       }}\ifNAT@swa\else
%         % 将 author-year 式 \cs{citet} 引用的页码置于括号外并改为上标。
%         %
%         % \if*#2*\else\NAT@cmt#2\fi
%         \if\relax\NAT@date\relax\else\NAT@@close\fi
%         \if*#2*\else\textsuperscript{#2}\fi
%       \fi}{#1}{#2}}
  %
  % 为了将参考文献加入目录和 pdf 书签，重新定义 \pkg{natbib} 的 \cmd{bibsection}
  % 另外如果调用了 \pkg{chapterbib} 或者使用了 \opt{sectionbib} 参数，
  % 需要使用节标题 \cs{section}。
  \newcommand\ash@bib@chapter{%
    \@mainmatterfalse
    \chapter{\bibname}%
  }%
  \newcommand\ash@bib@section{%
    \begingroup
      \ctexset{section/numbering=false}%
      \section{\bibname}%
    \endgroup
  }%
  \@ifpackagewith{chapterbib}{sectionbib}{%
    \ash@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
  }{}%
  \@ifpackageloaded{chapterbib}{%
    \let\bibsection\ash@bib@section
  }{%
    \@ifxundefined\NAT@sectionbib{%
      \let\bibsection\ash@bib@chapter
    }{%
      \let\bibsection\ash@bib@section
    }%
  }%
  %
  % 参考文献列表格式：宋体 10.5 磅，行距 20 磅，续行缩进两字，左对齐。
  % 本科生依然是小四宋体。
  \renewcommand\bibfont{%
    \ifash@degree@graduate
      \fontsize{10.5bp}{20bp}\selectfont
    \else
      \normalsize
    \fi
  }
  \setlength{\bibsep}{0\p@ \@plus.2\p@}
  \renewcommand\@biblabel[1]{[#1]\hfill}
  \setlength{\bibhang}{2em}
}


% biblatex 宏包的配置

\AtEndOfPackageFile*{biblatex}{
  \DeclareRobustCommand\inlinecite{\parencite}
  \defbibheading{bibliography}[\bibname]{%
    \@mainmatterfalse
    \chapter{\bibname}%
  }
  \renewcommand\bibfont{%
    \ifash@degree@graduate
      \fontsize{10.5bp}{20bp}\selectfont
    \else
      \normalsize
    \fi
  }
  \setlength{\bibitemsep}{0\p@ \@plus.2\p@}
  \setlength{\bibhang}{2em}
}

% \subsection{附录}

% 定义了一个满足要求的致谢环境：
\newenvironment{acknowledgements}{%
  \@mainmatterfalse
  \chapter{\ash@acknowledgements@name}%
}{
  \ifash@degree@bachelor
    \par
    \null\par
    \begingroup
      \raggedleft
      \ash@date@zh@short\par
    \endgroup
  \fi
}

% 结论环境：
\newenvironment{conclusion}{%
  \@mainmatterfalse
  \chapter{\ash@conclusion@name}%
}{
  \ifash@degree@bachelor
    \par
    \null\par
    \begingroup
      \raggedleft
      \ash@date@zh@short\par
    \endgroup
  \fi
}


% 兼容旧版本中“acknowledgments”的拼法。
% Reserved for compatibility until 2020-07-01.
\newenvironment{acknowledgments}{%
  \begin{acknowledgements}%
}{%
  \end{acknowledgements}%
}

% \newenvironment{conclusion}{%
% \begin{conclusion}%
%   }{%
%   \end{conclusion}%
% }

% 科研成果环境：
\newenvironment{achievements}{%
  \@mainmatterfalse
  \chapter{\ash@achievements@name}%
}{}


% 兼容旧的接口
\newenvironment{publications}{%
  \ash@deprecated{'publications' environment}{2024-12-15}{'achievements'}%
  \@mainmatterfalse
  \chapter{\ash@achievements@name}%
}{}


% \subsection{其他宏包的设置}

% 这些宏包并非格式要求，但是为了方便同学们使用，在这里进行简单设置。


% \subsubsection{\pkg{hyperref} 宏包}

\AtEndOfPackageFile*{hyperref}{
  \hypersetup{
    bookmarksnumbered  = true,
    bookmarksopen      = true,
    bookmarksopenlevel = 1,
    linktoc            = all,
    unicode            = true,
    psdextra           = true,
  }
  %
  % 如果为 \opt{pdf} 样式，设置 hyperlink 颜色
  \ifash@output@electronic
    \hypersetup{
      colorlinks = true,
      allcolors  = blue,
    }
  \else
    \hypersetup{hidelinks}
  \fi
  %
  % 填写 PDF 元信息。
  \AtBeginDocument{%
    \ifash@main@language@chinese
      \hypersetup{
        pdftitle  = \ash@title,
        pdfauthor = \ash@author,
      }%
    \else
      \hypersetup{
        pdftitle  = \ash@title@en,
        pdfauthor = \ash@author@en,
      }%
    \fi
  }
  %
  % 添加 PDF 书签
  %
  \newcounter{ash@bookmarknumber}
  \renewcommand\ash@pdfbookmark[1]{%
    \phantomsection
    \stepcounter{ash@bookmarknumber}%
    \pdfbookmark[0]{#1}{ashchapter.\theash@bookmarknumber}%
  }
  %
  % 在 PDF 字符串中去掉换行，以减少 \pkg{hyperref} 的警告信息。
  \pdfstringdefDisableCommands{
    \let\\\@empty
    \let\hspace\@gobble
  }
  %
  % \pkg{hyperref} 与 \pkg{unicode-math} 存在一些兼容性问题，见
  % \href{https://github.com/ashtug/bigash/issues/223}{%
  %   ashtug/bigash\#223}，
  % \href{https://github.com/ho-tex/hyperref/pull/90}{ho-tex/hyperref\#90} 和
  % \href{https://github.com/ashtug/bigash/issues/235}{%
  %   ashtug/bigash/\#235}。
  \@ifpackagelater{hyperref}{2019/04/27}{}{%
    \g@addto@macro\psdmapshortnames{\let\mu\textmu}%
  }
  %
  % 设置中文的 \cs{autoref}。
  % \footnote{\url{https://tex.stackexchange.com/a/66150/82731}}
  \ifash@language@chinese
    \def\equationautorefname~#1\null{公式~(#1)\null}
    \def\footnoteautorefname{脚注}
    \def\itemautorefname~#1\null{第~#1~项\null}
    \def\figureautorefname{图}
    \def\tableautorefname{表}
    \def\partautorefname~#1\null{第~#1~部分\null}
    \def\appendixautorefname{附录}
    \def\chapterautorefname~#1\null{第~#1~章\null}
    \def\sectionautorefname~#1\null{第~#1~节\null}
    \def\subsectionautorefname~#1\null{第~#1~小节\null}
    \def\subsubsectionautorefname~#1\null{第~#1~小小节\null}
    \def\paragraphautorefname~#1\null{第~#1~段\null}
    \def\subparagraphautorefname~#1\null{第~#1~小段\null}
    \def\theoremautorefname{定理}
    \def\HyRef@autopageref#1{\hyperref[{#1}]{第~\pageref*{#1} 页}}
  \fi
  %
  % 本科生需要在 \tableofcontents 处切换 \pagenumbering，
  % 在使用了 notoccite 后会导致 PDF 书签的页码有误（#293），
  % 所以需要补充 https://tex.stackexchange.com/a/593839/82731 的 patch。
  % LuaTeX 不需要这个 patch。
  \ifXeTeX
    \def\HyPL@StorePageLabel#1{%
      \begingroup
        \edef\Hy@tempa{\the\Hy@abspage<<#1>>}%
        \immediate\write\@mainaux{%
          \string\HyPL@Entry{\Hy@tempa}%
        }%
      \endgroup
    }
  \fi
}


% \subsubsection{\pkg{amsthm} 宏包}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{ashplain}
    {}{}
    {}{2em}
    {\bfseries}{}
    {1em}{}
  \theoremstyle{ashplain}
  % 定义新的定理
  \ifash@language@chinese
    \newcommand\ash@assertion@name{断言}
    \newcommand\ash@assumption@name{假设}
    \newcommand\ash@axiom@name{公理}
    \newcommand\ash@corollary@name{推论}
    \newcommand\ash@definition@name{定义}
    \newcommand\ash@example@name{例}
    \newcommand\ash@lemma@name{引理}
    \newcommand\ash@proof@name{证明}
    \newcommand\ash@proposition@name{命题}
    \newcommand\ash@remark@name{注}
    \newcommand\ash@theorem@name{定理}
  \else
    \newcommand\ash@assertion@name{Assertion}
    \newcommand\ash@assumption@name{Assumption}
    \newcommand\ash@axiom@name{Axiom}
    \newcommand\ash@corollary@name{Corollary}
    \newcommand\ash@definition@name{Definition}
    \newcommand\ash@example@name{Example}
    \newcommand\ash@lemma@name{Lemma}
    \newcommand\ash@proof@name{Proof}
    \newcommand\ash@proposition@name{Proposition}
    \newcommand\ash@remark@name{Remark}
    \newcommand\ash@theorem@name{Theorem}
  \fi
  \newtheorem{theorem}             {\ash@theorem@name}    [chapter]
  \newtheorem{assertion}  [theorem]{\ash@assertion@name}
  \newtheorem{axiom}      [theorem]{\ash@axiom@name}
  \newtheorem{corollary}  [theorem]{\ash@corollary@name}
  \newtheorem{lemma}      [theorem]{\ash@lemma@name}
  \newtheorem{proposition}[theorem]{\ash@proposition@name}
  \newtheorem{assumption}          {\ash@assumption@name} [chapter]
  \newtheorem{definition}          {\ash@definition@name} [chapter]
  \newtheorem{example}             {\ash@example@name}    [chapter]
  \newtheorem*{remark}             {\ash@remark@name}
  % \pkg{amsthm} 单独定义了 proof 环境，这里重新定义以满足格式要求。
  % 原本模仿 \pkg{amsthm} 写成 |\item[\hskip\labelsep\hskip2em #1\hskip1em]|，
  % 但是却会多出一些间隙。
  \renewenvironment{proof}[1][\ash@proof@name]{\par
    \pushQED{\qed}%
    \normalfont \topsep6\p@\@plus6\p@\relax
    \trivlist
      \item\relax\hskip2em\relax
      \textbf{#1}
      \hskip1em\ignorespaces
    }{%
    \popQED\endtrivlist\@endpefalse
  }
  \renewcommand\qedsymbol{\ash@qed}
}


% \subsubsection{\pkg{algorithm2e} 宏包}
% 输出后的直线定义
\newcommand{\algline}{%
  \par
  \vspace{2pt}
  \nointerlineskip
  \moveleft\algomargin\vbox{\hrule height 0.8pt width \columnwidth}
  \vspace{-1pt}
  % \nointerlineskip
}

% 按章节编号。
\PassOptionsToPackage{algochapter}{algorithm2e}

\AtEndOfPackageFile*{algorithm2e}{
  \ifash@language@chinese
    \SetAlgorithmName{算法}{算法}{算法清单}
    \SetKwInOut{KwIn}{输入}
    \SetKwInOut{KwOut}{输出}
  \else
    \SetAlgorithmName{Algorithm}{Algorithm}{List of Algorithms}
  \fi
  %
  % 设置算法环境的格式。
  \SetAlCapSkip{6bp}
  \SetAlCapFnt{\small}
  \SetAlCapNameFnt{\small}
  \ifash@degree@graduate
    \SetAlCapNameSty{textbf}
  \fi
  \SetAlgoCaptionSeparator{\unskip\hspace*{1em}}
  %
  % 设置算法清单的格式
  \renewcommand\listofalgocfs{%
    \ifash@degree@graduate
      \cleardoublepage
    \fi
    \ash@chapter{\listalgorithmcfname}%
    \@starttoc{loa}%
  }
  \titlecontents{algocf}
    [2.3em]{\normalsize}
    {\contentslabel{2.3em}}{}
    {\ash@leaders\contentspage}
  \contentsuse{algocf}{loa}
}


% \subsubsection{\pkg{mathtools} 宏包}

% \pkg{mathtools} 会修改 \pkg{unicode-math} 的 `\underbrace` 和 `\overbrace`，
% 需要还原为 `\LaTeXunderbrace` 和 `\LaTeXoverbrace`，
% 参考 \url{https://tex.stackexchange.com/q/521394/82731}。
\AtEndOfPackageFile*{mathtools}{
  \@ifpackageloaded{unicode-math}{
    \let\underbrace\LaTeXunderbrace
    \let\overbrace\LaTeXoverbrace
  }{}
}

% \subsubsection{\pkg{nomencl} 宏包}

\AtEndOfPackageFile*{nomencl}{
  \let\nomname\ash@notation@name
  \def\thenomenclature{%
    \ifash@degree@graduate
      \cleardoublepage
      \pagestyle{headings}%
    \fi
    \ash@chapter{\ash@notation@name}%
    \nompreamble
    \list{}{%
      \labelwidth\nom@tempdim
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemsep\nomitemsep
      \let\makelabel\nomlabel}}
  \def\endthenomenclature{%
    \endlist
    \nompostamble
    \ifash@degree@graduate
      \clearpage
      \pagestyle{plain}%
    \fi
  }
}


% \subsubsection{\pkg{siunitx} 宏包}

\AtEndOfPackageFile*{siunitx}{
  \newcommand\ash@set@siunitx@language{%
    \ifash@language@chinese
      \sisetup{
        list-final-separator = { 和~},
        list-pair-separator  = { 和 },
        range-phrase         = {～},
      }%
    \else
      \sisetup{
        list-final-separator = {, and },
        list-pair-separator  = { and },
        range-phrase         = { to },
      }%
    \fi
  }
  \ash@set@siunitx@language
  \ash@option@hook{language}{\ash@set@siunitx@language}
}

% \subsubsection{\pkg{chapterbib} 宏包}

\AtEndOfPackageFile*{chapterbib}{
  \@ifpackageloaded{natbib}{%
    \@ifpackagewith{chapterbib}{sectionbib}{%
      \ash@error{The "sectionbib" option cannot be used with chaperbib if natbib loaded}%
    }{}%
    \renewcommand\bibsection{%
      \begingroup
        \ctexset{section/numbering=false}%
        \section{\bibname}%
      \endgroup
    }
  }{}
}
