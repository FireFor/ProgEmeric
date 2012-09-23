-- program under public domain or creative commons CC0, as you prefer
-- programme dans le domaine publique ou sous la licence creative commons CCO, � votre guise

-- testriste, un *magnifique* jeu pour d�couvrir love2d (et lua)

-- --------------------------------------------------
-- a faire (peut-�tre)
--
-- touche haut = pivot de la pi�ce
-- animations
-- gestion des lignes remplies
-- score
-- passer le debug en affichage dans l'�cran
-- --------------------------------------------------

--configuration, initialisation et calculs
function love.load()
	math.randomseed(os.time()) --on veut des nombres pseudo al�atoires � peu pr�s r�alistes
	
	bloc_marge_initiale = nil --d�calage horizontal pour centrer les nouvelles pi�ces (en bloc de pi�ce)
	bloc_taille = nil --largeur d'un bloc de pi�ce = puissance de 2 maximum (en pixels)
	compteur_de_temps = 0.0 --compteur de temps pour savoir quand faire quoi (en secondes)
	compteur_de_temps_clavier = 0.0 --compteur de temps pour savoir quand faire quoi, version clavier (en secondes)
	compteur_de_temps_clavier_maximum = nil --temps entre chaque touche d'action (en secondes)
	compteur_de_temps_coefficient = 0.995 --coefficient pour acc�l�rer le temps d'un tour (en % / 100)
	compteur_de_temps_maximum = 0.5 --temps d'un tour (en secondes)
	couleurs = {} --couleurs
	fin_de_partie = false --drapeau marquant la fin du jeu (bool�en)
	matrice = {} --tableau multi-dimensionnel contenant nos pi�ces et blocs (pour stocker des lignes puis des colonnes de blocs de pi�ces)
	matrice_hauteur = 14 --hauteur de la matrice (en bloc de pi�ce)
	matrice_largeur = 7 --largeur de la matrice (en bloc de pi�ce)
	matrice_marge_hauteur = nil --d�calage vertical pour centrer la matrice (en pixels)
	matrice_marge_largeur = nil --d�calage horizontal pour centrer la matrice (en pixels)
	nombre_actions_par_tour = 0.125 --coefficient d�terminant le nombre d'actions par tour (pas d'unit� ?)
	piece_en_mouvement = {0, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}} --pi�ce en cours de mouvement (couleur puis coordonn�es (ligne, colonne))
	piece_en_mouvement_rotation = {0, {0, 0}, 0} --pi�ce en cours de mouvement (couleur puis coordonn�es principale (ligne, colonne) et enfin son �tat rotatif)
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
	
	for y = 1, matrice_hauteur do --pour chaque ligne de matrice...
		matrice[y] = {} --cr�ation de la ligne y
		
		for x = 1, matrice_largeur do --pour chaque colonne de la matrice...
			matrice[y][x] = 0 --bloc vide ins�r� dans la ligne y et la colonne x
		end
	end
	
	--debug
	print('bloc_marge_initiale = ', bloc_marge_initiale)
	print('bloc_taille = ', bloc_taille)
	print('compteur_de_temps_clavier_maximum = ', compteur_de_temps_clavier_maximum)
	print('matrice_marge_hauteur = ', matrice_marge_hauteur)
	print('matrice_marge_largeur = ', matrice_marge_largeur)
end

function debug_matrice(m)
	for i,v in ipairs(m) do for i2,v2 in ipairs(v) do print('m[', i, '][', i2, '] = ', v2) end end
end

function debug_piece(p)
	for i,v in ipairs(p) do for i2,v2 in ipairs(v) do print('p[', i, '][', i2, '] = ', v2) end end
end

