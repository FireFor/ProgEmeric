--calculs suivant le temps, coeur du jeu
function love.update(dt)
	compteur_de_temps = compteur_de_temps + dt --ajout du temps passé depuis le dernier appel dans notre compteur
	
	--gestion du clavier servant à l'action (= qui restent appuyées)
	if bool_clavier_action then
		compteur_de_temps_clavier = compteur_de_temps_clavier + dt --ajout du temps passé depuis le dernier appel dans notre compteur, version clavier
		
		if compteur_de_temps_clavier >= compteur_de_temps_clavier_maximum then
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
			elseif love.keyboard.isDown("up") then
				piece_en_mouvement_rotation = piece_en_mouvement_rotation + 0 --à faire
			end
			
			if not suis_je_hors_limite(piece_en_mouvement_calculee, y, x) and puis_je_mettre_la_piece_sur_la_matrice(matrice, piece_en_mouvement_calculee, y, x) then
				piece_en_mouvement_centre = {piece_en_mouvement_centre[1] + y, piece_en_mouvement_centre[2] + x}
				piece_en_mouvement_calculee = decale_la_piece(piece_en_mouvement_calculee, y, x)
			end
			
			compteur_de_temps_clavier = compteur_de_temps_clavier - compteur_de_temps_clavier_maximum
		end
	end
	
	if compteur_de_temps >= compteur_de_temps_maximum then --a-t-on fini un tour ?
		if piece_en_mouvement_type == 0 then --doit-on générer une nouvelle pièce ?
			piece_en_mouvement_type = piece_en_mouvement_type_prochain --le changement c'est maintenant ^^'
			piece_en_mouvement_type_prochain = math.random(7) --nombre aléatoire entre 1 et 7 inclus
			piece_en_mouvement_centre = {1, bloc_marge_initiale}
			piece_en_mouvement_calculee = convertir_en_piece(piece_en_mouvement_type, 0, {1, bloc_marge_initiale})
			
			bool_fin_de_partie = not puis_je_mettre_la_piece_sur_la_matrice(matrice, piece_en_mouvement_calculee, 0, 0) --si la pièce nouvellement créé tente d'écraser des blocs déjà présent, game over
		else --pas de nouvelle pièce à générer
			--tentons de faire descendre l'actuelle
			if not suis_je_hors_limite(piece_en_mouvement_calculee, 1, 0) and puis_je_mettre_la_piece_sur_la_matrice(matrice, piece_en_mouvement_calculee, 1, 0) then
				piece_en_mouvement_centre = {piece_en_mouvement_centre[1] + 1, piece_en_mouvement_centre[2] + 0}
				piece_en_mouvement_calculee = decale_la_piece(piece_en_mouvement_calculee, 1, 0)
			else
				--on ne peut plus descendre
				matrice = ecrit_la_piece_sur_la_matrice(matrice, piece_en_mouvement_calculee, piece_en_mouvement_type)
				piece_en_mouvement_type = 0 --demande de nouvelle pièce pour le prochain tour
				
				compteur_de_temps_maximum = compteur_de_temps_coefficient * compteur_de_temps_maximum --prochain tour plus rapide en attendant la gestion des lignes / score / niveaux...
			end
		end
		
		compteur_de_temps = compteur_de_temps - compteur_de_temps_maximum --on enlève le temps d'un tour au compteur
	end
	
	if bool_fin_de_partie then
		love.timer.sleep(3) --pause avant de quitter brutalement
		love.event.quit() --game over, bye
	end
end

--function d'affichage, on dessine la matrice puis la pièce en mouvement
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
			love.graphics.rectangle("fill", matrice_marge_largeur + (piece_en_mouvement_calculee[s][2] - 1) * bloc_taille, matrice_marge_hauteur + (piece_en_mouvement_calculee[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
			
			love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
			love.graphics.rectangle("line", matrice_marge_largeur + (piece_en_mouvement_calculee[s][2] - 1) * bloc_taille, matrice_marge_hauteur + (piece_en_mouvement_calculee[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
		end
	end
	
	piece_prochaine = convertir_en_piece(piece_en_mouvement_type_prochain, 0, {4, 4})
	for s = 1, 4 do
		love.graphics.setColor(couleurs[piece_en_mouvement_type_prochain][1], couleurs[piece_en_mouvement_type_prochain][2], couleurs[piece_en_mouvement_type_prochain][3])
		love.graphics.rectangle("fill", (piece_prochaine[s][2] - 1) * bloc_taille,  (piece_prochaine[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
		
		love.graphics.setColor(couleurs[8][1], couleurs[8][2], couleurs[8][3])
		love.graphics.rectangle("line", (piece_prochaine[s][2] - 1) * bloc_taille, (piece_prochaine[s][1] - 1) * bloc_taille, bloc_taille, bloc_taille)
	end
	
	love.graphics.print("type: " .. piece_en_mouvement_type .. "\nrotation: " .. piece_en_mouvement_rotation .. "\ncentre y: " .. piece_en_mouvement_centre[1] .. "\ncentre x: " .. piece_en_mouvement_centre[2], 0, 0)
	
	if piece_en_mouvement_type ~= 0 then
		piece = convertir_en_piece(piece_en_mouvement_type, piece_en_mouvement_rotation, piece_en_mouvement_centre)
		love.graphics.print("-> (" .. piece[1][1] .. ", " .. piece[1][2] .. "), (" .. piece[2][1] .. ", " .. piece[2][2] .. "), (" .. piece[3][1] .. ", " .. piece[3][2] .. "), (" .. piece[4][1] .. ", " .. piece[4][2] .. ")\nou (" .. piece_en_mouvement_calculee[1][1] .. ", " .. piece_en_mouvement_calculee[1][2] .. "), (" .. piece_en_mouvement_calculee[2][1] .. ", " .. piece_en_mouvement_calculee[2][2] .. "), (" .. piece_en_mouvement_calculee[3][1] .. ", " .. piece_en_mouvement_calculee[3][2] .. "), (" .. piece_en_mouvement_calculee[4][1] .. ", " .. piece_en_mouvement_calculee[4][2] .. ")", 0, 55)
	end
end

--gestion des touches n'ayant pas vocation de rester appuyées
function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	elseif key == "down" or key == "left" or key == "right" or key == "up" then
		bool_clavier_action = true
	end
end

--gestion du relachement des touches
function love.keyreleased(key, unicode)
	if key == "down" or key == "left" or key == "right" or key == "up" then
		bool_clavier_action = false
		compteur_de_temps_clavier = 0.0 --reset du temps d'appui de touche de direction
	end
end
