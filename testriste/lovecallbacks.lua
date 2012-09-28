--calculs suivant le temps, coeur du jeu
function love.update(dt)
	local piece, rotation = 90
	
	compteur_de_temps = compteur_de_temps + dt --ajout du temps passé depuis le dernier appel dans notre compteur
	
	if bool_clavier_action_tournante then
		if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
			rotation = 90
		elseif love.keyboard.isDown("q") then
			rotation = -90
		end
		
		piece_en_mouvement_rotation = (piece_en_mouvement_rotation + rotation) % 360
		
		piece = convertir_en_piece(piece_en_mouvement_type, piece_en_mouvement_rotation, piece_en_mouvement_centre)
		
		if suis_je_hors_limite(piece, 0, 0) or not puis_je_mettre_la_piece_sur_la_matrice(matrice, piece, 0, 0) then
			piece_en_mouvement_rotation = (piece_en_mouvement_rotation - rotation) % 360
		end
		
		bool_clavier_action_tournante = false
	end
	
	--gestion du clavier servant à l'action (= qui restent appuyées)
	if bool_clavier_action then
		compteur_de_temps_clavier = compteur_de_temps_clavier + dt --ajout du temps passé depuis le dernier appel dans notre compteur, version clavier
		
		if compteur_de_temps_clavier >= compteur_de_temps_clavier_maximum then
			local y, x
			
			y = 0
			x = 0
			
			if love.keyboard.isDown("left") then
				y = 0
				x = -1
			elseif love.keyboard.isDown("right") then
				y = 0
				x = 1
			elseif love.keyboard.isDown("down") then
				y = 1
				x = 0
			end
			
			piece = convertir_en_piece(piece_en_mouvement_type, piece_en_mouvement_rotation, piece_en_mouvement_centre)
			
			if not suis_je_hors_limite(piece, y, x) and puis_je_mettre_la_piece_sur_la_matrice(matrice, piece, y, x) then
				piece_en_mouvement_centre = {piece_en_mouvement_centre[1] + y, piece_en_mouvement_centre[2] + x}
			end
			
			compteur_de_temps_clavier = compteur_de_temps_clavier - compteur_de_temps_clavier_maximum
		end
	end
	
	if compteur_de_temps >= compteur_de_temps_maximum then --a-t-on fini un tour ?
		if piece_en_mouvement_type == 0 then --doit-on générer une nouvelle pièce ?
			piece_en_mouvement_type = piece_en_mouvement_type_prochain --le changement c'est maintenant ^^'
			piece_en_mouvement_type_prochain = math.random(7) --nombre aléatoire entre 1 et 7 inclus
			piece_en_mouvement_rotation = 0
			piece_en_mouvement_centre = {1, bloc_marge_initiale}
			
			piece = convertir_en_piece(piece_en_mouvement_type, piece_en_mouvement_rotation, piece_en_mouvement_centre)
			
			bool_fin_de_partie = not puis_je_mettre_la_piece_sur_la_matrice(matrice, piece, 0, 0) --si la pièce nouvellement créé tente d'écraser des blocs déjà présent, game over
		else --pas de nouvelle pièce à générer
			piece = convertir_en_piece(piece_en_mouvement_type, piece_en_mouvement_rotation, piece_en_mouvement_centre)
			
			--tentons de faire descendre l'actuelle
			if not suis_je_hors_limite(piece, 1, 0) and puis_je_mettre_la_piece_sur_la_matrice(matrice, piece, 1, 0) then
				piece_en_mouvement_centre = {piece_en_mouvement_centre[1] + 1, piece_en_mouvement_centre[2]}
			else
				--on ne peut plus descendre
				matrice = ecrit_la_piece_sur_la_matrice(matrice, piece, piece_en_mouvement_type)
				
				--on vérifie et modifie la matrice
				local nombre_lignes
				nombre_lignes = enlever_lignes_pleines()
				compter_points(nombre_lignes)
				
				piece_en_mouvement_type = 0 --demande de nouvelle pièce pour le prochain tour
				
			end
		end
		
		compteur_de_temps = compteur_de_temps - compteur_de_temps_maximum --on enlève le temps d'un tour au compteur
	end
	
	if bool_fin_de_partie then
		love.timer.sleep(3) --petite pause
		love.event.quit() --game over, bye
	end
end

