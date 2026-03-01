# Automatización de Backups en Azure SQL Server

## Descripción
Este proyecto consiste en la implementación de un sistema de respaldos automáticos para la base de datos **RepuestosPerez**, enviando las copias de seguridad a la nube para garantizar la protección de la información.

## Proceso de Automatización

1. Creación de un contenedor privado en Azure para almacenar los archivos de respaldo.
2. Generación de un Token SAS para permitir la conexión segura.
3. Creación de una CREDENTIAL en SQL Server para vincular el servidor local con Azure.
4. Ejecución del comando `BACKUP DATABASE` utilizando la opción `TO URL`.
5. Configuración de un Job en SQL Server Agent.
6. Programación automática del respaldo diario a las 12:00 am.

## Automatización
El respaldo se ejecuta automáticamente todos los días mediante SQL Server Agent, sin intervención manual.

## Seguridad
La conexión se realiza mediante autenticación con Token SAS, evitando el uso directo de usuario y contraseña.
