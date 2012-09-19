-- program under public domain or creative commons CC0, as you prefer
-- programme dans le domaine publique ou sous la licence creative commons CCO, à votre guise

-- testriste, un *magnifique* jeu pour découvrir love2d (et lua)

function love.load()
	--configuration
	coefTimestamp = 0.95 --coefficient pour accélérer le temps d'un tour (en % / 100)
	matrixHeight = 14 --hauteur de la matrice (en bloc de pièce)
	matrixWidth = 7 --largeur de la matrice (en bloc de pièce)
	maxTimestamp = 0.33 --temps d'un tour (en secondes)
	
	colors = {} --couleurs (rien pour 0, 1 à 7 pour les blocs de pièces, 8 pour les contours)
	colors[1] = {0, 255, 255} --cyan
	colors[2] = {0, 0, 255} --bleu
	colors[3] = {255, 127, 0} --orange
	colors[4] = {255, 255, 0} --jaune
	colors[5] = {0, 255, 0} --vert
	colors[6] = {255, 0, 255} --violet
	colors[7] = {255, 0, 0} --rouge
	colors[8] = {255, 255, 255} --blanc
	
	--initialisation
	math.randomseed(os.time()) --on veut des pseudo-vrais nombres aléatoires
	
	gameOver = false --drapeau marquant la fin du jeu (booléen)
	lastTimestamp = 0.0 --compteur de temps pour savoir quand faire quoi (en secondes)
	lastTimeClavi = 0.0 --compteur de temps pour savoir quand faire quoi (en secondes) // Mouvement clavier
	matrix = {} --tableau multi-dimensionnel contenant nos pièces et blocs (pour stocker des lignes puis des colonnes de blocs de pièces)
	movingPiece = {0, {{0, 0}, {0, 0}, {0, 0}, {0, 0}}} --pièce en cours de mouvement (couleur puis coordonnées (ligne, colonne))
	
	squareX = math.floor((matrixWidth - 4) / 2) --décalage horizontal pour centrer les nouvelles pièces (en bloc de pièce)
	squareWidth = math.pow(2, math.floor(math.log(math.min(love.graphics:getWidth(), love.graphics:getHeight()) / math.max(matrixWidth, matrixHeight)) / math.log(2))) --largeur d'un bloc de pièce = puissance de 2 maximum (en pixels)
	matrixX = (love.graphics:getWidth() - matrixWidth * squareWidth) / 2 --décalage horizontal pour centrer la matrice (en pixels)
	matrixY = (love.graphics:getHeight() - matrixHeight * squareWidth) / 2 --décalage vertical pour centrer la matrice (en pixels)
	
	--initiliasation de la matrice suivant sa taille
	for j = 1, matrixHeight do --pour chaque ligne de matrice...
		matrix[j] = {} --création de la ligne j
		
		for i = 1, matrixWidth do --pour chaque colonne de la matrice...
			matrix[j][i] = 0 --bloc vide inséré dans la ligne j et la colonne i
		end
	end
end

function give_me_a_new_piece(t, y, x) --Type, margin Y, margin X
	piece = {}
	
	--description de la pièce suivant le type/couleur choisi (t) avec le centrage (y;x)
	if t == 1 then
		piece = {{y + 2, x + 1}, {y + 2, x + 2}, {y + 2, x + 3}, {y + 2, x + 4}}
	elseif t == 2 then
		piece = {{y + 2, x + 1}, {y + 2, x + 2}, {y + 2, x + 3}, {y + 1, x + 1}}
	elseif t == 3 then
		piece = {{y + 2, x + 1}, {y + 2, x + 2}, {y + 2, x + 3}, {y + 1, x + 3}}
	elseif t == 4 then
		piece = {{y + 2, x + 1}, {y + 2, x + 2}, {y + 1, x + 1}, {y + 1, x + 2}}
	elseif t == 5 then
		piece = {{y + 2, x + 1}, {y + 2, x + 2}, {y + 1, x + 2}, {y + 1, x + 3}}
	elseif t == 6 then
		piece = {{y + 2, x + 1}, {y + 2, x + 2}, {y + 2, x + 3}, {y + 1, x + 2}}
	elseif t == 7 then
		piece = {{y + 2, x + 2}, {y + 2, x + 3}, {y + 1, x + 1}, {y + 1, x + 2}}
	end
	
	return piece
end

function am_i_off_limit(p, h, w, y, x) --Piece, Height, Width, offset Y, offset X
	for s = 1, 4 do
		if p[s][1] + y <= 0 or p[s][1] + y > h or p[s][2] + x <= 0 or p[s][2] + x > w then
			return true --si un des blocs de la pièce est en dehors de la matrice, la réponse est oui
		end
	end
	
	return false --si on arrive jusqu'ici, la réponse est non
end

