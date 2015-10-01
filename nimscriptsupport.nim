
import
  compiler/ast, compiler/modules, compiler/passes, compiler/passaux,
  compiler/condsyms, compiler/options, compiler/sem, compiler/semdata,
  compiler/llstream, compiler/vm, compiler/vmdef, compiler/commands,
  compiler/msgs, compiler/magicsys, compiler/lists, compiler/idents,
  compiler/astalgo

from compiler/scriptconfig import setupVM

import os, strutils
import themes, styles, common

proc raiseVariableError(ident, typ: string) {.noinline.} =
  raise newException(ValueError,
    "NimScript's variable '" & ident & "' needs a value of type '" & typ & "'.")

proc isStrLit(n: PNode): bool = n.kind in {nkStrLit..nkTripleStrLit}
proc isIntLit(n: PNode): bool = n.kind in {nkCharLit..nkUInt64Lit}

proc getIdent(n: PNode): int =
  if n.kind == nkIdent: n.ident.id
  elif n.kind == nkSym: n.sym.name.id
  else: -1

var
  actionsModule: PSym

proc getAction(x: string): PSym = strTableGet(actionsModule.tab, getIdent(x))

proc getGlobal(varname, field: string): PNode =
  let n = vm.globalCtx.getGlobalValue(getNimScriptSymbol varname)
  if n.kind != nkObjConstr:
    raiseVariableError(varname, "object")
  for i in 1..< n.len:
    let it = n[i]
    if getIdent(it[0]) == getIdent(field).id: return it[1]

proc getGlobal(varname, field: string; result: var int) =
  let n = getGlobal(varname, field)
  if n != nil and n.isIntLit:
    result = int(n.intVal)
  else:
    raiseVariableError(varname & "." & field, "int")

proc getGlobal(varname, field: string; result: var byte) =
  let n = getGlobal(varname, field)
  if n != nil and n.isIntLit and n.intVal <% 256:
    result = byte(n.intVal)
  else:
    raiseVariableError(varname & "." & field, "byte")

proc getGlobal(varname, field: string; result: var string) =
  let n = getGlobal(varname, field)
  if n != nil and n.isStrLit:
    result = if n.strVal.isNil: "" else: n.strVal
  else:
    raiseVariableError(varname & "." & field, "string")

proc getGlobal(varname, field: string; result: var type(parseColor"")) =
  let n = getGlobal(varname, field)
  if n != nil and n.isIntLit:
    result = colorFromInt(n.intVal)
  else:
    raiseVariableError(varname & "." & field, "Color")

proc extractStyles(result: var StyleManager; fm: var FontManager;
                   fontSize: byte) =
  let n = vm.globalCtx.getGlobalValue(getNimScriptSymbol "tokens")
  if n.kind == nkBracket and n.len == int(high(TokenClass))+1:
    for i, x in n.sons:
      if x.kind == nkPar and x.len == 2 and x[0].isIntLit and x[1].isIntLit:
        result.setStyle(fm, TokenClass(i),
            FontAttr(color: colorFromInt(x[0].intVal), style: FontStyle(x[1].intVal),
                     size: fontSize))
      else:
        raiseVariableError("tokens", "array[TokenClass, (Color, FontStyle)]")
  else:
    raiseVariableError("tokens", "array[TokenClass, (Color, FontStyle)]")

proc setupNimscript*() =
  passes.gIncludeFile = includeModule
  passes.gImportModule = importModule

  options.libpath = os.findExe("nim").splitPath()[0] /../ "lib"
  appendStr(searchPaths, options.libpath)
  appendStr(searchPaths, options.libpath / "pure")

  initDefines()
  defineSymbol("nimscript")
  defineSymbol("nimconfig")

  registerPass(semPass)
  registerPass(evalPass)


proc loadActions*(scriptName: string) =
  var m = makeModule(scriptName)
  processModule(m, llStreamOpen(scriptName, fmRead), nil)
  actionsModule = m

proc handleEvent*(procname: string) =
  let a = getAction(procname)
  if a != nil:
    discard vm.execProc(vm.globalCtx, a, [])

proc supportsAction*(procname: string): bool = getAction(procname) != nil

proc runTransformator*(procname, selectedText: string): string =
  let a = getAction(procname)
  if a != nil:
    let res = vm.execProc(vm.globalCtx, a, [newStrNode(nkStrLit, selectedText)])
    if res.isStrLit:
      result = res.strVal

proc loadTheme*(scriptName: string; result: var InternalTheme;
                sm: var StyleManager; fm: var FontManager) =
  #setDefaultLibpath()
  var m = makeModule(scriptName)
  incl(m.flags, sfMainModule)

  vm.globalCtx = setupVM(m, scriptName)

  compileSystemModule()
  processModule(m, llStreamOpen(scriptName, fmRead), nil)

  template trivialField(field) =
    getGlobal("theme", astToStr field, result.field)

  template trivialField(externalName, field) =
    getGlobal("theme", externalName, result.field)


  getGlobal("theme", "uiActiveElement", result.active[true])
  getGlobal("theme", "uiInactiveElement", result.active[false])

  getGlobal("theme", "selected", sm.b[mcSelected])
  getGlobal("theme", "highlighted", sm.b[mcHighlighted])

  trivialField "background", bg
  trivialField "foreground", fg
  trivialField cursor
  trivialField cursorWidth
  trivialField uiXGap
  trivialField uiYGap
  trivialField editorFont
  trivialField editorFontSize
  trivialField uiFont
  trivialField uiFontSize
  trivialField tabWidth
  trivialField consoleAfter

  extractStyles sm, fm, result.editorFontSize

  # ensure everything can be called again:
  #resetAllModulesHard()
  #vm.globalCtx = nil
