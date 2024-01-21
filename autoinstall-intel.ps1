 # Chromebook Intel Driver AutoInstaller
 # Copyright 2024, CoolStar. All Rights Reserved

 # Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole))
 {
 	Echo "Run As Admin -- OK"
 }
 else
 {
 	# We are not running "as Administrator" - so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter
    $newProcess.Arguments = "-ExecutionPolicy Bypass " + $myInvocation.MyCommand.Definition + " " + $PWD.Path;

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    exit
 }


If ($args.count -gt 0){
	Set-Location $args[0]
}
$Chip = "Unknown"
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INT34BB\0" 2>$NULL){
	$Chip = "CML"
	Echo "Detected Comet Lake"
}
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INT34C8\0" 2>$NULL){
	$Chip = "JSL"
	Echo "Detected Jasper Lake"
}
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INT34C5\0" 2>$NULL){
	$Chip = "TGL"
	Echo "Detected Tiger Lake"
}
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INTC1055\0" 2>$NULL){
	$Chip = "ADL"
	Echo "Detected Alder Lake"
}
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INTC1056\0" 2>$NULL){
	$Chip = "ADL"
	Echo "Detected Alder Lake"
}
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INTC1057\0" 2>$NULL){
	$Chip = "ADL-N"
	Echo "Detected Alder Lake-N"
}
If (Get-PnpDevice -PresentOnly -InstanceID "ACPI\INTC1085\0" 2>$NULL){
	$Chip = "ADL"
	Echo "Detected Raptor Lake"
}

If ($Chip -Eq "Unknown"){
	Echo "Failed to detect chipset. Make sure the GPIO controller is present in coreboot."
}

Remove-Item -Path CBookDriversTmp -Recurse 2>$NULL
New-Item -Name CBookDriversTmp -ItemType "Directory"
Set-Location CBookDriversTmp

If ($Chip -Eq "CML"){
	Echo "Downloading Comet Lake LPSS drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2021/11/6205d33d-a420-4dfc-9724-27999a3de111_ad6c425b1e3f5f70df82554d8300a80e1cca3921.cab" -OutFile lpss.cab
	Echo "Downloading Comet Lake Chipset drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2019/07/35853dc6-14f2-45e1-94f0-d2289e36d2f2_618696f00ecf5b12783ed6577f6ba18a9c6cb560.cab" -OutFile chipset.cab
	Echo "Downloading Comet Lake DPTF drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2022/07/0f500713-d36b-41e2-b9f0-85b56150532f_95f94116ea27c6994603bcce31eef0e314da9c16.cab" -OutFile dptf.cab

	Echo "Expanding Drivers"
	Expand lpss.cab -F:* . >$NULL
	Expand chipset.cab -F:* . >$NULL
	Expand dptf.cab -F:* . >$NULL

	Echo "Installing CML System Driver"
	pnputil /add-driver CometLakePCH-LPSystem.inf /install

	Echo "Installing CML System (Northpeak) Driver"
	pnputil /add-driver CometLakePCH-LPSystemNorthpeak.inf /install

	Echo "Installing CML System (Thermal) Driver"
	pnputil /add-driver CometLakePCH-LPSystemThermal.inf /install

	Echo "Installing GPIO Driver"
	pnputil /add-driver iaLPSS2_GPIO2_CNL.inf /install

	Echo "Installing I2C Driver"
	pnputil /add-driver iaLPSS2_I2C_CNL.inf /install

	Echo "Installing SPI Driver"
	pnputil /add-driver iaLPSS2_SPI_CNL.inf /install

	Echo "Installing UART Driver"
	pnputil /add-driver iaLPSS2_UART2_CNL.inf /install

	Echo "Installing DPTF ACPI Driver"
	pnputil /add-driver dptf_acpi.inf /install

	Echo "Installing DPTF CPU Driver"
	pnputil /add-driver dptf_cpu.inf /install
}