function can_i_put_my_piece_on_the_matrix(m, p, y, x) --Matrix, Piece, offset Y, offset X
	for s = 1, 4 do
		if m[p[s][1] + y][p[s][2] + x] ~= 0 then
			return false --si la matrice contient déjà quelque chose à un des blocs de la pièce, la réponse est non
		end
	end
	
	return true --si on arrive jusqu'ici, la réponse est oui
end

function put_an_offset_on_my_piece(p, y, x) --Piece, offset Y, offset X
	for s = 1, 4 do
		p[s] = {p[s][1] + y, p[s][2] + x}
	end
	
	return p
end

function copy_me_to_the_matrix(m, p, t) --Matrix, Piece, Type
	for s = 1, 4 do
		m[p[s][1]][p[s][2]] = t
	end
	
	return m
end

function love.update(dt)
	lastTimestamp = lastTimestamp + dt --ajout du temps passé depuis le dernier appel dans notre compteur
	
	--gestion du clavier servant à l'action
	if love.keyboard.isDown("left") then
		lastTimeClavi = lastTimeClavi + dt --ajout du temps passé depuis le dernier appel dans notre compteur / Pour l'utilisation clavier
		
		if can_i_put_my_piece_on_the_matrix(matrix, movingPiece[2], 0,-1) and lastTimeClavi >= (maxTimestamp) then
			movingPiece[2] =put_an_offset_on_my_piece(movingPiece[2], 0,-1)
			lastTimeClavi = lastTimeClavi - maxTimestamp
		end
	elseif love.keyboard.isDown("right") then
		lastTimeClavi = lastTimeClavi + dt --ajout du temps passé depuis le dernier appel dans notre compteur / Pour l'utilisation clavier
		
		if can_i_put_my_piece_on_the_matrix(matrix, movingPiece[2], 0, 1) and lastTimeClavi >= (maxTimestamp) then
			movingPiece[2] =put_an_offset_on_my_piece(movingPiece[2], 0, 1)
			lastTimeClavi = lastTimeClavi - maxTimestamp
		end
	end
	
	if lastTimestamp >= maxTimestamp then --a-t-on fini un tour ?
		if movingPiece[1] == 0 then --doit-on générer une nouvelle pièce ?
			movingPiece[1] = math.random(7) --lancer de dé
			movingPiece[2] = give_me_a_new_piece(movingPiece[1], 0, squareX) --donne moi une nouvelle pièce !
			
			gameOver = not can_i_put_my_piece_on_the_matrix(matrix, movingPiece[2], 0, 0) --si la pièce nouvellement créé tente d'écraser des blocs déjà présent, game over
		else --pas de nouvelle pièce à générer
			--tentons de faire descendre l'actuelle
			if not am_i_off_limit(movingPiece[2], matrixHeight, matrixWidth, 1, 0) and can_i_put_my_piece_on_the_matrix(matrix, movingPiece[2], 1, 0) then
				movingPiece[2] = put_an_offset_on_my_piece(movingPiece[2], 1, 0)
			else
				--on ne peut plus descendre
				matrix = copy_me_to_the_matrix(matrix, movingPiece[2], movingPiece[1])
				movingPiece[1] = 0 --demande de nouvelle pièce pour le prochain tour
				maxTimestamp = coefTimestamp * maxTimestamp --prochain tour plus rapide
			end
		end
		
		lastTimestamp = lastTimestamp - maxTimestamp --on enlève le temps d'un tour au compteur
	end
	
	if gameOver then
		love.timer.sleep(3)
		love.event.quit() --game over, bye
	end
end

function love.draw()
	love.graphics.setColor(colors[8][1], colors[8][2], colors[8][3])
	love.graphics.rectangle("line", matrixX, matrixY, matrixWidth * squareWidth, matrixHeight * squareWidth)
	
	for j = 1, matrixHeight do
		for i = 1, matrixWidth do
			if matrix[j][i] ~= 0 then
				love.graphics.setColor(colors[matrix[j][i]][1], colors[matrix[j][i]][2], colors[matrix[j][i]][3])
				love.graphics.rectangle("fill", matrixX + (i - 1) * squareWidth, matrixY + (j - 1) * squareWidth, squareWidth, squareWidth)
				
				love.graphics.setColor(colors[8][1], colors[8][2], colors[8][3])
				love.graphics.rectangle("line", matrixX + (i - 1) * squareWidth, matrixY + (j - 1) * squareWidth, squareWidth, squareWidth)
			end
		end
	end
	
	if movingPiece[1] ~= 0 then
		for s = 1, 4 do
			love.graphics.setColor(colors[movingPiece[1]][1], colors[movingPiece[1]][2], colors[movingPiece[1]][3])
			love.graphics.rectangle("line", matrixX + (movingPiece[2][s][2] - 1) * squareWidth, matrixY + (movingPiece[2][s][1] - 1) * squareWidth, squareWidth, squareWidth)
		end
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		gameOver = true --pour faire propre
		
		love.event.quit() --bye
	end
end

