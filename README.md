# 🏠 **LJL Roommates - Encuentra tu Compañero Ideal**

![Banner](https://img.shields.io/badge/Flutter-3.19-blue?style=for-the-badge&logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-3.0-green?style=for-the-badge&logo=supabase)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Conectamos arrendatarios con propiedades ideales y propietarios confiables.** Una aplicación moderna para encontrar roommates, gestionar arriendos y establecer conexiones seguras.

---

## ✨ **Características Principales**

### 👤 **Para Arrendatarios**
- 🔍 **Búsqueda inteligente** de propiedades con filtros avanzados
- ❤️ **Sistema de favoritos** para guardar propiedades interesantes
- 📍 **Geolocalización** y mapa interactivo de viviendas cercanas
- 📋 **Solicitudes integradas** para contactar propietarios
- ⭐ **Sistema de recomendaciones** basado en tus preferencias

### 🏠 **Para Propietarios**
- 📸 **Publicación de propiedades** con múltiples imágenes
- 👥 **Gestión de solicitudes** e interesados
- 🔒 **Verificación de arrendatarios**
- 💬 **Chat integrado** para comunicación directa
- 📅 **Calendario de visitas** programadas

### 🔒 **Seguridad y Confianza**
- ✅ **Verificación de identidad** con múltiples niveles
- ⚠️ **Sistema de reportes** y bloqueo de usuarios
- ⭐ **Sistema de referencias** y recomendaciones
- 🔐 **Autenticación segura** con Supabase Auth

---

## 🚀 **Cómo Empezar**

### **1. Crear una Cuenta**
1. Descarga e instala la aplicación
2. Selecciona tu rol: **Arrendatario** o **Propietario**
3. Completa tu perfil con información básica
4. ¡Listo para explorar!

### **2. Como Arrendatario**
```
📌 Pasos básicos:
1. Completa tu perfil al 100%
2. Usa los filtros para buscar propiedades
3. Guarda tus favoritos con ❤️
4. Envía solicitudes a propietarios
5. Programa visitas en el calendario
6. Comunícate por chat seguro
```

### **3. Como Propietario**
```
📌 Pasos básicos:
1. Verifica tu identidad
2. Publica tu propiedad con fotos
3. Gestiona solicitudes recibidas
4. Programa visitas con interesados
5. Chatea de forma segura
6. Genera referencias confiables
```

---

## 🛠️ **Tecnologías Utilizadas**

| Tecnología | Uso | Versión |
|------------|-----|---------|
| **Flutter** | Framework principal | 3.19.0 |
| **Supabase** | Backend & Auth | 2.12.0 |
| **Firebase** | Analytics & Crashlytics | 11.3.2 |
| **BLoC** | State Management | 9.1.1 |
| **Geolocator** | Ubicación en tiempo real | 14.0.2 |
| **Clean Architecture** | Estructura del proyecto | - |

---

## 📁 **Estructura del Proyecto**

```
lib/
├── core/           # Configuraciones y utilidades
│   ├── analytics/  # Servicio de analytics
│   ├── config/     # Configuración de APIs
│   ├── di/         # Inyección de dependencias
│   ├── errors/     # Manejo de errores
│   ├── theme/      # Temas y estilos
│   └── utils/      # Utilidades comunes
├── features/       # Módulos por funcionalidad
│   ├── auth/       # Autenticación
│   ├── tenant/     # Módulo de arrendatario
│   ├── listings/   # Propiedades
│   ├── chat/       # Mensajería
│   ├── profile/    # Perfiles
│   └── ...         # Otros módulos
└── main.dart       # Punto de entrada
```

---

## 🔧 **Configuración para Desarrollo**

### **Requisitos Previos**
- Flutter SDK >= 3.19.0
- Dart >= 3.3.0
- Android Studio / VS Code
- Cuenta en [Supabase](https://supabase.com)

### **Pasos de Instalación**

```bash
# 1. Clonar el repositorio
git clone https://github.com/tuusuario/LJL-Roommates.git
cd LJL-Roommates

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Supabase

# 4. Ejecutar la aplicación
flutter run
```

### **Variables de Entorno (.env)**
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
```

---

## 📊 **Dashboard de Usuario**

### **📊 Estadísticas en Tiempo Real**
- 🔢 **Propiedades visitadas:** Monitorea tu actividad
- ⭐ **Favoritos guardados:** Acceso rápido a tus intereses
- 📨 **Solicitudes enviadas:** Historial completo
- 👥 **Conexiones establecidas:** Red de contactos

### **🎯 Personalización**
- 🎨 **Tema claro/oscuro:** Adapta la interfaz a tu preferencia
- 🔔 **Notificaciones personalizadas:** Configura qué quieres recibir
- 📍 **Ubicación preferida:** Establece zonas de interés
- 💰 **Rango de precios:** Define tu presupuesto ideal

---

## 💬 **Sistema de Chat Integrado**

### **Características del Chat**
- 💬 **Mensajes en tiempo real**
- 📎 **Compartir ubicación y fotos**
- ✅ **Confirmación de lectura**
- ⏰ **Historial de conversaciones**
- 🔔 **Notificaciones push**

### **Seguridad en Comunicaciones**
- 🔒 **Encriptación punto a punto**
- 📝 **Registro de conversaciones**
- ⚠️ **Reporte de mensajes inapropiados**
- 🚫 **Bloqueo de usuarios**

---

## 📈 **Analytics & Optimización**

### **Métricas Seguidas**
- 📊 **Uso de funcionalidades:** Popularidad de cada feature
- ⏱️ **Tiempo de sesión:** Engagement de usuarios
- 🔄 **Conversiones:** Registro → Perfil completo → Interacción
- 🐛 **Errores y crashes:** Monitoreo en tiempo real

### **Optimizaciones Implementadas**
- 🚀 **Caché de imágenes:** Carga más rápida
- 📱 **Lazy loading:** Mejor performance
- 🔄 **Background sync:** Datos siempre actualizados
- 💾 **Almacenamiento local:** Funcionalidad offline

---

## 🎨 **Diseño y UX**

### **Principios de Diseño**
- 🎯 **Minimalista:** Interfaz limpia y sin distracciones
- ♿ **Accesible:** Cumple con WCAG 2.1
- 📱 **Responsive:** Adaptable a todos los dispositivos
- ⚡ **Rápida:** Tiempos de carga optimizados

### **Paleta de Colores**
```dart
Color primario: #2196F3 (Azul confianza)
Color secundario: #4CAF50 (Verde éxito)
Color acento: #FF9800 (Naranja atención)
Fondo claro: #FAFAFA
Texto: #212121
```

---

## 🔒 **Política de Seguridad y Privacidad**

### **Datos Protegidos**
- 🔐 **Contraseñas:** Encriptadas con bcrypt
- 📍 **Ubicación:** Solo con permiso explícito
- 📸 **Fotos:** Almacenamiento seguro en Supabase Storage
- 💬 **Mensajes:** Encriptados extremo a extremo

### **Transparencia**
- 📄 **Política de privacidad** accesible desde la app
- 👁️ **Control de datos** por parte del usuario
- 🗑️ **Derecho al olvido:** Eliminación completa de cuenta
- 📋 **Términos de servicio** claros y concisos

---

## 🤝 **Contribuir al Proyecto**

### **¿Quieres contribuir?**
1. 🍴 Haz fork del proyecto
2. 🌿 Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. 📤 Push a la rama (`git push origin feature/AmazingFeature`)
5. 🔀 Abre un Pull Request

### **Guía de Estilo**
- 📝 **Commits:** Usar [Conventional Commits](https://www.conventionalcommits.org/)
- 🎨 **Código:** Seguir las [guías de estilo de Flutter](https://flutter.dev/docs/development/tools/formatting)
- ✅ **Tests:** Mantener cobertura > 80%
- 📚 **Documentación:** Comentar código público

---

## 📄 **Licencia**

Este proyecto está bajo la **Licencia MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

```
MIT License

Copyright (c) 2024 LJL Roommates

Se concede permiso, libre de cargos, a cualquier persona que obtenga una copia
de este software y de los archivos de documentación asociados (el "Software"),
para utilizar el Software sin restricción, incluyendo sin limitación los derechos
a usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender
copias del Software, y a permitir a las personas a las que se les proporcione el Software
a hacer lo mismo, sujeto a las siguientes condiciones:
```

---

## 🌟 **Reconocimientos**

### **Librerías y Herramientas**
- [Flutter](https://flutter.dev) - Framework de UI
- [Supabase](https://supabase.com) - Backend como servicio
- [BLoC](https://bloclibrary.dev) - Gestión de estado
- [Firebase](https://firebase.google.com) - Analytics y monitoreo

### **Contribuidores**
- **Desarrollo:** [Lenin Proaño]
- **Diseño UI/UX:** [Josué Guerra]
- **Testing:** [Lenin Proaño, Josué Guerra]
- **Documentación:** [Luis Ramos]

---

## 🚀 **Roadmap 2024**

### **Q1 - Enero a Marzo** ✅ COMPLETADO
- [x] Sistema de autenticación completo
- [x] Módulo de arrendatario
- [x] Búsqueda y filtros básicos

### **Q2 - Abril a Junio** 🚧 EN PROGRESO
- [ ] Sistema de pagos integrado
- [ ] Contratos digitales
- [ ] Reseñas y calificaciones

### **Q3 - Julio a Septiembre** 📅 PLANEADO
- [ ] App para propietarios
- [ ] Dashboard de analytics
- [ ] Integración con APIs externas

### **Q4 - Octubre a Diciembre** 🔮 FUTURO
- [ ] Versión web
- [ ] Internacionalización
- [ ] Machine learning para matches

---

<div align="center">

## ⭐ **¿Te gusta el proyecto?**

¡Dale una estrella en GitHub y compártelo con otros!

[![Star](https://img.shields.io/github/stars/tuusuario/LJL-Roommates?style=social)](https://github.com/tuusuario/LJL-Roommates/stargazers)
[![Fork](https://img.shields.io/github/forks/tuusuario/LJL-Roommates?style=social)](https://github.com/tuusuario/LJL-Roommates/network/members)

**¡Encuentra tu hogar ideal hoy mismo!** 🏡

</div>

---

## 📋 **Changelog**

### **v1.0.0** - Lanzamiento Inicial
- ✅ Sistema de registro con roles múltiples
- ✅ Búsqueda y filtrado de propiedades
- ✅ Sistema de favoritos
- ✅ Chat en tiempo real
- ✅ Geolocalización y mapas
- ✅ Notificaciones push
- ✅ Perfiles de usuario completos

### **Próximas Versiones**
- **v1.1.0:** Sistema de pagos y contratos
- **v1.2.0:** Reseñas y calificaciones
- **v2.0.0:** Versión web y multiplataforma

---

> **Nota:** Este README se actualiza regularmente. Última actualización: Enero 2026

---
<div align="center">
  
**Hecho con ❤️ para la comunidad de roommates**
</div>