function donne_la_position_de_la_piece(t, y, x, r) --Type, position Y, position X, Rotation
	piece = {}
	
	--description de la pi�ce suivant le type choisi (t) avec le centrage (y;x)
	if t == 1 then  -- Type de pi�ce : Barre plate
		if r == 0 then -- En position 0�
			piece = {{y + 0, x - 1}, {y + 0, x + 0}, {y + 0, x + 1}, {y + 0, x + 2}} -- La pi�ce a pour "centre" le deuxieme block en partant de la gauche
		elseif r == 90 then -- En position 90�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y + 1, x + 0}, {y + 2, x + 0}}
		elseif r == 180 then -- En position 180�
			piece = {{y + 0, x + 1}, {y + 0, x + 0}, {y + 0, x - 1}, {y + 0, x - 2}}
		elseif r == 270 then -- En position 270�
			piece = {{y + 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 0}, {y - 2, x + 0}}
		end
	elseif t == 2 then  -- Type de pi�ce : "L" invers�
		if r == 0 then -- En position 0�
			piece = {{y - 1, x - 1}, {y + 0, x - 1}, {y + 0, x + 0}, {y + 0, x + 1}} -- La pi�ce a pour "centre" le deuxieme block de la grande barre
		elseif r == 90 then -- En position 90�
			piece = {{y - 1, x + 1}, {y - 1, x + 0}, {y + 0, x + 0}, {y + 1, x + 0}}
		elseif r == 180 then -- En position 180�
			piece = {{y + 1, x + 1}, {y + 0, x + 1}, {y + 0, x + 0}, {y + 0, x - 1}}
		elseif r == 270 then -- En position 270�
			piece = {{y + 1, x - 1}, {y + 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 0}}
		end		
	elseif t == 3 then  -- Type de pi�ce : "L" classique
		if r == 0 then -- En position 0�
			piece = {{y + 0, x - 1}, {y + 0, x + 0}, {y + 0, x + 1}, {y - 1, x + 1}} -- La pi�ce a pour "centre" le deuxieme block de la grande barre
		elseif r == 90 then -- En position 90�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y + 1, x + 0}, {y + 1, x + 1}}
		elseif r == 180 then -- En position 180�
			piece = {{y + 0, x + 1}, {y + 0, x + 0}, {y + 0, x - 1}, {y + 1, x - 1}}
		elseif r == 270 then -- En position 270�
			piece = {{y + 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 0}, {y - 1, x - 1}}
		end	
	elseif t == 4 then  -- Type de pi�ce : Carr�
		if r == 0 then -- En position 0�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 1}, {y + 0, x + 1}} -- La pi�ce a pour "centre" le coin bas gauche
		elseif r == 90 then -- En position 90�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 1}, {y + 0, x + 1}}
		elseif r == 180 then -- En position 180�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 1}, {y + 0, x + 1}}
		elseif r == 270 then -- En position 270�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y - 1, x + 1}, {y + 0, x + 1}}
		end	
	elseif t == 5 then  -- Type de pi�ce : "Z" invers�
		if r == 0 then -- En position 0�
			piece = {{y + 0, x - 1}, {y + 0, x + 0}, {y - 1, x + 0}, {y - 1, x + 1}} -- La pi�ce a pour "centre" le deuxieme block du milieu en bas
		elseif r == 90 then -- En position 90�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y + 0, x + 1}, {y + 1, x + 1}}
		elseif r == 180 then -- En position 180�
			piece = {{y + 0, x + 1}, {y + 0, x + 0}, {y + 1, x + 0}, {y + 1, x - 1}}
		elseif r == 270 then -- En position 270�
			piece = {{y + 1, x + 0}, {y + 0, x + 0}, {y + 0, x - 1}, {y - 1, x - 1}}
		end	
	elseif t == 6 then  -- Type de pi�ce : "T"
		if r == 0 then -- En position 0�
			piece = {{y + 0, x - 1}, {y + 0, x + 0}, {y - 1, x + 0}, {y + 0, x + 1}} -- La pi�ce a pour "centre" le deuxieme block de la grande barre
		elseif r == 90 then -- En position 90�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y + 0, x + 1}, {y + 1, x + 0}}
		elseif r == 180 then -- En position 180�
			piece = {{y + 0, x + 1}, {y + 0, x + 0}, {y + 1, x + 0}, {y + 0, x - 1}}
		elseif r == 270 then -- En position 270�
			piece = {{y + 1, x + 0}, {y + 0, x + 0}, {y + 0, x - 1}, {y - 1, x + 0}}
		end	
	elseif t == 7 then  -- Type de pi�ce : "Z" classique
		if r == 0 then -- En position 0�
			piece = {{y + 0, x + 1}, {y + 0, x + 0}, {y - 1, x + 0}, {y - 1, x - 1}} -- La pi�ce a pour "centre" le deuxieme block du milieu en bas
		elseif r == 90 then -- En position 90�
			piece = {{y + 1, x + 0}, {y + 0, x + 0}, {y + 0, x + 1}, {y - 1, x + 1}}
		elseif r == 180 then -- En position 180�
			piece = {{y + 0, x - 1}, {y + 0, x + 0}, {y + 1, x + 0}, {y + 1, x + 1}}
		elseif r == 270 then -- En position 270�
			piece = {{y - 1, x + 0}, {y + 0, x + 0}, {y + 0, x - 1}, {y + 1, x - 1}}
		end
	end
	
	return piece
