﻿$moduleName = 'PsTemplateEngine'

Describe "$ModuleName Module" -Tags 'Module' {
    
    # Import Module
    import-module "$PSScriptRoot\..\$ModuleName.psd1"
    
    #$FunctionsList = (get-command -Module ADSIPS).Name
    $FunctionsList = (get-command -Module $ModuleName | Where-Object -FilterScript { $_.CommandType -eq 'Function' }).Name
    
    FOREACH ($Function in $FunctionsList)
    {
        # Retrieve the Help of the function
        $Help = Get-Help -Name $Function -Full
        
        $Notes = ($Help.alertSet.alert.text -split '\n')
        
        # Parse the function using AST
        $AST = [Management.Automation.Language.Parser]::ParseInput((Get-Content function:$Function), [ref]$null, [ref]$null)
        
        Context "$Function - Help"{
            
            It 'Synopsis'{ $help.Synopsis | Should not BeNullOrEmpty }
            It 'Description'{ $help.Description | Should not BeNullOrEmpty }

            
            # Get the parameters declared in the Comment Based Help
            $RiskMitigationParameters = 'Whatif', 'Confirm'
            $HelpParameters = $help.parameters.parameter | Where-Object name -NotIn $RiskMitigationParameters
            
            # Get the parameters declared in the AST PARAM() Block
            $ASTParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath
            
            $FunctionsList = (get-command -Module $ModuleName | Where-Object -FilterScript { $_.CommandType -eq 'Function' }).Name
            
            It 'Parameter - Compare Count Help/AST' {
                $HelpParameters.name.count -eq $ASTParameters.count | Should Be $true
            }
            
            # Parameter Description
            #$help.parameters.parameter | ForEach-Object {
            $HelpParameters | ForEach-Object {
                It "Parameter $($_.Name) - Should contains description"{
                    $_.description | Should not BeNullOrEmpty
                }
            }
            
            # Examples
            it 'Example - Count should be greater than 0'{
                $Help.examples.example.code.count | Should BeGreaterthan 0
            }
            
            # Examples - Remarks (small description that comes with the example)
            foreach ($Example in $Help.examples.example)
            {
                it "Example - Remarks on $($Example.Title)"{
                    $Example.remarks | Should not BeNullOrEmpty
                }
            }
        }
    }
}