If ($Chip -Eq "JSL"){
	Echo "Downloading Jasper Lake LPSS drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2021/11/55c24871-140a-45f1-a1c2-40d466d71df3_6de29adb1d4df234bb10a4b875ec38cefe264641.cab" -OutFile lpss.cab
	Echo "Downloading Jasper Lake Chipset drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2021/11/24195e7c-f5e9-48f0-9df5-4362d4d23641_00e2dfeee8162ff1c69438a0d3b4e92033607d72.cab" -OutFile chipset.cab
	Echo "Downloading Jasper Lake DPTF drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2022/07/0f500713-d36b-41e2-b9f0-85b56150532f_95f94116ea27c6994603bcce31eef0e314da9c16.cab" -OutFile dptf.cab
	Echo "Downloading Intel GNA drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/11/51c140fd-d772-4a85-ac52-78a857df6d61_3bc0d593fc7d061deda5c8fe99225fec05f0ba89.cab" -OutFile gna.cab

	Echo "Expanding Drivers"
	Expand lpss.cab -F:* . >$NULL
	Expand chipset.cab -F:* . >$NULL
	Expand dptf.cab -F:* . >$NULL
	Expand gna.cab -F:* . >$NULL

	Echo "Installing JSL System Driver"
	pnputil /add-driver JasperLakePCH-NSystem.inf /install

	Echo "Installing JSL System (Northpeak) Driver"
	pnputil /add-driver JasperLakePCH-NSystemNorthpeak.inf /install

	Echo "Installing JSL System (LPSS) Driver"
	pnputil /add-driver JasperLakePCH-NSystemLPSS.inf /install

	Echo "Installing GPIO Driver"
	pnputil /add-driver iaLPSS2_GPIO2_JSL.inf /install

	Echo "Installing I2C Driver"
	pnputil /add-driver iaLPSS2_I2C_JSL.inf /install

	Echo "Installing SPI Driver"
	pnputil /add-driver iaLPSS2_SPI_JSL.inf /install

	Echo "Installing UART Driver"
	pnputil /add-driver iaLPSS2_UART2_JSL.inf /install

	Echo "Installing DPTF ACPI Driver"
	pnputil /add-driver dptf_acpi.inf /install

	Echo "Installing DPTF CPU Driver"
	pnputil /add-driver dptf_cpu.inf /install

	Echo "Installing Intel GNA Driver"
	pnputil /add-driver gna.inf /install
}

If ($Chip -Eq "TGL"){
	Echo "Downloading Tiger Lake LPSS drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2021/09/872123fa-1ca0-4616-b9c2-8652e3f02bba_a23e217ed5a22e229fd01e5fc3d5be09cc0deb13.cab" -OutFile lpss.cab
	Echo "Downloading Tiger Lake Chipset drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2021/07/99abf585-18e9-4f46-ac90-4510d48d2828_dea3cc1763220f7f71fba28a9a6a6fe6f05775ca.cab" -OutFile chipset.cab
	Echo "Downloading Jasper Lake DPTF drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2022/07/0f500713-d36b-41e2-b9f0-85b56150532f_95f94116ea27c6994603bcce31eef0e314da9c16.cab" -OutFile dptf.cab
	Echo "Downloading Intel GNA drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/11/51c140fd-d772-4a85-ac52-78a857df6d61_3bc0d593fc7d061deda5c8fe99225fec05f0ba89.cab" -OutFile gna.cab

	Echo "Expanding Drivers"
	Expand lpss.cab -F:* . >$NULL
	Expand chipset.cab -F:* . >$NULL
	Expand dptf.cab -F:* . >$NULL
	Expand gna.cab -F:* . >$NULL

	Echo "Installing TGL System Driver"
	pnputil /add-driver TigerlakePCH-LPSystem.inf /install

	Echo "Installing TGL System (USB Function) Driver"
	pnputil /add-driver TigerlakePCH-LPUSBFunctionController.inf /install

	Echo "Installing TGL System (LPSS) Driver"
	pnputil /add-driver TigerlakePCH-LPSystemLPSS.inf /install

	Echo "Installing GPIO Driver"
	pnputil /add-driver iaLPSS2_GPIO2_TGL.inf /install

	Echo "Installing I2C Driver"
	pnputil /add-driver iaLPSS2_I2C_TGL.inf /install

	Echo "Installing SPI Driver"
	pnputil /add-driver iaLPSS2_SPI_TGL.inf /install

	Echo "Installing UART Driver"
	pnputil /add-driver iaLPSS2_UART2_TGL.inf /install

	Echo "Installing DPTF ACPI Driver"
	pnputil /add-driver dptf_acpi.inf /install

	Echo "Installing DPTF CPU Driver"
	pnputil /add-driver dptf_cpu.inf /install

	Echo "Installing Intel GNA Driver"
	pnputil /add-driver gna.inf /install
}

