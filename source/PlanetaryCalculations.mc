import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;

class PlanetaryCalculations {
    
    // Périodes orbitales en jours terrestres
    static const MERCURY_PERIOD = 87.97;
    static const VENUS_PERIOD = 224.70;
    static const MARS_PERIOD = 686.98;
    static const JUPITER_PERIOD = 4332.59;
    static const SATURN_PERIOD = 10759.22;
    
    // Rayons orbitaux relatifs (en pourcentage du rayon disponible)
    static const SUN_RADIUS = 0.15;
    static const MERCURY_ORBIT = 0.25;
    static const VENUS_ORBIT = 0.40;//0.35;
    static const MARS_ORBIT = 0.58;//0.50;
    static const JUPITER_ORBIT = 0.78;//0.65;
    static const SATURN_ORBIT = 0.97;//0.80;
    
    // Tailles des planètes (rayon en pixels)
    static const SUN_SIZE = 17;//8;
    static const MERCURY_SIZE = 7;//2;
    static const VENUS_SIZE = 8;//3;
    static const MARS_SIZE = 8;//3;
    static const JUPITER_SIZE = 11;//6;
    static const SATURN_SIZE = 10;//5;

    // Calcule l'angle d'une planète basé sur le temps écoulé
    static function calculatePlanetAngle(period as Float, epochOffset as Float) as Float {
        var now = Time.now();
        var daysSinceEpoch = (now.value() / 86400.0) + epochOffset;
        var cycles = daysSinceEpoch / period;
        var angle = (cycles - Math.floor(cycles)) * 2 * Math.PI;
        return angle;
    }
    
    // Calcule la position d'une planète
    static function calculatePlanetPosition(centerX as Number, centerY as Number, 
                                         radius as Float, angle as Float) as Array<Number> {
        var x = centerX + (radius * Math.cos(angle));
        var y = centerY + (radius * Math.sin(angle));
        return [x.toNumber(), y.toNumber()];
    }
    
    // Données des planètes
    static function getPlanetData() as Array<Dictionary> {
        return [
            {
                :name => "Mercury",
                :period => MERCURY_PERIOD,
                :orbit => MERCURY_ORBIT,
                :size => MERCURY_SIZE,
                :color => 0xC0C0C0, // Gris clair
                :offset => 0.0
            },
            {
                :name => "Venus",
                :period => VENUS_PERIOD,
                :orbit => VENUS_ORBIT,
                :size => VENUS_SIZE,
                :color => 0xFFFFFF, // Blanc
                :offset => 50.0
            },
            {
                :name => "Mars",
                :period => MARS_PERIOD,
                :orbit => MARS_ORBIT,
                :size => MARS_SIZE,
                :color => 0xFF4500, // Rouge
                :offset => 100.0
            },
            {
                :name => "Jupiter",
                :period => JUPITER_PERIOD,
                :orbit => JUPITER_ORBIT,
                :size => JUPITER_SIZE,
                :color => 0xFF8C00, // Orange
                :offset => 150.0
            },
            {
                :name => "Saturn",
                :period => SATURN_PERIOD,
                :orbit => SATURN_ORBIT,
                :size => SATURN_SIZE,
                :color => 0xFFD700, // Jaune
                :offset => 200.0
            }
        ];
    }
}