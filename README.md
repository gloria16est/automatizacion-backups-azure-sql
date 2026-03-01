# Automatización de Backups en Azure SQL Server

## Descripción
Este proyecto consiste en la implementación de un sistema de respaldos automáticos para la base de datos **RepuestosPerez**, enviando las copias de seguridad a la nube para garantizar la protección de la información.

## Objetivo
Implementar un mecanismo automático de respaldo que permita proteger los datos ante fallos del sistema, daños en el servidor o pérdida accidental de información.

## Proceso de Automatización

1. Creación de un contenedor privado en Azure para almacenar los archivos de respaldo.
2. Generación de un Token SAS para permitir la conexión segura.
3. Creación de una CREDENTIAL en SQL Server para vincular el servidor local con Azure.
4. Ejecución del comando `BACKUP DATABASE` utilizando la opción `TO URL`.
5. Configuración de un Job en SQL Server Agent.
6. Programación automática del respaldo diario a las 12:00 am.

## Funcionamiento
El sistema ejecuta automáticamente el respaldo de la base de datos cada día sin intervención manual, almacenando el archivo `.bak` en el contenedor seguro en la nube.

## Seguridad
La conexión se realiza mediante autenticación con Token SAS, evitando el uso directo de usuario y contraseña.