If ($Chip -Eq "ADL"){
	Echo "Downloading Alder/Raptor Lake LPSS drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2022/11/51e4af59-23b4-412f-be73-8ef9e216c578_b019bda8c590dd1ef8f1c479605a5d1264746e57.cab" -OutFile lpss.cab
	Echo "Downloading Alder Lake Chipset drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2021/12/be4c97d3-f9d5-447b-81f3-edc826675887_633ce7865357186e59cd113fd9083203715ac64e.cab" -OutFile chipset.cab
	Echo "Downloading Alder/Raptor Lake IPF drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/11/facfb05f-6415-49e4-bb5b-3a4b2d2c0510_0b751a0c360fd4ec4adaa8dcb7105b4ffedf1621.cab" -OutFile ipf.cab
	Echo "Downloading Intel GNA drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/11/51c140fd-d772-4a85-ac52-78a857df6d61_3bc0d593fc7d061deda5c8fe99225fec05f0ba89.cab" -OutFile gna.cab

	Echo "Expanding Drivers"
	Expand lpss.cab -F:* . >$NULL
	Expand chipset.cab -F:* . >$NULL
	Expand ipf.cab -F:* . >$NULL
	Expand gna.cab -F:* . >$NULL

	Echo "Installing ADL System Driver"
	pnputil /add-driver AlderLakePCH-PSystem.inf /install

	Echo "Installing ADL System (Northpeak) Driver"
	pnputil /add-driver AlderLakePCH-PSystemNorthpeak.inf /install

	Echo "Installing ADL System (LPSS) Driver"
	pnputil /add-driver AlderLakePCH-PSystemLPSS.inf /install

	Echo "Installing GPIO Driver"
	pnputil /add-driver iaLPSS2_GPIO2_ADL.inf /install

	Echo "Installing I2C Driver"
	pnputil /add-driver iaLPSS2_I2C_ADL.inf /install

	Echo "Installing SPI Driver"
	pnputil /add-driver iaLPSS2_SPI_ADL.inf /install

	Echo "Installing UART Driver"
	pnputil /add-driver iaLPSS2_UART2_ADL.inf /install

	Echo "Installing IPF ACPI Driver"
	pnputil /add-driver ipf_acpi.inf /install

	Echo "Installing IPF CPU Driver"
	pnputil /add-driver ipf_cpu.inf /install

	Echo "Installing Intel GNA Driver"
	pnputil /add-driver gna.inf /install
}

If ($Chip -Eq "ADL-N"){
	Echo "Downloading Alder Lake-N LPSS drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2022/11/4831f32e-196f-4644-867f-2747cc7b85df_726f194a9fd7b5f21126cbb70b54f62f178c87ea.cab" -OutFile lpss.cab
	Echo "Downloading Alder Lake-N Chipset drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2022/09/203c7385-2d15-49db-8a5f-b0056fccc411_0f9a65ffbab916fbbf43015bd6af4395729cc08c.cab" -OutFile chipset.cab
	Echo "Downloading Alder/Raptor Lake IPF drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/11/facfb05f-6415-49e4-bb5b-3a4b2d2c0510_0b751a0c360fd4ec4adaa8dcb7105b4ffedf1621.cab" -OutFile ipf.cab
	Echo "Downloading Intel GNA drivers"
	Invoke-WebRequest "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/11/51c140fd-d772-4a85-ac52-78a857df6d61_3bc0d593fc7d061deda5c8fe99225fec05f0ba89.cab" -OutFile gna.cab

	Echo "Expanding Drivers"
	Expand lpss.cab -F:* . >$NULL
	Expand chipset.cab -F:* . >$NULL
	Expand ipf.cab -F:* . >$NULL
	Expand gna.cab -F:* . >$NULL

	Echo "Installing ADL-N System Driver"
	pnputil /add-driver AlderLakePCH-NSystem.inf /install

	Echo "Installing ADL-N System (Northpeak) Driver"
	pnputil /add-driver AlderLakePCH-NSystemNorthpeak.inf /install

	Echo "Installing ADL-N System (ISH) Driver"
	pnputil /add-driver AlderLakePCH-NSystemISH.inf /install

	Echo "Installing GPIO Driver"
	pnputil /add-driver iaLPSS2_GPIO2_ADL_N.inf /install

	Echo "Installing I2C Driver"
	pnputil /add-driver iaLPSS2_I2C_ADL_N.inf /install

	Echo "Installing SPI Driver"
	pnputil /add-driver iaLPSS2_SPI_ADL_N.inf /install

	Echo "Installing UART Driver"
	pnputil /add-driver iaLPSS2_UART2_ADL_N.inf /install

	Echo "Installing IPF ACPI Driver"
	pnputil /add-driver ipf_acpi.inf /install

	Echo "Installing IPF CPU Driver"
	pnputil /add-driver ipf_cpu.inf /install

	Echo "Installing Intel GNA Driver"
	pnputil /add-driver gna.inf /install
}

Echo "Done"