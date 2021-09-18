$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "ServeFrom-RemoteCrecon" 
{
    It "is ever ready to serve crecon data" 
    {
        $true | Should Be $false
    }

    It "supports enterprise-standard authentication scheme"
    {
        $true | Should Be $false
    }

    It "has a robust role management system"
    {
        $true | Should Be $false
    }

    It "beacons handshakeably potential crecon data takers"
    {
        $true | Should Be $false
    }

    It "serves a fixed number of crecon data takers"
    {
        $true | Should Be $false
    }
}
