$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$inputPath = Join-Path $root 'explicacao-diagrama-aws.md'
$outputPath = Join-Path $root 'Documento-Academico-Arquitetura-AWS.docx'

if (-not (Test-Path -LiteralPath $inputPath)) {
    throw "Arquivo de entrada nao encontrado: $inputPath"
}

function U {
    param([int[]]$Codes)
    return -join ($Codes | ForEach-Object { [char]$_ })
}

$institution = 'XP ' + (U 69,100,117,99,97,231,227,111)
$program = 'Bootcamp Arquiteto(a) de Solu' + (U 231,245,101,115)
$student = 'Marco'
$city = 'Fortaleza'
$dateText = '20 de junho de 2026'
$title = 'Arquitetura de Solu' + (U 231,227,111) + ' em Nuvem na AWS'
$subtitle = 'Documento acad' + (U 234) + 'mico com base no arquivo explicacao-diagrama-aws.md'
$academicId = 'Identifica' + (U 231,227,111) + ' Acad' + (U 234) + 'mica'
$labelInstitution = 'Institui' + (U 231,227,111)
$labelProgram = 'Curso/P' + (U 243) + 's-gradua' + (U 231,227,111)
$bullet = [char]0x2022

function Escape-Xml {
    param([string]$Text)
    [System.Security.SecurityElement]::Escape($Text)
}

