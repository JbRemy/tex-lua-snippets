
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local l = require("luasnip.extras").lambda

-- A function to visually selct
local get_visual = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else  -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

-- Some LaTeX-specific conditional expansion functions (requires VimTeX)

local tex_utils = {}
tex_utils.in_mathzone = function()  -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function()  -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end
tex_utils.in_env = function(name)  -- generic environment detection
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function()  -- equation environment detection
    return tex_utils.in_env('equation')
end
tex_utils.in_itemize = function()  -- itemize environment detection
    return tex_utils.in_env('itemize')
end
tex_utils.in_hlist = function()  -- itemize environment detection
    return tex_utils.in_hlist('hlist')
end
tex_utils.in_tikz = function()  -- TikZ picture environment detection
    return tex_utils.in_env('tikzpicture')
end

return {

  --------------------------------------------------------------
  -- text formating
  --
  s({trig = "([^%a])tit", wordTrig=false, regTrig=true, dscr = "Expands 'tit' into LaTeX's textit{} command.", snippetType="autosnippet"},
  fmta("<>\\textit{<>}",
    {
      f( function(_, snip) return snip.captures[1] end ),
      d(1, get_visual),
    }
  )
  ),

  s({trig = "tbf", dscr = "Expands 'tbf' into LaTeX's textbf{} command.", snippetType="autosnippet"},
  fmta("\\textbf{<>}",
    {
      d(1, get_visual),
    }
  )
  ),

  s({trig = "underline", dscr = "Expands into underline"},
  fmta("\\underline{<>}",
    {
      d(1, get_visual),
    }
  )
  ),

  --------------------------------------------------------------
  -- Sections
  --
  s(
    {trig="sec", dscr="Section"},
    fmta(
      [[
        \section{<>}
        \label{sec:<>}
        <>
      ]],
      {i(1),l(l._1:gsub(" ","_"), 1),i(2)}
    )
  ),

  s(
    {trig="ssec", dscr="Sub section"},
    fmta(
      [[
        \subsection{<>}
        \label{sec:<>}
        <>
      ]],
      {i(1),l(l._1:gsub(" ","_"), 1),i(2)}
    )
  ),

  --------------------------------------------------------------
  -- Envs
  --
  s(
    {trig="begin", dscr="Begins env"},
    fmta(
      [[
        \begin{<>}
          <>
        \end{<>}
      ]],
      {i(1),i(2),rep(1)}
    )
  ),

  s(
    {trig="eq", dscr="Unnumberd equation"},
    fmta(
      [[
        \begin{equation*}
          <>
        \end{equation*}
      ]],
      {i(1)}
    )
  ),
  s(
    {trig="eqtag", dscr="Equation with tag"},
    fmta(
      [[
        \begin{equation*}
          \tag{$<>$}
          \label{<>}
          <>
        \end{equation*}
      ]],
      {i(1),rep(1),i(2)}
    )
  ),

  s(
    {trig="align", dscr="Expands into an align* env"},
    fmta(
      [[
        \begin{align*}
          <>
        \end{align*}
      ]],
      {i(1)}
    )
  ),

  s(
    {trig="hlist", dscr="Expands into an hlist"},
    fmta(
      [[
        \begin{hlist}[<>]<>
          \hitem <>
        \end{hlist}
      ]],
      {i(1), i(2), i(3)}
    )
  ),

  s(
    {trig="shlist", dscr="Expands into an subhlist"},
    fmta(
      [[
        \begin{hlist}[label=\alpha{hlistii}]<>
          \setcounter{hlistii}{0}
          \hitem <>
        \end{hlist}
      ]],
      {i(1), i(2)}
    )
  ),

  s(
    {trig = '([%s])ht', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>\\hitem "
      ,
      {f( function(_, snip) return snip.captures[1] end ),}
    )
  ),

  s(
    {trig="Def", dscr="Expands into the Definition env"},
    fmta(
      [[
        \begin{Definition}[<>]
          <>
        \end{Definition}
      ]],
      {i(1), i(2)}
    )
  ),

  s(
    {trig="Prop", dscr="Expands into the Propriété env"},
    fmta(
      [[
        \begin{Propriete}[<>]
          <>
        \end{Propriete}
      ]],
      {i(1), i(2)}
    )
  ),

  s(
    {trig="Theo", dscr="Expands into the Theoreme env"},
    fmta(
      [[
        \begin{Theoreme}[<>]
          <>
        \end{Theoreme}
      ]],
      {i(1), i(2)}
    )
  ),

  s(
    {trig="Cor", dscr="Expands into the Corolaire env"},
    fmta(
      [[
        \begin{Corolaire}[<>]
          <>
        \end{Corolaire}
      ]],
      {i(1), i(2)}
    )
  ),

  s(
    {trig="Aver", dscr="Expands into the Avertissement env"},
    fmta(
      [[
        \begin{Avertissement}
          <>
        \end{Avertissement}
      ]],
      {i(1)}
    )
  ),

  s(
    {trig="Ex", dscr="Expands into the Exemple env"},
    fmta(
      [[
        \begin{Exemple}
          <>
        \end{Exemple}
      ]],
      {i(1)}
    )
  ),

  s(
    {trig="Rq", dscr="Expands into the Remarque env"},
    fmta(
      [[
        \begin{Remarque}
          <>
        \end{Remarque}
      ]],
      {i(1)}
    )
  ),

  s(
    {trig="Exo", dscr="Expands into the Exercice env"},
    fmta(
      [[
        \begin{Exercice}
          <>
        \end{Exercice}
      ]],
      {i(1)}
    )
  ),

  s(
    {trig="Voc", dscr="Expands into the Vocabulaire env"},
    fmta(
      [[
        \begin{Vocabulaire}
          <>
        \end{Vocabulaire}
      ]],
      {i(1)}
    )
  ),

  --------------------------------------------------------------
  --- Adding parenthesis
  s({trig = "prs", snippetType="autosnippet", dscr = "expands into a parenthesis"},
  fmta("(<>)",
    {
      d(1, get_visual),
    }
  )
  ),

  s({trig = "lprs", snippetType="autosnippet", dscr = "expands into a parenthesis"},
  fmta("\\left(<>\\right)",
    {
      d(1, get_visual),
    }
  ),
    {condition = tex_utils.in_mathzone}
  ),

  s({trig = "brks", snippetType="autosnippet", dscr = "expands into a brakets"},
  fmta("\\[<>\\]",
    {
      d(1, get_visual),
    }
  )
  ),

  s({trig = "lbrks", snippetType="autosnippet", dscr = "expands into a brakets"},
  fmta("\\left\\[<>\\right\\]",
    {
      d(1, get_visual),
    }
  ),
    {condition = tex_utils.in_mathzone}
  ),

  s({trig = "brcs", snippetType="autosnippet", dscr = "expands into a brakets"},
  fmta("\\{<>\\}",
    {
      d(1, get_visual),
    }
  )
  ),

  s({trig = "lbrcs", snippetType="autosnippet", dscr = "expands into a brakets"},
  fmta("\\left\\{<>\\right\\}",
    {
      d(1, get_visual),
    }
  ),
    {condition = tex_utils.in_mathzone}
  ),

  --------------------------------------------------------------
  -- Maths
  --
  -- Enter math mode
  s({trig = "([^%a])mm", wordTrig = false, regTrig = true,
    snippetType="autosnippet"},
    fmta(
      "<>$ <> $",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    )
  ),
  s({trig = "([^%a])dmm", wordTrig = false, regTrig = true,
    snippetType="autosnippet"},
    fmta(
      "<>$\\displaystyle <> $",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    )
  ),
  s(
    {trig="trm", dscr="textrm", snippetType="autosnippet"},
    fmta(
      "\\textrm{ <> } ",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="abs", dscr="Valeur absolue", snippetType="autosnippet"},
    fmta(
      "\\norml{<>}",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="([^%a])congru", regTrig=true, wordTrig=false, dscr="Congruence", snippetType="autosnippet"},
    fmta(
      "<>\\equiv ",
      {
        f( function(_, snip) return snip.captures[1] end )
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])equiv", regTrig=true, wordTrig=false, dscr="Equivalence", snippetType="autosnippet"},
    fmta(
      "<>\\Leftrightarrow ",
      {
        f( function(_, snip) return snip.captures[1] end )
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),


  s(
    {trig="circ", dscr="composition round", snippetType="autosnippet"},
    fmta(
      "\\circ ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="exi", dscr="exists", snippetType="autosnippet"},
    fmta(
      "\\exists ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="ff", dscr="fractions", snippetType="autosnippet"},
    fmta(
      "\\frac{<>}{<>}",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="fall", dscr="forall", snippetType="autosnippet"},
    fmta(
      "\\forall ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="geq", dscr="Greater or equa", snippetType="autosnippet"},
    fmta(
      "\\geq ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="sff", dscr="inline fractions", snippetType="autosnippet"},
    fmta(
      "\\sfrac{<>}{<>}",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])in", regTrig=true, wordTrig=false, dscr="Appartient", snippetType="autosnippet"},
    fmta(
      "<>\\in ",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])imp", regTrig=true, wordTrig=false, dscr="Implication", snippetType="autosnippet"},
    fmta(
      "<>\\Rightarrow ",
      {
        f( function(_, snip) return snip.captures[1] end )
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="Inf", dscr="integrale", snippetType="autosnippet"},
    fmta(
      "\\infty",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="Int", dscr="integrale", snippetType="autosnippet"},
    fmta(
      "\\int_{<>}^{<>}",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])ocint", regTrig=true, wordTrig=false, dscr="Intervalle ouvert fermé", snippetType="autosnippet"},
    fmta(
      "<>\\left]<>;<>\\right]",
      {f( function(_, snip) return snip.captures[1] end ), i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="([^%a])coint", regTrig=true, wordTrig=false, dscr="Intervalle fermé ouvert", snippetType="autosnippet"},
    fmta(
      "<>\\left[<>;<>\\right[",
      {f( function(_, snip) return snip.captures[1] end ), i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="([^%a])ooint", regTrig=true, wordTrig=false, dscr="Intervalle ouvert", snippetType="autosnippet"},
    fmta(
      "<>\\left]<>;<>\\right[",
      {f( function(_, snip) return snip.captures[1] end ), i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="([^%a])ccint", regTrig=true, wordTrig=false, dscr="Intervalle fermé", snippetType="autosnippet"},
    fmta(
      "<>\\left[<>;<>\\right]",
      {f( function(_, snip) return snip.captures[1] end ), i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="leq", dscr="Lower or equal", snippetType="autosnippet"},
    fmta(
      "\\leq ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="leq", dscr="Lower or equal", snippetType="autosnippet"},
    fmta(
      "\\leq ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])limit", regTrig=true, wordTrig=false, dscr="Limite", snippetType="autosnippet"},
    fmta(
      "<>\\lim_{<> \\to <>} ",
      {f( function(_, snip) return snip.captures[1] end ), i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="norm", dscr="Norme (double)", snippetType="autosnippet"},
    fmta(
      "\\normll{<>}",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])mto", regTrig=true, wordTrig=false, dscr="mapsto", snippetType="autosnippet"},
    fmta(
      "<>\\mapsto ",
      {f( function(_, snip) return snip.captures[1] end )}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])neq", regTrig=true, wordTrig=false, dscr="Non equal", snippetType="autosnippet"},
    fmta(
      "<>\\neq ",
      {f( function(_, snip) return snip.captures[1] end )}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="norml", dscr="Norme triple", snippetType="autosnippet"},
    fmta(
      "\\normlll{<>}",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),


  s(
    {trig="([^%a])qq", wordTrig=false, regTrig=true, snippetType="autosnippet"
    , dscr="quad in mathmode"},
    fmta(
      "<>\\quad ",
      {f( function(_, snip) return snip.captures[1] end )}
    ),
    {condition=tex_utils.in_mathzone}
  ),

  s(
    {trig="subset", dscr="subset", snippetType="autosnippet"},
    fmta(
      "\\subset ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="sqrt", dscr="Square root", snippetType="autosnippet"},
    fmta(
      "\\sqrt{<>}",
      {i(1),}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="nsqrt", dscr="Nieme Square root", snippetType="autosnippet"},
    fmta(
      "\\sqrt[<>]{<>}",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="Sum", dscr="Somme de termes", snippetType="autosnippet"},
    fmta(
      "\\sum_{<>}^{<>}",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])vec", wordTrig=false, regTrig=true, snippetType="autosnippet"
    , dscr="Vector line over variable"},
    fmta(
      "<>\\vec{<>}",
      {f( function(_, snip) return snip.captures[1] end ), i(1)}
    ),
    {condition=tex_utils.in_mathzone}
  ),

  s(
    {trig="xx", dscr="Times (cross) sign", snippetType="autosnippet"},
    fmta(
      "\\times ",
      {}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s({trig = '%_%_', regTrig = true, wordTrig = false, snippetType="autosnippet", dscr="subscript"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1)
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s({trig = '%-%-', regTrig = true, wordTrig = false, snippetType="autosnippet", dscr="superscripts"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1)
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),
  ----------------------------------------------------------
  -- Fonctions
  --
  s(
    {trig="atan", dscr="tan", snippetType="autosnippet"},
    fmta(
      "\\arctan(<>)",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="cos", dscr="cosinus", snippetType="autosnippet"},
    fmta(
      "\\cos(<>)",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="pcos", dscr="cosinus exponsant", snippetType="autosnippet"},
    fmta(
      "\\cos^{<>}(<>)",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="exp", dscr="exponentielle", snippetType="autosnippet"},
    fmta(
      "\\exp(<>)",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="ln", dscr="Log neperien", snippetType="autosnippet"},
    fmta(
      "\\ln(<>)",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),


  s(
    {trig="sin", dscr="sin", snippetType="autosnippet"},
    fmta(
      "\\sin(<>)",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="psin", dscr="sin exposant", snippetType="autosnippet"},
    fmta(
      "\\sin^{<>}(<>)",
      {i(1),i(2)}
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="tan", dscr="tan", snippetType="autosnippet"},
    fmta(
      "\\tan(<>)",
      {i(1)}
    ),
    {condition = tex_utils.in_mathzone}
  ),




  ----------------------------------------------------------
  -- Ensembles
  --
  s(
    {trig="([^%a])RR", regTrig=true, wordTrig=false, dscr="Real numbers", snippetType="autosnippet"},
    fmta(
      "<>\\R",
      {
        f( function(_, snip) return snip.captures[1] end )
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="Rp", dscr="Positive Real numbers", snippetType="autosnippet"},
    fmta(
      "\\R_+",
      { }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="Rm", dscr="Negative Real numbers", snippetType="autosnippet"},
    fmta(
      "\\R_-",
      { }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="Re", dscr="Non null Real numbers", snippetType="autosnippet"},
    fmta(
      "\\R^*",
      { }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="eRp", regTrig=false, dscr="Strictly Positive Real numbers", snippetType="autosnippet"},
    fmta(
      "\\R_+^*",
      { }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])NN", regTrig=true, wordTrig=false, dscr="Natural  numbers", snippetType="autosnippet"},
    fmta(
      "<>\\N",
      {
        f( function(_, snip) return snip.captures[1] end )
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),
  
  s(
    {trig="([%s])ZZ", regTrig=true, wordTrig=false, dscr="Relative  numbers", snippetType="autosnippet"},
    fmta(
      "<>\\Z",
      {
        f( function(_, snip) return snip.captures[1] end )
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),
  -------------------------------------------------------------------------
  -- Fonctions
  --
  
  s(
  {
      trig="func", dscr="Définition d'une fonction"
    },
    fmta(
      "\\fonction{<>}{<>}{<>}{<>}{<>}"
    ,
    {
      i(1,"Nom"),i(2,"Départ"),i(3,"Arrivée"),i(4,"Variable"),i(5,"Image"),
    }),
    {condition=tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])Deriv", regTrig=true, wordTrig=false, dscr="Fonctions dérivables", snippetType="autosnippet"},
    fmta(
      "<>\\Derivable(<>,<>)",
      {
        f( function(_, snip) return snip.captures[1] end ), i(1), i(2)
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  


  
  -------------------------------------------------------------------------
  -- Constantes

  s(
    {trig="([^%a])ee", regTrig = true, wordTrig = false, dscr="exponentielle", snippetType="autosnippet"},
    fmta(
      "<>\\e^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1)
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="([^%a])Pi", regTrig = true, wordTrig = false, dscr="Nombre Pi", snippetType="autosnippet"},
    fmta(
      "<>\\pi",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),


  s(
    {trig="([^%a])alp", regTrig=true, wordTrig=false, dscr="alpha", snippetType="autosnippet"},
    fmta(
      "<>\\alpha",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])bet", regTrig=true, wordTrig=false, dscr="beta", snippetType="autosnippet"},
    fmta(
      "<>\\beta",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])delta", regTrig=true, wordTrig=false, dscr="delta", snippetType="autosnippet"},
    fmta(
      "<>\\delta",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),
  s(
    {trig="([^%a])Delta", regTrig=true, worDTrig=false, dscr="delta", snippetType="autosnippet"},
    fmta(
      "<>\\Delta",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])lam", regTrig=true, wordTrig=false, dscr="lambda", snippetType="autosnippet"},
    fmta(
      "<>\\lambda",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),


  s(
    {trig="([^%a])eps", regTrig=true, wordTrig=false, dscr="epsilon", snippetType="autosnippet"},
    fmta(
      "<>\\epsilon",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])gamma", regTrig=true, wordTrig=false, dscr="gamma", snippetType="autosnippet"},
    fmta(
      "<>\\gamma",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])Gamma", regTrig=true, wordTrig=false, dscr="Gamma", snippetType="autosnippet"},
    fmta(
      "<>\\Gamma",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  s(
    {trig="([^%a])theta", regTrig=true, wordTrig=false, dscr="theta", snippetType="autosnippet"},
    fmta(
      "<>\\theta",
      {
        f( function(_, snip) return snip.captures[1] end ),
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  -------------------------------------------------------------------------------
  -- Mathfonts
  --
  s(
    {trig="([^%a])scr", regTrig=true, dscr="expands into mathscr", snippetType="autosnippet"},
    fmta(
      "<>\\mathscr{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1)
      }
    ),
    {condition = tex_utils.in_mathzone}
  ),

  -------------------------------------------------------------------------------
  -- TikZ
  --
  s({trig = "dd"},
    fmta(
      "\\draw [<>] ",
      {
        i(1),
      }
    ),
    { condition = tex_utils.in_tikz }
  ),

  s({trig="graph"},
    fmta(
      [[ 
      \begin{tikzpicture}[scale=1]
        \begin{axis}[axis lines=middle,
          xmin=<>, xmax=<>,
          ymin=<>, ymax=<>, ticks=none ,
          trig format plots=rad,
          restrict y to domain=<>:<>]

          \addplot[thick, smooth, samples=1000, domain=<>:<>]
                {<>} ;
        \end{axis}
      \end{tikzpicture}
      ]],
      {i(1), i(2), i(3), i(4), rep(3),rep(4),rep(1), rep(2), i(5, "f(x)")}
    )
  ),

  s({trig="axnode", dscr="A node in an axis env"},
    fmta(
      "\\node[label=<>] (<>) at (axis cs: <>,<>){};",
      {i(1, "label"),i(2, "name"),i(3), i(4)}
    ),
    { condition = tex_utils.in_tikz }
  )
}

