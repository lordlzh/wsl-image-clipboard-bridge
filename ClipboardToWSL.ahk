; ClipboardToWSL.ahk - Windows 剪贴板图片同步到 WSL xclip
; AutoHotkey v2
; 快捷键: Win+Alt+V

#Requires AutoHotkey v2.0
#SingleInstance Force

; 临时文件路径
TEMP_PNG := A_Temp "\clipboard_to_wsl.png"

; ========== Win+Alt+V: 同步图片到 WSL xclip ==========
#!v:: {
    if !ClipboardHasImage() {
        ToolTip("剪贴板中没有图片")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    SyncImageToWSL()
}

; ========== 核心函数：同步图片到 WSL xclip ==========
SyncImageToWSL() {
    global TEMP_PNG

    ToolTip("正在同步图片到 WSL...")

    ; 用 PowerShell 保存剪贴板图片为 PNG
    psScript := "Add-Type -AssemblyName System.Windows.Forms;"
        . " `$img = [System.Windows.Forms.Clipboard]::GetImage();"
        . " if (`$img) { `$img.Save('" TEMP_PNG "', [System.Drawing.Imaging.ImageFormat]::Png); exit 0 }"
        . " else { exit 1 }"

    saveCmd := "powershell.exe -NoProfile -Command `"" psScript "`""

    result := RunWait(saveCmd, , "Hide")
    if (result != 0) {
        ToolTip("保存图片失败")
        SetTimer(() => ToolTip(), -2000)
        return
    }

    ; 转换路径并调用 wsl xclip
    ; 使用 nohup + setsid 让 xclip 在 bash 退出后继续存活持有剪贴板
    wslPath := StrReplace(TEMP_PNG, "\", "/")
    wslPath := RegExReplace(wslPath, "^([A-Za-z]):", "/mnt/$L1")

    wslCmd := "wsl.exe bash -c `"DISPLAY=:0 nohup setsid xclip -selection clipboard -t image/png -i '" wslPath "' >/dev/null 2>&1`""
    RunWait(wslCmd, , "Hide")

    ToolTip("图片已同步到 WSL 剪贴板 ✓")
    SetTimer(() => ToolTip(), -2000)
}

; ========== 检查剪贴板是否包含图片 ==========
ClipboardHasImage() {
    ; CF_BITMAP = 2, CF_DIB = 8
    return DllCall("IsClipboardFormatAvailable", "UInt", 2) || DllCall("IsClipboardFormatAvailable", "UInt", 8)
}
