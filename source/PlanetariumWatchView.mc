import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.ActivityMonitor;

class PlanetariumWatchView extends WatchUi.WatchFace {

    private var _centerX as Number = 0;
    private var _centerY as Number = 0;
    private var _radius as Number = 0;
    private var _radiusMarkers as Number = 0;
    private var _hasNotifications as Boolean = false;
    private var _isInSleepMode = false;


    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _centerX = dc.getWidth() / 2;
        _centerY = dc.getHeight() / 2;
        _radius = (_centerX < _centerY ? _centerX : _centerY) - 20;
        _radiusMarkers = dc.getWidth() /2;
    }

    function onUpdate(dc as Dc) as Void {
         // Fond bleu nuit étoilé
        dc.setColor(0x001133, 0x001133);
        dc.clear();

        // Test sleep mode
        //_isInSleepMode = true;
        // Test sleep mode

        if (!_isInSleepMode) {
            drawConcentricBackground(dc);
            drawStarField(dc);
            drawHourMarkers(dc);
            drawCurvedMonth(dc); 
            drawPlanets(dc);
            drawHourIndicator(dc); 
            drawNotificationStar(dc);
            // Informations système (optionnel)
            drawSystemInfo(dc);
            drawShootingStar(dc);
        }
        if (_isInSleepMode) {      
            var clockTime = System.getClockTime();
            var hours = clockTime.hour;
            var minutes = clockTime.min;
            drawNebulaSleepMode(dc,hours,minutes);
        }
    }


    private function drawConcentricBackground(dc as Dc) as Void {
        // Couleurs du dégradé du plus foncé au plus clair
        /*
        var colors = [
            0x000811,  // Bleu nuit très très foncé (centre)
            0x001122,  // Bleu nuit très foncé
            0x001833,  // Bleu nuit foncé
            0x002244,  // Bleu nuit moyen
            0x003355   // Bleu nuit plus clair (extérieur)
        ];
        */
        var colors = [
            0x000510, // Centre: Bleu très très sombre
            0x000A18,
            0x001020,
            0x001528,
            0x001A30,
            0x002038,
            0x002540,
            0x003048,
            0x003550,
            0x004060  // Extérieur: Bleu nuit plus clair
        ];
        var maxRadius = _radius + 20;
        var numRings = colors.size();
        
        // Dessiner les cercles concentriques du plus grand au plus petit
        for (var i = numRings - 1; i >= 0; i--) {
            var ringRadius = maxRadius * (i + 1) / numRings;
            dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(_centerX, _centerY, ringRadius);
        }
    }

    private function drawStarField(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Vous pouvez ajuster le nombre d'étoiles ici
        var numStars = 200;
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Utilise une graine (seed) constante pour que le champ d'étoiles soit
        // identique à chaque appel. C'est un simple générateur pseudo-aléatoire.
        var seed = 1;

        for (var i = 0; i < numStars; i++) {
            // Génère une coordonnée X pseudo-aléatoire
            seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var x = seed % width;

            // Génère une coordonnée Y pseudo-aléatoire
            seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var y = seed % height;

            // Fait varier la taille des étoiles pour un effet plus naturel
            // 30% des étoiles seront un peu plus grandes.
            seed = (seed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var size = (seed % 10 > 7) ? 2 : 1;

            dc.fillCircle(x, y, size);
        }
    }

    private function drawHourMarkers(dc as Dc) as Void {
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        
        var outerRadius = _radiusMarkers - 5;
        var innerRadius = _radiusMarkers - 20; // Allongé de 15 à 20 (5 pixels de plus)
        
        // Dessiner les traits d'heures
        for (var i = 0; i < 24; i++) {
            var angle = (i * Math.PI * 2) / 24 - Math.PI / 2;
            var cos = Math.cos(angle);
            var sin = Math.sin(angle);
            
            var x1 = _centerX + outerRadius * cos;
            var y1 = _centerY + outerRadius * sin;
            var x2 = _centerX + innerRadius * cos;
            var y2 = _centerY + innerRadius * sin;
            
            dc.drawLine(x1, y1, x2, y2);
            
            // Ajouter 3 points entre ce trait et le suivant
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT); // Couleur or pour les points
            for (var j = 1; j <= 3; j++) {
                // Calculer l'angle pour chaque point (répartition égale)
                var nextHourAngle = ((i + 1) * Math.PI * 2) / 24 - Math.PI / 2;
                var pointAngle = angle + (nextHourAngle - angle) * j / 4;
                
                var pointCos = Math.cos(pointAngle);
                var pointSin = Math.sin(pointAngle);
                
                // Position des points (plus près du bord extérieur)
                var pointRadius = _radiusMarkers - 8;
                var pointX = _centerX + pointRadius * pointCos;
                var pointY = _centerY + pointRadius * pointSin;
                
                // Dessiner le point
                dc.fillCircle(pointX, pointY, 1);
            }
        }
        
        // Numéros des heures principales
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);  
        dc.drawText(_centerX, _centerY - _radiusMarkers * 0.92, Graphics.FONT_XTINY, "0", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _centerY + _radiusMarkers * 0.78, Graphics.FONT_XTINY, "12", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX - _radiusMarkers * 0.82, _centerY - _radiusMarkers * 0.08, Graphics.FONT_XTINY, "18", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX + _radiusMarkers * 0.82, _centerY - _radiusMarkers * 0.08, Graphics.FONT_XTINY, "6", Graphics.TEXT_JUSTIFY_CENTER);
    }
