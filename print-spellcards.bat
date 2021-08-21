@echo off

set "result_folder=reshaped"
set "print_folder=print"
set "template=blank_template.jpg"
set /a mw=745
set /a mh=1052
set /a x0=75
set /a y0=80
set /a spacing=1
set /a max_cols=2
set /a max_rows=3
set /a pages=0

if exist "%print_folder%" (
    echo ...carpeta ok
    echo ...copiando plantilla
    xcopy "%template%" "%print_folder%" /Y
) else (
    echo ...creando carpeta result2
    md print
    echo ...copiando plantilla
    xcopy "%template%" "%print_folder%" /Y
)

if exist "%result_folder%" ( 
    echo ...carpeta result ok
) else (
    md reshaped
    echo ...carpeta %result_folder% creada
)

for %%a in ("*.png") do (
    if "%%a" == "%template%" goto Test
    echo ...redimensionando "%%~nxa"
    call scale.bat -source "%%~fa" -target "%result_folder%\%%~nxa" -max-width %mw% -max-height %mh% -keep-ratio no -force yes    
    :Test
    rem label para saltar la plantilla
)

set /a actualcolumn=0
set /a actualrow=0
setlocal enabledelayedexpansion
for %%a in ("%result_folder%\*png") do (  
    if "%%a" == "%template%" goto Test2    
    set num=%%~nxa:~0,1%
    
    for /L %%i in (1,1,!num!) do (
        set /a posX = !x0! + !mw! * !actualcolumn!
        set /a posY = !y0! + !mh! * !actualrow!
        if !actualcolumn! == 0 (set /a posX = !posX!) else (set /a posX = !posX! + !spacing! * !actualcolumn!)
        if !actualrow! == 0 (set /a posY = !posY!) else (set /a posY = !posY! + !spacing! * !actualrow!)
        call stamp.bat -source "%print_folder%\blank_template.jpg" -stamp "%%~fa" -target "%print_folder%\result.png" -top !posY! -left !posX! -force yes
        echo ...incrustando "%%~nxa" en la plantilla
        del "%print_folder%\blank_template.jpg"
        ren "%print_folder%\result.png" "blank_template.jpg"
        if !actualcolumn! == !max_cols! ( 
            set /a actualcolumn=0            
            set /a actualrow = !actualrow! + 1
        ) else (
            set /a actualcolumn = !actualcolumn! + 1
        )

        if !actualrow! == !max_rows! (
            set /a pages=!pages!+1
            ren "%print_folder%\blank_template.jpg" "page-!pages!.png"
            echo ...Pagina !pages! creada
            xcopy "%template%" "%print_folder%" /Y            
            set /a actualcolumn=0
            set /a actualrow=0
        )
    )
    
    :Test2
    rem label para saltar la plantilla
)

set /a pages=%pages%+1
ren "%print_folder%\blank_template.jpg" "page-!pages!.png"

pause