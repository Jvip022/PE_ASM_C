#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "persona.h"

#define MAX_INPUT 100

void mostrarMenu()
{
    printf("\n=== SISTEMA DE GESTIÓN DE PERSONAS ===\n");
    printf("1. Crear nueva persona\n");
    printf("2. Mostrar todas las personas\n");
    printf("3. Mostrar cantidad de personas\n");
    printf("4. Mostrar Persona x\n");
    printf("5. Liberar todas las personas\n");
    printf("6. Salir\n");
    printf("Seleccione una opción: ");
}

void limpiarBuffer()
{
    int c;
    while ((c = getchar()) != '\n' && c != EOF)
        ;
}

int main()
{
    inicializarSistema();
    int opcion;
    char nombre[MAX_INPUT];
    int edad;
    float altura;

    printf("Bienvenido al Sistema de Gestión de Personas\n");
    printf("Los datos se manejan internamente en ensamblador\n");

    do
    {
        mostrarMenu();
        scanf("%d", &opcion);
        limpiarBuffer();

        switch (opcion)
        {
        case 1:
            printf("\n--- Crear Nueva Persona ---\n");
            printf("Nombre: ");
            fgets(nombre, MAX_INPUT, stdin);
            nombre[strcspn(nombre, "\n")] = 0;

            printf("Edad: ");
            scanf("%d", &edad);

            printf("Altura (en metros): ");
            scanf("%f", &altura);
            limpiarBuffer();

            Persona p= crearPersona(nombre, edad, altura);
            if (p)
            {
                printf("✓ Persona creada exitosamente\n");
            }
            else
            {
                printf("✗ Error al crear persona\n");
            }
            break;

        case 2:
            printf("\n--- Lista de Todas las Personas ---\n");
            if (obtenerCantidadPersonas() == 0)
            {
                printf("No hay personas registradas.\n");
            }
            else
            {
                mostrarTodasLasPersonas();
            }
            break;

        case 3:
            printf("\n--- Estadísticas ---\n");
            printf("Cantidad de personas en el sistema: %d\n",
                   obtenerCantidadPersonas());
            break;
        case 4:
            printf("\n--- Mostrar Persona por Índice ---\n");
            int cantidad = obtenerCantidadPersonas();

            if (cantidad == 0)
            {
                printf("No hay personas registradas.\n");
            }
            else
            {
                printf("Hay %d personas en el sistema.\n", cantidad);
                printf("Ingrese el índice (0 a %d): ", cantidad - 1);

                int indice;
                if (scanf("%d", &indice) == 1)
                {
                    if (indice >= 0 && indice < cantidad)
                    {
                        mostrarPersonaPorIndice(indice); // ¡CORRECTO! Muestra persona existente
                    }
                    else
                    {
                        printf("Índice fuera de rango.\n");
                    }
                }
                else
                {
                    printf("Entrada inválida.\n");
                }
                limpiarBuffer();
            }
            break;
        case 5:
            printf("\n--- Limpiar Sistema ---\n");
            limpiarSistema();
            printf("✓ Todas las personas han sido liberadas\n");
            break;

        case 6:
            printf("Saliendo del sistema...\n");
            break;
        default:
            printf("Opción no válida. Intente nuevamente.\n");
        }
    } while (opcion != 6);

    limpiarSistema();
    printf("Sistema finalizado correctamente.\n");
    return 0;
}