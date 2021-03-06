## See the file 'themedesc.nim' to see what is theme-able (everything).
import themedesc

# "" means to take the nimsuggest that the installer provided. You can also
# use "$path" to make NimEdit use a nimsuggest.exe that is in your path.
theme.nimsuggestPath = r""

const
  White = 0xffffff
  Orange = 0xFFA500
  Blue = 0x00FFFF
  Red = 0xFF0000
  Yellow = 0xFFFF00
  Pink = 0xFF00FF
  Gray = 0x808080
  Green = 0x44FF44
  Deeppink = 0xFF1493

theme.editorFont = when defined(linux): "dejavu/DejaVuSansMono"
                   else: "DejaVuSansMono"
theme.editorFontSize = 15

theme.uiFont = when defined(linux): "freefont/FreeSans" else: "Arial"
theme.uiFontSize = 12
theme.uiXGap = 5
theme.uiYGap = 5

theme.uiActiveElement = 0xFFA500
theme.uiInactiveElement = 0xC0C0C0
theme.background = 0x292929
const foreground = 0xfafafa
theme.foreground = foreground
theme.cursor = foreground
theme.lines = 0x898989

theme.selected = 0x00 # 0x1d1d1d
theme.highlighted = 0x440000
theme.showLines = true
theme.showIndentation = true
theme.indentation = theme.lines
theme.cursorWidth = 2
# Note: This is the default tab width used when the tabsize could not be
# detected.
theme.tabWidth = 2

theme.showBracket = true
theme.showMinimap = true
theme.bracket = Deeppink

# If the width of the window exceeds this value, a console is activated.
# Use -1 to disable it completely:
theme.consoleAfter = 900
# 'consoleWidth's value is in % of the Window width:
theme.consoleWidth = 40

template ss(key, val; style = FontStyle.Normal) =
  tokens[TokenClass.key] = (val, style)

ss None, White
ss Whitespace, White
ss DecNumber, Blue
ss BinNumber, Blue
ss HexNumber, Blue
ss OctNumber, Blue
ss FloatNumber, Blue
ss Identifier, White
ss Keyword, Yellow
ss StringLit, Orange
ss LongStringLit, Orange
ss CharLit, Orange
ss Backticks, Orange
ss EscapeSequence, Gray
ss Operator, White
ss Punctuation, White
ss Comment, Green, FontStyle.Italic
ss LongComment, DeepPink
ss RegularExpression, Pink
ss TagStart, Yellow
ss TagStandalone, Yellow
ss TagEnd, Yellow
ss Key, 0xff44ff
ss Value, Blue
ss RawData, Pink
ss Assembler, Pink
ss Preprocessor, Yellow
ss Directive, Yellow
ss Command, Yellow
ss Rule, Yellow
ss Link, Blue, FontStyle.Bold
ss Label, Blue
ss Reference, Blue
ss Text, White
ss Other, White
ss Red, Red
ss Green, Green
ss Yellow, Yellow

ss Breakpoint1, Red
ss Breakpoint2, Orange
ss LineActive, Yellow
