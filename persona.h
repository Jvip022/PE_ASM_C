#ifndef PERSONA_H
#define PERSONA_H

// Tipo opaco - C no conoce la estructura interna
typedef void* Persona;

// Funciones del sistema en ensamblador
extern void inicializarSistema();
extern void limpiarSistema();
extern Persona crearPersona(const char* nombre, int edad, float altura);
extern void mostrarPersona(Persona p);
extern void mostrarTodasLasPersonas();
extern void liberarPersona(Persona p);
extern int obtenerCantidadPersonas();

#endif