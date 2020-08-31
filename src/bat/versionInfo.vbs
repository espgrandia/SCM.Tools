set args = WScript.Arguments
Set fso = CreateObject("Scripting.FileSystemObject")
WScript.Echo "[version] " + fso.GetFileVersion(args(0))
Wscript.Quit