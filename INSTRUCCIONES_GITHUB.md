# Instrucciones para subir el código a GitHub

## Paso 1: Crear el repositorio en GitHub

1. Ve a https://github.com/new
2. Nombre del repositorio: `brick_breaker`
3. Descripción: "Brick Breaker game with 50 levels, skins, timer, enemies, and music system"
4. Elige si quieres que sea público o privado
5. **NO marques** "Initialize this repository with a README" (ya tenemos archivos)
6. Haz clic en "Create repository"

## Paso 2: Obtener un Token de Acceso Personal

1. Ve a https://github.com/settings/tokens
2. Haz clic en "Generate new token" > "Generate new token (classic)"
3. Dale un nombre como "brick_breaker_token"
4. Selecciona el scope `repo` (acceso completo a repositorios)
5. Haz clic en "Generate token"
6. **COPIA EL TOKEN** (solo se muestra una vez)

## Paso 3: Conectar y subir el código

Una vez que tengas el token, ejecuta estos comandos:

```bash
cd C:\Users\eguci\brick_breaker
git remote add origin https://github.com/jerry345/brick_breaker.git
git branch -M main
git push -u origin main
```

Cuando te pida usuario: `jerry345`
Cuando te pida contraseña: **PEGA EL TOKEN** (no tu contraseña)