/*
    // NOUVELLE FONCTION pour dessiner le mois en suivant une courbe
    private function drawCurvedMonth(dc as Dc) as Void {
        // Récupérer le nom du mois en toutes lettres et en majuscules
        var today = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var monthString = today.month.toUpper();

        // Définir les paramètres pour le texte courbe
        var font = Graphics.FONT_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Le rayon où le texte sera dessiné (légèrement à l'intérieur des marqueurs d'heure)
        var textRadius = _radiusMarkers - 28;

        // L'angle de séparation entre chaque lettre (à ajuster pour un espacement idéal)
        var anglePerChar = 0.12; // en radians

        // Calculer l'angle total nécessaire pour tout le mot
        var totalAngle = monthString.length() * anglePerChar;

        // Définir l'angle de départ pour que le mot soit centré autour de la position 2h
        // Angle pour 2h = (2/24) * 2*PI, et on décale de -PI/2 car 0h est en haut
        var centerAngle = (2.0 / 24.0) * Math.PI * 2 - Math.PI / 2;
        var startAngle = centerAngle - (totalAngle / 2.0);

        // Boucler sur chaque lettre du mois pour la dessiner
        for (var i = 0; i < monthString.length(); i++) {
            var charAngle = startAngle + (i * anglePerChar);
            var char = monthString.substring(i, i + 1);

            // Calculer les coordonnées X et Y pour la lettre sur l'arc de cercle
            var x = _centerX + textRadius * Math.cos(charAngle);
            var y = _centerY + textRadius * Math.sin(charAngle);

            // Dessiner la lettre. La justification centrée (verticalement et horizontalement)
            // est importante pour un bon alignement.
            dc.drawText(x, y, font, char, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
*/
    // NOUVELLE FONCTION pour dessiner le mois en suivant une courbe
    private function drawCurvedMonth(dc as Dc) as Void {
        // NOUVEAU : Tableau des noms des mois en anglais
        var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

        // On récupère les informations de date avec le mois en tant que NUMÉRO (1-12)
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var monthNumber = today.month;

        // On sélectionne le nom du mois en anglais dans notre tableau
        // (on soustrait 1 car les tableaux commencent à l'index 0)
        var monthString = monthNames[monthNumber - 1];

        // Le reste de la fonction est inchangé et dessinera le mot anglais
        var font = Graphics.FONT_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var textRadius = _radiusMarkers - 28;
        var anglePerChar = 0.12; 
        var totalAngle = monthString.length() * anglePerChar;
        var centerAngle = (2.0 / 24.0) * Math.PI * 2 - Math.PI / 2;
        var startAngle = centerAngle - (totalAngle / 2.0);

        for (var i = 0; i < monthString.length(); i++) {
            var charAngle = startAngle + (i * anglePerChar);
            var char = monthString.substring(i, i + 1);

            var x = _centerX + textRadius * Math.cos(charAngle);
            var y = _centerY + textRadius * Math.sin(charAngle);

            dc.drawText(x, y, font, char, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawPlanets(dc as Dc) as Void {
        var planets = PlanetaryCalculations.getPlanetData();
        var maxRadius = _radius * 0.8;
        
        // Dessiner le Soleil au centre
        dc.setColor(0xFFFF00, Graphics.COLOR_TRANSPARENT); // Jaune
        dc.fillCircle(_centerX, _centerY, PlanetaryCalculations.SUN_SIZE);

        // Ajouter un cercle orange sur le bord du Soleil
        dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT); // Orange
        dc.setPenWidth(2);
        dc.drawCircle(_centerX, _centerY, PlanetaryCalculations.SUN_SIZE);
        
        // Dessiner les orbites (cercles de guidage subtils)
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < planets.size(); i++) {
            var planet = planets[i];
            var orbitRadius = maxRadius * planet[:orbit];
            dc.drawCircle(_centerX, _centerY, orbitRadius);
        }
        
        // Dessiner les planètes
        for (var i = 0; i < planets.size(); i++) {
            var planet = planets[i];
            var angle = PlanetaryCalculations.calculatePlanetAngle(
                planet[:period], planet[:offset]
            );
            var orbitRadius = maxRadius * planet[:orbit];
            var position = PlanetaryCalculations.calculatePlanetPosition(
                _centerX, _centerY, orbitRadius, angle
            );
            
            dc.setColor(planet[:color], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(position[0], position[1], planet[:size]);

            // Dessiner les anneaux de Saturne
            if (planet[:name].equals("Saturn")) {
                drawSaturnRings(dc, position[0], position[1], planet[:size]);
            }

            // Dessiner la Grande Tache Rouge de Jupiter
            if (planet[:name].equals("Jupiter")) {
                drawJupiterSpot(dc, position[0], position[1], planet[:size], angle);
            }

        }
    }

    // Nouvelle fonction pour dessiner les anneaux de Saturne
    private function drawSaturnRings(dc as Dc, planetX as Number, planetY as Number, planetSize as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        
        // Calculer la longueur du trait des anneaux (proportionnelle à la taille de la planète)
        var ringLength = planetSize * 2.5;
        var ringOffset = ringLength / 2;
        
        // Angle d'inclinaison des anneaux (peut être ajusté pour l'effet visuel)
        var ringAngle = Math.PI / 6; // 30 degrés d'inclinaison
        
        // Calculer les points de début et fin du trait
        var startX = planetX - ringOffset * Math.cos(ringAngle);
        var startY = planetY - ringOffset * Math.sin(ringAngle);
        var endX = planetX + ringOffset * Math.cos(ringAngle);
        var endY = planetY + ringOffset * Math.sin(ringAngle);
        
        // Dessiner le trait principal des anneaux
        dc.drawLine(startX, startY, endX, endY);
        
        // Optionnel : ajouter un deuxième anneau plus fin et plus long
        dc.setPenWidth(1);
        var outerRingLength = planetSize * 3;
        var outerRingOffset = outerRingLength / 2;
        
        var outerStartX = planetX - outerRingOffset * Math.cos(ringAngle);
        var outerStartY = planetY - outerRingOffset * Math.sin(ringAngle);
        var outerEndX = planetX + outerRingOffset * Math.cos(ringAngle);
        var outerEndY = planetY + outerRingOffset * Math.sin(ringAngle);
        
        dc.drawLine(outerStartX, outerStartY, outerEndX, outerEndY);
    }

    // Nouvelle fonction pour dessiner la Grande Tache Rouge de Jupiter
    private function drawJupiterSpot(dc as Dc, planetX as Number, planetY as Number, planetSize as Number, planetAngle as Float) as Void {
        // Position fixe de la tache par rapport à Jupiter (par exemple à 45° de sa "face")
        var spotAngle = planetAngle + Math.PI / 4; // 45° par rapport à la direction orbitale
        var spotDistance = planetSize * 0.6; // Distance du centre de Jupiter
        
        // Calculer la position de la tache
        var spotX = planetX + spotDistance * Math.cos(spotAngle);
        var spotY = planetY + spotDistance * Math.sin(spotAngle);
        
        // Dessiner la Grande Tache Rouge (petite ellipse rouge)
        dc.setColor(0xFF4500, Graphics.COLOR_TRANSPARENT); // Rouge-orange
        dc.fillCircle(spotX, spotY, planetSize / 4); // Taille proportionnelle à Jupiter
        
        // Optionnel : ajouter quelques bandes nuageuses
        dc.setColor(0xDDDDDD, Graphics.COLOR_TRANSPARENT); // Gris clair
        dc.setPenWidth(1);
        
        // Bande équatoriale
        var bandY1 = planetY - planetSize * 0.3;
        var bandY2 = planetY + planetSize * 0.3;
        
        dc.drawLine(planetX - planetSize, bandY1, planetX + planetSize, bandY1);
        dc.drawLine(planetX - planetSize, bandY2, planetX + planetSize, bandY2);
    }


    private function drawShootingStar(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        
        // Calcul de la position sur 24h (et non 12h)
        // L'angle commence à 0h en haut (12h position) et tourne dans le sens horaire
        var totalMinutes = clockTime.hour * 60 + clockTime.min + clockTime.sec / 60.0;
        var angle24h = (totalMinutes / (24 * 60)) * Math.PI * 2 - Math.PI / 2;
        
        // Une seule étoile filante indiquant le temps sur 24h
        var starRadius = _radius * 0.88; // Position entre les orbites planétaires
        var starX = _centerX + starRadius * Math.cos(angle24h);
        var starY = _centerY + starRadius * Math.sin(angle24h);
        
        // Dessiner l'étoile filante principale (AGRANDIE)
        drawStar(dc, starX, starY, 15, Graphics.COLOR_DK_RED); // Taille augmentée de 10 à 18
        
        // Arc de cercle léger pour la traînée (suit la trajectoire circulaire)
        dc.setPenWidth(4);
        dc.setColor(0xFF8C00, Graphics.COLOR_TRANSPARENT);
        
        // Calculer l'arc en arrière de l'étoile (sens inverse de rotation)
        var arcLength = 0.15; // Longueur de l'arc en radians (environ 8.6 degrés)
        var startArcAngle = angle24h - arcLength;
        var endArcAngle = angle24h;
        
        // Dessiner l'arc principal
        drawArc(dc, _centerX, _centerY, starRadius, startArcAngle, endArcAngle);
        
        // Arc de dégradé plus léger et plus long
        dc.setPenWidth(2);
        dc.setColor(0xFFB347, Graphics.COLOR_TRANSPARENT);
        var extendedArcLength = 0.25; // Arc plus long pour l'effet de dégradé
        var extendedStartAngle = angle24h - extendedArcLength;
        drawArc(dc, _centerX, _centerY, starRadius, extendedStartAngle, startArcAngle);
        
        // Ajout d'un halo autour de l'étoile pour plus de visibilité
        dc.setPenWidth(2);
        dc.setColor(0xFF4500, Graphics.COLOR_TRANSPARENT); // Rouge-orange plus vif
        dc.drawCircle(starX, starY, 17); // Cercle de halo autour de l'étoile

    }

    // Fonction helper pour dessiner un arc de cercle
    private function drawArc(dc , centerX , centerY , radius , startAngle , endAngle) as Void {
        var numSegments = 8; // Nombre de segments pour approximer l'arc
        var angleStep = (endAngle - startAngle) / numSegments;
        
        var prevX = centerX + radius * Math.cos(startAngle);
        var prevY = centerY + radius * Math.sin(startAngle);
        
        for (var i = 1; i <= numSegments; i++) {
            var currentAngle = startAngle + i * angleStep;
            var currentX = centerX + radius * Math.cos(currentAngle);
            var currentY = centerY + radius * Math.sin(currentAngle);
            
            dc.drawLine(prevX, prevY, currentX, currentY);
            
            prevX = currentX;
            prevY = currentY;
        }
    }


    // NOUVELLE FONCTION : Point rouge indiquant l'heure exacte sur le cadran
    private function drawHourIndicator(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        
        // Calcul de la position exacte sur 24h avec les minutes
        var totalMinutes = clockTime.hour * 60 + clockTime.min;
        var angle24h = (totalMinutes / (24 * 60.0)) * Math.PI * 2 - Math.PI / 2;
        
        // Position du point rouge au niveau des marques (même rayon que les marques dorées)
        var indicatorRadius = _radiusMarkers - 12; // Même position que les marques dorées
        var indicatorX = _centerX + indicatorRadius * Math.cos(angle24h);
        var indicatorY = _centerY + indicatorRadius * Math.sin(angle24h);
        
        // Dessiner le point rouge
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(indicatorX, indicatorY, 4); // Point de taille 4
        
        // Ajouter un contour blanc pour une meilleure visibilité
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(indicatorX, indicatorY, 4);
    }

    private function drawStar(dc, centerX, centerY, size, color) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        
        var points = new Array<Array<Number>>[10];
        for (var i = 0; i < 10; i++) {
            var angle = i * Math.PI / 5;
            var radius = (i % 2 == 0) ? size : size / 2;
            var x = centerX + radius * Math.cos(angle - Math.PI / 2);
            var y = centerY + radius * Math.sin(angle - Math.PI / 2);
            points[i] = [x.toNumber(), y.toNumber()];
        }
        
        dc.fillPolygon(points);
    }

    private function drawNotificationStar(dc as Dc) as Void {
        var settings = System.getDeviceSettings();
        _hasNotifications = settings.notificationCount > 0;
        
        if (_hasNotifications) {
            // Étoile de notification en haut
            drawStar(dc, _centerX, _centerY - _radius + 30, 12, 0xFF6B6B);
        }
    }

    // NOUVELLE FONCTION pour dessiner la date et l'icône de batterie en courbe
    private function drawSystemInfo(dc as Dc) as Void {
        // --- 1. Dessin de la date en courbe avec espacement ---
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayString = today.day.format("%02d");

        var font = Graphics.FONT_XTINY;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var textRadius = _radiusMarkers - 28;
        
        // Espacement de base entre les centres des caractères
        var baseSpacing = 0.12; 
        // NOUVEAU : Espace supplémentaire à ajouter
        var extraSpaceAngle = 0.02; // Ajustez cette valeur pour plus/moins d'espace

        // L'angle de la position centrale (4h30) reste notre référence
        var centerAngle = (3.5 / 24.0) * Math.PI * 2 - Math.PI / 2;
        
        // L'écart total entre les centres des deux chiffres sera la somme des espacements
        var totalSpacing = baseSpacing + extraSpaceAngle;

        // Calculer l'angle pour chaque chiffre en se basant sur le centre
        var tensAngle = centerAngle - (totalSpacing / 2.0);
        var unitsAngle = centerAngle + (totalSpacing / 2.0);

        // Dessiner le premier chiffre (dizaines)
        var tensChar = dayString.substring(0, 1);
        var x1 = _centerX + textRadius * Math.cos(tensAngle);
        var y1 = _centerY + textRadius * Math.sin(tensAngle);
        dc.drawText(x1, y1, font, tensChar, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Dessiner le second chiffre (unités)
        var unitsChar = dayString.substring(1, 2);
        var x2 = _centerX + textRadius * Math.cos(unitsAngle);
        var y2 = _centerY + textRadius * Math.sin(unitsAngle);
        dc.drawText(x2, y2, font, unitsChar, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);


        // --- 2. Vérification et dessin de l'icône de batterie ---
        var stats = System.getSystemStats();
        if (stats.battery < 20) {
            // Positionner l'étoile juste après le chiffre des unités
            var starAngle = unitsAngle + baseSpacing * 1.5;
            
            var starX = _centerX + textRadius * Math.cos(starAngle);
            var starY = _centerY + textRadius * Math.sin(starAngle);
            
            drawStar(dc, starX, starY, 12, Graphics.COLOR_RED);
        }
    }

    function drawNebulaSleepMode(dc, hours, minutes) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();     
        // 1. Dessiner un arrière-plan d'étoiles discret
        drawFloatingParticles(dc, 30);     
        // 2. Dessiner une "suggestion" de nébuleuse avec des couleurs légèrement plus claires
        drawNebulaEffect(dc, _centerX, _centerY, (hours * 60 + minutes));        
        // 3. Dessiner l'heure de manière sobre mais visible
        // Heures dans le quart haut
        var hoursY = _centerY - (dc.getHeight() * 0.25);
        drawMinimalisteSleepModeTime(dc, hours.format("%02d"), _centerX, hoursY, Graphics.FONT_SYSTEM_LARGE);
        
        // Minutes décalées vers le bas et légèrement à droite
        var minutesX = _centerX + (dc.getWidth() * 0.1);
        var minutesY = _centerY - (dc.getHeight() * 0.05);
        drawMinimalisteSleepModeTime(dc, minutes.format("%02d"), minutesX, minutesY, Graphics.FONT_SYSTEM_LARGE);

    }

    function drawNebulaEffect(dc, centerX, centerY, seed) {
        // Palette de gris un peu plus clairs
        var colors = [0x222222, 0x333333, 0x2A2A2A]; 
        var localSeed = seed;
        // Augmentation du nombre de particules pour un effet plus dense
        var particleCount = 25;

        for (var i = 0; i < particleCount; i++) {
            localSeed = (localSeed * 1664525 + 1013904223) & 0x7FFFFFFF;
            
            var angle = (localSeed.toFloat() / 0x7FFFFFFF) * 2 * Math.PI;
            
            localSeed = (localSeed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var radius = (localSeed % (dc.getWidth() / 4)).abs();
            
            var x = centerX + radius * Math.cos(angle);
            var y = centerY + radius * Math.sin(angle);
            
            // Taille des bulles considérablement agrandie
            localSeed = (localSeed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var size = (localSeed % 80) + 50; // Tailles entre 50 et 129 (au lieu de 25-69)
            
            localSeed = (localSeed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var color = colors[localSeed % colors.size()];

            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x.toNumber(), y.toNumber(), size);
        }
    }

    function drawFloatingParticles(dc, count) {
        var localSeed = 12345; 
        for (var i = 0; i < count; i++) {
            localSeed = (localSeed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var x = localSeed % dc.getWidth();
            localSeed = (localSeed * 1664525 + 1013904223) & 0x7FFFFFFF;
            var y = localSeed % dc.getHeight();
            
            // Mélange de gris sombres et clairs pour plus de visibilité
            var color = (localSeed % 10 > 7) ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY;
            
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 1);
        }
    }
        
    function drawMinimalisteSleepModeTime(dc, text, x, y, font) {     
        // Texte en blanc pour une lisibilité maximale en mode veille
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {
        _isInSleepMode = true;
    }

    function onShow() as Void {
        _isInSleepMode = false;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        _isInSleepMode = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _isInSleepMode = true;
    }

    function onPartialUpdate(dc as Dc) as Void {
        // Mise à jour partielle pour économiser la batterie
    }

}