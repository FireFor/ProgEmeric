require("testriste");
require("lovecallbacks");

--configuration, initialisation et calculs
function love.load()
	math.randomseed(os.time()) --on veut des nombres pseudo al�atoires � peu pr�s r�alistes
	
	bloc_marge_initiale = nil --d�calage horizontal pour centrer les nouvelles pi�ces (en bloc de pi�ce)
	bloc_taille = nil --largeur d'un bloc de pi�ce = puissance de 2 maximum (en pixels)
	bool_clavier_action = false --drapeau marquant l'utilisation d'une touche d'action (bool�en)
	bool_clavier_action_tournante = false --drapeau marquant l'utilisation d'une touche d'action de tournante (bool�en)
	bool_fin_de_partie = false --drapeau marquant la fin du jeu (bool�en)
	compteur_de_temps = 0.0 --compteur de temps pour savoir quand faire quoi (en secondes)
	compteur_de_temps_clavier = 0.0 --compteur de temps pour savoir quand faire quoi, version clavier (en secondes)
	compteur_de_temps_clavier_maximum = nil --temps entre chaque touche d'action (en secondes)
	compteur_de_temps_coefficient = 0.95 --coefficient pour acc�l�rer le temps d'un tour (en % / 100)
	compteur_de_temps_maximum = 0.5 --temps d'un tour (en secondes)
	couleurs = {} --couleurs
	matrice = {} --tableau multi-dimensionnel contenant nos pi�ces et blocs (pour stocker des lignes puis des colonnes de blocs de pi�ces)
	matrice_hauteur = 14 --hauteur de la matrice (en bloc de pi�ce)
	matrice_largeur = 7 --largeur de la matrice (en bloc de pi�ce)
	matrice_marge_hauteur = nil --d�calage vertical pour centrer la matrice (en pixels)
	matrice_marge_largeur = nil --d�calage horizontal pour centrer la matrice (en pixels)
	nombre_actions_par_tour = 0.125 --coefficient d�terminant le nombre d'actions par tour (pas d'unit� ?)
	piece_en_mouvement_centre = {0, 0} --coordonn�es {y, x} du "centre" de la pi�ce en cours de mouvement (en bloc de matrice {ligne, colonne})
	piece_en_mouvement_rotation = 0 --rotation de la pi�ce en cours de mouvement (en degr�)
	piece_en_mouvement_type = 0 --type de la pi�ce en cours de mouvement (de 1 � 7 inclus cf variables couleurs & pieces)
	piece_en_mouvement_type_prochain = 0 --prochain type de la pi�ce en cours de mouvement (de 1 � 7 inclus cf variables couleurs & pieces)
	score_tetris = 0.00 --score du jeu.
	pieces = {} --pieces
	
	--format RGB/RVB sur un octet (de 0 � 255)
	couleurs[1] = {0, 255, 255} --cyan pour I
	couleurs[2] = {0, 0, 255} --bleu pour J
	couleurs[3] = {255, 127, 0} --orange pour L
	couleurs[4] = {255, 255, 0} --jaune pour O
	couleurs[5] = {0, 255, 0} --vert pour S
	couleurs[6] = {255, 0, 255} --violet pour T
	couleurs[7] = {255, 0, 0} --rouge pour Z
	couleurs[8] = {255, 255, 255} --blanc
	
	--jeu de 4 coordonn�es {y, x} d�crivant la pi�ce sans rotation
	--attention il faut y >= 0
	--le centre de la pi�ce correspond � x = 0
	pieces[1] = {{0, -1}, {0, 0}, {0, 1}, {0, 2}} --I
	pieces[2] = {{0, -2}, {0, -1}, {0, 0}, {1, 0}} --J
	pieces[3] = {{0, 0}, {0, 1}, {0, 2}, {1, 0}} --L
	pieces[4] = {{0, 0}, {0, 1}, {1, 0}, {1, 1}} --O
	pieces[5] = {{0, 0}, {0, 1}, {1, -1}, {1, 0}} --S
	pieces[6] = {{0, -1}, {0, 0}, {0, 1}, {1, 0}} --T
	pieces[7] = {{0, -1}, {0, 0}, {1, 0}, {1, 1}} --Z
	
	bloc_marge_initiale = math.floor(matrice_largeur / 2.0)
	bloc_taille = math.pow(2, math.floor(math.log(math.min(love.graphics:getWidth(), love.graphics:getHeight()) / math.max(matrice_largeur, matrice_hauteur)) / math.log(2)))
	compteur_de_temps_clavier_maximum = nombre_actions_par_tour * compteur_de_temps_maximum
	matrice_marge_hauteur = (love.graphics:getHeight() - matrice_hauteur * bloc_taille) / 2
	matrice_marge_largeur = (love.graphics:getWidth() - matrice_largeur * bloc_taille) / 2
	piece_en_mouvement_type_prochain = math.random(7)
	
	for y = 1, matrice_hauteur do --pour chaque ligne de matrice...
		matrice[y] = {} --cr�ation de la ligne y
		
		for x = 1, matrice_largeur do --pour chaque colonne de la matrice...
			matrice[y][x] = 0 --bloc vide ins�r� dans la ligne y et la colonne x
		end
	end
end