end

function donne_la_piece(t, y, x) --Type, margin Y, margin X
	piece = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
	
	for s = 1, 4 do
		piece[s] = {pieces[t][s][1] + y, pieces[t][s][2] + x}
	end
	
	return piece
end

function suis_je_hors_limite(p, y, x) --Piece, offset Y, offset X
	for s = 1, 4 do
		if p[s][1] + y <= 0 or p[s][1] + y > matrice_hauteur or p[s][2] + x <= 0 or p[s][2] + x > matrice_largeur then
			return true --si un des blocs de la pi�ce est en dehors de la matrice, la r�ponse est oui
		end
	end
	
	return false --si on arrive jusqu'ici, la r�ponse est non
end

function puis_je_mettre_la_piece_sur_la_matrice(m, p, y, x) --matrice, Piece, offset Y, offset X
	for s = 1, 4 do
		if m[p[s][1] + y][p[s][2] + x] ~= 0 then
			return false --si la matrice contient d�j� quelque chose � un des blocs de la pi�ce, la r�ponse est non
		end
	end
	
	return true --si on arrive jusqu'ici, la r�ponse est oui
end

function decale_la_piece(p, y, x) --Piece, offset Y, offset X
	for s = 1, 4 do
		p[s] = {p[s][1] + y, p[s][2] + x}
	end
	
	return p
end

function tenter_de_bouger_la_piece(m, p, y, x) --matrice, Piece, offset Y, offset X
	if not suis_je_hors_limite(p, y, x) and puis_je_mettre_la_piece_sur_la_matrice(m, p, y, x) then
		p = decale_la_piece(p, y, x)
	end
	
	return p
end

function ecrit_la_piece_sur_la_matrice(m, p, t) --matrice, Piece, Type
	for s = 1, 4 do
		m[p[s][1]][p[s][2]] = t
	end
	
	return m
end

