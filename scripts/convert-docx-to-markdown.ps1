param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-NodeText {
    param(
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$Node,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNamespaceManager]$NamespaceManager
    )

    $parts = New-Object System.Collections.Generic.List[string]

    foreach ($child in $Node.ChildNodes) {
        switch ($child.LocalName) {
            "t" {
                $parts.Add($child.InnerText)
            }
            "tab" {
                $parts.Add("    ")
            }
            "br" {
                $parts.Add("<br>")
            }
            default {
                if ($child.HasChildNodes) {
                    $nested = Get-NodeText -Node $child -NamespaceManager $NamespaceManager
                    if ($nested) {
                        $parts.Add($nested)
                    }
                }
            }
        }
    }

    return (($parts -join "") -replace "\s+", " ").Trim()
}

function Get-ParagraphStyle {
    param(
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$Paragraph,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNamespaceManager]$NamespaceManager
    )

    $styleNode = $Paragraph.SelectSingleNode("./w:pPr/w:pStyle", $NamespaceManager)
    if (-not $styleNode) {
        return $null
    }

    $attribute = $styleNode.Attributes.GetNamedItem("w:val")
    if ($attribute) {
        return $attribute.Value
    }

    return $null
}

function Convert-ParagraphToMarkdown {
    param(
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$Paragraph,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNamespaceManager]$NamespaceManager
    )

    $style = Get-ParagraphStyle -Paragraph $Paragraph -NamespaceManager $NamespaceManager
    $text = Get-NodeText -Node $Paragraph -NamespaceManager $NamespaceManager
    if (-not $text) {
        return $null
    }

    switch ($style) {
        "Heading1" { return "# $text" }
        "Heading2" { return "## $text" }
        "Heading3" { return "### $text" }
        default { return $text }
    }
}

function Convert-TableToMarkdown {
    param(
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$Table,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNamespaceManager]$NamespaceManager
    )

    $rows = @()

    foreach ($row in $Table.SelectNodes("./w:tr", $NamespaceManager)) {
        $cells = @()

        foreach ($cell in $row.SelectNodes("./w:tc", $NamespaceManager)) {
            $paragraphs = @()
            foreach ($paragraph in $cell.SelectNodes("./w:p", $NamespaceManager)) {
                $text = Get-NodeText -Node $paragraph -NamespaceManager $NamespaceManager
                if ($text) {
                    $paragraphs += $text
                }
            }

            $cellText = ($paragraphs -join "<br>") -replace "\|", "\|"
            $cells += $cellText.Trim()
        }

        if ($cells.Count -gt 0) {
            $rows += ,$cells
        }
    }

    if ($rows.Count -eq 0) {
        return @()
    }

    $columnCount = ($rows | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
    $normalizedRows = foreach ($row in $rows) {
        $expanded = @($row)
        while ($expanded.Count -lt $columnCount) {
            $expanded += ""
        }
        ,$expanded
    }

    $tableLines = New-Object System.Collections.Generic.List[string]
    $header = $normalizedRows[0]
    $tableLines.Add("| " + ($header -join " | ") + " |")
    $tableLines.Add("| " + ((1..$columnCount | ForEach-Object { "---" }) -join " | ") + " |")

    foreach ($row in $normalizedRows | Select-Object -Skip 1) {
        $tableLines.Add("| " + ($row -join " | ") + " |")
    }

    return $tableLines
}

$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedInput)
try {
    $documentEntry = $archive.GetEntry("word/document.xml")
    if (-not $documentEntry) {
        throw "DOCX does not contain word/document.xml"
    }

    $reader = [System.IO.StreamReader]::new($documentEntry.Open())
    try {
        $documentXml = [xml]$reader.ReadToEnd()
    }
    finally {
        $reader.Close()
    }
}
finally {
    $archive.Dispose()
}

$namespaceManager = [System.Xml.XmlNamespaceManager]::new($documentXml.NameTable)
$namespaceManager.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

$body = $documentXml.SelectSingleNode("//w:body", $namespaceManager)
if (-not $body) {
    throw "Unable to locate document body"
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("<!-- Generated from $(Split-Path -Leaf $resolvedInput) using scripts/convert-docx-to-markdown.ps1 -->")
$lines.Add("")

foreach ($child in $body.ChildNodes) {
    switch ($child.LocalName) {
        "p" {
            $markdown = Convert-ParagraphToMarkdown -Paragraph $child -NamespaceManager $namespaceManager
            if ($markdown) {
                $lines.Add($markdown)
                $lines.Add("")
            }
        }
        "tbl" {
            $tableLines = Convert-TableToMarkdown -Table $child -NamespaceManager $namespaceManager
            if ($tableLines.Count -gt 0) {
                foreach ($line in $tableLines) {
                    $lines.Add($line)
                }
                $lines.Add("")
            }
        }
    }
}

$content = ($lines -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine
[System.IO.File]::WriteAllText($OutputPath, $content, [System.Text.Encoding]::UTF8)
