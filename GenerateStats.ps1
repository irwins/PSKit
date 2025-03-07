function GenerateStats {
    param(
        [Parameter(Mandatory)]
        $TargetData
    )

    $names = $TargetData[0].psobject.properties.name

    foreach ($name in $names) {
        $h = [Ordered]@{ }
        $h.ColumnName = $name

        $dt = for ($idx = 0; $idx -lt $NumberOfRowsToCheck + 1; $idx++) {
            if ([string]::IsNullOrEmpty($TargetData[$idx].$name)) {
                "null"
            }
            else {
                (Invoke-AllTests  $TargetData[$idx].$name -OnlyPassing -FirstOne).datatype
            }
        }

        $DataType = GetDataTypePrecedence @($dt)

        $h.DataType = $DataType
        $h.HasNulls = if ($DataType) { @($TargetData.$name -match '^$').count -gt 0 } else { }
        $h.Min = if ($DataType -match 'string|^$') { } else { ($TargetData.$name | Measure-Object -Minimum).Minimum }
        $h.Max = if ($DataType -match 'string|^$') { } else { ($TargetData.$name | Measure-Object -Maximum).Maximum }
        $h.Avg = if ($DataType -match 'int|double') { ($TargetData.$name | Measure-Object -Average).Average } else { }
        $h.Sum = if ($DataType -match 'int|double') { ($TargetData.$name | Measure-Object -Sum).Sum } else { }

        [PSCustomObject]$h
    }
}