--calculs suivant le temps, coeur du jeu
function love.update(dt)
	compteur_de_temps = compteur_de_temps + dt --ajout du temps pass� depuis le dernier appel dans notre compteur
	
	--gestion du clavier servant � l'action (= qui restent appuy�es)
	if love.keyboard.isDown("left") or love.keyboard.isDown("right") or love.keyboard.isDown("down") or love.keyboard.isDown("up") then --moche, j'ai pas mieux pour le moment, un flag g�r� dans keypressed peut-�tre ?
		compteur_de_temps_clavier = compteur_de_temps_clavier + dt --ajout du temps pass� depuis le dernier appel dans notre compteur, version clavier
		
		if compteur_de_temps_clavier >= compteur_de_temps_clavier_maximum then
			if love.keyboard.isDown("left") then
				tenter_de_bouger_la_piece(matrice, piece_en_mouvement[2], 0, -1)
			elseif love.keyboard.isDown("right") then
				tenter_de_bouger_la_piece(matrice, piece_en_mouvement[2], 0, 1)
			elseif love.keyboard.isDown("down") then
				tenter_de_bouger_la_piece(matrice, piece_en_mouvement[2], 1, 0)
			elseif love.keyboard.isDown("up") then
				--hum
			end
			
			compteur_de_temps_clavier = compteur_de_temps_clavier - compteur_de_temps_clavier_maximum
		end
	end
	
	if compteur_de_temps >= compteur_de_temps_maximum then --a-t-on fini un tour ?
		if piece_en_mouvement[1] == 0 then --doit-on g�n�rer une nouvelle pi�ce ?
			piece_en_mouvement[1] = math.random(7) --lancer de d�
			piece_en_mouvement[2] = donne_la_piece(piece_en_mouvement[1], 1, bloc_marge_initiale) --donne moi une nouvelle pi�ce !
			
			fin_de_partie = not puis_je_mettre_la_piece_sur_la_matrice(matrice, piece_en_mouvement[2], 0, 0) --si la pi�ce nouvellement cr�� tente d'�craser des blocs d�j� pr�sent, game over
		else --pas de nouvelle pi�ce � g�n�rer
			--tentons de faire descendre l'actuelle
			if not suis_je_hors_limite(piece_en_mouvement[2], 1, 0) and puis_je_mettre_la_piece_sur_la_matrice(matrice, piece_en_mouvement[2], 1, 0) then --semblable � tenter_de_bouger_la_piece, on ne pourrait pas l'utiliser ?
				piece_en_mouvement[2] = decale_la_piece(piece_en_mouvement[2], 1, 0)
			else
				--on ne peut plus descendre
				matrice = ecrit_la_piece_sur_la_matrice(matrice, piece_en_mouvement[2], piece_en_mouvement[1])
				piece_en_mouvement[1] = 0 --demande de nouvelle pi�ce pour le prochain tour
				
				compteur_de_temps_maximum = compteur_de_temps_coefficient * compteur_de_temps_maximum --prochain tour plus rapide en attendant la gestion des lignes / score / niveaux...
				print('compteur_de_temps_maximum = ', compteur_de_temps_maximum) --debug
			end
		end
		
		compteur_de_temps = compteur_de_temps - compteur_de_temps_maximum --on enl�ve le temps d'un tour au compteur
	end
	
	if fin_de_partie then
		love.timer.sleep(3) --3 sec de pause, utile pour debug
		love.event.quit() --game over, bye
	end
end

--function d'affichage, on dessine la matrice puis la pi�ce en mouvement
function love.draw()
	--contour
	love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
	love.graphics.rectangle("line", matrice_marge_largeur, matrice_marge_hauteur, matrice_largeur * bloc_taille, matrice_hauteur * bloc_taille)
	
	--matrice
	for j = 1, matrice_hauteur do
		for i = 1, matrice_largeur do
			if matrice[j][i] ~= 0 then
				love.graphics.setColor(couleurs[matrice[j][i]][1], couleurs[matrice[j][i]][2], couleurs[matrice[j][i]][3])
				love.graphics.rectangle("fill", matrice_marge_largeur + (i - 1) * bloc_taille, matrice_marge_hauteur + (j - 1) * bloc_taille, bloc_taille, bloc_taille)
				
				--contour du bloc de pi�ce
				love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
				love.graphics.rectangle("line", matrice_marge_largeur + (i - 1) * bloc_taille, matrice_marge_hauteur + (j - 1) * bloc_taille, bloc_taille, bloc_taille)
			end
		end
	end
	
	--pi�ce en mouvement
	if piece_en_mouvement[1] ~= 0 then
		for s = 1, 4 do
			love.graphics.setColor(couleurs[piece_en_mouvement[1]][1], couleurs[piece_en_mouvement[1]][2], couleurs[piece_en_mouvement[1]][3])
			love.graphics.rectangle("fill", matrice_marge_largeur + (piece_en_mouvement[2][s][2] - 1) * bloc_taille, matrice_marge_hauteur + (piece_en_mouvement[2][s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
			
			love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
			love.graphics.rectangle("line", matrice_marge_largeur + (piece_en_mouvement[2][s][2] - 1) * bloc_taille, matrice_marge_hauteur + (piece_en_mouvement[2][s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
		end
	end
end

--gestion des touches n'ayant pas vocation de rester appuy�es
function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
end

--gestion du relachement des touches
function love.keyreleased(key, unicode)
	if key == "left" or key == "right" or key == "down" or key == "up" then
		compteur_de_temps_clavier = 0.0 --reset du temps d'appui de touche de direction
	end
end