--function d'affichage, on dessine la matrice puis la pièce en mouvement
function love.draw()
	local piece, piece_prochaine
	
	piece = convertir_en_piece(piece_en_mouvement_type, piece_en_mouvement_rotation, piece_en_mouvement_centre)
	piece_prochaine = convertir_en_piece(piece_en_mouvement_type_prochain, 0, {4, 4})
	
	--contour
	love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
	love.graphics.rectangle("line", matrice_marge_largeur, matrice_marge_hauteur, matrice_largeur * bloc_taille, matrice_hauteur * bloc_taille)
	
	--matrice
	for j = 1, matrice_hauteur do
		for i = 1, matrice_largeur do
			if matrice[j][i] ~= 0 then
				love.graphics.setColor(couleurs[matrice[j][i]][1], couleurs[matrice[j][i]][2], couleurs[matrice[j][i]][3])
				love.graphics.rectangle("fill", matrice_marge_largeur + (i - 1) * bloc_taille, matrice_marge_hauteur + (j - 1) * bloc_taille, bloc_taille, bloc_taille)
				
				--contour du bloc de pièce
				love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
				love.graphics.rectangle("line", matrice_marge_largeur + (i - 1) * bloc_taille, matrice_marge_hauteur + (j - 1) * bloc_taille, bloc_taille, bloc_taille)
			end
		end
	end
	
	--pièce en mouvement
	if piece_en_mouvement_type ~= 0 then
		for s = 1, 4 do
			love.graphics.setColor(couleurs[piece_en_mouvement_type][1], couleurs[piece_en_mouvement_type][2], couleurs[piece_en_mouvement_type][3])
			love.graphics.rectangle("fill", matrice_marge_largeur + (piece[s][2] - 1) * bloc_taille, matrice_marge_hauteur + (piece[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
			
			love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
			love.graphics.rectangle("line", matrice_marge_largeur + (piece[s][2] - 1) * bloc_taille, matrice_marge_hauteur + (piece[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
		end
	end
	
	--prochaine pièce à apparaître
	if piece_en_mouvement_type_prochain ~= 0 then
		for s = 1, 4 do
			love.graphics.setColor(couleurs[piece_en_mouvement_type_prochain][1], couleurs[piece_en_mouvement_type_prochain][2], couleurs[piece_en_mouvement_type_prochain][3])
			love.graphics.rectangle("fill", (piece_prochaine[s][2] - 1) * bloc_taille,  (piece_prochaine[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
			
			love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
			love.graphics.rectangle("line", (piece_prochaine[s][2] - 1) * bloc_taille, (piece_prochaine[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
		end
	end
	
	--debug
	love.graphics.print("type: " .. piece_en_mouvement_type .. "\nrotation: " .. piece_en_mouvement_rotation .. "\ncentre y: " .. piece_en_mouvement_centre[1] .. "\ncentre x: " .. piece_en_mouvement_centre[2] .. "\ncoords: " .. piece_en_mouvement_rotation .. ": (" .. piece[1][1] .. ", " .. piece[1][2] .. "), (" .. piece[2][1] .. ", " .. piece[2][2] .. "), (" .. piece[3][1] .. ", " .. piece[3][2] .. "), (" .. piece[4][1] .. ", " .. piece[4][2] .. ")", 0, 0)
	piece = convertir_en_piece(piece_en_mouvement_type, 0, {0,0})
	love.graphics.print(0 .. ": (" .. piece[1][1] .. ", " .. piece[1][2] .. "), (" .. piece[2][1] .. ", " .. piece[2][2] .. "), (" .. piece[3][1] .. ", " .. piece[3][2] .. "), (" .. piece[4][1] .. ", " .. piece[4][2] .. ")", 0, 300)
	piece = convertir_en_piece(piece_en_mouvement_type, 90, {0,0})
	love.graphics.print(90 .. ": (" .. piece[1][1] .. ", " .. piece[1][2] .. "), (" .. piece[2][1] .. ", " .. piece[2][2] .. "), (" .. piece[3][1] .. ", " .. piece[3][2] .. "), (" .. piece[4][1] .. ", " .. piece[4][2] .. ")", 0, 325)
	piece = convertir_en_piece(piece_en_mouvement_type, 180, {0,0})
	love.graphics.print(180 .. ": (" .. piece[1][1] .. ", " .. piece[1][2] .. "), (" .. piece[2][1] .. ", " .. piece[2][2] .. "), (" .. piece[3][1] .. ", " .. piece[3][2] .. "), (" .. piece[4][1] .. ", " .. piece[4][2] .. ")", 0, 350)
	piece = convertir_en_piece(piece_en_mouvement_type, 270, {0,0})
	love.graphics.print(270 .. ": (" .. piece[1][1] .. ", " .. piece[1][2] .. "), (" .. piece[2][1] .. ", " .. piece[2][2] .. "), (" .. piece[3][1] .. ", " .. piece[3][2] .. "), (" .. piece[4][1] .. ", " .. piece[4][2] .. ")", 0, 375)
	love.graphics.print("score: " .. score_tetris, 0, 450)
end

--gestion des touches n'ayant pas vocation de rester appuyées
function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	elseif key == "down" or key == "left" or key == "right" then
		bool_clavier_action = true
	elseif  key == "up"  or key == "w"  or key == "q" then
		bool_clavier_action_tournante = true --si je souhaite tourner 
	end
end

--gestion du relachement des touches
function love.keyreleased(key, unicode)
	if key == "down" or key == "left" or key == "right" then
		bool_clavier_action = false
		compteur_de_temps_clavier = 0.0 --reset du temps d'appui de touche de direction
	end
end
