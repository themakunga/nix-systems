# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Locale: UI en inglés, región Chile — moneda CLP, métrico, Celsius,
# separador de miles ".", decimal ",", fecha dd-MMM-yyyy, hora HH:mm.
_: {
  flake.darwinModules.locale = {
    system.defaults.NSGlobalDomain = {
      # Región Chile → formato de números, moneda, fechas y hora chilenos
      # El idioma de la UI lo fija AppleLanguages (mantiene inglés).
      AppleLocale = "es_CL@currency=CLP";
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = true;
      AppleTemperatureUnit = "Celsius";
    };

    system.defaults.CustomUserPreferences."NSGlobalDomain" = {
      # Separadores numéricos
      AppleICUNumberSymbols = {
        "0" = ","; # decimal
        "1" = "."; # miles
        "10" = ","; # decimal monetario
        "11" = "."; # miles monetario
      };

      # Formato de fecha: dd-MMM-yyyy (ej: 10-Oct-2026)
      AppleICUDateFormatStrings = {
        "1" = "dd-MM-yy";
        "2" = "dd-MMM-yyyy";
        "3" = "dd-MMM-yyyy";
        "4" = "EEEE, dd 'de' MMMM 'de' yyyy";
      };

      # Hora 24h HH:mm
      AppleICUTimeFormatStrings = {
        "1" = "HH:mm";
        "2" = "HH:mm:ss";
        "3" = "HH:mm:ss z";
        "4" = "HH:mm:ss zzzz";
      };
    };
  };
}
