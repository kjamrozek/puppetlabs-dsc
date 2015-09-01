#--------------------------------------------------------------------------------- 

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    #Get the status of system restore on the target computer.
    $GetSystemRestore = Get-CimInstance -Class SystemRestoreConfig -Namespace 'root\default'

    $returnValue = @{
                        Ensure = $Ensure
                    }

    #Check if the system restore is enabled or disabled.
    If($GetSystemRestore.RPSessionInterval -eq 1)
    {
        $returnValue.Ensure = 'Present'
    }
    Else
    {
        $returnValue.Ensure = 'Absent'
    }
    
    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String[]]
        $Drive
    )

    Switch($Ensure)
    {
        'Present'
        {
            If($PSCmdlet.ShouldProcess("'$Drive'","Enable the system restore"))
            {
                Try
                {
                    Write-Verbose "Enable the System Restore feature on the '$Drive' file system drive."
                    Enable-ComputerRestore -Drive $Drive -ErrorAction Stop
                }
                Catch
                {
                    $ErrorMsg = $_.Exception.Message
                    Write-Verbose $ErrorMsg
                }
            }
        }
        'Absent'
        {
            If($PSCmdlet.ShouldProcess("$Drive","Disable the system restore"))
            {
                Try
                {
                    Write-Verbose "Disable the System Restore feature on the '$Drive' file system drive."
                    Disable-ComputerRestore -Drive $Drive
                }
                Catch
                {
                    $ErrorMsg = $_.Exception.Message
                    Write-Verbose $ErrorMsg
                }
            }
        }
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String[]]
        $Drive
    )

    #Output the result of Get-TargetResource function.
    $Get = Get-TargetResource -Ensure $Ensure

    If($Ensure -eq $Get.Ensure)
    {
        return $true
    }
    Else
    {
        return $false
    }
}


Export-ModuleMember -Function *-TargetResource


