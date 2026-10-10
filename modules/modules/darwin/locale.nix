# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Locale: UI en inglés, región Chile — moneda CLP, métrico, Celsius,
# separador de miles ".", decimal ",", fecha dd-MMM-yyyy, hora HH:mm.
_: {
  flake.darwinModules.locale = {
    system = {
      defaults.NSGlobalDomain = {
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
      };

      defaults.CustomUserPreferences = {
        "NSGlobalDomain" = {
          # Región Chile (UI sigue en inglés vía AppleLanguages)
          AppleLocale = "es_CL@currency=CLP";

          # Separadores numéricos: miles "." decimal ","
          AppleICUNumberSymbols = {
            "0" = ",";
            "1" = ".";
            "10" = ",";
            "11" = ".";
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

          AppleICUForce24HourTime = true;
        };

        "com.apple.menuextra.clock" = {
          ShowAMPM = 0;
          ShowDate = 1;
          ShowDayOfWeek = 1;
          DateFormat = "EEE dd-MMM HH:mm";
        };
      };
    };
  };
}