function New-ParagraphXml {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$StyleId = 'Normal',
        [string]$Justification = 'both',
        [int]$FirstLine = 709,
        [int]$SpacingAfter = 120,
        [int]$Line = 360,
        [switch]$Bold,
        [switch]$Italic
    )

    $escaped = Escape-Xml $Text
    $runProps = '<w:lang w:val="pt-BR"/>'

    if ($Bold) {
        $runProps += '<w:b/>'
    }

    if ($Italic) {
        $runProps += '<w:i/>'
    }

    $indentXml = ''
    if ($FirstLine -gt 0) {
        $indentXml = "<w:ind w:firstLine=`"$FirstLine`"/>"
    }

    @"
<w:p>
  <w:pPr>
    <w:pStyle w:val="$StyleId"/>
    <w:jc w:val="$Justification"/>
    <w:spacing w:after="$SpacingAfter" w:line="$Line" w:lineRule="auto"/>
    $indentXml
  </w:pPr>
  <w:r>
    <w:rPr>$runProps</w:rPr>
    <w:t xml:space="preserve">$escaped</w:t>
  </w:r>
</w:p>
"@
}

function New-PageBreakXml {
@"
<w:p>
  <w:r>
    <w:br w:type="page"/>
  </w:r>
</w:p>
"@
}

$markdown = Get-Content -LiteralPath $inputPath -Raw -Encoding UTF8
$lines = $markdown -split "`r?`n"
$paragraphs = [System.Collections.Generic.List[string]]::new()

$paragraphs.Add((New-ParagraphXml -Text $institution -StyleId 'Title' -Justification 'center' -FirstLine 0 -SpacingAfter 240))
$paragraphs.Add((New-ParagraphXml -Text $program -StyleId 'Subtitle' -Justification 'center' -FirstLine 0 -SpacingAfter 240))
$paragraphs.Add((New-ParagraphXml -Text $student -StyleId 'Subtitle' -Justification 'center' -FirstLine 0 -SpacingAfter 2200))
$paragraphs.Add((New-ParagraphXml -Text $title -StyleId 'Heading1' -Justification 'center' -FirstLine 0 -SpacingAfter 240 -Bold))
$paragraphs.Add((New-ParagraphXml -Text $subtitle -StyleId 'Subtitle' -Justification 'center' -FirstLine 0 -SpacingAfter 2200 -Italic))
$paragraphs.Add((New-ParagraphXml -Text "$city, $dateText" -StyleId 'Subtitle' -Justification 'center' -FirstLine 0 -SpacingAfter 0))
$paragraphs.Add((New-PageBreakXml))
$paragraphs.Add((New-ParagraphXml -Text $academicId -StyleId 'Heading1' -Justification 'center' -FirstLine 0 -SpacingAfter 240 -Bold))
$paragraphs.Add((New-ParagraphXml -Text "${labelInstitution}: $institution." -StyleId 'Normal'))
$paragraphs.Add((New-ParagraphXml -Text "${labelProgram}: $program." -StyleId 'Normal'))
$paragraphs.Add((New-ParagraphXml -Text "Aluno: $student." -StyleId 'Normal'))
$paragraphs.Add((New-ParagraphXml -Text "Local e data: $city, $dateText." -StyleId 'Normal'))

foreach ($line in $lines) {
    $trimmed = $line.Trim()

    if (-not $trimmed) {
        continue
    }

    $clean = $trimmed.Replace('`', '')

    if ($trimmed -match '^#\s+(.*)$') {
        $paragraphs.Add((New-ParagraphXml -Text $Matches[1] -StyleId 'Heading1' -Justification 'center' -FirstLine 0 -SpacingAfter 240 -Bold))
        continue
    }

    if ($trimmed -match '^##\s+(.*)$') {
        $paragraphs.Add((New-ParagraphXml -Text $Matches[1] -StyleId 'Heading2' -Justification 'left' -FirstLine 0 -SpacingAfter 180 -Bold))
        continue
    }

    if ($trimmed -match '^###\s+(.*)$') {
        $paragraphs.Add((New-ParagraphXml -Text $Matches[1] -StyleId 'Heading3' -Justification 'left' -FirstLine 0 -SpacingAfter 120 -Bold))
        continue
    }

    if ($trimmed -match '^####\s+(.*)$') {
        $paragraphs.Add((New-ParagraphXml -Text $Matches[1] -StyleId 'Heading3' -Justification 'left' -FirstLine 0 -SpacingAfter 120 -Bold))
        continue
    }

    if ($trimmed -match '^\d+\.\s+(.*)$') {
        $paragraphs.Add((New-ParagraphXml -Text $clean -StyleId 'ListParagraph' -Justification 'left' -FirstLine 0 -SpacingAfter 60))
        continue
    }

    if ($trimmed -match '^-+\s+(.*)$') {
        $paragraphs.Add((New-ParagraphXml -Text ($bullet + ' ' + $Matches[1]) -StyleId 'ListParagraph' -Justification 'left' -FirstLine 0 -SpacingAfter 60))
        continue
    }

    $paragraphs.Add((New-ParagraphXml -Text $clean -StyleId 'Normal'))
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
 xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
 xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
 xmlns:v="urn:schemas-microsoft-com:vml"
 xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
 xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
 xmlns:w10="urn:schemas-microsoft-com:office:word"
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
 xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
 xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
 xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
 xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
 xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
 xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
 mc:Ignorable="w14 w15 wp14">
  <w:body>
    $($paragraphs -join "`n")
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1417" w:right="1134" w:bottom="1417" w:left="1701" w:header="708" w:footer="708" w:gutter="0"/>
      <w:cols w:space="708"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
        <w:lang w:val="pt-BR"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:spacing w:after="120" w:line="360" w:lineRule="auto"/>
        <w:jc w:val="both"/>
        <w:ind w:firstLine="709"/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Title">
    <w:name w:val="Title"/>
    <w:basedOn w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:jc w:val="center"/>
      <w:spacing w:after="240" w:line="360" w:lineRule="auto"/>
      <w:ind w:firstLine="0"/>
    </w:pPr>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
      <w:b/>
      <w:sz w:val="24"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle">
    <w:name w:val="Subtitle"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:jc w:val="center"/>
      <w:spacing w:after="240" w:line="360" w:lineRule="auto"/>
      <w:ind w:firstLine="0"/>
    </w:pPr>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="120" w:after="240"/>
      <w:ind w:firstLine="0"/>
    </w:pPr>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
      <w:b/>
      <w:sz w:val="28"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="120" w:after="180"/>
      <w:ind w:firstLine="0"/>
    </w:pPr>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
      <w:b/>
      <w:sz w:val="26"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3"/>
    <w:basedOn w:val="Normal"/>
    <w:next w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:before="80" w:after="120"/>
      <w:ind w:firstLine="0"/>
    </w:pPr>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
      <w:b/>
      <w:sz w:val="24"/>
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="ListParagraph">
    <w:name w:val="List Paragraph"/>
    <w:basedOn w:val="Normal"/>
    <w:pPr>
      <w:jc w:val="left"/>
      <w:spacing w:after="60" w:line="360" w:lineRule="auto"/>
      <w:ind w:left="360" w:firstLine="0"/>
    </w:pPr>
    <w:rPr>
      <w:lang w:val="pt-BR"/>
    </w:rPr>
  </w:style>
</w:styles>
"@

$contentTypesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
"@

$packageRelsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"@

$documentRelsXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
"@

$createdIso = (Get-Date '2026-06-20T00:00:00').ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$keywords = 'arquitetura aws; documento academico; pt-BR'
$description = 'Documento academico gerado a partir do arquivo explicacao-diagrama-aws.md.'

$coreXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:dcterms="http://purl.org/dc/terms/"
 xmlns:dcmitype="http://purl.org/dc/dcmitype/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>$(Escape-Xml $title)</dc:title>
  <dc:subject>$(Escape-Xml $program)</dc:subject>
  <dc:creator>$(Escape-Xml $student)</dc:creator>
  <cp:keywords>$(Escape-Xml $keywords)</cp:keywords>
  <dc:description>$(Escape-Xml $description)</dc:description>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$createdIso</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$createdIso</dcterms:modified>
</cp:coreProperties>
"@

$appXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
 xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Office Word</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <Company>$(Escape-Xml $institution)</Company>
  <LinksUpToDate>false</LinksUpToDate>
  <SharedDoc>false</SharedDoc>
  <HyperlinksChanged>false</HyperlinksChanged>
  <AppVersion>16.0000</AppVersion>
</Properties>
"@

$tempRoot = Join-Path $env:TEMP ('docx_build_' + [Guid]::NewGuid().ToString('N'))
$relsDir = Join-Path $tempRoot '_rels'
$wordDir = Join-Path $tempRoot 'word'
$wordRelsDir = Join-Path $wordDir '_rels'
$docPropsDir = Join-Path $tempRoot 'docProps'

New-Item -ItemType Directory -Path $relsDir, $wordDir, $wordRelsDir, $docPropsDir -Force | Out-Null

$utf8 = [System.Text.UTF8Encoding]::new($true)
[System.IO.File]::WriteAllText((Join-Path $tempRoot '[Content_Types].xml'), $contentTypesXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $relsDir '.rels'), $packageRelsXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $wordDir 'document.xml'), $documentXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $wordDir 'styles.xml'), $stylesXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $wordRelsDir 'document.xml.rels'), $documentRelsXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $docPropsDir 'core.xml'), $coreXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $docPropsDir 'app.xml'), $appXml, $utf8)

if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Force
}

[System.IO.Compression.ZipFile]::CreateFromDirectory($tempRoot, $outputPath)
Remove-Item -LiteralPath $tempRoot -Recurse -Force

Write-Output "Arquivo gerado: $outputPath"
